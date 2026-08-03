// lib/src/components/empty/empty.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A centered empty-state placeholder for lists, tables, and panels that
/// have nothing to show: optional icon in a soft circular surface, a title,
/// an optional description, and an optional call-to-action.
///
/// ```dart
/// NasikoEmpty(
///   icon: HugeIcons.strokeRoundedInbox,
///   title: 'No invoices yet',
///   description: 'Invoices you create will show up here.',
///   action: PrimaryButton(label: 'Create invoice', onPressed: …),
/// )
/// ```
/// Enters with a subtle one-shot fade + rise at `context.motion.base`;
/// reduced-motion aware (renders immediately with no transition).
class NasikoEmpty extends StatelessWidget {
  const NasikoEmpty({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.action,
  });

  /// Optional icon shown above the title in a circular surface.
  final HugeIconsType? icon;

  /// Short headline describing the empty state.
  final String title;

  /// Optional supporting copy under the title.
  final String? description;

  /// Optional call-to-action (e.g. a NasikoButton) below the text.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final motion = context.motion;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon in a soft circular surface.
        if (icon != null) ...[
          Container(
            width: spacing.s48r,
            height: spacing.s48r,
            decoration: BoxDecoration(
              color: colors.backgroundSurface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: HugeIcon(
              icon: icon!,
              size: context.iconSize.m,
              color: colors.foregroundSecondary,
            ),
          ),
          SizedBox(height: spacing.s16h),
        ],

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: typography.bodyPrimaryBold.copyWith(
            color: colors.foregroundPrimary,
          ),
        ),

        // Description
        if (description != null) ...[
          SizedBox(height: spacing.s8h),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: typography.bodySecondary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
        ],

        // Action
        if (action != null) ...[
          SizedBox(height: spacing.s16h),
          action!,
        ],
      ],
    );

    // Subtle one-shot entrance: fade + slight rise. Paint-only, so layout
    // is identical once settled.
    final resolved = motion.resolve(context, motion.base);
    if (resolved == Duration.zero) return Center(child: content);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: resolved,
        curve: motion.enter,
        child: content,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, spacing.s4 * (1 - t)),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
