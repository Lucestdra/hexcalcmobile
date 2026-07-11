import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

/// Hand-computed anchors (mirror the backend ReplayEngineTests): expected totals
/// are derived by hand from docs/gameplay/scoring-and-replay.md.
void main() {
  final Ruleset rs1 = Ruleset.fromJson(
    jsonDecode(
          File('test/contract/fixtures/rulesets/rs-v1.json').readAsStringSync(),
        )
        as Map<String, dynamic>,
  );

  RunEvent ev(int tMs, bool correct, bool matchedTarget, List<Operator> ops) =>
      RunEvent(
        tMs: tMs,
        correct: correct,
        matchedTarget: matchedTarget,
        operators: ops,
      );

  int total(List<RunEvent> events) =>
      ReplayEngine.replay(rs1, events).finalState.totalScore;

  test('single add scores base only', () {
    expect(
      total(<RunEvent>[
        ev(0, true, false, <Operator>[Operator.add]),
      ]),
      100,
    );
  });

  test('two adds in window apply combo and speed', () {
    expect(
      total(<RunEvent>[
        ev(0, true, false, <Operator>[Operator.add]),
        ev(1000, true, false, <Operator>[Operator.add]),
      ]),
      246,
    );
  });

  test('target match doubles the score', () {
    expect(
      total(<RunEvent>[
        ev(0, true, true, <Operator>[Operator.add]),
      ]),
      200,
    );
  });

  test('divide adds operator difficulty bonus', () {
    expect(
      total(<RunEvent>[
        ev(0, true, false, <Operator>[Operator.divide]),
      ]),
      115,
    );
  });

  test('two-operator equation adds length bonus', () {
    expect(
      total(<RunEvent>[
        ev(0, true, false, <Operator>[Operator.add, Operator.multiply]),
      ]),
      130,
    );
  });

  test('wrong equation breaks the combo', () {
    final ReplayOutcome o = ReplayEngine.replay(rs1, <RunEvent>[
      ev(0, true, false, <Operator>[Operator.add]),
      ev(500, false, false, <Operator>[]),
      ev(1000, true, false, <Operator>[Operator.add]),
    ]);
    expect(o.finalState.comboCount, 1);
    expect(o.finalState.totalScore, 233);
  });

  test('five correct completes level zero', () {
    final ReplayOutcome o = ReplayEngine.replay(rs1, <RunEvent>[
      for (int i = 0; i < 5; i++)
        ev(i * 500, true, false, <Operator>[Operator.add]),
    ]);
    expect(o.finalState.level, 1);
    expect(o.finalState.equationsThisLevel, 0);
    expect(o.finalState.totalScore, 804);
  });

  test('eight consecutive correct ignite fever', () {
    final ReplayOutcome o = ReplayEngine.replay(rs1, <RunEvent>[
      for (int i = 0; i < 8; i++)
        ev(i * 500, true, false, <Operator>[Operator.add]),
    ]);
    expect(o.finalState.feverActive, isTrue);
    expect(o.finalState.feverEnergy, 0);
    expect(o.finalState.comboCount, 8);
  });

  test('fever expires before a much later equation', () {
    final ReplayOutcome o = ReplayEngine.replay(rs1, <RunEvent>[
      for (int i = 0; i < 8; i++)
        ev(i * 500, true, false, <Operator>[Operator.add]),
      ev(25000, true, false, <Operator>[Operator.add]),
    ]);
    expect(o.finalState.feverActive, isFalse);
    expect(o.finalState.comboCount, 1);
  });

  test('wrong outside fever drains energy but not below zero', () {
    final ReplayOutcome o = ReplayEngine.replay(rs1, <RunEvent>[
      ev(0, true, false, <Operator>[Operator.add]),
      ev(500, true, false, <Operator>[Operator.add]),
      ev(1000, false, false, <Operator>[]),
    ]);
    expect(o.finalState.feverEnergy, 0);
  });
}
