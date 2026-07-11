import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/analytics/analytics_event.dart';
import '../../core/design_system/design_system.dart';
import '../../core/settings/app_settings.dart';
import '../../core/settings/settings_controller.dart';

/// Audio + accessibility settings. Every control writes straight through the
/// [SettingsController] (persisted immediately); effects across the app read the
/// same [AppSettings] source of truth.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).logEvent(AnalyticsEvent.settingsOpened());
  }

  @override
  Widget build(BuildContext context) {
    final AppSettings s = ref.watch(settingsProvider);
    final SettingsController c = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        title: const Text('SETTINGS', style: AppTypography.hudLabel),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            const _SectionHeader('AUDIO'),
            _SliderTile(
              label: 'Music volume',
              value: s.musicVolume,
              onChanged: c.setMusicVolume,
            ),
            _SliderTile(
              label: 'Sound effects',
              value: s.sfxVolume,
              onChanged: c.setSfxVolume,
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SectionHeader('ACCESSIBILITY'),
            _SwitchTile(
              label: 'Haptics',
              subtitle: 'Vibration feedback on taps and events',
              value: s.hapticsEnabled,
              onChanged: c.setHapticsEnabled,
            ),
            _SwitchTile(
              label: 'Reduced motion',
              subtitle: 'No screen shake, minimal particles, gentle fades',
              value: s.reducedMotion,
              onChanged: c.setReducedMotion,
            ),
            _SliderTile(
              label: 'Neon intensity',
              value: s.neonIntensity,
              onChanged: c.setNeonIntensity,
            ),
            _SliderTile(
              label: 'Particle intensity',
              value: s.particleIntensity,
              onChanged: c.setParticleIntensity,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.hudLabel.copyWith(color: AppColors.neonBlue),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label, style: AppTypography.body)),
              Text(
                '${(value * 100).round()}%',
                style: AppTypography.body.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            // 0–100% in 5% steps.
            divisions: 20,
            label: '${(value * 100).round()}%',
            semanticFormatterCallback: (double v) =>
                '$label ${(v * 100).round()} percent',
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(label, style: AppTypography.body),
      subtitle: Text(
        subtitle,
        style: AppTypography.hudLabel.copyWith(letterSpacing: 0.5),
      ),
    );
  }
}
