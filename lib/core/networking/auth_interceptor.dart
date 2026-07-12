import 'package:dio/dio.dart';

import '../auth/token_store.dart';
import 'refresh_coordinator.dart';

/// Injects the access token and recovers from expiry. On a 401 for a request that
/// carried a token, it asks the [RefreshCoordinator] to rotate (single-flight) and
/// retries the original request once with the new token. A rejected refresh
/// signals a recoverable signed-out state via [onSignedOut]; an offline refresh
/// leaves tokens intact so the caller can retry later.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStore store,
    required RefreshCoordinator coordinator,
    required Dio retryClient,
    this.onSignedOut,
  }) : _store = store,
       _coordinator = coordinator,
       _retryClient = retryClient;

  /// Marks a request that must never carry a bearer token or trigger a refresh
  /// (the refresh call itself, and the anonymous auth endpoints).
  static const String skipAuthKey = 'hexcalc.skipAuth';
  static const String _retriedKey = 'hexcalc.retried';

  final TokenStore _store;
  final RefreshCoordinator _coordinator;
  final Dio _retryClient;

  /// Invoked when a refresh is rejected — the session is now signed out. Late-bound
  /// so it can point at the auth session without a construction cycle.
  void Function()? onSignedOut;

  bool _skips(RequestOptions options) => options.extra[skipAuthKey] == true;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_skips(options)) {
      final AuthTokenSet? tokens = await _store.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions options = err.requestOptions;
    final bool eligible =
        err.response?.statusCode == 401 &&
        !_skips(options) &&
        options.extra[_retriedKey] != true &&
        options.headers.containsKey('Authorization');

    if (!eligible) {
      handler.next(err);
      return;
    }

    final RefreshOutcome outcome = await _coordinator.refresh();
    switch (outcome) {
      case RefreshOutcome.refreshed:
        final AuthTokenSet? tokens = await _store.read();
        if (tokens == null) {
          handler.next(err);
          return;
        }
        options
          ..extra[_retriedKey] = true
          ..headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        try {
          // Retry on a client without this interceptor, so a second 401 cannot
          // loop back into another refresh.
          final Response<dynamic> response = await _retryClient.fetch<dynamic>(
            options,
          );
          handler.resolve(response);
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      case RefreshOutcome.signedOut:
        onSignedOut?.call();
        handler.next(err);
      case RefreshOutcome.offline:
        handler.next(err);
    }
  }
}
