import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/components/buttons/button_size.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A primary icon button for Nasiko UI.
///
/// This is a high-emphasis icon-only button with brand color fill.
/// Supports two sizes: large and small.
class PrimaryIconButton extends StatelessWidget {
  const PrimaryIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = NasikoButtonSize.large,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The icon to display on the button.
  final IconData icon;

  /// The size of the button. Defaults to [NasikoButtonSize.large].
  final NasikoButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final iconSizes = context.iconSize;

    final double padding;
    final double iconSize;
    final double borderRadius;

    switch (size) {
      case NasikoButtonSize.large:
        padding = spacing.s16;
        iconSize = iconSizes.l;
        borderRadius = radii.r10;
        break;
      case NasikoButtonSize.medium:
        padding = spacing.s12;
        iconSize = iconSizes.m;
        borderRadius = radii.r8;
        break;
      case NasikoButtonSize.small:
        padding = spacing.s8;
        iconSize = iconSizes.s;
        borderRadius = radii.r8;
        break;
    }

    final style = ButtonStyle(
      // --- Padding ---
      padding: WidgetStateProperty.all(EdgeInsets.all(padding)),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color ---
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
        return colors.backgroundBrand;
      }),

      // --- Foreground Color (Icon) ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        return colors.foregroundOnAction;
      }),

      // --- Shape & Focus Ring ---
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        BorderSide borderSide = BorderSide.none;

        if (states.contains(WidgetState.focused)) {
          borderSide = BorderSide(
            color: colors.borderSecondary,
            width: spacing.s2,
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
      child: Icon(icon, size: iconSize, color: null),
    );
  }
}
