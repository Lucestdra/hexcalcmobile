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

    final RunStats stats = await repo.stats();
    expect(stats.personalBest, 1200);
    expect(stats.totalRuns, 2);
    expect(stats.bestCombo, 6);

    final List<RunSummary> recent = await repo.recentRuns();
    expect(recent.first.score, 1200); // most recent by playedAtMs
    expect(recent.last.score, 500);
  });
}
