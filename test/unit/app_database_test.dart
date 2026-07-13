import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart';
import 'package:hexcalc/features/gameplay/persistence/run_history_repository.dart';

void main() {
  test('records runs and computes personal best / recent order', () async {
    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    final RunHistoryRepository repo = RunHistoryRepository(db);
    addTearDown(repo.close);

    await repo.recordRun(
      playedAtMs: 1000,
      mode: 'normal',
      score: 500,
      equations: 4,
      bestCombo: 3,
      levelReached: 1,
      durationMs: 60000,
      rulesetVersion: 'rs-v1',
      seed: 'a',
    );
    await repo.recordRun(
      playedAtMs: 2000,
      mode: 'normal',
      score: 1200,
      equations: 9,
      bestCombo: 6,
      levelReached: 2,
      durationMs: 60000,
      rulesetVersion: 'rs-v1',
      seed: 'b',
    );
    await repo.recordRun(
      playedAtMs: 3000,
      mode: 'endless',
      score: 99999,
      equations: 99,
      bestCombo: 20,
      levelReached: 0,
      durationMs: 120000,
      rulesetVersion: 'rs-v2',
      seed: 'endless',
      protocolVersion: 'target-swipe-v2',
      mapCatalogVersion: 'maps-v1',
      mapId: 'open-hex',
      targetsSolved: 99,
    );
    await repo.recordRun(
      playedAtMs: 4000,
      mode: 'timeAttack',
      score: 1300,
      equations: 0,
      bestCombo: 7,
      levelReached: 0,
      durationMs: 60000,
      rulesetVersion: 'rs-v2',
      seed: 'time-attack-v2',
      protocolVersion: 'target-swipe-v2',
      mapCatalogVersion: 'maps-v1',
      mapId: 'open-hex',
      targetsSolved: 8,
    );

    final RunStats stats = await repo.stats();
    expect(stats.personalBest, 1300);
    expect(stats.totalRuns, 3); // Endless is intentionally excluded.
    expect(stats.bestCombo, 7);

    final List<RunSummary> recent = await repo.recentRuns();
    expect(recent.first.score, 1300);
    expect(recent[1].score, 99999); // history still includes every mode
    expect(recent.last.score, 500);
  });

  test('schema v3 upgrades additively and preserves legacy runs', () async {
    final NativeDatabase executor = NativeDatabase.memory(
      setup: (raw) {
        raw
          ..execute('''
            CREATE TABLE runs (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              played_at_ms INTEGER NOT NULL,
              mode TEXT NOT NULL,
              score INTEGER NOT NULL,
              equations INTEGER NOT NULL,
              best_combo INTEGER NOT NULL,
              level_reached INTEGER NOT NULL,
              duration_ms INTEGER NOT NULL,
              ruleset_version TEXT NOT NULL,
              seed TEXT NOT NULL
            )
          ''')
          ..execute('''
            INSERT INTO runs (
              played_at_ms, mode, score, equations, best_combo,
              level_reached, duration_ms, ruleset_version, seed
            ) VALUES (1, 'normal', 321, 3, 2, 0, 60000, 'rs-v1', 'legacy')
          ''')
          ..execute('PRAGMA user_version = 3');
      },
    );
    final AppDatabase db = AppDatabase(executor);
    addTearDown(db.close);

    final Run legacy = (await db.recentRuns()).single;
    expect(legacy.score, 321);
    expect(legacy.protocolVersion, isNull);
    expect(legacy.mapId, isNull);
    expect(legacy.targetsSolved, 0);
    expect(await db.mapProgress('maps-v1', 'open-hex'), isNull);
  });
}
