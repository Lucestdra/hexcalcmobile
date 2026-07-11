import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/providers.dart';
import 'app/routing/app_router.dart';
import 'core/design_system/design_system.dart';
import 'features/gameplay/domain/domain.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  final String rulesetJson = await rootBundle.loadString(
    'assets/gameplay/rs-v1.json',
  );
  final Ruleset ruleset = Ruleset.fromJson(
    jsonDecode(rulesetJson) as Map<String, dynamic>,
  );

  runApp(
    ProviderScope(
      overrides: [rulesetProvider.overrideWithValue(ruleset)],
      child: const HexCalcApp(),
    ),
  );
}

class HexCalcApp extends StatefulWidget {
  const HexCalcApp({super.key});

  @override
  State<HexCalcApp> createState() => _HexCalcAppState();
}

class _HexCalcAppState extends State<HexCalcApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HEX CALC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonBlue,
          surface: AppColors.background,
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
