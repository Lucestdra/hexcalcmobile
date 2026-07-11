import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import '../../../core/design_system/design_system.dart';
import '../application/game_controller.dart';
import '../domain/domain.dart';
import 'effects.dart';
import 'game_feel.dart';
import 'hex_metrics.dart';

/// The Flame gameplay surface: renders the hex board and the selection path, and
/// drives the run clock from its update loop. Pointer input is captured by the
/// Flutter layer and forwarded through [pressAt] / [extendAt] / [release] using
/// the same [HexMetrics], so hit testing and rendering stay aligned.
class HexBoardGame extends FlameGame {
  HexBoardGame(this.controller, {GameFeel feel = GameFeel.standard})
    : _feel = feel;

  final GameController controller;

  GameFeel _feel;
  set feel(GameFeel value) => _feel = value;

  final EffectsLayer _effects = EffectsLayer();

  HexMetrics? _metrics;
  HexMetrics? get metrics => _metrics;

  final Map<String, TextPainter> _textCache = <String, TextPainter>{};

  /// The last cell a pointer sample was resolved to, so a fast swipe between
  /// two samples can be interpolated cell-by-cell.
  AxialCoordinate? _lastForwarded;

  @override
  Color backgroundColor() => AppColors.background;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _metrics = HexMetrics.fit(Size(size.x, size.y), controller.board.radius);
  }

  @override
  void update(double dt) {
    super.update(dt);
    controller.tick((dt * 1000).round());
    _effects.update(dt);
  }

  @override
  void onRemove() {
    // Release cached text layouts and any live effects so repeated runs
    // (Play → result → Play again) do not accumulate native paragraph memory.
    for (final TextPainter tp in _textCache.values) {
      tp.dispose();
    }
    _textCache.clear();
    _effects.clear();
    super.onRemove();
  }

  // ----- choreography (driven by the controller's discrete signals) -----

  /// Correct equation: an energy wave along the path, a soft pop + particle
  /// burst at the result cell. Colours follow the current energy state. Waves and
  /// the pop are travel animations, so they are suppressed under reduced motion
  /// (which then relies on the cell/HUD state changes + audio/haptics).
  void playCorrect(List<AxialCoordinate> cells, {required bool fever}) {
    final HexMetrics? m = _metrics;
    if (m == null || cells.isEmpty) {
      return;
    }
    final Color color = fever ? AppColors.feverMagenta : AppColors.neonBlue;
    final Offset result = m.centerOf(cells.last);
    if (!_feel.reducedMotion) {
      _effects.pop(result, color);
      _effects.wave(m.centerOf(cells.first), color, maxRadius: m.hexSize * 3);
    }
    _effects.burst(result, color, _particleBudget(fever ? 26 : 16));
  }

  /// Target-matched bonus: an extra bright burst on the result cell.
  void playTargetMatched(List<AxialCoordinate> cells) {
    final HexMetrics? m = _metrics;
    if (m == null || cells.isEmpty) {
      return;
    }
    _effects.burst(
      m.centerOf(cells.last),
      AppColors.primaryText,
      _particleBudget(22),
      speed: 130,
    );
  }

  /// Complete-but-wrong: a restrained shake + a small warning burst at the last
  /// cell. Shake is suppressed under reduced motion.
  void playIncorrect(List<AxialCoordinate> cells) {
    final HexMetrics? m = _metrics;
    if (m == null) {
      return;
    }
    if (!_feel.reducedMotion) {
      _effects.shake(6, 0.26);
    }
    if (cells.isNotEmpty) {
      _effects.burst(
        m.centerOf(cells.last),
        AppColors.warning,
        _particleBudget(10),
        speed: 60,
      );
    }
  }

  /// Fever ignition: a magenta shockwave from the board centre + a firmer shake.
  /// Wave/shake are suppressed under reduced motion; the burst is already gated
  /// to zero by [_particleBudget].
  void playFeverStart() {
    final HexMetrics? m = _metrics;
    if (m == null) {
      return;
    }
    final Offset centre = m.centerOf(const AxialCoordinate(0, 0));
    if (!_feel.reducedMotion) {
      _effects.wave(centre, AppColors.feverMagenta, maxRadius: m.hexSize * 6);
      _effects.shake(10, 0.4);
    }
    _effects.burst(
      centre,
      AppColors.feverMagenta,
      _particleBudget(40),
      speed: 150,
    );
  }

  /// Level swap: a gentle transition wave. It does NOT clear existing effects —
  /// clearing would erase the success/fever choreography of the very equation
  /// that completed the level (they are transient and fade out on their own).
  void playLevelUp() {
    final HexMetrics? m = _metrics;
    if (m == null || _feel.reducedMotion) {
      return;
    }
    _effects.wave(
      m.centerOf(const AxialCoordinate(0, 0)),
      AppColors.neonBlue,
      maxRadius: m.hexSize * 5,
    );
  }

  int _particleBudget(int base) {
    if (_feel.reducedMotion) {
      return 0;
    }
    return (base * _feel.particleIntensity).round().clamp(0, base);
  }

  // ----- pointer forwarding (called by the Flutter GestureDetector) -----

  void pressAt(Offset localPosition) {
    final HexMetrics? m = _metrics;
    if (m == null) {
      return;
    }
    final AxialCoordinate coord = m.roundToCell(localPosition);
    _lastForwarded = coord;
    controller.pressCell(coord);
  }

  void extendAt(Offset localPosition) {
    final HexMetrics? m = _metrics;
    if (m == null) {
      return;
    }
    final AxialCoordinate target = m.roundToCell(localPosition);
    final AxialCoordinate? from = _lastForwarded;
    if (from == null) {
      _lastForwarded = target;
      controller.extendToCell(target);
      return;
    }
    // Fill in every cell along the line so a fast swipe never skips one; each
    // step is still validated by the controller's adjacency/no-repeat rules.
    for (final AxialCoordinate cell in HexMetrics.line(from, target).skip(1)) {
      controller.extendToCell(cell);
    }
    _lastForwarded = target;
  }

  void release() {
    _lastForwarded = null;
    controller.release();
  }

  /// Pointer/gesture cancelled: abort the selection without validating it.
  void cancel() {
    _lastForwarded = null;
    controller.cancelSelection();
  }

  // ----- rendering -----

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final HexMetrics? m = _metrics;
    if (m == null) {
      return;
    }

    // Shake translates the whole board + effects together so nothing drifts.
    final Offset shake = _effects.shakeOffset;
    canvas.save();
    if (shake != Offset.zero) {
      canvas.translate(shake.dx, shake.dy);
    }
    _renderBoard(canvas, m);
    _effects.render(canvas);
    canvas.restore();
  }

  void _renderBoard(Canvas canvas, HexMetrics m) {
    final bool fever = controller.notifier.value.feverActive;
    final Color energyColor = fever
        ? AppColors.feverMagenta
        : AppColors.neonBlue;
    // Neon glow strength is dialable for accessibility (never below a legible
    // floor so selection stays visible).
    final double glow = _feel.neonIntensity.clamp(0.35, 1.0);
    final List<AxialCoordinate> path = controller.path;
    final Set<AxialCoordinate> selected = path.toSet();

    for (final BoardCell cell in controller.board.cells) {
      final bool isSelected = selected.contains(cell.coord);
      final Path hex = Path()..addPolygon(m.cornersOf(cell.coord), true);

      canvas.drawPath(
        hex,
        Paint()
          ..style = PaintingStyle.fill
          ..color = isSelected
              ? energyColor.withValues(alpha: 0.16 * glow)
              : AppColors.inactiveCell,
      );
      canvas.drawPath(
        hex,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? AppStroke.medium : AppStroke.thin
          ..color = isSelected
              ? energyColor.withValues(alpha: glow)
              : AppColors.inactiveBorder,
      );

      // Numbers and operators stay white in every state for readability.
      _paintContent(canvas, m, cell, AppColors.primaryText);
    }

    if (path.length >= 2) {
      final Paint line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppStroke.thick
        ..strokeCap = StrokeCap.round
        ..color = energyColor.withValues(alpha: glow);
      final Path poly = Path()
        ..moveTo(m.centerOf(path.first).dx, m.centerOf(path.first).dy);
      for (int i = 1; i < path.length; i++) {
        poly.lineTo(m.centerOf(path[i]).dx, m.centerOf(path[i]).dy);
      }
      canvas.drawPath(poly, line);
    }
  }

  void _paintContent(Canvas canvas, HexMetrics m, BoardCell cell, Color color) {
    final String glyph = _glyphFor(cell);
    final TextPainter tp = _textCache.putIfAbsent(
      '$glyph|${color.toARGB32()}',
      () {
        final TextPainter painter = TextPainter(
          text: TextSpan(
            text: glyph,
            style: AppTypography.cellNumber.copyWith(color: color),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        return painter;
      },
    );
    final Offset center = m.centerOf(cell.coord);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  static String _glyphFor(BoardCell cell) {
    switch (cell.kind) {
      case CellKind.number:
        return cell.value.toString();
      case CellKind.equals:
        return '=';
      case CellKind.operator:
        switch (cell.operator!) {
          case Operator.add:
            return '+';
          case Operator.subtract:
            return '−'; // minus sign
          case Operator.multiply:
            return '×'; // multiplication sign
          case Operator.divide:
            return '÷'; // division sign
        }
    }
  }
}
