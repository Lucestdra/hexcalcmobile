import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import '../../../core/design_system/design_system.dart';
import '../application/game_controller_v2.dart';
import '../domain/domain.dart';
import 'effects.dart';
import 'game_feel.dart';
import 'hex_metrics.dart';

/// Flame renderer/input adapter for authored v2 topologies.
class HexBoardGameV2 extends FlameGame {
  HexBoardGameV2(this.controller, {GameFeel feel = GameFeel.standard})
    : _feel = feel;

  final GameControllerV2 controller;
  GameFeel _feel;
  set feel(GameFeel value) => _feel = value;

  final EffectsLayer _effects = EffectsLayer();
  final Map<String, TextPainter> _textCache = <String, TextPainter>{};
  HexMetrics? _metrics;
  List<AxialCoordinate> _rejectedPath = const <AxialCoordinate>[];
  List<AxialCoordinate> _consumedPath = const <AxialCoordinate>[];
  double _rejectedRemaining = 0;
  double _consumedRemaining = 0;

  HexMetrics? get metrics => _metrics;

  @override
  Color backgroundColor() => AppColors.background;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _metrics = HexMetrics.fitCoordinates(
      Size(size.x, size.y),
      controller.board.topology.layoutCoordinates,
      usable: 0.78,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    controller.tick((dt * 1000).round());
    _effects.update(dt);
    if (_rejectedRemaining > 0) {
      _rejectedRemaining -= dt;
      if (_rejectedRemaining <= 0) {
        _rejectedPath = const <AxialCoordinate>[];
      }
    }
    if (_consumedRemaining > 0) {
      _consumedRemaining -= dt;
      if (_consumedRemaining <= 0) {
        _consumedPath = const <AxialCoordinate>[];
      }
    }
  }

  @override
  void onRemove() {
    for (final TextPainter painter in _textCache.values) {
      painter.dispose();
    }
    _textCache.clear();
    _effects.clear();
    super.onRemove();
  }

  void pressAt(Offset position) {
    final HexMetrics? metrics = _metrics;
    if (metrics != null) {
      controller.pressCell(metrics.roundToCell(position));
    }
  }

  void extendAt(Offset position) {
    final HexMetrics? metrics = _metrics;
    final List<AxialCoordinate> accepted = controller.path;
    if (metrics == null || accepted.isEmpty) {
      return;
    }
    final AxialCoordinate target = metrics.roundToCell(position);
    // Always interpolate from the last accepted cell. Invalid/blocked samples
    // never move the origin and therefore cannot cause a later cell to skip the
    // controller's adjacency checks.
    for (final AxialCoordinate coordinate in HexMetrics.line(
      accepted.last,
      target,
    ).skip(1)) {
      controller.extendToCell(coordinate);
    }
  }

  void release() => controller.release();
  void cancel() => controller.cancelSelection();

  void playCorrect(List<AxialCoordinate> cells, {required bool fever}) {
    final HexMetrics? metrics = _metrics;
    if (metrics == null || cells.isEmpty) {
      return;
    }
    _consumedPath = List<AxialCoordinate>.unmodifiable(cells);
    _consumedRemaining = _feel.reducedMotion ? 0.08 : 0.34;
    final Color color = fever ? AppColors.feverMagenta : AppColors.neonBlue;
    final Offset result = metrics.centerOf(cells.last);
    if (!_feel.reducedMotion) {
      _effects.pop(result, color);
      _effects.wave(
        metrics.centerOf(cells.first),
        color,
        maxRadius: metrics.hexSize * 3,
      );
    }
    _effects.burst(result, color, _particleBudget(fever ? 26 : 16));
  }

  void playTargetMatched(List<AxialCoordinate> cells) {
    final HexMetrics? metrics = _metrics;
    if (metrics == null || cells.isEmpty) {
      return;
    }
    _effects.burst(
      metrics.centerOf(cells.last),
      AppColors.primaryText,
      _particleBudget(22),
      speed: 130,
    );
  }

  void playIncorrect(List<AxialCoordinate> cells) {
    final HexMetrics? metrics = _metrics;
    if (metrics == null) {
      return;
    }
    _rejectedPath = List<AxialCoordinate>.unmodifiable(cells);
    _rejectedRemaining = 0.26;
    if (!_feel.reducedMotion) {
      _effects.shake(6, 0.26);
    }
    if (cells.isNotEmpty) {
      _effects.burst(
        metrics.centerOf(cells.last),
        AppColors.warning,
        _particleBudget(10),
        speed: 60,
      );
    }
  }

  void playFeverStart() {
    final HexMetrics? metrics = _metrics;
    if (metrics == null) {
      return;
    }
    final Offset center = _layoutCenter(metrics);
    if (!_feel.reducedMotion) {
      _effects.wave(
        center,
        AppColors.feverMagenta,
        maxRadius: metrics.hexSize * 6,
      );
      _effects.shake(10, 0.4);
    }
    _effects.burst(
      center,
      AppColors.feverMagenta,
      _particleBudget(40),
      speed: 150,
    );
  }

