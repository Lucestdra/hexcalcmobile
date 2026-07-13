import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/presentation/single_pointer_swipe_input.dart';

void main() {
  testWidgets('starts immediately and follows only the first pointer', (
    WidgetTester tester,
  ) async {
    final List<String> events = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: SinglePointerSwipeInput(
          onDown: (Offset p) => events.add('down:${p.dx.round()}'),
          onMove: (Offset p) => events.add('move:${p.dx.round()}'),
          onUp: () => events.add('up'),
          onCancel: () => events.add('cancel'),
        ),
      ),
    );

    final TestGesture first = await tester.startGesture(
      const Offset(10, 10),
      pointer: 1,
    );
    expect(events, <String>['down:10']);

    final TestGesture second = await tester.startGesture(
      const Offset(30, 10),
      pointer: 2,
    );
    await second.moveTo(const Offset(40, 10));
    await first.moveTo(const Offset(20, 10));
    await second.up();
    await first.up();

    expect(events, <String>['down:10', 'move:20', 'up']);
  });

  testWidgets('cancel and disabling rewind the active pointer once', (
    WidgetTester tester,
  ) async {
    final List<String> events = <String>[];
    bool enabled = true;
    late StateSetter setState;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setter) {
            setState = setter;
            return SinglePointerSwipeInput(
              enabled: enabled,
              onDown: (_) => events.add('down'),
              onMove: (_) => events.add('move'),
              onUp: () => events.add('up'),
              onCancel: () => events.add('cancel'),
            );
          },
        ),
      ),
    );

    final TestGesture first = await tester.startGesture(
      const Offset(10, 10),
      pointer: 3,
    );
    await first.cancel();
    expect(events, <String>['down', 'cancel']);

    final TestGesture second = await tester.startGesture(
      const Offset(10, 10),
      pointer: 4,
    );
    setState(() => enabled = false);
    await tester.pump();
    await second.up();
    expect(events, <String>['down', 'cancel', 'down', 'cancel']);
  });
}
