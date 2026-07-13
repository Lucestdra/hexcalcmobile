import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/leaderboard/application/freshness.dart';

void main() {
  const int base = 1000000000000; // fixed epoch ms so the test is deterministic

  test('under 45s reads as "just now"', () {
    expect(freshnessLabel(base, base), 'just now');
    expect(freshnessLabel(base, base + 44 * 1000), 'just now');
  });

  test('minutes round down and clamp to at least 1m', () {
    expect(freshnessLabel(base, base + 45 * 1000), '1m ago');
    expect(freshnessLabel(base, base + 5 * 60 * 1000), '5m ago');
    expect(freshnessLabel(base, base + 59 * 60 * 1000), '59m ago');
  });

  test('hours below a day', () {
    expect(freshnessLabel(base, base + 60 * 60 * 1000), '1h ago');
    expect(freshnessLabel(base, base + 23 * 60 * 60 * 1000), '23h ago');
  });

  test('days beyond 24h', () {
    expect(freshnessLabel(base, base + 24 * 60 * 60 * 1000), '1d ago');
    expect(freshnessLabel(base, base + 3 * 24 * 60 * 60 * 1000), '3d ago');
  });

  test('clock skew (stamp ahead of now) never goes negative', () {
    expect(freshnessLabel(base + 5000, base), 'just now');
  });
}
