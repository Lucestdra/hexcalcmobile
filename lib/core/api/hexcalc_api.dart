import 'package:dio/dio.dart';

import '../errors/app_error.dart';
import '../networking/api_client.dart';
import '../networking/error_mapper.dart';
import 'dtos.dart';

/// Typed facade over the backend REST contract. Every method returns a typed DTO
/// and throws an [AppError] on failure (never a raw `DioException`). Anonymous
/// endpoints (auth, `meta/config`) go through the [ApiClient.anonymous] client;
/// `link-account`, the player endpoints, and the game-run endpoints go through
/// [ApiClient.authenticated] (bearer + single-flight refresh). Ranked submit and
/// normal-result writes carry a caller-supplied `Idempotency-Key` header so a
/// retried send is the same operation server-side.
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

  // ── Game runs ─────────────────────────────────────────────────────────────

  /// Public active gameplay config (anonymous). Read before ranked play to gate
  /// on the ruleset/generator versions.
  Future<MetaConfigResponse> getMetaConfig() async {
    try {
      final Response<dynamic> response = await _anon.get<dynamic>(
        '/api/v1/meta/config',
      );
      return _parse(response.data, MetaConfigResponse.fromJson);
    } catch (error) {
      throw toAppError(error);
    }
  }

  /// Issues a new signed ranked challenge (authenticated).
  Future<GameRunChallengeResponse> issueGameRun(IssueGameRunRequest request) =>
      _json(
        '/api/v1/game-runs',
        request.toJson(),
        GameRunChallengeResponse.fromJson,
        _auth,
      );

  /// Submits an event log for verification. [idempotencyKey] must be reused
  /// verbatim on every retry of the same submission (sourced from the outbox item).
  Future<GameRunResultResponse> submitGameRun(
    String runId,
    SubmitGameRunRequest request, {
    required String idempotencyKey,
  }) => _jsonWithOptions(
    '/api/v1/game-runs/$runId/submit',
    request.toJson(),
    GameRunResultResponse.fromJson,
    _auth,
    Options(headers: <String, dynamic>{'Idempotency-Key': idempotencyKey}),
  );

  /// Fetches a run's current verification status/result (authenticated).
  Future<GameRunResultResponse> getGameRun(String runId) async {
    try {
      final Response<dynamic> response = await _auth.get<dynamic>(
        '/api/v1/game-runs/$runId',
      );
      return _parse(response.data, GameRunResultResponse.fromJson);
    } catch (error) {
      throw toAppError(error);
    }
  }

  /// Records an offline normal-run result idempotently (authenticated).
  Future<NormalRunAckResponse> postNormalResult(
    NormalRunResultRequest request, {
    required String idempotencyKey,
  }) => _jsonWithOptions(
    '/api/v1/game-runs/normal-results',
    request.toJson(),
    NormalRunAckResponse.fromJson,
    _auth,
    Options(headers: <String, dynamic>{'Idempotency-Key': idempotencyKey}),
  );

  // ── Leaderboards (authenticated) ──────────────────────────────────────────

  /// The weekly top page (top 100, cursor-paginated). [limit] and [cursor] are
  /// optional; an omitted cursor returns the first page.
  Future<WeeklyLeaderboardResponse> getWeeklyLeaderboard({
    int? limit,
    String? cursor,
  }) async {
    try {
      final Response<dynamic> response = await _auth.get<dynamic>(
        '/api/v1/leaderboards/weekly',
        queryParameters: <String, dynamic>{'limit': ?limit, 'cursor': ?cursor},
      );
      return _parse(response.data, WeeklyLeaderboardResponse.fromJson);
    } catch (error) {
      throw toAppError(error);
    }
  }

  /// The requesting player's weekly rank and a ±5 window centred on them.
  Future<MyWeeklyRankResponse> getMyWeeklyRank() async {
    try {
      final Response<dynamic> response = await _auth.get<dynamic>(
        '/api/v1/leaderboards/weekly/me',
      );
      return _parse(response.data, MyWeeklyRankResponse.fromJson);
    } catch (error) {
      throw toAppError(error);
    }
  }

  // ── Daily challenge (authenticated) ───────────────────────────────────────

  /// The current daily challenge card (window + whether the player has attempted).
  Future<DailyChallengeView> getDailyChallenge() async {
    try {
      final Response<dynamic> response = await _auth.get<dynamic>(
        '/api/v1/daily-challenges/current',
      );
      return _parse(response.data, DailyChallengeView.fromJson);
    } catch (error) {
      throw toAppError(error);
    }
  }

  /// Starts the player's daily attempt, returning a signed challenge to play
  /// through the ranked pipeline. Throws [ConflictError] (409) if the player has
  /// already made their one scored attempt today.
  Future<DailyAttemptResponse> startDailyAttempt() async {
    try {
      final Response<dynamic> response = await _auth.post<dynamic>(
        '/api/v1/daily-challenges/current/attempts',
      );
      return _parse(response.data, DailyAttemptResponse.fromJson);
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

  Future<T> _jsonWithOptions<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) parse,
    Dio client,
    Options options,
  ) async {
    try {
      final Response<dynamic> response = await client.post<dynamic>(
        path,
        data: body,
        options: options,
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
