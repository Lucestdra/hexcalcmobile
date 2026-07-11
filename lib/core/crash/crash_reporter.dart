import 'package:flutter/foundation.dart';

/// The crash/diagnostics seam. A real Sentry/Crashlytics client is wired behind
/// this later; diagnostics are kept strictly separate from product analytics.
/// Never record tokens, passwords, or PII.
abstract interface class CrashReporter {
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal,
    Map<String, Object>? context,
  });

  void log(String message);
  Future<void> setUserId(String? id);
}

class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    Map<String, Object>? context,
  }) async {}

  @override
  void log(String message) {}

  @override
  Future<void> setUserId(String? id) async {}
}

class DebugCrashReporter implements CrashReporter {
  const DebugCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    Map<String, Object>? context,
  }) async {
    debugPrint('[crash]${fatal ? ' FATAL' : ''} $error');
    if (context != null && context.isNotEmpty) {
      debugPrint('[crash] context $context');
    }
    if (stack != null) {
      debugPrint('[crash] $stack');
    }
  }

  @override
  void log(String message) => debugPrint('[crash] $message');

  @override
  Future<void> setUserId(String? id) async => debugPrint('[crash] userId=$id');
}
