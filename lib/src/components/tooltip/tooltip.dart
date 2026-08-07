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
    this.verticalOffset,
    this.waitDuration = const Duration(milliseconds: 300),
  });

  final String message;
  final Widget child;

  /// When `true` (default) the tooltip floats below the target; set to `false`
  /// to prefer placement above.
  final bool preferBelow;

  /// Distance from the target's vertical center to the tooltip, in logical
  /// px. `null` keeps the framework default (24). For a precise gap below a
  /// target of known height, pass `targetHeight / 2 + gap`.
  final double? verticalOffset;

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
      verticalOffset: verticalOffset,
      waitDuration: waitDuration,
      // Explicit (matches the framework default): keeps [message] exposed to
      // assistive technology as a semantics tooltip. The framework Tooltip
      // hosts no FocusNode of its own, so it never steals keyboard focus.
      excludeFromSemantics: false,
      // The dedicated inverse-overlay pair: near-black surface with light
      // text in the light theme, light surface with dark text in the dark
      // theme (12.34:1 / 9.96:1). A constant-black tooltip was invisible
      // against the dark theme's near-black canvas.
      textStyle: typography.bodyPrimary.copyWith(
        color: colors.foregroundInformationOverlay,
        fontStyle: FontStyle.normal,
        height: 1.4,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundInformationOverlay,
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
