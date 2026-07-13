import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/api/dtos.dart';

/// The daily challenge's `challengeDateUtc` is an OpenAPI date-only value
/// (`YYYY-MM-DD`). A bare date has no zone, so a naive `DateTime.parse` reads it
/// as LOCAL midnight and `.toUtc()` shifts the calendar day for non-UTC devices.
/// This guards that it is parsed as the intended UTC calendar date.
void main() {
  Map<String, dynamic> body(String date) => <String, dynamic>{
    'challengeDateUtc': date,
    'windowStartUtc': '2026-07-13T00:00:00Z',
    'windowEndUtc': '2026-07-14T00:00:00Z',
    'rulesetVersion': 'rs-v1',
    'generatorVersion': 'gen-v1',
    'attempted': false,
    'asOfUtc': '2026-07-13T12:00:00Z',
  };

  test('a date-only challengeDateUtc parses as the UTC calendar date', () {
    final DailyChallengeView view = DailyChallengeView.fromJson(
      body('2026-07-13'),
    );

    expect(view.challengeDateUtc.isUtc, isTrue);
    expect(view.challengeDateUtc, DateTime.utc(2026, 7, 13));
  });

  test('a full date-time challengeDateUtc is still honoured', () {
    final DailyChallengeView view = DailyChallengeView.fromJson(
      body('2026-07-13T00:00:00Z'),
    );

    expect(view.challengeDateUtc, DateTime.utc(2026, 7, 13));
  });
}
