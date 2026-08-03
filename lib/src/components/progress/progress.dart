// lib/src/components/progress/progress.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A horizontal progress bar.
///
/// - Determinate: pass [value] in `0..1`. Value changes animate at
///   `context.motion.base` / `context.motion.move` (reduced-motion aware).
/// - Indeterminate: pass `null` to show a looping [LinearProgressIndicator]
///   themed with Nasiko colors.
///
/// The fill uses `context.colors.foregroundPrimary` — the same color
/// primary buttons use for their background — over a
/// `backgroundSurface` track, clipped to a pill.
///
/// ```dart
/// NasikoProgress(value: 0.6)      // determinate, 60%
/// const NasikoProgress()          // indeterminate
/// ```
class NasikoProgress extends StatelessWidget {
  const NasikoProgress({super.key, this.value, this.minHeight})
      : assert(
          value == null || (value >= 0.0 && value <= 1.0),
          'value must be null (indeterminate) or within 0.0..1.0.',
        );

  /// Progress in `0..1`, or `null` for an indeterminate bar.
  final double? value;

  /// Bar thickness. Defaults to `context.spacing.s4h`.
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final height = minHeight ?? context.spacing.s4h;
    final borderRadius = BorderRadius.circular(context.radius.r40);

    if (value == null) {
      return Semantics(
        label: 'Loading',
        child: ClipRRect(
          borderRadius: borderRadius,
          child: LinearProgressIndicator(
            minHeight: height,
            color: colors.foregroundPrimary,
            backgroundColor: colors.backgroundSurface,
          ),
        ),
      );
    }

    final clamped = value!.clamp(0.0, 1.0);

    return Semantics(
      value: '${(clamped * 100).round()}%',
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          height: height,
          color: colors.backgroundSurface,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: clamped),
            duration: motion.resolve(context, motion.base),
            curve: motion.move,
            builder: (context, t, _) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: t,
                  child: ColoredBox(color: colors.foregroundPrimary),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
