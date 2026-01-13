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
      child: InkWell(
        onTap: widget.isDisabled ? null : widget.onTap,
        onHover: (val) => setState(() => _isHovering = val),
        borderRadius: BorderRadius.circular(radii.r4),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radii.r4),
            border: Border.all(color: borderColor, width: borderWidths.w1),
          ),
          padding: EdgeInsets.symmetric(
            vertical: spacing.s8h,
            horizontal: spacing.s12w,
          ),
          child: Row(
            children: [
              // 1. Indentation (Hierarchy)
              SizedBox(width: widget.indentLevel * spacing.s24w),

              // 2. Expand/Collapse Chevron
              if (widget.hasChildren)
                InkWell(
                  onTap: widget.isDisabled ? null : widget.onToggleExpand,
                  borderRadius: BorderRadius.circular(radii.r4),
                  child: Icon(
                    widget.isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: iconSizes.s,
                    color: colors.foregroundIconPrimary,
                  ),
                )
              else
                SizedBox(width: spacing.s20w), // Placeholder for alignment

              SizedBox(width: spacing.s12w),

              // 3. Avatar (Image)
              if (widget.imageUrl != null) ...[
                NasikoAvatar(
                  size: NasikoAvatarSize.medium, // Matches design (~32px)
                  imageUrl: widget.imageUrl,
                ),
                SizedBox(width: spacing.s12w),
              ],

              // 4. Leading Icon (The Hexagon)
              if (widget.leadingIcon != null) ...[
                HugeIcon(
                  icon: widget.leadingIcon!,
                  size: iconSizes.s,
                  color: colors.foregroundPrimary,
                ),
                SizedBox(width: spacing.s12w),
              ],

              // 5. Title
              Flexible(
                child: Text(
                  widget.title,
                  style: typography.bodySecondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 6. Status Dot
              if (widget.showStatusDot) ...[
                SizedBox(width: spacing.s12w),
                Container(
                  width: spacing.s8r,
                  height: spacing.s8r,
                  decoration: BoxDecoration(
                    color: colors.foregroundSuccess, // Green
                    shape: BoxShape.circle,
                  ),
                ),
              ],

              SizedBox(width: spacing.s12w),

              // 7. Badge (e.g., 1.85s)
              if (widget.badgeLabel != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s8w,
                    vertical: spacing.s4h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radii.r4),
                    border: Border.all(
                      color: colors.borderPrimary,
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
                          color: colors.foregroundIconPrimary,
                        ),
                        SizedBox(width: spacing.s8w),
                      ],
                      Text(widget.badgeLabel!, style: typography.bodyTertiary),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
