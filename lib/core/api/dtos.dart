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
    this.protocolVersion,
    this.payloadVersion,
    this.mapCatalogVersion,
    this.mapId,
    this.modeCatalogVersion,
    this.modeId,
    this.targetsSolved,
  });

  final String rulesetVersion;
  final String generatorVersion;
  final String? seed;
  final int clientScore;
  final DateTime playedAtUtc;
  final String? protocolVersion;
  final int? payloadVersion;
  final String? mapCatalogVersion;
  final String? mapId;
  final String? modeCatalogVersion;
  final String? modeId;
  final int? targetsSolved;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'rulesetVersion': rulesetVersion,
    'generatorVersion': generatorVersion,
    if (seed != null) 'seed': seed,
    'clientScore': clientScore,
    'playedAtUtc': playedAtUtc.toUtc().toIso8601String(),
    if (protocolVersion != null) 'protocolVersion': protocolVersion,
    if (payloadVersion != null) 'payloadVersion': payloadVersion,
    if (mapCatalogVersion != null) 'mapCatalogVersion': mapCatalogVersion,
    if (mapId != null) 'mapId': mapId,
    if (modeCatalogVersion != null) 'modeCatalogVersion': modeCatalogVersion,
    if (modeId != null) 'modeId': modeId,
    if (targetsSolved != null) 'targetsSolved': targetsSolved,
  };
}

/// The public gameplay config: active versions the client gates ranked play on.
class MetaConfigResponse {
  const MetaConfigResponse({
    required this.rulesetVersion,
    required this.generatorVersion,
    required this.payloadVersion,
    required this.runDurationMs,
    this.protocolVersion = 'equation-v1',
    this.mapCatalogVersion,
    this.mapCatalogHash,
    this.modeCatalogVersion,
    this.modeCatalogHash,
  });

  final String rulesetVersion;
  final String generatorVersion;
  final int payloadVersion;
  final int runDurationMs;
  final String protocolVersion;
  final String? mapCatalogVersion;
  final String? mapCatalogHash;
  final String? modeCatalogVersion;
  final String? modeCatalogHash;

  static MetaConfigResponse fromJson(Map<String, dynamic> json) =>
      MetaConfigResponse(
        rulesetVersion: json['rulesetVersion'] as String,
        generatorVersion: json['generatorVersion'] as String,
        payloadVersion: ProblemDetails.asInt(json['payloadVersion']) ?? 1,
        runDurationMs: ProblemDetails.asInt(json['runDurationMs']) ?? 0,
        protocolVersion: json['protocolVersion'] as String? ?? 'equation-v1',
        mapCatalogVersion: json['mapCatalogVersion'] as String?,
        mapCatalogHash: json['mapCatalogHash'] as String?,
        modeCatalogVersion: json['modeCatalogVersion'] as String?,
        modeCatalogHash: json['modeCatalogHash'] as String?,
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
    this.protocolVersion,
    this.payloadVersion,
    this.mapCatalogVersion,
    this.mapId,
    this.modeCatalogVersion,
    this.modeId,
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
  final String? protocolVersion;
  final int? payloadVersion;
  final String? mapCatalogVersion;
  final String? mapId;
  final String? modeCatalogVersion;
  final String? modeId;

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
        protocolVersion: json['protocolVersion'] as String?,
        payloadVersion: ProblemDetails.asInt(json['payloadVersion']),
        mapCatalogVersion: json['mapCatalogVersion'] as String?,
        mapId: json['mapId'] as String?,
        modeCatalogVersion: json['modeCatalogVersion'] as String?,
        modeId: json['modeId'] as String?,
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
    this.protocolVersion,
    this.payloadVersion,
    this.mapCatalogVersion,
    this.mapId,
    this.modeCatalogVersion,
    this.modeId,
    this.targetsSolved,
    this.boardRevision,
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
  final String? protocolVersion;
  final int? payloadVersion;
  final String? mapCatalogVersion;
  final String? mapId;
  final String? modeCatalogVersion;
  final String? modeId;
  final int? targetsSolved;
  final int? boardRevision;

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
        protocolVersion: json['protocolVersion'] as String?,
        payloadVersion: ProblemDetails.asInt(json['payloadVersion']),
        mapCatalogVersion: json['mapCatalogVersion'] as String?,
        mapId: json['mapId'] as String?,
        modeCatalogVersion: json['modeCatalogVersion'] as String?,
        modeId: json['modeId'] as String?,
        targetsSolved: ProblemDetails.asInt(json['targetsSolved']),
        boardRevision: ProblemDetails.asInt(json['boardRevision']),
      );
}

