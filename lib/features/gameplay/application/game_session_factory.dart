import '../domain/domain.dart';
import 'game_session_config.dart';

/// Resolves a session's authored map without embedding selection policy in the
/// controller. Competitive and player-selected modes must carry an explicit map;
/// only Time Attack performs deterministic catalog selection locally.
class GameSessionFactory {
  GameSessionFactory._();

  static MapDefinitionV2 resolveMap({
    required GameSessionConfig config,
    required MapCatalogV1 catalog,
  }) {
    if (config.protocol.protocolVersion != BoardGeneratorV2.protocolId ||
        config.protocol.generatorVersion != BoardGeneratorV2.generatorVersion ||
        config.protocol.mapCatalogVersion != catalog.version) {
      throw StateError(
        'Session protocol/map catalog does not match the bundled v2 engine',
      );
    }
    final String modeId = config.mode.wireName;
    if (config.mapId case final String mapId) {
      final MapDefinitionV2 map = catalog.map(mapId);
      if (!map.eligibleModes.contains(modeId)) {
        throw StateError('Map $mapId is not eligible for mode $modeId');
      }
      return map;
    }
    if (config.mode != V2GameMode.timeAttack) {
      throw StateError('$modeId requires an explicit map ID');
    }

    final List<MapDefinitionV2> eligible =
        catalog.maps
            .where((MapDefinitionV2 map) => map.eligibleModes.contains(modeId))
            .toList(growable: false)
          ..sort(
            (MapDefinitionV2 a, MapDefinitionV2 b) =>
                a.order.compareTo(b.order),
          );
    if (eligible.isEmpty) {
      throw StateError('No $modeId maps exist in ${catalog.version}');
    }
    final Drbg selector = Drbg(
      'HEXCALC|${catalog.version}|mode-map|$modeId|${config.seed}',
    );
    return eligible[selector.nextInt(eligible.length)];
  }
}
