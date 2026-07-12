import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dtos.dart';
import '../api/hexcalc_api.dart';
import '../errors/app_error.dart';
import '../networking/api_client.dart';
import '../networking/connectivity_monitor.dart';
import '../utilities/jwt.dart';
import 'token_store.dart';

/// What kind of server session (if any) the app currently holds.
enum AuthKind {
  /// Not yet determined, or no server session (offline play still works).
  none,

  /// An anonymous guest session.
  guest,

  /// A full email/password account.
  account,
}

/// Immutable auth session state. Gameplay never blocks on this — a `none` session
/// only limits server features (ranked/profile), not offline play.
class AuthState {
  const AuthState({
    required this.kind,
    this.userId,
    this.error,
    this.isBusy = false,
    this.isBootstrapping = false,
  });

  static const AuthState initial = AuthState(
    kind: AuthKind.none,
    isBootstrapping: true,
  );

  final AuthKind kind;
  final String? userId;

  /// The last recoverable failure (e.g. a guest bootstrap that failed offline, or
  /// a rejected refresh). Informational; does not block offline play.
  final AppError? error;

  /// An interactive auth action (login/register/link/…) is in flight.
  final bool isBusy;

  /// The initial session resolution has not finished yet.
  final bool isBootstrapping;

  bool get isAccount => kind == AuthKind.account;
  bool get isGuest => kind == AuthKind.guest;
  bool get hasServerSession => kind != AuthKind.none;

  AuthState copyWith({
    AuthKind? kind,
    String? userId,
    bool? isBusy,
    bool? isBootstrapping,
    AppError? error,
    bool clearError = false,
    bool clearUserId = false,
  }) => AuthState(
    kind: kind ?? this.kind,
    userId: clearUserId ? null : (userId ?? this.userId),
    isBusy: isBusy ?? this.isBusy,
    isBootstrapping: isBootstrapping ?? this.isBootstrapping,
    error: clearError ? null : (error ?? this.error),
  );
}

/// Drives the auth lifecycle: a non-blocking guest bootstrap, the email/password
/// flows, guest→account linking, logout, and recovery from a rejected refresh.
class AuthSessionNotifier extends Notifier<AuthState> {
  // Resolved once at build; cached so a fire-and-forget continuation (bootstrap,
  // refresh-recovery) never reads `ref` after the provider is disposed.
  late final HexcalcApi _api;
  late final TokenStore _store;

  bool _disposed = false;

  /// Guards against a late async continuation (bootstrap, refresh-rejected) trying
  /// to set state after the provider has been disposed.
  void _set(AuthState next) {
    if (!_disposed) {
      state = next;
    }
  }

  @override
  AuthState build() {
    ref.onDispose(() => _disposed = true);
    _api = ref.read(hexcalcApiProvider);
    _store = ref.read(tokenStoreProvider);

    // The interceptor calls this when a refresh is rejected mid-request.
    ref.read(apiClientProvider).onSignedOut = _onRefreshRejected;

    // Retry the guest bootstrap when connectivity returns, if still session-less.
    final StreamSubscription<bool> sub = ref
        .read(connectivityMonitorProvider)
        .onOnline
        .listen((_) {
          if (!state.hasServerSession) {
            unawaited(ensureGuest());
          }
        });
    ref.onDispose(sub.cancel);

    unawaited(_bootstrap());
    return AuthState.initial;
  }

  Future<void> _bootstrap() async {
    final AuthTokenSet? tokens = await _store.read();
    if (tokens != null) {
      _set(
        AuthState(kind: _kindFor(tokens.accessToken), userId: tokens.userId),
      );
      return;
    }
    await ensureGuest();
    if (state.isBootstrapping) {
      _set(state.copyWith(isBootstrapping: false));
    }
  }

  Future<void>? _guestInFlight;

  /// Creates a guest session if there is none. Single-flight: overlapping callers
  /// (bootstrap, the connectivity retry, a rejected-refresh recovery) share one
  /// sign-in rather than minting several guest identities. Failure is non-fatal:
  /// offline play continues and a retry fires when connectivity returns.
  Future<void> ensureGuest() {
    if (state.hasServerSession) {
      return Future<void>.value();
    }
    return _guestInFlight ??= _createGuest().whenComplete(
      () => _guestInFlight = null,
    );
  }

  Future<void> _createGuest() async {
    if (state.hasServerSession) {
      return;
    }
    try {
      final AuthTokens tokens = await _api.guestSignIn(
        const GuestSignInRequest(),
      );
      await _persist(tokens);
      _set(AuthState(kind: AuthKind.guest, userId: tokens.userId));
    } on AppError catch (error) {
      // Stay session-less but playable; surface the reason for optional UI.
      _set(AuthState(kind: AuthKind.none, error: error));
    }
  }

