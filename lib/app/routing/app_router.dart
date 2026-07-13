import 'package:go_router/go_router.dart';

import '../../features/authentication/account_link_screen.dart';
import '../../features/authentication/forgot_password_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/register_screen.dart';
import '../../features/authentication/reset_password_screen.dart';
import '../../features/daily_challenge/presentation/daily_challenge_screen.dart';
import '../../features/gameplay/application/game_session_config.dart';
import '../../features/gameplay/presentation/gameplay_screen.dart';
import '../../features/gameplay/presentation/gameplay_screen_v2.dart';
import '../../features/gameplay/presentation/map_selection_screen.dart';
import '../../features/gameplay/presentation/mode_selection_screen.dart';
import '../../features/gameplay/presentation/ranked_result_screen.dart';
import '../../features/gameplay/presentation/ranked_run_config.dart';
import '../../features/gameplay/presentation/ranked_screen.dart';
import '../../features/gameplay/presentation/run_result_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';

/// App routes. Home -> Gameplay -> Run result, with Settings and Profile reachable
/// from Home, and the auth flows (sign-in, register, password reset, account link)
/// reachable from Profile.
GoRouter createRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/modes', builder: (_, _) => const ModeSelectionScreen()),
      GoRoute(path: '/play', builder: (_, _) => const GameplayScreen()),
      GoRoute(
        path: '/play-v2',
        builder: (_, GoRouterState state) {
          final Object? extra = state.extra;
          final GameSessionConfig config = extra is GameSessionConfig
              ? extra
              : GameSessionConfig(
                  protocol: GameplayProtocolRef.targetSwipeV2,
                  mode: V2GameMode.timeAttack,
                  seed: 'timeAttack-${DateTime.now().microsecondsSinceEpoch}',
                );
          return GameplayScreenV2(config: config);
        },
      ),
      GoRoute(
        path: '/levels',
        builder: (_, _) => const MapSelectionScreen(mode: V2GameMode.level),
      ),
      GoRoute(
        path: '/endless-maps',
        builder: (_, _) => const MapSelectionScreen(mode: V2GameMode.endless),
      ),
      GoRoute(path: '/ranked', builder: (_, _) => const RankedScreen()),
      GoRoute(
        path: '/leaderboard',
        builder: (_, _) => const LeaderboardScreen(),
      ),
      GoRoute(path: '/daily', builder: (_, _) => const DailyChallengeScreen()),
      GoRoute(
        path: '/play-ranked',
        builder: (_, GoRouterState state) {
          final Object? extra = state.extra;
          // Without a server-issued config a ranked run cannot start: fall back
          // to the ranked entry to fetch a fresh challenge.
          if (extra is! RankedRunConfig) {
            return const RankedScreen();
          }
          if (!extra.isTargetSwipeV2) {
            return GameplayScreen(ranked: extra);
          }
          final String? mapId = extra.mapId;
          if (mapId == null) {
            return const RankedScreen();
          }
          return GameplayScreenV2(
            config: GameSessionConfig(
              protocol: GameplayProtocolRef.targetSwipeV2,
              mode: extra.isDaily ? V2GameMode.daily : V2GameMode.ranked,
              seed: extra.seed,
              mapId: mapId,
              durationMs: extra.runDurationMs,
              competitiveRun: CompetitiveRunEnvelope(
                runId: extra.runId,
                challengeToken: extra.challengeToken,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/ranked-result',
        builder: (_, GoRouterState state) {
          final Object? extra = state.extra;
          return extra is RankedResultArgs
              ? RankedResultScreen(
                  runId: extra.runId,
                  clientScore: extra.clientScore,
                  isDaily: extra.isDaily,
                )
              : const HomeScreen();
        },
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, GoRouterState state) {
          final Object? extra = state.extra;
          return ResetPasswordScreen(
            initialEmail: extra is String ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/link-account',
        builder: (_, _) => const AccountLinkScreen(),
      ),
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
