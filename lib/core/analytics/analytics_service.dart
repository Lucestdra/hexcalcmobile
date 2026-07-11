import 'package:flutter/foundation.dart';

import 'analytics_event.dart';

/// The analytics seam. Real SDKs (Firebase for acquisition, PostHog for product
/// funnels) are wired behind this interface in a later phase; today only the
/// no-op and debug-console implementations exist, so the app never depends on a
/// third-party SDK to run.
abstract interface class AnalyticsService {
  void logEvent(AnalyticsEvent event);
  Future<void> setUserProperty(String key, String value);
}

/// Drops every event. The safe default (e.g. before consent, or in production
/// until a real provider is wired).
class NoopAnalytics implements AnalyticsService {
  const NoopAnalytics();

  @override
  void logEvent(AnalyticsEvent event) {}

  @override
  Future<void> setUserProperty(String key, String value) async {}
}

/// Prints events to the debug console. Used in development builds so the event
/// stream is observable without any backend.
class DebugAnalytics implements AnalyticsService {
  const DebugAnalytics();

  @override
  void logEvent(AnalyticsEvent event) {
    debugPrint('[analytics] $event');
  }

  @override
  Future<void> setUserProperty(String key, String value) async {
    debugPrint('[analytics] userProperty $key=$value');
  }
}

/// Fans an event out to several providers. The app talks to one
/// [AnalyticsService]; routing "which provider gets which event" lives here so
/// feature code stays provider-agnostic.
class MultiplexAnalytics implements AnalyticsService {
  const MultiplexAnalytics(this._delegates);

  final List<AnalyticsService> _delegates;

  @override
  void logEvent(AnalyticsEvent event) {
    for (final AnalyticsService d in _delegates) {
      d.logEvent(event);
    }
  }

  @override
  Future<void> setUserProperty(String key, String value) async {
    for (final AnalyticsService d in _delegates) {
      await d.setUserProperty(key, value);
    }
  }
}
