import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/design_system.dart';
import '../application/game_session_config.dart';
import '../domain/domain.dart';
import '../persistence/map_progress_repository.dart';

class MapSelectionScreen extends ConsumerWidget {
  const MapSelectionScreen({required this.mode, super.key});

  final V2GameMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(mode == V2GameMode.level || mode == V2GameMode.endless);
    final MapCatalogV1 catalog = ref.watch(mapCatalogV1Provider);
    final AsyncValue<Map<String, MapProgress>> progress = ref.watch(
      mapProgressProvider(catalog.version),
    );
    final List<MapDefinitionV2> maps =
        catalog.maps
            .where(
              (MapDefinitionV2 map) =>
                  map.eligibleModes.contains(mode.wireName),
            )
            .toList(growable: false)
          ..sort(
            (MapDefinitionV2 a, MapDefinitionV2 b) =>
                a.order.compareTo(b.order),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryText,
        elevation: 0,
        title: Text(
          mode == V2GameMode.level ? 'SELECT LEVEL' : 'SELECT MAP',
          style: AppTypography.hudLabel,
        ),
      ),
      body: SafeArea(
        child: progress.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.neonBlue),
          ),
          error: (_, _) =>
              const Center(child: Text('Map progress could not be loaded.')),
          data: (Map<String, MapProgress> values) => ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: maps.length,
            itemBuilder: (BuildContext context, int index) {
              final MapDefinitionV2 map = maps[index];
              final MapProgress? saved = values[map.id];
              final bool unlocked =
                  index == 0 ||
                  (values[maps[index - 1].id]?.bestRating ?? 0) >= 1;
              return _MapCard(
                map: map,
                progress: saved,
                unlocked: unlocked,
                mode: mode,
                onTap: unlocked
                    ? () => context.go(
                        '/play-v2',
                        extra: GameSessionConfig(
                          protocol: GameplayProtocolRef.targetSwipeV2,
                          mode: mode,
                          seed:
                              '${mode.wireName}-${map.id}-'
                              '${DateTime.now().microsecondsSinceEpoch}',
                          mapId: map.id,
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.map,
    required this.progress,
    required this.unlocked,
    required this.mode,
    required this.onTap,
  });

  final MapDefinitionV2 map;
  final MapProgress? progress;
  final bool unlocked;
  final V2GameMode mode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final int stars = progress?.bestRating ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        button: unlocked,
        enabled: unlocked,
        label: unlocked
            ? '${map.name}, ${_tierName(map.tier)}, $stars stars'
            : '${map.name}, locked',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: unlocked
                    ? AppColors.inactiveBorder
                    : AppColors.inactiveBorder.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 36,
                  child: unlocked
                      ? Text(
                          '${map.order + 1}',
                          style: AppTypography.hudNumeric.copyWith(
                            color: AppColors.neonBlue,
                            fontSize: 20,
                          ),
                        )
                      : const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.secondaryText,
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Opacity(
                    opacity: unlocked ? 1 : 0.55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          map.name,
                          style: AppTypography.body.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          mode == V2GameMode.level
                              ? '${_tierName(map.tier)} · '
                                    '${map.levelGoal.targetQuota} targets · '
                                    '${map.levelGoal.durationMs ~/ 1000}s'
                              : '${_tierName(map.tier)} · '
                                    '${map.playableCoordinates.length} tiles',
                          style: AppTypography.body.copyWith(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                        if (unlocked) ...<Widget>[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            stars == 0
                                ? '☆☆☆'
                                : '${'★' * stars}${'☆' * (3 - stars)}',
                            style: AppTypography.body.copyWith(
                              color: AppColors.neonBlue,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (unlocked)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondaryText,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _tierName(MapTierV2 tier) => switch (tier) {
  MapTierV2.beginner => 'Beginner',
  MapTierV2.intermediate => 'Intermediate',
  MapTierV2.advanced => 'Advanced',
};
