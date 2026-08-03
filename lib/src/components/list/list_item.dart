// lib/src/components/list/nasiko_list_item.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A comprehensive list item component that supports hierarchy,
/// selection states, badges, and status indicators.
class NasikoListItem extends StatefulWidget {
  const NasikoListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.leadingIcon, // The hexagon icon in your design
    this.indentLevel = 0,
    this.isSelected = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.hasChildren = false,
    this.showStatusDot = false,
    this.badgeLabel,
    this.badgeIcon,
    this.onTap,
    this.onToggleExpand,
  });

  final String title;
  final String? subtitle;
  final String? imageUrl;
  final HugeIconsType? leadingIcon;

  /// The depth of the item in the tree (0 = root).
  /// Each level adds indentation.
  final int indentLevel;

  final bool isSelected;
  final bool isDisabled;

  /// Whether the arrow is pointing down (expanded) or right (collapsed).
  final bool isExpanded;

  /// If true, shows the expand/collapse arrow.
  final bool hasChildren;

  /// If true, shows a small green status dot.
  final bool showStatusDot;

  /// Text for the trailing badge (e.g. "1.85s").
  final String? badgeLabel;

  /// Icon for the trailing badge.
  final HugeIconsType? badgeIcon;

  final VoidCallback? onTap;
  final VoidCallback? onToggleExpand;

  @override
  State<NasikoListItem> createState() => _NasikoListItemState();
}

class _NasikoListItemState extends State<NasikoListItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;
    final motion = context.motion;

    // --- Determine Styles based on State ---
    Color backgroundColor = Colors.transparent;
    Color borderColor = Colors.transparent;

    if (widget.isDisabled) {
      backgroundColor = colors.backgroundDisabled;
      borderColor = colors.borderDisabled;
    } else if (widget.isSelected) {
      backgroundColor = colors.backgroundSecondaryBrand;
      borderColor = colors.borderSecondary;
    } else if (_isHovering) {
      borderColor = colors.borderSecondary;
    }

    return InkWell(
      onTap: widget.isDisabled ? null : widget.onTap,
      onHover: (val) => setState(() => _isHovering = val),
      borderRadius: BorderRadius.circular(radii.r4),
      child: AnimatedContainer(
        duration: motion.hover,
        curve: motion.enter,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radii.r4),
          border: Border.all(color: borderColor, width: borderWidths.w1),
        ),
        padding: EdgeInsets.symmetric(
          vertical: spacing.s8,
          horizontal: spacing.s12,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final indentWidth = (widget.indentLevel * spacing.s24).clamp(
              0.0,
              constraints.maxWidth * 0.4,
            );
            return Row(
              children: [
                // 1. Indentation (Hierarchy)
                if (widget.indentLevel > 0) SizedBox(width: indentWidth),

                // 2. Expand/Collapse Chevron
                if (widget.hasChildren)
                  InkWell(
                    onTap: widget.isDisabled ? null : widget.onToggleExpand,
                    borderRadius: BorderRadius.circular(radii.r4),
                    // Rotating the down chevron by -90deg reproduces the
                    // right chevron, so the toggle animates instead of
                    // swapping glyphs.
                    child: AnimatedRotation(
                      turns: widget.isExpanded ? 0 : -0.25,
                      duration: motion.resolve(context, motion.fast),
                      curve: motion.move,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: iconSizes.s,
                        color: widget.isDisabled
                            ? colors.foregroundDisabled
                            : colors.foregroundIconPrimary,
                      ),
                    ),
                  )
                else
                  SizedBox(width: spacing.s20), // Placeholder for alignment

                SizedBox(width: spacing.s12),

                // 3. Avatar (Image)
                if (widget.imageUrl != null) ...[
                  NasikoAvatar(
                    size: NasikoAvatarSize.medium, // Matches design (~32px)
                    imageUrl: widget.imageUrl,
                  ),
                  SizedBox(width: spacing.s12),
                ],

                // 4. Leading Icon (The Hexagon)
                if (widget.leadingIcon != null) ...[
                  HugeIcon(
                    icon: widget.leadingIcon!,
                    size: iconSizes.s,
                    color: widget.isDisabled
                        ? colors.foregroundDisabled
                        : colors.foregroundPrimary,
                  ),
                  SizedBox(width: spacing.s12),
                ],

                // 5. Title
                Expanded(
                  child: Text(
                    widget.title,
                    style: typography.bodySecondary.copyWith(
                      color: widget.isDisabled
                          ? colors.foregroundDisabled
                          : colors.foregroundPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 6. Status Dot
                if (widget.showStatusDot) ...[
                  SizedBox(width: spacing.s12),
                  Container(
                    width: spacing.s8,
                    height: spacing.s8,
                    decoration: BoxDecoration(
                      color: colors.foregroundSuccess, // Green
                      shape: BoxShape.circle,
                    ),
                  ),
                ],

                SizedBox(width: spacing.s12),

                // 7. Badge (e.g., 1.85s)
                if (widget.badgeLabel != null) ...[
                  AnimatedContainer(
                    duration: motion.hover,
                    curve: motion.enter,
                    padding: EdgeInsets.all(spacing.s4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radii.r4),
                      border: Border.all(
                        color: widget.isDisabled
                            ? colors.borderDisabled
                            : widget.isSelected
                            ? colors.borderSecondary
                            : colors.borderPrimary,
                        width: borderWidths.w1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.badgeIcon != null) ...[
                          HugeIcon(
                            icon: widget.badgeIcon!,
                            size: iconSizes.xs, // Tiny icon
                            color: widget.isDisabled
                                ? colors.foregroundDisabled
                                : colors.foregroundIconPrimary,
                          ),
                          SizedBox(width: spacing.s8),
                        ],
                        Text(
                          widget.badgeLabel!,
                          style: typography.bodySecondary.copyWith(
                            color: widget.isDisabled
                                ? colors.foregroundDisabled
                                : colors.foregroundPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
