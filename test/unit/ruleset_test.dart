import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

Ruleset loadRs1() {
  final Map<String, dynamic> j =
      jsonDecode(
            File(
              'test/contract/fixtures/rulesets/rs-v1.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  return Ruleset.fromJson(j);
}

void main() {
  test('rs-v1 parses with expected values', () {
    final Ruleset r = loadRs1();
    expect(r.rulesetVersion, 'rs-v1');
    expect(r.run.durationMs, 60000);
    expect(r.level.equationsToComplete, 5);
    expect(r.combo.windowMs, 4000);
    expect(r.fever.threshold, 8);
    expect(r.fever.multiplierPercent, 200);
    expect(r.fever.wrongEnergyPenalty, 4);
    expect(r.scoring.baseEquationScore, 100);
    expect(r.scoring.lengthBonusPerUnit, 20);
    expect(r.scoring.speedBonusMax, 50);
    expect(r.scoring.targetMatchPercent, 200);
    expect(r.scoring.comboMaxPercent, 200);
  });

  test('operator difficulty bonus is ordered by hardness', () {
    final ScoringConfig s = loadRs1().scoring;
    expect(s.operatorBonus(Operator.add), 0);
    expect(s.operatorBonus(Operator.subtract), 5);
    expect(s.operatorBonus(Operator.multiply), 10);
    expect(s.operatorBonus(Operator.divide), 15);
  });
}
