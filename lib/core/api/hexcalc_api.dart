import 'package:dio/dio.dart';

import '../errors/app_error.dart';
import '../networking/api_client.dart';
import '../networking/error_mapper.dart';
import 'dtos.dart';

/// Typed facade over the backend REST contract. Every method returns a typed DTO
/// and throws an [AppError] on failure (never a raw `DioException`). Anonymous
/// endpoints go through the [ApiClient.anonymous] client; `link-account` and the
/// player endpoints go through [ApiClient.authenticated] (bearer + refresh).
class HexcalcApi {
  HexcalcApi(this._client);

  final ApiClient _client;

  Dio get _anon => _client.anonymous;
  Dio get _auth => _client.authenticated;

  // ── Auth (anonymous) ──────────────────────────────────────────────────────

  Future<AuthTokens> guestSignIn(GuestSignInRequest request) =>
      _json('/api/v1/auth/guest', request.toJson(), AuthTokens.fromJson, _anon);

  Future<AuthStatusResponse> register(RegisterRequest request) => _json(
    '/api/v1/auth/register',
    request.toJson(),
    AuthStatusResponse.fromJson,
    _anon,
  );

  Future<AuthTokens> login(LoginRequest request) =>
      _json('/api/v1/auth/login', request.toJson(), AuthTokens.fromJson, _anon);

  Future<AuthStatusResponse> forgotPassword(ForgotPasswordRequest request) =>
      _json(
        '/api/v1/auth/password/forgot',
        request.toJson(),
        AuthStatusResponse.fromJson,
        _anon,
      );

  Future<AuthStatusResponse> resetPassword(ResetPasswordRequest request) =>
      _json(
        '/api/v1/auth/password/reset',
        request.toJson(),
        AuthStatusResponse.fromJson,
        _anon,
      );

  Future<void> logout(LogoutRequest request) async {
    try {
      await _anon.post<dynamic>('/api/v1/auth/logout', data: request.toJson());
    } catch (error) {
      throw toAppError(error);
    }
  }

  // ── Auth (authenticated) ──────────────────────────────────────────────────

  Future<AuthTokens> linkAccount(LinkAccountRequest request) => _json(
    '/api/v1/auth/link-account',
    request.toJson(),
    AuthTokens.fromJson,
    _auth,
  );

  // ── Players (authenticated) ───────────────────────────────────────────────

  Future<PlayerProfile> getMe() async {
    try {
      final Response<dynamic> response = await _auth.get<dynamic>(
        '/api/v1/players/me',
      );
      return _parse(response.data, PlayerProfile.fromJson);
    } catch (error) {
      throw toAppError(error);
    }
  }

  Future<PlayerProfile> updateMe(UpdatePlayerRequest request) async {
    try {
      final Response<dynamic> response = await _auth.patch<dynamic>(
        '/api/v1/players/me',
        data: request.toJson(),
      );
      return _parse(response.data, PlayerProfile.fromJson);
    } catch (error) {
      throw toAppError(error);
    }
  }

  Future<T> _json<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) parse,
    Dio client,
  ) async {
    try {
      final Response<dynamic> response = await client.post<dynamic>(
        path,
        data: body,
      );
      return _parse(response.data, parse);
    } catch (error) {
      throw toAppError(error);
    }
  }

  T _parse<T>(Object? data, T Function(Map<String, dynamic>) parse) {
    if (data is Map) {
      return parse(data.cast<String, dynamic>());
    }
    throw const ServerError(
      message: 'The server returned an unexpected response.',
    );
  }
}
