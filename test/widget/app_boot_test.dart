import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/main.dart';

void main() {
  testWidgets('boot screen shows the HEX CALC wordmark', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HexCalcApp());

    expect(find.text('HEX • CALC'), findsOneWidget);
  });
}
