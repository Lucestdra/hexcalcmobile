import 'problem_details.dart';

/// Data-transfer objects mirroring the backend OpenAPI contract
/// (`docs/api/openapi.v1.json`, mirrored at `test/contract/openapi.v1.json`).
///
/// These are hand-authored rather than generated: openapi-generator renders the
/// backend's OpenAPI 3.1 multi-type integer schemas (`["integer","string"]`) as
/// broken empty wrapper classes, and the dart-dio generator needs build_runner,
/// which collides with this repo's sqlite3 native-build-hook constraint. Instead a
/// contract test (`test/contract/api_contract_test.dart`) parses the committed
/// spec and fails if any endpoint, required field, or key field type used here
/// drifts from it — comparable drift protection to a generated client (though it
/// does not enforce full round-trip type-safety). Regeneration is revisitable via
/// `tool/generate_api.sh`.

// ── Requests ───────────────────────────────────────────────────────────────

class GuestSignInRequest {
  const GuestSignInRequest({this.locale, this.deviceId});

  final String? locale;
  final String? deviceId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (locale != null) 'locale': locale,
    if (deviceId != null) 'deviceId': deviceId,
  };
}

class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    this.displayName,
    this.locale,
  });

  final String email;
  final String password;
  final String? displayName;
  final String? locale;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'password': password,
    if (displayName != null) 'displayName': displayName,
    if (locale != null) 'locale': locale,
  };
}

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    this.deviceId,
  });

  final String email;
  final String password;
  final String? deviceId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'password': password,
    if (deviceId != null) 'deviceId': deviceId,
  };
}

class RefreshRequest {
  const RefreshRequest({required this.refreshToken, this.deviceId});

  final String refreshToken;
  final String? deviceId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'refreshToken': refreshToken,
    if (deviceId != null) 'deviceId': deviceId,
  };
}

class LogoutRequest {
  const LogoutRequest({required this.refreshToken, this.allDevices = false});

  final String refreshToken;
  final bool allDevices;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'refreshToken': refreshToken,
    'allDevices': allDevices,
  };
}

class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => <String, dynamic>{'email': email};
}

class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.email,
    required this.token,
    required this.newPassword,
  });

  final String email;
  final String token;
  final String newPassword;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'token': token,
    'newPassword': newPassword,
  };
}

class LinkAccountRequest {
  const LinkAccountRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'password': password,
  };
}

class UpdatePlayerRequest {
  const UpdatePlayerRequest({this.displayName, this.locale});

  final String? displayName;
  final String? locale;

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (displayName != null) 'displayName': displayName,
    if (locale != null) 'locale': locale,
  };
}

// ── Responses ──────────────────────────────────────────────────────────────

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresInSeconds;
  final String userId;

  static AuthTokens fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    tokenType: json['tokenType'] as String? ?? 'Bearer',
    // Tolerate the OpenAPI 3.1 integer|string encoding.
    expiresInSeconds: ProblemDetails.asInt(json['expiresInSeconds']) ?? 0,
    userId: json['userId'] as String,
  );
}

class AuthStatusResponse {
  const AuthStatusResponse({required this.status});

  final String status;

  static AuthStatusResponse fromJson(Map<String, dynamic> json) =>
      AuthStatusResponse(status: json['status'] as String? ?? '');
}

class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.displayName,
    required this.locale,
    required this.status,
    required this.createdAtUtc,
  });

  final String id;
  final String displayName;
  final String locale;
  final String status;
  final DateTime createdAtUtc;

  static PlayerProfile fromJson(Map<String, dynamic> json) => PlayerProfile(
    id: json['id'] as String,
    displayName: json['displayName'] as String? ?? '',
    locale: json['locale'] as String? ?? 'en',
    status: json['status'] as String? ?? 'Active',
    createdAtUtc:
        DateTime.tryParse(json['createdAtUtc'] as String? ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );
}
