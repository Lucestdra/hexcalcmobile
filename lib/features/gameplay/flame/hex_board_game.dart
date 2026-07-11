import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import '../../../core/design_system/design_system.dart';
import '../application/game_controller.dart';
import '../domain/domain.dart';
import 'hex_metrics.dart';

/// The Flame gameplay surface: renders the hex board and the selection path, and
/// drives the run clock from its update loop. Pointer input is captured by the
/// Flutter layer and forwarded through [pressAt] / [extendAt] / [release] using
/// the same [HexMetrics], so hit testing and rendering stay aligned.
class HexBoardGame extends FlameGame {
  HexBoardGame(this.controller);

  final GameController controller;

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

  // ----- rendering -----

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final HexMetrics? m = _metrics;
    if (m == null) {
      return;
    }

    final bool fever = controller.notifier.value.feverActive;
    final Color energyColor = fever
        ? AppColors.feverMagenta
        : AppColors.neonBlue;
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
              ? energyColor.withValues(alpha: 0.16)
              : AppColors.inactiveCell,
      );
      canvas.drawPath(
        hex,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? AppStroke.medium : AppStroke.thin
          ..color = isSelected ? energyColor : AppColors.inactiveBorder,
      );

      // Numbers and operators stay white in every state for readability.
      _paintContent(canvas, m, cell, AppColors.primaryText);
    }

    if (path.length >= 2) {
      final Paint line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppStroke.thick
        ..strokeCap = StrokeCap.round
        ..color = energyColor;
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
