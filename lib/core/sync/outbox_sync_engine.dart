import 'dart:math';

import '../../features/gameplay/persistence/sync_store.dart';
import '../api/dtos.dart';
import '../api/hexcalc_api.dart';
import '../errors/app_error.dart';
import '../networking/connectivity_monitor.dart';

/// Drains the offline outbox to the backend with the durability rules from the
/// working agreement: persist-before-durable (done at enqueue), exponential backoff
/// with jitter on transient failure, pause while offline, permanent 4xx are terminal
/// (never retried, kept visible), and a single-flight drain so overlapping triggers
/// (launch, reconnect, "just enqueued", the periodic tick) share one pass.
///
/// Pure and side-effect-scoped to [SyncStore] + [HexcalcApi]; the timer and
/// connectivity subscription live in the provider layer so this stays unit-testable
/// with an injected clock and RNG.
class OutboxSyncEngine {
  OutboxSyncEngine({
    required SyncStore store,
    required HexcalcApi api,
    required ConnectivityMonitor connectivity,
    int Function()? nowMs,
    double Function()? nextRandom,
  }) : _store = store,
       _api = api,
       _connectivity = connectivity,
       _nowMs = nowMs ?? _systemNowMs,
       _rng = nextRandom ?? Random().nextDouble;

  final SyncStore _store;
  final HexcalcApi _api;
  final ConnectivityMonitor _connectivity;
  final int Function() _nowMs;
  final double Function() _rng;

  /// Base delay for the first retry; doubles per attempt up to [maxBackoffMs].
  static const int baseBackoffMs = 2000;
  static const int maxBackoffMs = 300000; // 5 minutes

  static int _systemNowMs() => DateTime.now().millisecondsSinceEpoch;

  Future<void>? _inFlight;

  /// Runs one drain pass. Single-flight: concurrent callers share the same pass.
  Future<void> drain() =>
      _inFlight ??= _drainOnce().whenComplete(() => _inFlight = null);

  /// Capped exponential backoff with jitter, in `[cap/2, cap]` — so evenly-spaced
  /// retries never synchronize (thundering herd) yet always make progress.
  Duration backoffFor(int attemptCount) {
    final int shift = attemptCount <= 1 ? 0 : min(attemptCount - 1, 20);
    final int cap = min(maxBackoffMs, baseBackoffMs << shift);
    final int ms = (cap / 2 + (cap / 2) * _rng()).round();
    return Duration(milliseconds: ms);
  }

  Future<void> _drainOnce() async {
    if (!await _connectivity.isOnline()) {
      return; // paused: retries resume on the reconnect edge
    }

    final List<OutboxItem> items = await _store.dueItems(_nowMs());
    for (final OutboxItem item in items) {
      try {
        final GameRunResultResponse? result = await _dispatch(item);
        final bool finalized = await _onSuccess(item, result);
        if (!finalized) {
          // A 200 that is not a terminal verdict (e.g. an async 'issued' ack, or a
          // missing status) must NOT be recorded as rejected: leave it pending and
          // retry — the idempotent resubmit returns the real verdict.
          await _reschedule(item, code: 'sync.pending_verification');
        }
      } on AppError catch (error) {
        final _Disposition d = _classify(error);
        final Duration? retryAfter = error is RateLimitedError
            ? error.retryAfter
            : null;
        switch (d) {
          case _Disposition.transientStop:
            await _reschedule(item, code: error.code, retryAfter: retryAfter);
            return; // back off and stop this pass (offline / rate limited)
          case _Disposition.transient:
            await _reschedule(item, code: error.code);
          case _Disposition.terminal:
            await _terminal(item, error.code ?? error.runtimeType.toString());
        }
      } catch (_) {
        // A non-AppError (a malformed/legacy payload whose casts throw, or an
        // unexpected deserialization error) must never poison the queue: fail this
        // item terminally so the drain moves on to the rest.
        await _terminal(item, 'sync.malformed_payload');
      }
    }
  }

