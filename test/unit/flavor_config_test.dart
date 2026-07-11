import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/flavors/flavor_config.dart';

void main() {
  test('production hides the debug banner and uses no-op analytics', () {
    const FlavorConfig p = FlavorConfig.production;
    expect(p.isProduction, isTrue);
    expect(p.showDebugBanner, isFalse);
    expect(p.verboseLogging, isFalse);
    expect(p.useDebugAnalytics, isFalse);
    expect(p.apiBaseUrl.startsWith('https://'), isTrue);
  });

  test('development is debuggable and not production', () {
    const FlavorConfig d = FlavorConfig.development;
    expect(d.isProduction, isFalse);
    expect(d.showDebugBanner, isTrue);
    expect(d.useDebugAnalytics, isTrue);
  });

  test('each flavor has a distinct name and api base url', () {
    final Set<String> names = <String>{
      FlavorConfig.development.appName,
      FlavorConfig.staging.appName,
      FlavorConfig.production.appName,
    };
    final Set<String> urls = <String>{
      FlavorConfig.development.apiBaseUrl,
      FlavorConfig.staging.apiBaseUrl,
      FlavorConfig.production.apiBaseUrl,
    };
    expect(names.length, 3);
    expect(urls.length, 3);
  });
}
