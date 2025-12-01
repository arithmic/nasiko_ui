// lib/src/components/buttons/primary_button.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/components/buttons/button_size.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// The primary call-to-action button for Nasiko UI.
///
/// This is a high-emphasis button that uses the 'brand' color.
/// It should be used for the most important action on a screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
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
  final IconData? leadingIcon;

  /// An optional icon to display after the label.
  final IconData? trailingIcon;

  /// The size of the button. Defaults to [NasikoButtonSize.medium].
  final NasikoButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final iconSizes = context.iconSize;

    final EdgeInsets padding;
    final TextStyle textStyle;
    final double iconSize;
    final double borderRadius;
    // --- NEW: Added iconSpacing variable ---
    final double iconSpacing;

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
        break;
    }

    final style = ButtonStyle(
      // --- Base Properties ---
      padding: WidgetStateProperty.all(padding),
      textStyle: WidgetStateProperty.all(textStyle),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color (Handles Default, Hover, Disabled) ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.backgroundDisabled;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.backgroundBrandHover;
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.backgroundBrand;
        }
        // Default state
        return colors.backgroundBrand;
      }),

      // --- Foreground Color (Handles Default, Disabled) ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        // Default, Hover, Focus, Pressed
        return colors.foregroundOnAction;
      }),

      // --- Shape & Focus Ring ---
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        BorderSide borderSide = BorderSide.none;

        if (states.contains(WidgetState.focused)) {
          borderSide = BorderSide(
            color: colors.borderSecondary,
            width: spacing.s2,
            strokeAlign: BorderSide.strokeAlignOutside,
          );
        }

        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderSide,
        );
      }),
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Leading Icon
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: iconSize, color: null),
            SizedBox(width: iconSpacing),
          ],

          // Label
          Text(label),

          // Trailing Icon
          if (trailingIcon != null) ...[
            SizedBox(width: iconSpacing),
            Icon(trailingIcon, size: iconSize, color: null),
          ],
        ],
      ),
    );
  }
}