  void playLevelUp() {
    final HexMetrics? metrics = _metrics;
    if (metrics != null && !_feel.reducedMotion) {
      _effects.wave(
        _layoutCenter(metrics),
        AppColors.neonBlue,
        maxRadius: metrics.hexSize * 5,
      );
    }
  }

  int _particleBudget(int base) => _feel.reducedMotion
      ? 0
      : (base * _feel.particleIntensity).round().clamp(0, base);

  Offset _layoutCenter(HexMetrics metrics) {
    final List<AxialCoordinate> coordinates =
        controller.board.topology.layoutCoordinates;
    Offset total = Offset.zero;
    for (final AxialCoordinate coordinate in coordinates) {
      total += metrics.centerOf(coordinate);
    }
    return total / coordinates.length.toDouble();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final HexMetrics? metrics = _metrics;
    if (metrics == null) {
      return;
    }
    final Offset shake = _effects.shakeOffset;
    canvas.save();
    if (shake != Offset.zero) {
      canvas.translate(shake.dx, shake.dy);
    }
    _renderBoard(canvas, metrics);
    _effects.render(canvas);
    canvas.restore();
  }

  void _renderBoard(Canvas canvas, HexMetrics metrics) {
    final Color energy = controller.notifier.value.feverActive
        ? AppColors.feverMagenta
        : AppColors.neonBlue;
    final double glow = _feel.neonIntensity.clamp(0.35, 1.0);
    final List<AxialCoordinate> path = controller.path;
    final Set<AxialCoordinate> selected = path.toSet();
    final Set<AxialCoordinate> rejected = _rejectedPath.toSet();
    final Set<AxialCoordinate> consumed = _consumedPath.toSet();

    for (final AxialCoordinate coordinate
        in controller.board.topology.blockedCoordinates) {
      final Path hex = Path()..addPolygon(metrics.cornersOf(coordinate), true);
      canvas.drawPath(
        hex,
        Paint()
          ..style = PaintingStyle.fill
          ..color = AppColors.surface,
      );
      canvas.drawPath(
        hex,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppStroke.thin
          ..color = AppColors.secondaryText.withValues(alpha: 0.38),
      );
      final Offset center = metrics.centerOf(coordinate);
      final double half = metrics.hexSize * 0.2;
      final Paint mark = Paint()
        ..color = AppColors.secondaryText.withValues(alpha: 0.35)
        ..strokeWidth = AppStroke.medium
        ..strokeCap = StrokeCap.round;
      canvas
        ..drawLine(
          center + Offset(-half, -half),
          center + Offset(half, half),
          mark,
        )
        ..drawLine(
          center + Offset(half, -half),
          center + Offset(-half, half),
          mark,
        );
    }

    for (final BoardTileV2 tile in controller.board.tiles) {
      final AxialCoordinate coordinate = tile.coordinate;
      final bool isSelected = selected.contains(coordinate);
      final bool isRejected = rejected.contains(coordinate);
      final bool isConsumed = consumed.contains(coordinate);
      final Color stateColor = isRejected ? AppColors.warning : energy;
      final Path hex = Path()..addPolygon(metrics.cornersOf(coordinate), true);
      canvas.drawPath(
        hex,
        Paint()
          ..style = PaintingStyle.fill
          ..color = isSelected || isRejected || isConsumed
              ? stateColor.withValues(alpha: isConsumed ? 0.08 : 0.16 * glow)
              : AppColors.inactiveCell,
      );
      canvas.drawPath(
        hex,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected || isRejected
              ? AppStroke.medium
              : AppStroke.thin
          ..color = isSelected || isRejected || isConsumed
              ? stateColor.withValues(alpha: glow)
              : AppColors.inactiveBorder,
      );
      _paintGlyph(canvas, metrics, tile.displayText, coordinate);
    }

    if (path.length >= 2) {
      _paintPath(canvas, metrics, path, energy.withValues(alpha: glow));
    }
    if (_rejectedPath.length >= 2) {
      _paintPath(canvas, metrics, _rejectedPath, AppColors.warning);
    }
  }

  void _paintPath(
    Canvas canvas,
    HexMetrics metrics,
    List<AxialCoordinate> path,
    Color color,
  ) {
    final Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppStroke.thick
      ..strokeCap = StrokeCap.round
      ..color = color;
    final Path polyline = Path()
      ..moveTo(
        metrics.centerOf(path.first).dx,
        metrics.centerOf(path.first).dy,
      );
    for (final AxialCoordinate coordinate in path.skip(1)) {
      polyline.lineTo(
        metrics.centerOf(coordinate).dx,
        metrics.centerOf(coordinate).dy,
      );
    }
    canvas.drawPath(polyline, line);
  }

  void _paintGlyph(
    Canvas canvas,
    HexMetrics metrics,
    String glyph,
    AxialCoordinate coordinate,
  ) {
    final TextPainter painter = _textCache.putIfAbsent(glyph, () {
      return TextPainter(
        text: TextSpan(
          text: glyph,
          style: AppTypography.cellNumber.copyWith(
            color: AppColors.primaryText,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    });
    final Offset center = metrics.centerOf(coordinate);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }
}
