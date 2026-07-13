import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_session.dart';
import '../core/design_system/design_system.dart';
import 'providers.dart';
import 'routing/app_router.dart';
import 'sync_controller.dart';

/// The app shell. Flavor-aware (title + debug banner) and dark/neon themed.
class HexCalcApp extends ConsumerStatefulWidget {
  const HexCalcApp({super.key});

  @override
  ConsumerState<HexCalcApp> createState() => _HexCalcAppState();
}

class _HexCalcAppState extends ConsumerState<HexCalcApp> {
  late final GoRouter _router = createRouter();

  @override
  void initState() {
    super.initState();
    // Start the non-blocking guest bootstrap at app launch; gameplay never waits
    // on it. Reading the provider instantiates the notifier and runs build().
    ref.read(authSessionProvider);
    // Start the outbox sync engine (initial drain + reconnect + periodic retries).
    ref.read(outboxSyncControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final bool showBanner = ref.watch(
      flavorProvider.select((f) => f.showDebugBanner),
    );
    final String title = ref.watch(flavorProvider.select((f) => f.appName));

    return MaterialApp.router(
      title: title,
      debugShowCheckedModeBanner: showBanner,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppTypography.uiFamily,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonBlue,
          surface: AppColors.background,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.neonBlue,
          thumbColor: AppColors.neonBlue,
          inactiveTrackColor: AppColors.inactiveBorder,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            return states.contains(WidgetState.selected)
                ? AppColors.neonBlue
                : AppColors.secondaryText;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            return states.contains(WidgetState.selected)
                ? AppColors.neonBlue.withValues(alpha: 0.4)
                : AppColors.inactiveCell;
          }),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.neonBlue,
            foregroundColor: AppColors.background,
            textStyle: AppTypography.button,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}
