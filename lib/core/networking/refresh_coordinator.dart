import '../api/dtos.dart';
import '../auth/token_store.dart';
import '../errors/app_error.dart';

/// Performs the raw token rotation against the backend (POST /auth/refresh),
/// throwing an [AppError] on failure. Supplied by the API layer so the
/// coordinator does not depend on Dio directly.
typedef RawRefresh = Future<AuthTokens> Function(String refreshToken);

enum RefreshOutcome {
  /// New tokens were stored; the caller may retry with the fresh access token.
  refreshed,

  /// The refresh token was rejected (expired/reused/invalid). Tokens are cleared;
  /// the session is now signed out.
  signedOut,

  /// A connectivity failure — tokens are left intact so a later attempt can work.
  offline,
}

/// Coordinates access-token refresh so concurrent 401s trigger exactly **one**
/// network refresh. Every caller that arrives while a refresh is in flight awaits
/// the same future, then acts on its shared outcome.
class RefreshCoordinator {
  RefreshCoordinator({
    required TokenStore store,
    required RawRefresh performRefresh,
  }) : _store = store,
       _performRefresh = performRefresh;

  final TokenStore _store;
  final RawRefresh _performRefresh;

  Future<RefreshOutcome>? _inFlight;

  /// The number of actual network refresh calls made — asserted by the
  /// single-flight concurrency test to be exactly one for a burst of 401s.
  int networkRefreshCount = 0;

  Future<RefreshOutcome> refresh() =>
      _inFlight ??= _run().whenComplete(() => _inFlight = null);

  Future<RefreshOutcome> _run() async {
    final AuthTokenSet? current = await _store.read();
    if (current == null) {
      return RefreshOutcome.signedOut;
    }

    try {
      networkRefreshCount++;
      final AuthTokens tokens = await _performRefresh(current.refreshToken);
      await _store.write(
        AuthTokenSet(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          userId: tokens.userId,
        ),
      );
      return RefreshOutcome.refreshed;
    } on UnauthorizedError {
      // The refresh token itself was rejected (expired/reused/invalid) — sign out.
      await _store.clear();
      return RefreshOutcome.signedOut;
    } on ForbiddenError {
      await _store.clear();
      return RefreshOutcome.signedOut;
    } on AppError {
      // Transient (offline / 5xx / 429 / malformed body): keep the tokens so a
      // later attempt can recover the session rather than forcing a re-login.
      return RefreshOutcome.offline;
    } catch (_) {
      return RefreshOutcome.offline;
    }
  }
}