/// Acknowledges an idempotent normal-result sync.
class NormalRunAckResponse {
  const NormalRunAckResponse({required this.status});

  final String status;

  static NormalRunAckResponse fromJson(Map<String, dynamic> json) =>
      NormalRunAckResponse(status: json['status'] as String? ?? 'recorded');
}

// ── Leaderboards (Phase 10/11) ───────────────────────────────────────────────

/// One ranked standing on the weekly board. [score] is the server-authoritative
/// verified score; [isCurrentPlayer] flags the requesting player's own row.
class LeaderboardEntryView {
  const LeaderboardEntryView({
    required this.rank,
    required this.playerId,
    required this.displayName,
    required this.score,
    required this.achievedAtUtc,
    required this.isCurrentPlayer,
  });

  final int rank;
  final String playerId;
  final String displayName;
  final int score;
  final DateTime achievedAtUtc;
  final bool isCurrentPlayer;

  static LeaderboardEntryView fromJson(Map<String, dynamic> json) =>
      LeaderboardEntryView(
        rank: ProblemDetails.asInt(json['rank']) ?? 0,
        playerId: json['playerId'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        score: ProblemDetails.asInt(json['score']) ?? 0,
        achievedAtUtc:
            DateTime.tryParse(
              json['achievedAtUtc'] as String? ?? '',
            )?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        isCurrentPlayer: json['isCurrentPlayer'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'rank': rank,
    'playerId': playerId,
    'displayName': displayName,
    'score': score,
    'achievedAtUtc': achievedAtUtc.toUtc().toIso8601String(),
    'isCurrentPlayer': isCurrentPlayer,
  };
}

/// The weekly top page. [status] is `open` for the live week; [nextCursor] is the
/// opaque cursor for the next page (null on the last page). [asOfUtc] is when the
/// standings were computed server-side (surfaced as a freshness stamp).
class WeeklyLeaderboardResponse {
  const WeeklyLeaderboardResponse({
    required this.weekStartUtc,
    required this.status,
    required this.entries,
    required this.nextCursor,
    required this.asOfUtc,
  });

  final DateTime weekStartUtc;
  final String status;
  final List<LeaderboardEntryView> entries;
  final String? nextCursor;
  final DateTime asOfUtc;

  static WeeklyLeaderboardResponse fromJson(Map<String, dynamic> json) =>
      WeeklyLeaderboardResponse(
        weekStartUtc: _utc(json['weekStartUtc']),
        status: json['status'] as String? ?? 'open',
        entries: _entries(json['entries']),
        nextCursor: json['nextCursor'] as String?,
        asOfUtc: _utc(json['asOfUtc']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'weekStartUtc': weekStartUtc.toUtc().toIso8601String(),
    'status': status,
    'entries': entries.map((LeaderboardEntryView e) => e.toJson()).toList(),
    'nextCursor': nextCursor,
    'asOfUtc': asOfUtc.toUtc().toIso8601String(),
  };
}

/// The requesting player's weekly standing: their [rank] (null before any verified
/// run this week), the total ranked [totalPlayers], and a ±5 [window] centred on
/// them (empty when unranked).
class MyWeeklyRankResponse {
  const MyWeeklyRankResponse({
    required this.weekStartUtc,
    required this.status,
    required this.rank,
    required this.totalPlayers,
    required this.window,
    required this.asOfUtc,
  });

  final DateTime weekStartUtc;
  final String status;
  final int? rank;
  final int totalPlayers;
  final List<LeaderboardEntryView> window;
  final DateTime asOfUtc;

  static MyWeeklyRankResponse fromJson(Map<String, dynamic> json) =>
      MyWeeklyRankResponse(
        weekStartUtc: _utc(json['weekStartUtc']),
        status: json['status'] as String? ?? 'open',
        rank: ProblemDetails.asInt(json['rank']),
        totalPlayers: ProblemDetails.asInt(json['totalPlayers']) ?? 0,
        window: _entries(json['window']),
        asOfUtc: _utc(json['asOfUtc']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'weekStartUtc': weekStartUtc.toUtc().toIso8601String(),
    'status': status,
    'rank': rank,
    'totalPlayers': totalPlayers,
    'window': window.map((LeaderboardEntryView e) => e.toJson()).toList(),
    'asOfUtc': asOfUtc.toUtc().toIso8601String(),
  };
}

// ── Daily challenge (Phase 10/11) ────────────────────────────────────────────

/// The current daily challenge card. [attempted] is true once the player has made
/// their one scored attempt for [challengeDateUtc]; the window bounds when the
/// challenge is playable.
class DailyChallengeView {
  const DailyChallengeView({
    required this.challengeDateUtc,
    required this.windowStartUtc,
    required this.windowEndUtc,
    required this.rulesetVersion,
    required this.generatorVersion,
    required this.attempted,
    required this.asOfUtc,
    this.protocolVersion,
    this.payloadVersion,
    this.mapCatalogVersion,
    this.mapId,
    this.modeCatalogVersion,
    this.modeId,
  });

  /// The UTC calendar date (date-only) the challenge belongs to.
  final DateTime challengeDateUtc;
  final DateTime windowStartUtc;
  final DateTime windowEndUtc;
  final String rulesetVersion;
  final String generatorVersion;
  final bool attempted;
  final DateTime asOfUtc;
  final String? protocolVersion;
  final int? payloadVersion;
  final String? mapCatalogVersion;
  final String? mapId;
  final String? modeCatalogVersion;
  final String? modeId;

  static DailyChallengeView fromJson(Map<String, dynamic> json) =>
      DailyChallengeView(
        challengeDateUtc: _utcDate(json['challengeDateUtc']),
        windowStartUtc: _utc(json['windowStartUtc']),
        windowEndUtc: _utc(json['windowEndUtc']),
        rulesetVersion: json['rulesetVersion'] as String? ?? '',
        generatorVersion: json['generatorVersion'] as String? ?? '',
        attempted: json['attempted'] as bool? ?? false,
        asOfUtc: _utc(json['asOfUtc']),
        protocolVersion: json['protocolVersion'] as String?,
        payloadVersion: ProblemDetails.asInt(json['payloadVersion']),
        mapCatalogVersion: json['mapCatalogVersion'] as String?,
        mapId: json['mapId'] as String?,
        modeCatalogVersion: json['modeCatalogVersion'] as String?,
        modeId: json['modeId'] as String?,
      );
}

/// The signed challenge issued for a daily attempt — structurally the same as a
/// ranked [GameRunChallengeResponse], played and submitted through the same
/// game-runs pipeline (server-side `mode=daily`).
class DailyAttemptResponse {
  const DailyAttemptResponse({
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
    this.protocolVersion,
    this.payloadVersion,
    this.mapCatalogVersion,
    this.mapId,
    this.modeCatalogVersion,
    this.modeId,
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
  final String? protocolVersion;
  final int? payloadVersion;
  final String? mapCatalogVersion;
  final String? mapId;
  final String? modeCatalogVersion;
  final String? modeId;

  static DailyAttemptResponse fromJson(Map<String, dynamic> json) =>
      DailyAttemptResponse(
        runId: json['runId'] as String,
        mode: json['mode'] as String? ?? 'daily',
        seed: json['seed'] as String,
        rulesetVersion: json['rulesetVersion'] as String,
        generatorVersion: json['generatorVersion'] as String,
        runDurationMs: ProblemDetails.asInt(json['runDurationMs']) ?? 0,
        nonce: json['nonce'] as String? ?? '',
        issuedAtUtc: _utc(json['issuedAtUtc']),
        expiresAtUtc: _utc(json['expiresAtUtc']),
        challengeToken: json['challengeToken'] as String,
        protocolVersion: json['protocolVersion'] as String?,
        payloadVersion: ProblemDetails.asInt(json['payloadVersion']),
        mapCatalogVersion: json['mapCatalogVersion'] as String?,
        mapId: json['mapId'] as String?,
        modeCatalogVersion: json['modeCatalogVersion'] as String?,
        modeId: json['modeId'] as String?,
      );
}

/// Parses a required date/date-time string into a UTC [DateTime], falling back to
/// the epoch so a malformed value never throws mid-parse.
DateTime _utc(Object? value) =>
    DateTime.tryParse(value as String? ?? '')?.toUtc() ??
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

/// Parses an OpenAPI `date` (date-only, e.g. `2026-07-13`) as a UTC calendar
/// date. A bare date has no zone, so `DateTime.parse` reads it as LOCAL midnight;
/// `.toUtc()` would then shift the calendar day for any non-UTC device (e.g.
/// UTC+3 turns 2026-07-13 into 2026-07-12). Appending a `Z` when absent forces
/// the intended UTC interpretation. A value that already carries a time/zone is
/// parsed as-is.
DateTime _utcDate(Object? value) {
  final String raw = value as String? ?? '';
  final String normalized = raw.contains('T') ? raw : '${raw}T00:00:00Z';
  return DateTime.tryParse(normalized)?.toUtc() ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

List<LeaderboardEntryView> _entries(Object? value) =>
    (value as List<dynamic>?)
        ?.map(
          (dynamic e) =>
              LeaderboardEntryView.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList(growable: false) ??
    const <LeaderboardEntryView>[];
