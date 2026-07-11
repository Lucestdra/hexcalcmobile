import 'package:go_router/go_router.dart';

import '../../features/gameplay/presentation/gameplay_screen.dart';
import '../../features/gameplay/presentation/run_result_screen.dart';
import '../../features/home/home_screen.dart';

/// App routes: Home -> Gameplay -> Run result.
GoRouter createRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/play', builder: (_, _) => const GameplayScreen()),
      GoRoute(
        path: '/result',
        builder: (_, GoRouterState state) {
          final Object? extra = state.extra;
          final RunResultData data = extra is RunResultData
              ? extra
              : const RunResultData(
                  score: 0,
                  equationsSolved: 0,
                  bestCombo: 0,
                  level: 0,
                );
          return RunResultScreen(data: data);
        },
      ),
    ],
  );
}