  /// Signs in to an existing email/password account.
  Future<void> signIn(String email, String password) async {
    await _run(() async {
      final AuthTokens tokens = await _api.login(
        LoginRequest(email: email.trim(), password: password),
      );
      await _persist(tokens);
      _set(AuthState(kind: AuthKind.account, userId: tokens.userId));
    });
  }

  /// Registers a new account. Enumeration-safe: the caller should route to sign-in
  /// afterwards rather than expecting to be logged in.
  Future<AuthStatusResponse> register(
    String email,
    String password, {
    String? displayName,
  }) => _run(
    () => _api.register(
      RegisterRequest(
        email: email.trim(),
        password: password,
        displayName: displayName?.trim(),
      ),
    ),
  );

  Future<AuthStatusResponse> forgotPassword(String email) => _run(
    () => _api.forgotPassword(ForgotPasswordRequest(email: email.trim())),
  );

  Future<AuthStatusResponse> resetPassword(
    String email,
    String token,
    String newPassword,
  ) => _run(
    () => _api.resetPassword(
      ResetPasswordRequest(
        email: email.trim(),
        token: token,
        newPassword: newPassword,
      ),
    ),
  );

  /// Merges the current guest into an existing account (password-proven). On
  /// success the session becomes that account.
  Future<void> linkAccount(String email, String password) async {
    await _run(() async {
      final AuthTokens tokens = await _api.linkAccount(
        LinkAccountRequest(email: email.trim(), password: password),
      );
      await _persist(tokens);
      _set(AuthState(kind: AuthKind.account, userId: tokens.userId));
    });
  }

  /// Signs out (best-effort server revoke), preserving local offline data, then
  /// bootstraps a fresh guest so the app stays fully playable.
  Future<void> signOut({bool allDevices = false}) async {
    final AuthTokenSet? tokens = await _store.read();
    if (tokens != null) {
      try {
        await _api.logout(
          LogoutRequest(
            refreshToken: tokens.refreshToken,
            allDevices: allDevices,
          ),
        );
      } on AppError {
        // Best-effort: local sign-out proceeds regardless.
      }
    }
    await _store.clear();
    _set(const AuthState(kind: AuthKind.none));
    await ensureGuest();
  }

  Future<void> _onRefreshRejected() async {
    await _store.clear();
    _set(
      const AuthState(
        kind: AuthKind.none,
        error: UnauthorizedError(
          message: 'Your session expired. Please sign in again.',
        ),
      ),
    );
    // Restore a playable guest session in the background.
    unawaited(ensureGuest());
  }

  /// Runs an interactive action with busy state, surfacing [AppError] to the caller.
  Future<T> _run<T>(Future<T> Function() action) async {
    _set(state.copyWith(isBusy: true, clearError: true));
    try {
      return await action();
    } on AppError catch (error) {
      _set(state.copyWith(error: error));
      rethrow;
    } finally {
      if (state.isBusy) {
        _set(state.copyWith(isBusy: false));
      }
    }
  }

  Future<void> _persist(AuthTokens tokens) => _store.write(
    AuthTokenSet(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      userId: tokens.userId,
    ),
  );

  AuthKind _kindFor(String accessToken) =>
      readRoleClaim(accessToken) == 'user' ? AuthKind.account : AuthKind.guest;
}

// ── Providers (infra overridden at bootstrap; monitor defaults offline-safe) ──

/// The API base URL for the active flavor — overridden at bootstrap so `core`
/// stays independent of the `app` flavor layer.
final apiBaseUrlProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'apiBaseUrlProvider must be overridden at bootstrap',
  );
});

/// The secure token store — overridden at bootstrap (secure storage) or in tests.
final tokenStoreProvider = Provider<TokenStore>((ref) {
  throw UnimplementedError(
    'tokenStoreProvider must be overridden at bootstrap',
  );
});

/// Connectivity signal — defaults to always-online (no plugin); the app overrides
/// it with a `connectivity_plus`-backed monitor at bootstrap.
final connectivityMonitorProvider = Provider<ConnectivityMonitor>((ref) {
  return const AlwaysOnlineMonitor();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: ref.read(apiBaseUrlProvider),
    tokenStore: ref.read(tokenStoreProvider),
  );
});

final hexcalcApiProvider = Provider<HexcalcApi>((ref) {
  return HexcalcApi(ref.read(apiClientProvider));
});

final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthState>(
  AuthSessionNotifier.new,
);
