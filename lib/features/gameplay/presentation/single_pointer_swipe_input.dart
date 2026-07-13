import 'package:flutter/widgets.dart';

/// A raw, single-pointer input surface for hex swipes.
///
/// Unlike a pan recognizer this accepts the first cell on pointer-down instead
/// of waiting for touch slop. Additional fingers are ignored until the active
/// pointer ends or is cancelled, keeping a run's chain deterministic.
class SinglePointerSwipeInput extends StatefulWidget {
  const SinglePointerSwipeInput({
    required this.onDown,
    required this.onMove,
    required this.onUp,
    required this.onCancel,
    this.enabled = true,
    this.child,
    super.key,
  });

  final ValueChanged<Offset> onDown;
  final ValueChanged<Offset> onMove;
  final VoidCallback onUp;
  final VoidCallback onCancel;
  final bool enabled;
  final Widget? child;

  @override
  State<SinglePointerSwipeInput> createState() =>
      _SinglePointerSwipeInputState();
}

class _SinglePointerSwipeInputState extends State<SinglePointerSwipeInput> {
  int? _activePointer;

  @override
  void didUpdateWidget(SinglePointerSwipeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled && _activePointer != null) {
      _activePointer = null;
      widget.onCancel();
    }
  }

  void _handleDown(PointerDownEvent event) {
    if (!widget.enabled || _activePointer != null) {
      return;
    }
    _activePointer = event.pointer;
    widget.onDown(event.localPosition);
  }

  void _handleMove(PointerMoveEvent event) {
    if (widget.enabled && event.pointer == _activePointer) {
      widget.onMove(event.localPosition);
    }
  }

  void _handleUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) {
      return;
    }
    _activePointer = null;
    widget.onUp();
  }

  void _handleCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) {
      return;
    }
    _activePointer = null;
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleDown,
      onPointerMove: _handleMove,
      onPointerUp: _handleUp,
      onPointerCancel: _handleCancel,
      child: widget.child ?? const SizedBox.expand(),
    );
  }
}
