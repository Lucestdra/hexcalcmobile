import 'package:connectivity_plus/connectivity_plus.dart';

/// A minimal connectivity signal used to retry the non-blocking guest bootstrap
/// when the device comes back online. Kept behind an interface so the auth session
/// depends on the signal, not the plugin, and tests can drive it deterministically.
abstract interface class ConnectivityMonitor {
  /// Emits `true` each time connectivity is (re)gained.
  Stream<bool> get onOnline;

  Future<bool> isOnline();
}

/// [ConnectivityMonitor] backed by `connectivity_plus`.
class ConnectivityPlusMonitor implements ConnectivityMonitor {
  ConnectivityPlusMonitor([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _online(List<ConnectivityResult> results) =>
      results.any((ConnectivityResult r) => r != ConnectivityResult.none);

  @override
  Stream<bool> get onOnline => _connectivity.onConnectivityChanged
      .map(_online)
      .where((bool online) => online);

  @override
  Future<bool> isOnline() async =>
      _online(await _connectivity.checkConnectivity());
}

/// A monitor that reports permanently online and never emits — a safe fallback
/// and a test default when connectivity behaviour is not under test.
class AlwaysOnlineMonitor implements ConnectivityMonitor {
  const AlwaysOnlineMonitor();

  @override
  Stream<bool> get onOnline => const Stream<bool>.empty();

  @override
  Future<bool> isOnline() async => true;
}
