// lib/src/components/chip/chip.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A chip component that can be actionable (with delete) or non-actionable.
///
/// Chips are compact elements that represent an input, attribute, or action.
/// They can display a leading icon, label text, and an optional trailing
/// delete action.
///
/// There are two visual variants:
/// - [NasikoChipVariant.neutral] - Gray background for default/unselected state
/// - [NasikoChipVariant.brand] - Yellow/brand background for selected state
///
/// There are two size variants:
/// - [NasikoChipSize.large] - Uses bodySecondary typography with standard padding
/// - [NasikoChipSize.small] - Uses bodyTertiary typography with compact padding
///
/// There are two shape variants:
/// - [NasikoChipShape.rectangle] - Subtly rounded rectangular chip
/// - [NasikoChipShape.rounded] - Rounded chip with 32px border radius
class NasikoChip extends StatelessWidget {
  const NasikoChip({
    super.key,
    required this.label,
    this.leadingIcon,
    this.onTap,
    this.onDelete,
    this.variant = NasikoChipVariant.neutral,
    this.size = NasikoChipSize.small,
    this.shape = NasikoChipShape.rectangle,
    this.enabled = true,
    this.borderColor,
  });

  /// The text label displayed on the chip.
  final String label;

  /// An optional icon to display before the label.a
  final HugeIconsType? leadingIcon;

  /// Callback when the chip is tapped.
  /// If `null` and [onDelete] is also `null`, the chip is non-actionable.
  final VoidCallback? onTap;

  /// Callback when the delete/remove icon is tapped.
  /// If `null`, no delete icon is shown (non-actionable chip).
  final VoidCallback? onDelete;

  /// The visual style variant of the chip.
  /// Defaults to [NasikoChipVariant.neutral].
  final NasikoChipVariant variant;

  /// The size variant of the chip.
  /// Defaults to [NasikoChipSize.large].
  final NasikoChipSize size;

  /// The shape variant of the chip.
  /// Defaults to [NasikoChipShape.rectangle].
  final NasikoChipShape shape;

  /// Whether the chip is enabled.
  /// When `false`, the chip appears disabled and ignores interactions.
  final bool enabled;

  /// The color of the chip's border. Defaults to a [NasikoColorTheme.borderPrimary] color.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    // Determine colors based on variant and enabled state
    final Color backgroundColor;
    final Color hoverColor;
    final Color pressedColor;
    final Color foregroundColor;
    if (!enabled) {
      backgroundColor = colors.backgroundBase;
      hoverColor = colors.backgroundDisabled;
      pressedColor = colors.backgroundDisabled;
      foregroundColor = colors.foregroundDisabled;
    } else {
      switch (variant) {
        case NasikoChipVariant.neutral:
          backgroundColor = colors.backgroundSurfaceHover;
          hoverColor = colors.backgroundSurfaceHover;
          pressedColor = colors.backgroundSurfaceActive;
          foregroundColor = colors.foregroundPrimary;
          break;
        case NasikoChipVariant.brand:
          backgroundColor = colors.backgroundSecondaryBrand;
          hoverColor = colors.backgroundSecondaryBrandHover;
          pressedColor = colors.backgroundSecondaryBrandActive;
          foregroundColor = colors.foregroundPrimary;
          break;
        case NasikoChipVariant.base:
          backgroundColor = colors.backgroundBase;
          hoverColor = colors.backgroundSurfaceHover;
          pressedColor = colors.backgroundSurfaceActive;
          foregroundColor = colors.foregroundPrimary;
          break;
        case NasikoChipVariant.tag:
          backgroundColor = colors.backgroundInformation.withValues(alpha: 0.64);
          hoverColor = colors.backgroundInformation.withValues(alpha: 0.64);
          pressedColor = colors.backgroundSurfaceActive;
          foregroundColor = colors.foregroundPrimary;
          break;
      }
    }

    final isActionable = onTap != null || onDelete != null;
    final borderRadius = BorderRadius.circular(
      shape == NasikoChipShape.rounded ? radii.r40 : radii.r8,
    );

    Widget chipContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s12,
        vertical: spacing.s8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color:variant == NasikoChipVariant.tag ? Colors.transparent : borderColor ?? colors.borderPrimary,
          strokeAlign: BorderSide.strokeAlignOutside,
          width: borderWidths.w1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Leading Icon
          if (leadingIcon != null) ...[
            HugeIcon(
              icon: leadingIcon!,
              size: size == NasikoChipSize.small ? iconSizes.xs : iconSizes.s,
              color: foregroundColor,
            ),
            SizedBox(width: spacing.s4),
          ],
          Text(
            label,
            style: size == NasikoChipSize.small
                ? typography.bodyTertiary.copyWith(height: 1.0)
                : typography.bodySecondary.copyWith(height: 1.0),
          ),

          // Delete Icon (only for actionable chips)
          if (onDelete != null) ...[
            SizedBox(width: spacing.s4),
            GestureDetector(
              onTap: enabled ? onDelete : null,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMinusSign,
                size: size == NasikoChipSize.small ? iconSizes.xs : iconSizes.s,
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
        size: size,
        borderRadius: borderRadius,
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
    required this.size,
    required this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color hoverColor;
  final Color pressedColor;
  final NasikoChipSize size;
  final BorderRadius borderRadius;

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
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
