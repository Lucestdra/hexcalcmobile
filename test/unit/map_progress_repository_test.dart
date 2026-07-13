import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart';
import 'package:hexcalc/features/gameplay/persistence/map_progress_repository.dart';

void main() {
  test(
    'progress keeps best rating and score while counting attempts',
    () async {
      final AppDatabase db = AppDatabase(NativeDatabase.memory());
      final MapProgressRepository repository = MapProgressRepository(db);
      addTearDown(db.close);

      await repository.recordAttempt(
        catalogVersion: 'maps-v1',
        mapId: 'open-hex',
        score: 800,
        rating: 2,
        playedAtMs: 1000,
      );
      await repository.recordAttempt(
        catalogVersion: 'maps-v1',
        mapId: 'open-hex',
        score: 600,
        rating: 1,
        playedAtMs: 2000,
      );
      await repository.recordAttempt(
        catalogVersion: 'maps-v1',
        mapId: 'open-hex',
        score: 1200,
        rating: 3,
        playedAtMs: 3000,
      );

      final MapProgress progress = (await repository.get(
        'maps-v1',
        'open-hex',
      ))!;
      expect(progress.bestRating, 3);
      expect(progress.bestScore, 1200);
      expect(progress.attempts, 3);
      expect(progress.completedAtMs, 1000);
    },
  );

  test('rejects ratings outside zero to three', () async {
    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    final MapProgressRepository repository = MapProgressRepository(db);
    addTearDown(db.close);

    expect(
      () => repository.recordAttempt(
        catalogVersion: 'maps-v1',
        mapId: 'open-hex',
        score: 0,
        rating: 4,
        playedAtMs: 0,
      ),
      throwsArgumentError,
    );
  });
}
