import 'package:dio/dio.dart';

import '../api/dtos.dart';
import '../auth/token_store.dart';
import 'auth_interceptor.dart';
import 'correlation_interceptor.dart';
import 'error_mapper.dart';
import 'refresh_coordinator.dart';

/// Owns the configured Dio stack. Two clients share one base config:
///
/// * [anonymous] — correlation only, used for the `[AllowAnonymous]` auth
///   endpoints and as the retry client for the auth interceptor (so a retried
///   request cannot loop back into another refresh);
/// * [authenticated] — adds the [AuthInterceptor] (bearer injection + single-flight
///   refresh on 401), used for `players/me` and `link-account`.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStore tokenStore,
    Dio Function(BaseOptions options)? dioBuilder,
  }) {
    final BaseOptions base = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
      headers: <String, dynamic>{'Accept': 'application/json'},
      // A REST API should not 3xx; not following redirects keeps the bearer from
      // ever being replayed to another host.
      followRedirects: false,
      // Only 2xx succeed; 4xx/5xx raise DioException so onError/error mapping run.
      validateStatus: (int? status) =>
          status != null && status >= 200 && status < 300,
    );
    final Dio Function(BaseOptions) build = dioBuilder ?? Dio.new;

    _anonymous = build(base);
    _anonymous.interceptors.add(CorrelationInterceptor());

    _coordinator = RefreshCoordinator(
      store: tokenStore,
      performRefresh: _rawRefresh,
    );
    _authInterceptor = AuthInterceptor(
      store: tokenStore,
      coordinator: _coordinator,
      retryClient: _anonymous,
    );

    _authenticated = build(base);
    _authenticated.interceptors.add(CorrelationInterceptor());
    _authenticated.interceptors.add(_authInterceptor);
  }

  late final Dio _anonymous;
  late final Dio _authenticated;
  late final RefreshCoordinator _coordinator;
  late final AuthInterceptor _authInterceptor;

  Dio get anonymous => _anonymous;
  Dio get authenticated => _authenticated;
  RefreshCoordinator get refreshCoordinator => _coordinator;

  /// Called when a refresh is rejected and the session becomes signed out.
  set onSignedOut(void Function() callback) =>
      _authInterceptor.onSignedOut = callback;

  Future<AuthTokens> _rawRefresh(String refreshToken) async {
    try {
      final Response<dynamic> response = await _anonymous.post<dynamic>(
        '/api/v1/auth/refresh',
        data: RefreshRequest(refreshToken: refreshToken).toJson(),
        options: Options(
          extra: <String, dynamic>{AuthInterceptor.skipAuthKey: true},
        ),
      );
      final Object? data = response.data;
      if (data is Map) {
        return AuthTokens.fromJson(data.cast<String, dynamic>());
      }
      throw const FormatException('Unexpected refresh response.');
    } catch (error) {
      throw toAppError(error);
    }
  }
}
