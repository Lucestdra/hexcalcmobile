import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/api/dtos.dart';
import '../../../core/api/hexcalc_api.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/errors/app_error.dart';
import '../application/game_session_config.dart';
import '../domain/domain.dart';
import 'ranked_run_config.dart';

/// The ranked entry point: checks the client is on a supported ruleset/generator
/// (blocking ranked — never normal — play on a mismatch), issues a server challenge,
/// then hands the challenge to gameplay. Ranked requires connectivity; offline and
/// server errors are recoverable with a retry.
class RankedScreen extends ConsumerStatefulWidget {
  const RankedScreen({super.key});

  @override
  ConsumerState<RankedScreen> createState() => _RankedScreenState();
}

class _RankedScreenState extends ConsumerState<RankedScreen> {
  _RankedState _state = const _Loading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const _Loading());
    final HexcalcApi api = ref.read(hexcalcApiProvider);
    final String localV1Ruleset = ref.read(rulesetProvider).rulesetVersion;
    const String localV2Ruleset = BoardGeneratorV2.rulesetVersion;
    final GameplayCatalogHashesV2 localHashes = ref.read(
      gameplayCatalogHashesV2Provider,
    );
    try {
      final MetaConfigResponse meta = await api.getMetaConfig();
      if (!_supportsProtocol(
            protocolVersion: meta.protocolVersion,
            rulesetVersion: meta.rulesetVersion,
            generatorVersion: meta.generatorVersion,
            payloadVersion: meta.payloadVersion,
            mapCatalogVersion: meta.mapCatalogVersion,
            modeCatalogVersion: meta.modeCatalogVersion,
            localV1Ruleset: localV1Ruleset,
            localV2Ruleset: localV2Ruleset,
          ) ||
          (meta.protocolVersion ==
                  GameplayProtocolRef.targetSwipeV2.protocolVersion &&
              (meta.mapCatalogHash != localHashes.mapCatalogHash ||
                  meta.modeCatalogHash != localHashes.modeCatalogHash))) {
        _set(_Blocked(meta.rulesetVersion, meta.generatorVersion));
        return;
      }

      final GameRunChallengeResponse challenge = await api.issueGameRun(
        const IssueGameRunRequest(mode: 'ranked'),
      );
      // Belt and suspenders: the issued run must match what we can play/replay.
      if (!_supportsProtocol(
            protocolVersion: challenge.protocolVersion ?? 'equation-v1',
            rulesetVersion: challenge.rulesetVersion,
            generatorVersion: challenge.generatorVersion,
            payloadVersion: challenge.payloadVersion ?? 1,
            mapCatalogVersion: challenge.mapCatalogVersion,
            modeCatalogVersion: challenge.modeCatalogVersion,
            localV1Ruleset: localV1Ruleset,
            localV2Ruleset: localV2Ruleset,
          ) ||
          (challenge.protocolVersion ==
                  GameplayProtocolRef.targetSwipeV2.protocolVersion &&
              (challenge.mapId == null || challenge.modeId != 'ranked'))) {
        _set(_Blocked(challenge.rulesetVersion, challenge.generatorVersion));
        return;
      }

      _set(
        _Ready(
          RankedRunConfig(
            runId: challenge.runId,
            seed: challenge.seed,
            rulesetVersion: challenge.rulesetVersion,
            generatorVersion: challenge.generatorVersion,
            challengeToken: challenge.challengeToken,
            runDurationMs: challenge.runDurationMs,
            protocolVersion: challenge.protocolVersion ?? 'equation-v1',
            payloadVersion: challenge.payloadVersion ?? 1,
            mapCatalogVersion: challenge.mapCatalogVersion,
            mapId: challenge.mapId,
            modeCatalogVersion: challenge.modeCatalogVersion,
            modeId: challenge.modeId,
          ),
        ),
      );
    } on AppError catch (error) {
      _set(_Failed(error));
    }
  }

  void _set(_RankedState state) {
    if (mounted) {
      setState(() => _state = state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryText,
        elevation: 0,
        title: const Text('RANKED', style: AppTypography.hudLabel),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(child: _body(context)),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final _RankedState state = _state;
    return switch (state) {
      _Loading() => const _Message(
        icon: null,
        title: 'Preparing your ranked run…',
        detail: 'Requesting a challenge from the server.',
        showSpinner: true,
      ),
      _Blocked() => _Message(
        icon: Icons.system_update_rounded,
        title: 'Update required',
        detail:
            'Ranked play needs the latest version (server is on '
            '${state.serverRuleset}/${state.serverGenerator}). Normal play still '
            'works — update the app to play ranked.',
        action: _Action('Back to home', () => context.go('/')),
      ),
      _Failed() => _Message(
        icon: state.error.isOffline
            ? Icons.wifi_off_rounded
            : Icons.error_outline_rounded,
        title: state.error.isOffline
            ? 'You\'re offline'
            : 'Couldn\'t start a ranked run',
        detail: state.error.isOffline
            ? 'Ranked runs need a connection to get a fair, server-issued board. '
                  'Normal play works offline.'
            : state.error.message,
        action: _Action('Try again', _load),
        secondary: _Action('Back to home', () => context.go('/')),
      ),
      _Ready() => _Message(
        icon: Icons.bolt_rounded,
        title: 'Ranked run ready',
        detail:
            'A fresh server board is waiting. Your score is verified by the '
            'server after you play.',
        action: _Action(
          'START RANKED RUN',
          () => context.go('/play-ranked', extra: state.config),
        ),
      ),
    };
  }
}

bool _supportsProtocol({
  required String protocolVersion,
  required String rulesetVersion,
  required String generatorVersion,
  required int payloadVersion,
  required String? mapCatalogVersion,
  required String? modeCatalogVersion,
  required String localV1Ruleset,
  required String localV2Ruleset,
}) {
  if (protocolVersion == GameplayProtocolRef.targetSwipeV2.protocolVersion) {
    return rulesetVersion == localV2Ruleset &&
        generatorVersion == BoardGeneratorV2.generatorVersion &&
        payloadVersion == GameplayProtocolRef.targetSwipeV2.payloadVersion &&
        mapCatalogVersion ==
            GameplayProtocolRef.targetSwipeV2.mapCatalogVersion &&
        modeCatalogVersion ==
            GameplayProtocolRef.targetSwipeV2.modeCatalogVersion;
  }
  return protocolVersion == 'equation-v1' &&
      rulesetVersion == localV1Ruleset &&
      generatorVersion == BoardGeneratorV1.generatorVersion &&
      payloadVersion == 1;
}

sealed class _RankedState {
  const _RankedState();
}

class _Loading extends _RankedState {
  const _Loading();
}

class _Ready extends _RankedState {
  const _Ready(this.config);
  final RankedRunConfig config;
}

class _Blocked extends _RankedState {
  const _Blocked(this.serverRuleset, this.serverGenerator);
  final String serverRuleset;
  final String serverGenerator;
}

class _Failed extends _RankedState {
  const _Failed(this.error);
  final AppError error;
}

class _Action {
  const _Action(this.label, this.onPressed);
  final String label;
  final VoidCallback onPressed;
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.detail,
    this.showSpinner = false,
    this.action,
    this.secondary,
  });

  final IconData? icon;
  final String title;
  final String detail;
  final bool showSpinner;
  final _Action? action;
  final _Action? secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showSpinner)
          const CircularProgressIndicator(color: AppColors.neonBlue)
        else if (icon != null)
          Icon(icon, color: AppColors.neonBlue, size: 48),
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: AppTypography.title.copyWith(fontSize: 24)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          detail,
          style: AppTypography.body.copyWith(color: AppColors.secondaryText),
          textAlign: TextAlign.center,
        ),
        if (action != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: action!.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.neonBlue,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
            child: Text(action!.label),
          ),
        ],
        if (secondary != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: secondary!.onPressed,
            child: Text(secondary!.label),
          ),
        ],
      ],
    );
  }
}
