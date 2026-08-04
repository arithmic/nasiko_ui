// lib/src/components/spinner/spinner.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A [CircularProgressIndicator] that waits [delay] before fading in, so
/// fast responses never flash a spinner.
///
/// The fade-in runs at `context.motion.base` / `context.motion.enter` and is
/// reduced-motion aware (the spinner appears instantly after the delay).
///
/// ```dart
/// if (state.isLoading) const NasikoSpinner()
/// ```
class NasikoSpinner extends StatefulWidget {
  const NasikoSpinner({
    super.key,
    this.delay = const Duration(milliseconds: 150),
    this.size,
    this.strokeWidth,
    this.color,
    this.semanticLabel = 'Loading',
  });

  /// How long to wait before revealing the spinner. Pass [Duration.zero]
  /// to show it immediately.
  final Duration delay;

  /// Diameter of the spinner; `null` uses the indicator's intrinsic size.
  final double? size;

  /// Stroke width. Defaults to `context.borderWidth.w4`.
  final double? strokeWidth;

  /// Stroke color. Defaults to `context.colors.foregroundPrimary` — the
  /// same color primary buttons use for their background.
  final Color? color;

  /// Accessibility label announced for the spinner.
  final String semanticLabel;

  @override
  State<NasikoSpinner> createState() => _NasikoSpinnerState();
}

class _NasikoSpinnerState extends State<NasikoSpinner> {
  Timer? _timer;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _shown = true;
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) setState(() => _shown = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;

    final indicator = CircularProgressIndicator(
      strokeWidth: widget.strokeWidth ?? context.borderWidth.w4,
      color: widget.color ?? context.colors.foregroundPrimary,
    );

    return Semantics(
      label: widget.semanticLabel,
      child: AnimatedOpacity(
        opacity: _shown ? 1.0 : 0.0,
        duration: motion.resolve(context, motion.base),
        curve: motion.enter,
        child: widget.size != null
            ? SizedBox(
                width: widget.size,
                height: widget.size,
                child: indicator,
              )
            : indicator,
      ),
    );
  }
}
