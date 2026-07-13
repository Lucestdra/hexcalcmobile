import 'package:go_router/go_router.dart';

import '../../features/authentication/account_link_screen.dart';
import '../../features/authentication/forgot_password_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/register_screen.dart';
import '../../features/authentication/reset_password_screen.dart';
import '../../features/gameplay/presentation/gameplay_screen.dart';
import '../../features/gameplay/presentation/ranked_result_screen.dart';
import '../../features/gameplay/presentation/ranked_run_config.dart';
import '../../features/gameplay/presentation/ranked_screen.dart';
import '../../features/gameplay/presentation/run_result_screen.dart';
import '../../features/home/home_screen.dart';
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
      GoRoute(path: '/play', builder: (_, _) => const GameplayScreen()),
      GoRoute(path: '/ranked', builder: (_, _) => const RankedScreen()),
      GoRoute(
        path: '/play-ranked',
        builder: (_, GoRouterState state) {
          final Object? extra = state.extra;
          // Without a server-issued config a ranked run cannot start: fall back
          // to the ranked entry to fetch a fresh challenge.
          return extra is RankedRunConfig
              ? GameplayScreen(ranked: extra)
              : const RankedScreen();
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
