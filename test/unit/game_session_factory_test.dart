import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_session_config.dart';
import 'package:hexcalc/features/gameplay/application/game_session_factory.dart';

import '../support/harness.dart';

void main() {
  test('Time Attack map selection is deterministic for a seed', () {
    final catalog = loadTestMapCatalogV1();
    const GameSessionConfig config = GameSessionConfig(
      protocol: GameplayProtocolRef.targetSwipeV2,
      mode: V2GameMode.timeAttack,
      seed: 'fixed-time-attack-seed',
    );

    final first = GameSessionFactory.resolveMap(
      config: config,
      catalog: catalog,
    );
    final second = GameSessionFactory.resolveMap(
      config: config,
      catalog: catalog,
    );

    expect(second.id, first.id);
    expect(first.eligibleModes, contains('timeAttack'));
  });

  test('rejects a session bound to a different map catalog', () {
    final catalog = loadTestMapCatalogV1();
    const GameSessionConfig config = GameSessionConfig(
      protocol: GameplayProtocolRef(
        protocolVersion: 'target-swipe-v2',
        rulesetVersion: 'rs-v2',
        generatorVersion: 'gen-v2',
        mapCatalogVersion: 'maps-v999',
        modeCatalogVersion: 'modes-v1',
        payloadVersion: 2,
      ),
      mode: V2GameMode.timeAttack,
      seed: 'fixed-time-attack-seed',
    );

    expect(
      () => GameSessionFactory.resolveMap(config: config, catalog: catalog),
      throwsStateError,
    );
  });
}
