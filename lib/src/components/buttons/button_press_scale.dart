// lib/src/components/buttons/button_press_scale.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Shared press micro-feedback wrapper for Nasiko buttons.
///
/// Scales its child from 1.0 to 0.98 while a pointer is down, using the
/// motion tokens (`context.motion.pressed` / `context.motion.enter`).
/// Pointer events are only observed via a [Listener] with
/// [HitTestBehavior.translucent], so the wrapped button's own gesture
/// handling is untouched.
///
/// Disabled buttons ([enabled] == false) and reduced-motion environments
/// render without any scale change.
///
/// Internal to the package: intentionally not exported from `buttons.dart`.
class ButtonPressScale extends StatefulWidget {
  const ButtonPressScale({
    super.key,
    required this.enabled,
    required this.child,
  });

  /// Whether the wrapped button is interactive (`onPressed != null`).
  final bool enabled;

  /// The button to wrap.
  final Widget child;

  @override
  State<ButtonPressScale> createState() => _ButtonPressScaleState();
}

class _ButtonPressScaleState extends State<ButtonPressScale> {
  static const double _pressedScale = 0.98;

  bool _pressed = false;

  @override
  void didUpdateWidget(ButtonPressScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _pressed) {
      _pressed = false;
    }
  }

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;
    final reduceMotion = NasikoMotionTheme.reduceMotion(context);
    final scale = _pressed && widget.enabled && !reduceMotion
        ? _pressedScale
        : 1.0;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: scale,
        duration: motion.resolve(context, motion.pressed),
        curve: motion.enter,
        child: widget.child,
      ),
    );
  }
}
