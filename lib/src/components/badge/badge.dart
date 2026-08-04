// lib/src/components/badge/badge.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Semantic intent of a [NasikoBadge], mapped onto the feedback color
/// tokens (`backgroundSuccess`/`foregroundSuccess`, etc.).
enum NasikoBadgeIntent {
  /// Neutral status — surface background, secondary text.
  neutral,

  /// Positive status: completed, active, healthy.
  success,

  /// Cautionary status: pending, degraded, expiring.
  warning,

  /// Negative status: failed, blocked, overdue.
  error,

  /// Informational status: new, beta, synced.
  info,
}

/// A small, non-interactive status pill.
///
/// ```dart
/// NasikoBadge(label: 'Active', intent: NasikoBadgeIntent.success)
/// ```
/// Colors animate at `context.motion.hover` when [intent] changes (a
/// decorative color fade — exempt from reduced-motion per the motion
/// theme's convention).
class NasikoBadge extends StatelessWidget {
  const NasikoBadge({
    super.key,
    required this.label,
    this.intent = NasikoBadgeIntent.neutral,
  });

  /// The short status text inside the pill.
  final String label;

  /// The semantic intent driving the badge's colors.
  final NasikoBadgeIntent intent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final motion = context.motion;

    final (Color background, Color foreground) = switch (intent) {
      NasikoBadgeIntent.neutral => (
        colors.backgroundSurface,
        colors.foregroundSecondary,
      ),
      NasikoBadgeIntent.success => (
        colors.backgroundSuccess,
        colors.foregroundSuccess,
      ),
      NasikoBadgeIntent.warning => (
        colors.backgroundWarning,
        colors.foregroundWarning,
      ),
      NasikoBadgeIntent.error => (
        colors.backgroundError,
        colors.foregroundError,
      ),
      NasikoBadgeIntent.info => (
        colors.backgroundInformation,
        colors.foregroundInformation,
      ),
    };

    return AnimatedContainer(
      duration: motion.hover,
      curve: motion.move,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s8w,
        vertical: spacing.s4h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(context.radius.r40),
      ),
      child: AnimatedDefaultTextStyle(
        duration: motion.hover,
        curve: motion.move,
        style: context.typography.bodyTertiaryBold.copyWith(color: foreground),
        child: Text(label),
      ),
    );
  }
}
