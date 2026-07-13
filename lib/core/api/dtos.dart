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

// ── Game runs (Phase 8/9) ────────────────────────────────────────────────────

/// Requests a new server-issued ranked challenge. [mode] defaults to `ranked`.
class IssueGameRunRequest {
  const IssueGameRunRequest({this.mode});

  final String? mode;

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (mode != null) 'mode': mode,
  };
}

/// Submits an event log for verification. The `Idempotency-Key` is sent as a
/// header (see [HexcalcApi.submitGameRun]), never in the body. [eventLog] is the
/// payloadVersion-1 map produced by the run-event-log mapper.
class SubmitGameRunRequest {
  const SubmitGameRunRequest({
    required this.challengeToken,
    required this.eventLog,
  });

  final String challengeToken;
  final Map<String, dynamic> eventLog;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'challengeToken': challengeToken,
    'eventLog': eventLog,
  };
}

/// Records an offline normal-run result for personal history (never competitive).
/// The `Idempotency-Key` is a header, not a body field.
class NormalRunResultRequest {
  const NormalRunResultRequest({
    required this.rulesetVersion,
    required this.generatorVersion,
    this.seed,
    required this.clientScore,
    required this.playedAtUtc,
  });

  final String rulesetVersion;
  final String generatorVersion;
  final String? seed;
  final int clientScore;
  final DateTime playedAtUtc;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'rulesetVersion': rulesetVersion,
    'generatorVersion': generatorVersion,
    if (seed != null) 'seed': seed,
    'clientScore': clientScore,
    'playedAtUtc': playedAtUtc.toUtc().toIso8601String(),
  };
}

/// The public gameplay config: active versions the client gates ranked play on.
class MetaConfigResponse {
  const MetaConfigResponse({
    required this.rulesetVersion,
    required this.generatorVersion,
    required this.payloadVersion,
    required this.runDurationMs,
  });

  final String rulesetVersion;
  final String generatorVersion;
  final int payloadVersion;
  final int runDurationMs;

  static MetaConfigResponse fromJson(Map<String, dynamic> json) =>
      MetaConfigResponse(
        rulesetVersion: json['rulesetVersion'] as String,
        generatorVersion: json['generatorVersion'] as String,
        payloadVersion: ProblemDetails.asInt(json['payloadVersion']) ?? 1,
        runDurationMs: ProblemDetails.asInt(json['runDurationMs']) ?? 0,
      );
}

/// The signed challenge a ranked run is played against and submitted with.
class GameRunChallengeResponse {
  const GameRunChallengeResponse({
    required this.runId,
    required this.mode,
    required this.seed,
    required this.rulesetVersion,
    required this.generatorVersion,
    required this.runDurationMs,
    required this.nonce,
    required this.issuedAtUtc,
    required this.expiresAtUtc,
    required this.challengeToken,
  });

  final String runId;
  final String mode;
  final String seed;
  final String rulesetVersion;
  final String generatorVersion;
  final int runDurationMs;
  final String nonce;
  final DateTime issuedAtUtc;
  final DateTime expiresAtUtc;
  final String challengeToken;

  static GameRunChallengeResponse fromJson(Map<String, dynamic> json) =>
      GameRunChallengeResponse(
        runId: json['runId'] as String,
        mode: json['mode'] as String? ?? 'ranked',
        seed: json['seed'] as String,
        rulesetVersion: json['rulesetVersion'] as String,
        generatorVersion: json['generatorVersion'] as String,
        runDurationMs: ProblemDetails.asInt(json['runDurationMs']) ?? 0,
        nonce: json['nonce'] as String? ?? '',
        issuedAtUtc:
            DateTime.tryParse(json['issuedAtUtc'] as String? ?? '')?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        expiresAtUtc:
            DateTime.tryParse(json['expiresAtUtc'] as String? ?? '')?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        challengeToken: json['challengeToken'] as String,
      );
}

/// A run's verification outcome, returned by both submit and GET. The competitive
/// score is [verifiedScore] (null unless verified); [clientScore] is diagnostic.
class GameRunResultResponse {
  const GameRunResultResponse({
    required this.runId,
    required this.mode,
    required this.status,
    this.verifiedScore,
    this.clientScore,
    this.anomalyFlags = const <String>[],
    this.rejectionReason,
    this.submittedAtUtc,
  });

  final String runId;
  final String mode;

  /// `issued` | `verified` | `rejected`.
  final String status;
  final int? verifiedScore;
  final int? clientScore;
  final List<String> anomalyFlags;
  final String? rejectionReason;
  final DateTime? submittedAtUtc;

  static GameRunResultResponse fromJson(Map<String, dynamic> json) =>
      GameRunResultResponse(
        runId: json['runId'] as String,
        mode: json['mode'] as String? ?? 'ranked',
        status: json['status'] as String? ?? 'issued',
        verifiedScore: ProblemDetails.asInt(json['verifiedScore']),
        clientScore: ProblemDetails.asInt(json['clientScore']),
        anomalyFlags:
            (json['anomalyFlags'] as List<dynamic>?)
                ?.map((dynamic e) => e as String)
                .toList(growable: false) ??
            const <String>[],
        rejectionReason: json['rejectionReason'] as String?,
        submittedAtUtc: DateTime.tryParse(
          json['submittedAtUtc'] as String? ?? '',
        )?.toUtc(),
      );
}

/// Acknowledges an idempotent normal-result sync.
class NormalRunAckResponse {
  const NormalRunAckResponse({required this.status});

  final String status;

  static NormalRunAckResponse fromJson(Map<String, dynamic> json) =>
      NormalRunAckResponse(status: json['status'] as String? ?? 'recorded');
}
