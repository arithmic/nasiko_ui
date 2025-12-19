import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// The tertiary call-to-action button for Nasiko UI.
///
/// This is a medium-emphasis button that uses an outlined style with the 'brand' color.
/// It should be used for tertiary actions on a screen.
class TertiaryButton extends StatelessWidget {
  const TertiaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.size = NasikoButtonSize.medium,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The text label displayed on the button.
  final String label;

  /// An optional icon to display before the label.
  final HugeIconsType? leadingIcon;

  /// An optional icon to display after the label.
  final HugeIconsType? trailingIcon;

  /// The size of the button. Defaults to [NasikoButtonSize.medium].
  final NasikoButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final iconSizes = context.iconSize;
    final borderWidths = context.borderWidth;

    final EdgeInsets padding;
    final TextStyle textStyle;
    final double iconSize;
    final double borderRadius;
    final double iconSpacing;
    final double minHeight;

    switch (size) {
      case NasikoButtonSize.large:
        padding = EdgeInsets.symmetric(
          vertical: spacing.s20,
          horizontal: spacing.s24,
        );
        textStyle = typography.buttonPrimary;
        iconSize = iconSizes.l; // 28px
        borderRadius = radii.r10; // 10px radius
        iconSpacing = spacing.s12; // 12px spacing
        minHeight = 68;
        break;
      case NasikoButtonSize.medium:
        padding = EdgeInsets.symmetric(
          vertical: spacing.s12,
          horizontal: spacing.s16,
        );
        textStyle = typography.buttonSecondary;
        iconSize = iconSizes.s; // 20px
        borderRadius = radii.r8; // 8px radius
        iconSpacing = spacing.s8; // 8px spacing
        minHeight = 44;
        break;
      case NasikoButtonSize.small:
        padding = EdgeInsets.symmetric(
          vertical: spacing.s8,
          horizontal: spacing.s12,
        );
        textStyle = typography.buttonSecondary;
        iconSize = iconSizes.s; // 20px
        borderRadius = radii.r8; // 8px radius
        iconSpacing = spacing.s8; // 8px spacing
        minHeight = 36;
        break;
    }

    final style = ButtonStyle(
      // --- Base Properties ---
      padding: WidgetStateProperty.all(padding),
      minimumSize: WidgetStateProperty.all(Size(0, minHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStateProperty.all(textStyle),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color (Default outline, Hover filled, Disabled filled light) ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.transparent;
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.transparent;
        }
        if (states.contains(WidgetState.pressed)) {
          return Colors.transparent;
        }
        // Default state - transparent
        return Colors.transparent;
      }),

      // --- Foreground Color (Text & Icons) ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.foregroundIconHover;
        }
        // Default, Focus, Pressed
        return colors.foregroundPrimary;
      }),

      // --- Shape & Border ---
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        BorderSide borderSide;

        if (states.contains(WidgetState.disabled)) {
          borderSide = BorderSide(
            color: colors.borderDisabled,
            width: borderWidths.w1,
          );
        } else if (states.contains(WidgetState.hovered)) {
          borderSide = BorderSide(
            color: Colors.transparent,
            width: borderWidths.w1,
          );
        } else {
          // Default, Focus states
          borderSide = BorderSide(
            color: colors.borderSecondary,
            width: borderWidths.w1,
          );
        }

        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderSide,
        );
      }),
    );

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Leading Icon
          if (leadingIcon != null) ...[
            HugeIcon(icon: leadingIcon!, size: iconSize),
            SizedBox(width: iconSpacing),
          ],

          // Label
          Text(label),

          // Trailing Icon
          if (trailingIcon != null) ...[
            SizedBox(width: iconSpacing),
            HugeIcon(icon: trailingIcon!, size: iconSize),
          ],
        ],
      ),
    );
  }
}
