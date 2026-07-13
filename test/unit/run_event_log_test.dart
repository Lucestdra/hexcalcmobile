import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_controller.dart';
import 'package:hexcalc/features/gameplay/application/run_event_log.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

Ruleset _loadRuleset() => Ruleset.fromJson(
  jsonDecode(
        File('test/contract/fixtures/rulesets/rs-v1.json').readAsStringSync(),
      )
      as Map<String, dynamic>,
);

void main() {
  test('buildEventLogPayload serializes equation + pause/resume events', () {
    final Map<String, dynamic> payload = buildEventLogPayload(
      clientTotalScore: 246,
      events: <LoggedRunEvent>[
        const LoggedRunEvent.equation(
          tMs: 1200,
          levelIndex: 0,
          path: <AxialCoordinate>[AxialCoordinate(0, 0), AxialCoordinate(1, 0)],
        ),
        const LoggedRunEvent.pause(2000),
        const LoggedRunEvent.resume(2000),
      ],
    );

    expect(payload['payloadVersion'], 1);
    expect(payload['clientTotalScore'], 246);
    final List<dynamic> events = payload['events'] as List<dynamic>;
    expect(events, hasLength(3));

    final Map<String, dynamic> eq = events[0] as Map<String, dynamic>;
    expect(eq['type'], 'equation');
    expect(eq['levelIndex'], 0);
    expect(eq['tMs'], 1200);
    expect(eq['path'], <Map<String, int>>[
      <String, int>{'q': 0, 'r': 0},
      <String, int>{'q': 1, 'r': 0},
    ]);

    expect(events[1], <String, dynamic>{'type': 'pause', 'tMs': 2000});
    expect(events[2], <String, dynamic>{'type': 'resume', 'tMs': 2000});
  });

  test('the controller captures a played equation as an event-log entry', () {
    final GameController controller = GameController(
      ruleset: _loadRuleset(),
      seed: 'alpha',
    );
    controller.startRun();

    // Drive a real solution path from the generated board.
    final List<AxialCoordinate> solution =
        controller.board.sampleSolutions.first;
    controller.pressCell(solution.first);
    for (int i = 1; i < solution.length; i++) {
      controller.extendToCell(solution[i]);
    }
    controller.release();

    final List<LoggedRunEvent> log = controller.loggedEvents;
    expect(log, hasLength(1));
    expect(log.single.kind, LoggedEventKind.equation);
    expect(log.single.levelIndex, 0);
    expect(
      log.single.path.map((AxialCoordinate c) => (c.q, c.r)).toList(),
      solution.map((AxialCoordinate c) => (c.q, c.r)).toList(),
    );

    // Pause/resume are captured as audit markers.
    controller.togglePause();
    controller.togglePause();
    expect(
      controller.loggedEvents.map((LoggedRunEvent e) => e.kind).toList(),
      <LoggedEventKind>[
        LoggedEventKind.equation,
        LoggedEventKind.pause,
        LoggedEventKind.resume,
      ],
    );

    // The built payload is well-formed and scores against the live replay total.
    final Map<String, dynamic> payload = controller.buildEventLog();
    expect(payload['payloadVersion'], 1);
    expect((payload['events'] as List<dynamic>).length, 3);

    controller.dispose();
  });
}
