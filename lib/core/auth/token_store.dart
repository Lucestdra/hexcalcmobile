import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The persisted token pair plus the owning user id.
class AuthTokenSet {
  const AuthTokenSet({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
}

/// Persists the auth tokens. Tokens are sensitive, so the production
/// implementation uses the platform secure store (Keychain / Keystore) — never
/// SharedPreferences. Kept behind an interface so the networking layer and tests
/// depend on the contract, not the plugin.
abstract interface class TokenStore {
  Future<AuthTokenSet?> read();
  Future<void> write(AuthTokenSet tokens);
  Future<void> clear();
}

/// [TokenStore] backed by `flutter_secure_storage`.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            // Bind tokens to this device: not migrated by a device/iCloud backup,
            // and only readable after first unlock.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const String _kAccess = 'auth.accessToken';
  static const String _kRefresh = 'auth.refreshToken';
  static const String _kUserId = 'auth.userId';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthTokenSet?> read() async {
    final String? access = await _storage.read(key: _kAccess);
    final String? refresh = await _storage.read(key: _kRefresh);
    final String? userId = await _storage.read(key: _kUserId);
    if (access == null || refresh == null || userId == null) {
      return null;
    }
    return AuthTokenSet(
      accessToken: access,
      refreshToken: refresh,
      userId: userId,
    );
  }

  @override
  Future<void> write(AuthTokenSet tokens) async {
    await _storage.write(key: _kAccess, value: tokens.accessToken);
    await _storage.write(key: _kRefresh, value: tokens.refreshToken);
    await _storage.write(key: _kUserId, value: tokens.userId);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUserId);
  }
}

/// In-memory [TokenStore] for tests (no platform channel).
class InMemoryTokenStore implements TokenStore {
  AuthTokenSet? _tokens;

  @override
  Future<AuthTokenSet?> read() async => _tokens;

  @override
  Future<void> write(AuthTokenSet tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}
