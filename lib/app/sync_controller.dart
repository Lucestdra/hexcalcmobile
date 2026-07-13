import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_session.dart';
import 'providers.dart';

/// Drives the outbox drain over the app lifetime: an initial pass at launch, a
/// pass on every reconnect edge, and a periodic pass so backed-off items retry
/// once their delay elapses. Read once at app start (like the auth session); the
/// [OutboxSyncEngine]'s single-flight guard collapses overlapping triggers.
class SyncController extends Notifier<void> {
  Timer? _timer;
  StreamSubscription<bool>? _sub;

  static const Duration _tick = Duration(seconds: 20);

  @override
  void build() {
    _sub = ref
        .read(connectivityMonitorProvider)
        .onOnline
        .listen((_) => _drain());
    _timer = Timer.periodic(_tick, (_) => _drain());
    ref.onDispose(() {
      _timer?.cancel();
      _sub?.cancel();
    });
    _drain(); // initial pass at launch
  }

  /// Requests an immediate drain (e.g. right after enqueuing a submission).
  void kick() => _drain();

  void _drain() => unawaited(ref.read(outboxSyncEngineProvider).drain());
}

final outboxSyncControllerProvider = NotifierProvider<SyncController, void>(
  SyncController.new,
);
