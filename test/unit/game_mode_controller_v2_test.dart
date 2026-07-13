import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_mode_controller_v2.dart';
import 'package:hexcalc/features/gameplay/application/game_session_config.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import '../support/harness.dart';

void main() {
  final MapDefinitionV2 map = loadTestMapCatalogV1().map('open-hex');

  test('all five modes expose only their policy differences', () {
    final Map<V2GameMode, GameModeControllerV2> policies =
        <V2GameMode, GameModeControllerV2>{
          for (final V2GameMode mode in V2GameMode.values)
            mode: GameModeControllerFactoryV2.create(
              config: GameSessionConfig(
                protocol: GameplayProtocolRef.targetSwipeV2,
                mode: mode,
                seed: 'mode-test',
                mapId: map.id,
              ),
              map: map,
            ),
        };

    expect(policies[V2GameMode.timeAttack]!.durationMs, 60000);
    expect(policies[V2GameMode.ranked]!.durationMs, 60000);
    expect(policies[V2GameMode.daily]!.durationMs, 60000);
    expect(policies[V2GameMode.endless]!.durationMs, isNull);
    expect(policies[V2GameMode.endless]!.allowsManualFinish, isTrue);
    expect(policies[V2GameMode.level]!.durationMs, map.levelGoal.durationMs);
    expect(policies[V2GameMode.level]!.targetQuota, map.levelGoal.targetQuota);
    expect(
      policies[V2GameMode.level]!.completesAfterSolve(
        map.levelGoal.targetQuota,
      ),
      isTrue,
    );
    expect(
      policies[V2GameMode.level]!.rating(
        targetsSolved: map.levelGoal.targetQuota - 1,
        score: 100000,
      ),
      0,
    );
  });
}