  Future<GameRunResultResponse?> _dispatch(OutboxItem item) async {
    switch (item.operationType) {
      case kOpRankedSubmit:
        return _api.submitGameRun(
          item.payload['runId'] as String,
          SubmitGameRunRequest(
            challengeToken: item.payload['challengeToken'] as String,
            eventLog: (item.payload['eventLog'] as Map<dynamic, dynamic>)
                .cast<String, dynamic>(),
          ),
          idempotencyKey: item.idempotencyKey,
        );
      case kOpNormalResult:
        await _api.postNormalResult(
          NormalRunResultRequest(
            rulesetVersion: item.payload['rulesetVersion'] as String,
            generatorVersion: item.payload['generatorVersion'] as String,
            seed: item.payload['seed'] as String?,
            clientScore: item.payload['clientScore'] as int,
            playedAtUtc: DateTime.parse(item.payload['playedAtUtc'] as String),
          ),
          idempotencyKey: item.idempotencyKey,
        );
        return null;
      default:
        // An unknown operation (a legacy/future build) cannot be dispatched. Throw a
        // non-AppError so the poison-isolation catch fails it terminally rather than
        // retrying it forever.
        throw StateError('Unknown outbox operation: ${item.operationType}');
    }
  }

  /// Applies a successful (HTTP 2xx) dispatch. Returns true if the item reached a
  /// terminal outcome (and was compacted), false if it must be retried.
  Future<bool> _onSuccess(
    OutboxItem item,
    GameRunResultResponse? result,
  ) async {
    if (item.operationType == kOpRankedSubmit && result != null) {
      // Only a real verdict finalizes the run. An 'issued'/unknown/missing status
      // is NOT a rejection — leave it pending to resubmit idempotently.
      final String? status = switch (result.status) {
        'verified' => kRankedVerified,
        'rejected' => kRankedRejected,
        _ => null,
      };
      if (status == null) {
        return false;
      }
      await _store.completeRankedSubmit(
        localId: item.localId,
        runId: result.runId,
        status: status,
        verifiedScore: result.verifiedScore,
        rejectionReason: result.rejectionReason,
        nowMs: _nowMs(),
      );
      return true;
    }
    await _store.completeItem(item.localId);
    return true;
  }

  Future<void> _reschedule(
    OutboxItem item, {
    String? code,
    Duration? retryAfter,
  }) {
    final int attempt = item.attemptCount + 1;
    final Duration delay = retryAfter ?? backoffFor(attempt);
    return _store.reschedule(
      localId: item.localId,
      attemptCount: attempt,
      nextAttemptAt: _nowMs() + delay.inMilliseconds,
      lastErrorCode: code,
    );
  }

  Future<void> _terminal(OutboxItem item, String code) {
    if (item.operationType == kOpRankedSubmit) {
      // Extract the runId defensively — a malformed payload must not throw here too.
      final Object? runId = item.payload['runId'];
      if (runId is String) {
        return _store.failRankedSubmit(
          localId: item.localId,
          runId: runId,
          failureCode: code,
          nowMs: _nowMs(),
        );
      }
    }
    return _store.failItem(localId: item.localId, failureCode: code);
  }

  static _Disposition _classify(AppError error) {
    return switch (error) {
      // A mid-request network failure OR a server-side timeout: back off and stop
      // the pass (device-offline is already handled before dispatch). Never a
      // tight-retry, never a drop.
      NetworkError() => _Disposition.transientStop,
      RateLimitedError() => _Disposition.transientStop,
      // Only genuinely permanent client errors are terminal. Everything else (5xx,
      // 401 from a transient refresh failure, 408, unknown) is retried with backoff
      // rather than dropped.
      ValidationError() ||
      ForbiddenError() ||
      NotFoundError() ||
      ConflictError() => _Disposition.terminal,
      _ => _Disposition.transient,
    };
  }
}

enum _Disposition {
  /// Transient — back off and stop this pass (offline / rate limited).
  transientStop,

  /// Transient — back off and keep draining other items.
  transient,

  /// Permanent (definite 4xx) — mark failed, keep visible, never retry.
  terminal,
}
