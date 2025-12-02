// lib/src/components/chip/chip.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

import 'chip_variant.dart';

/// A chip component that can be actionable (with delete) or non-actionable.
///
/// Chips are compact elements that represent an input, attribute, or action.
/// They can display a leading icon, label text, and an optional trailing
/// delete action.
///
/// There are two visual variants:
/// - [NasikoChipVariant.neutral] - Gray background for default/unselected state
/// - [NasikoChipVariant.brand] - Yellow/brand background for selected state
class NasikoChip extends StatelessWidget {
  const NasikoChip({
    super.key,
    required this.label,
    this.leadingIcon,
    this.onTap,
    this.onDelete,
    this.variant = NasikoChipVariant.neutral,
    this.enabled = true,
  });

  /// The text label displayed on the chip.
  final String label;

  /// An optional icon to display before the label.
  final IconData? leadingIcon;

  /// Callback when the chip is tapped.
  /// If `null` and [onDelete] is also `null`, the chip is non-actionable.
  final VoidCallback? onTap;

  /// Callback when the delete/remove icon is tapped.
  /// If `null`, no delete icon is shown (non-actionable chip).
  final VoidCallback? onDelete;

  /// The visual style variant of the chip.
  /// Defaults to [NasikoChipVariant.neutral].
  final NasikoChipVariant variant;

  /// Whether the chip is enabled.
  /// When `false`, the chip appears disabled and ignores interactions.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    // Determine colors based on variant and enabled state
    final Color backgroundColor;
    final Color hoverColor;
    final Color pressedColor;
    final Color foregroundColor;
    final Color borderColor;

    if (!enabled) {
      backgroundColor = colors.backgroundDisabled;
      hoverColor = colors.backgroundDisabled;
      pressedColor = colors.backgroundDisabled;
      foregroundColor = colors.foregroundDisabled;
      borderColor = colors.borderDisabled;
    } else {
      switch (variant) {
        case NasikoChipVariant.neutral:
          backgroundColor = colors.backgroundGroup;
          hoverColor = colors.backgroundSurface;
          pressedColor = colors.backgroundSurfaceActive;
          foregroundColor = colors.foregroundPrimary;
          borderColor = colors.borderPrimary;
          break;
        case NasikoChipVariant.brand:
          backgroundColor = colors.backgroundSecondaryBrand;
          hoverColor = colors.backgroundSecondaryBrandHover;
          pressedColor = colors.backgroundSecondaryBrandActive;
          foregroundColor = colors.foregroundPrimary;
          borderColor = colors.borderSecondary;
          break;
      }
    }

    final isActionable = onTap != null || onDelete != null;

    Widget chipContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s12,
        vertical: spacing.s8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999), // Pill shape
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Leading Icon
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: iconSizes.s, color: foregroundColor),
            SizedBox(width: spacing.s8),
          ],

          // Label
          Text(
            label,
            style: typography.bodyTertiaryBold.copyWith(color: foregroundColor),
          ),

          // Delete Icon (only for actionable chips)
          if (onDelete != null) ...[
            SizedBox(width: spacing.s8),
            GestureDetector(
              onTap: enabled ? onDelete : null,
              child: Icon(
                Icons.remove,
                size: iconSizes.s,
                color: foregroundColor,
              ),
            ),
          ],
        ],
      ),
    );

    // Wrap with interaction handlers if actionable
    if (isActionable && enabled) {
      return _InteractiveChip(
        onTap: onTap,
        backgroundColor: backgroundColor,
        hoverColor: hoverColor,
        pressedColor: pressedColor,
        borderColor: borderColor,
        child: chipContent,
      );
    }

    return chipContent;
  }
}

/// Internal widget to handle hover and press states for chips.
class _InteractiveChip extends StatefulWidget {
  const _InteractiveChip({
    required this.child,
    required this.backgroundColor,
    required this.hoverColor,
    required this.pressedColor,
    required this.borderColor,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color hoverColor;
  final Color pressedColor;
  final Color borderColor;

  @override
  State<_InteractiveChip> createState() => _InteractiveChipState();
}

class _InteractiveChipState extends State<_InteractiveChip> {
  bool _isHovered = false;
  bool _isPressed = false;

  Color get _currentColor {
    if (_isPressed) return widget.pressedColor;
    if (_isHovered) return widget.hoverColor;
    return widget.backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s8,
          ),
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: widget.borderColor, width: 1),
          ),
          child: (widget.child as Container).child,
        ),
      ),
    );
  }
}
