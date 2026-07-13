import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_controller_v2.dart';
import 'package:hexcalc/features/gameplay/application/game_session_config.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

void main() {
  group('GameControllerV2', () {
    test('accepts a reachable target and deterministically refills', () {
      final GameControllerV2 controller = _controller(
        mode: V2GameMode.timeAttack,
      )..startRun();
      final BoardStateV2 before = controller.board;
      final TargetCandidateV2 solution = TargetAnalyzerV2.analyze(
        before,
      ).singleWhere((TargetCandidateV2 c) => c.result == before.target);

      _swipe(controller, solution.canonicalHintPath);

      expect(controller.board.revision, 1);
      expect(
        controller.board.lastTransition.consumed,
        solution.canonicalHintPath,
      );
      expect(controller.notifier.value.targetsSolved, 1);
      expect(controller.notifier.value.score, greaterThan(0));
      expect(
        TargetAnalyzerV2.analyze(
          controller.board,
        ).any((TargetCandidateV2 c) => c.result == controller.board.target),
        isTrue,
      );
      expect(controller.loggedEvents, hasLength(1));
      expect(controller.loggedEvents.single.boardRevision, 0);

      final BoardStateV2 independentlyReplayed = BoardEngineV2.submit(
        state: before,
        path: solution.canonicalHintPath,
        map: _map(),
      ).board;
      expect(independentlyReplayed.tiles, controller.board.tiles);
      expect(independentlyReplayed.target, controller.board.target);
    });

    test('incomplete release rewinds without score or event', () {
      final GameControllerV2 controller = _controller(
        mode: V2GameMode.timeAttack,
      )..startRun();
      final AxialCoordinate number = controller.board.tiles
          .firstWhere((BoardTileV2 tile) => tile.kind == BoardTileKindV2.number)
          .coordinate;

      controller.pressCell(number);
      controller.release();

      expect(controller.path, isEmpty);
      expect(controller.loggedEvents, isEmpty);
      expect(controller.notifier.value.score, 0);
      expect(controller.board.revision, 0);
    });

    test(
      'wrong complete chain is logged but leaves board and target unchanged',
      () {
        GameControllerV2? selected;
        TargetCandidateV2? wrong;
        for (int seedIndex = 0; seedIndex < 20 && wrong == null; seedIndex++) {
          final GameControllerV2 candidate = _controller(
            mode: V2GameMode.timeAttack,
            seed: 'wrong-$seedIndex',
          )..startRun();
          for (final TargetCandidateV2 target in TargetAnalyzerV2.analyze(
            candidate.board,
          )) {
            if (target.result != candidate.board.target) {
              selected = candidate;
              wrong = target;
              break;
            }
          }
        }
        expect(
          wrong,
          isNotNull,
          reason: 'test map should expose multiple results',
        );
        final GameControllerV2 controller = selected!;
        final BoardStateV2 before = controller.board;

        _swipe(controller, wrong!.canonicalHintPath);

        expect(controller.board, same(before));
        expect(controller.board.revision, 0);
        expect(controller.notifier.value.score, 0);
        expect(controller.notifier.value.lastChainCorrect, isFalse);
        expect(controller.loggedEvents, hasLength(1));
      },
    );

    test('Endless has no timer and only manual finish ends the run', () {
      final GameControllerV2 controller = _controller(mode: V2GameMode.endless)
        ..startRun();

      controller.tick(600000);
      expect(controller.notifier.value.timeRemainingMs, isNull);
      expect(controller.notifier.value.finished, isFalse);

      controller.finishManually();
      expect(controller.notifier.value.finished, isTrue);
    });

    test('Level finishes after reaching its quota and computes stars', () {
      final GameControllerV2 controller = _controller(mode: V2GameMode.level)
        ..startRun();
      final TargetCandidateV2 solution =
          TargetAnalyzerV2.analyze(controller.board).singleWhere(
            (TargetCandidateV2 c) => c.result == controller.board.target,
          );

      _swipe(controller, solution.canonicalHintPath);
      expect(controller.notifier.value.levelCompleted, isTrue);
      controller.pressCell(
        controller.board.tiles
            .firstWhere(
              (BoardTileV2 tile) => tile.kind == BoardTileKindV2.number,
            )
            .coordinate,
      );
      expect(controller.path, isEmpty, reason: 'completed Level blocks input');
      controller.tick(500);

      expect(controller.notifier.value.finished, isTrue);
      expect(controller.notifier.value.rating, greaterThanOrEqualTo(1));
    });
  });
}

void _swipe(GameControllerV2 controller, List<AxialCoordinate> path) {
  controller.pressCell(path.first);
  for (final AxialCoordinate coordinate in path.skip(1)) {
    controller.extendToCell(coordinate);
  }
  controller.release();
}

GameControllerV2 _controller({
  required V2GameMode mode,
  String seed = 'controller-v2-test',
}) => GameControllerV2(
  ruleset: _ruleset,
  config: GameSessionConfig(
    protocol: GameplayProtocolRef.targetSwipeV2,
    mode: mode,
    seed: seed,
    mapId: _map().id,
  ),
  map: _map(),
);

MapDefinitionV2 _map() => MapDefinitionV2(
  id: 'controller-test-map',
  order: 0,
  name: 'Controller Test',
  tier: MapTierV2.beginner,
  eligibleModes: const <String>[
    'timeAttack',
    'ranked',
    'level',
    'endless',
    'daily',
  ],
  playableCoordinates: <AxialCoordinate>[
    for (int q = -2; q <= 2; q++)
      for (
        int r = (-2 > -q - 2 ? -2 : -q - 2);
        r <= (2 < -q + 2 ? 2 : -q + 2);
        r++
      )
        AxialCoordinate(q, r),
  ],
  distribution: TileDistributionV2(
    numberWeight: 3,
    operatorWeight: 2,
    numbers: const <WeightedNumberV2>[
      WeightedNumberV2(value: 1, weight: 1),
      WeightedNumberV2(value: 2, weight: 1),
      WeightedNumberV2(value: 3, weight: 1),
      WeightedNumberV2(value: 4, weight: 1),
      WeightedNumberV2(value: 5, weight: 1),
      WeightedNumberV2(value: 6, weight: 1),
    ],
    operators: const <Operator, int>{
      Operator.add: 3,
      Operator.subtract: 2,
      Operator.multiply: 2,
      Operator.divide: 1,
    },
  ),
  levelGoal: LevelGoalV2(
    durationMs: 60000,
    targetQuota: 1,
    starScoreThresholds: const <int>[100, 150, 225],
  ),
);

const RulesetV2 _ruleset = RulesetV2(
  rulesetVersion: 'rs-v2',
  combo: ComboRulesV2(windowMs: 4000),
  fever: FeverRulesV2(
    threshold: 8,
    durationMs: 20000,
    multiplierPercent: 200,
    wrongEnergyPenalty: 4,
  ),
  scoring: ScoringRulesV2(
    baseChainScore: 100,
    lengthBonusPerAdditionalOperator: 20,
    operatorBonusAdd: 0,
    operatorBonusSubtract: 5,
    operatorBonusMultiply: 10,
    operatorBonusDivide: 15,
    speedBonusMax: 50,
    speedBonusWindowMs: 3000,
    comboBasePercent: 100,
    comboStepPercent: 10,
    comboMaxPercent: 200,
  ),
);
