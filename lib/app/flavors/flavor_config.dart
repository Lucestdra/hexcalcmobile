/// The three build flavors. No feature code branches on this enum directly —
/// it selects a [FlavorConfig] at bootstrap, and everything else reads typed
/// values from that config (per the "Flavor and Configuration Rules").
enum AppFlavor { development, staging, production }

/// Immutable, typed configuration for a flavor. Selected once at bootstrap and
/// injected; never assembled from ad-hoc conditionals inside features.
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.showDebugBanner,
    required this.verboseLogging,
    required this.useDebugAnalytics,
  });

  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final bool showDebugBanner;
  final bool verboseLogging;

  /// When true, analytics/crash route to the debug-console implementations so
  /// the event stream is observable; otherwise they are no-ops until a real
  /// provider is wired in a later phase.
  final bool useDebugAnalytics;

  bool get isProduction => flavor == AppFlavor.production;

  static const FlavorConfig development = FlavorConfig(
    flavor: AppFlavor.development,
    appName: 'HEX CALC Dev',
    // Physical USB device via `adb reverse tcp:8080 tcp:8080` (device localhost
    // tunnels to the host). For the Android emulator, use 'http://10.0.2.2:8080'.
    apiBaseUrl: 'http://localhost:8080',
    showDebugBanner: true,
    verboseLogging: true,
    useDebugAnalytics: true,
  );

  static const FlavorConfig staging = FlavorConfig(
    flavor: AppFlavor.staging,
    appName: 'HEX CALC Staging',
    apiBaseUrl: 'https://staging.api.hexcalc.example',
    showDebugBanner: true,
    verboseLogging: true,
    useDebugAnalytics: true,
  );

  static const FlavorConfig production = FlavorConfig(
    flavor: AppFlavor.production,
    appName: 'HEX CALC',
    apiBaseUrl: 'https://api.hexcalc.example',
    showDebugBanner: false,
    verboseLogging: false,
    useDebugAnalytics: false,
  );
}
