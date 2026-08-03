import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A design-system tooltip that wraps Flutter's built-in [Tooltip] with
/// Nasiko tokens: dark overlay background, white body-tertiary text, and
/// r8 rounded corners.
///
/// Shows on hover (desktop/web) or long-press (touch) after [waitDuration].
/// Fades in via [Tooltip]'s built-in 150ms fade — matching the design
/// system's `motion.fast` token (the framework does not expose the fade
/// duration publicly).
///
/// ```dart
/// NasikoTooltip(
///   message: 'Helpful context',
///   child: Text('Hover me'),
/// )
/// ```
class NasikoTooltip extends StatelessWidget {
  const NasikoTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = true,
    this.waitDuration = const Duration(milliseconds: 300),
  });

  final String message;
  final Widget child;

  /// When `true` (default) the tooltip floats below the target; set to `false`
  /// to prefer placement above.
  final bool preferBelow;

  final Duration waitDuration;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;

    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      waitDuration: waitDuration,
      textStyle: typography.bodyPrimary.copyWith(
        color: colors.foregroundConstantWhite,
        fontStyle: FontStyle.normal,
        height: 1.4,
      ),
      decoration: BoxDecoration(
        color: colors.foregroundConstantBlack,
        borderRadius: BorderRadius.circular(radii.r8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s12,
        vertical: spacing.s8,
      ),
      child: child,
    );
  }
}
