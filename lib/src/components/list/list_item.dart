// lib/src/components/list/nasiko_list_item.dart

import 'package:flutter/material.dart';
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
  final IconData? leadingIcon;

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
  final IconData? badgeIcon;

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

    // --- Determine Styles based on State ---
    Color backgroundColor = Colors.transparent;
    Color borderColor = Colors.transparent;

    if (widget.isDisabled) {
      backgroundColor = colors.backgroundDisabled.withValues(
        alpha: 0.1,
      ); // Subtle disabled bg
    } else if (widget.isSelected) {
      // Matches the yellow style in your screenshot
      backgroundColor = colors.backgroundSecondaryBrand; // yellow/100
      borderColor = colors.borderSecondary; // yellow/600
    } else if (_isHovering) {
      backgroundColor = colors.backgroundSurfaceHover; // neutral/200
    }

    final double opacity = widget.isDisabled ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.s2.h),
        child: InkWell(
          onTap: widget.isDisabled ? null : widget.onTap,
          onHover: (val) => setState(() => _isHovering = val),
          borderRadius: BorderRadius.circular(radii.r8.r),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radii.r8.r),
              border: Border.all(color: borderColor, width: borderWidths.w1.w),
            ),
            padding: EdgeInsets.symmetric(
              vertical: spacing.s8.h,
              horizontal: spacing.s8.w,
            ),
            child: Row(
              children: [
                // 1. Indentation (Hierarchy)
                SizedBox(width: widget.indentLevel * spacing.s24.w),

                // 2. Expand/Collapse Chevron
                if (widget.hasChildren)
                  InkWell(
                    onTap: widget.isDisabled ? null : widget.onToggleExpand,
                    borderRadius: BorderRadius.circular(radii.r4.r),
                    child: Icon(
                      widget.isExpanded
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_right_rounded,
                      size: iconSizes.s.r,
                      color: colors.foregroundSecondary,
                    ),
                  )
                else
                  SizedBox(width: spacing.s20.w), // Placeholder for alignment

                SizedBox(width: spacing.s8.w),

                // 3. Avatar (Image)
                if (widget.imageUrl != null) ...[
                  NasikoAvatar(
                    size: NasikoAvatarSize.small, // Matches design (~32px)
                    imageUrl: widget.imageUrl,
                  ),
                  SizedBox(width: spacing.s8.w),
                ],

                // 4. Leading Icon (The Hexagon)
                if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: iconSizes.m.r,
                    color: colors.foregroundPrimary,
                  ),
                  SizedBox(width: spacing.s8.w),
                ],

                // 5. Title
                Expanded(
                  child: Text(
                    widget.title,
                    style: typography.bodyPrimary.copyWith(
                      color: colors.foregroundPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 6. Status Dot
                if (widget.showStatusDot) ...[
                  SizedBox(width: spacing.s8.w),
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: colors.backgroundSuccess, // Green
                      shape: BoxShape.circle,
                    ),
                  ),
                ],

                SizedBox(width: spacing.s12.w),

                // 7. Badge (e.g., 1.85s)
                if (widget.badgeLabel != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.s8.w,
                      vertical: spacing.s2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.backgroundSurface, // neutral/100
                      borderRadius: BorderRadius.circular(radii.r4.r),
                      border: Border.all(
                        color: colors.borderPrimary,
                        width: borderWidths.w1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.badgeIcon != null) ...[
                          Icon(
                            widget.badgeIcon,
                            size: 12.r, // Tiny icon
                            color: colors.foregroundSecondary,
                          ),
                          SizedBox(width: spacing.s4.w),
                        ],
                        Text(
                          widget.badgeLabel!,
                          style: typography.caption.copyWith(
                            color: colors.foregroundSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.s8.w),
                ],

                // 8. Trailing Dropdown Arrow (Static in design)
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: iconSizes.s.r,
                  color: colors.foregroundSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
