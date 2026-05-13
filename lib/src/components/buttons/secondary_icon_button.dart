import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';
import 'package:nasiko_ui/src/tokens/types.dart';

import 'button_layout.dart';

/// A secondary icon button for Nasiko UI.
///
/// This is a medium-emphasis icon-only button with outline style.
/// Supports three sizes: large, medium and small.
class SecondaryIconButton extends StatelessWidget {
  const SecondaryIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = NasikoButtonSize.medium,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The icon to display on the button.
  final HugeIconsType icon;

  /// The size of the button. Defaults to [NasikoButtonSize.medium].
  final NasikoButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final layout = iconButtonLayout(context, size);
    final borderRadius = radii.r10;

    final style = ButtonStyle(
      padding: WidgetStateProperty.all(layout.padding),
      minimumSize: WidgetStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.backgroundDisabled;
        }
        return Colors.transparent;
      }),

      // --- Foreground Color (Icon) ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return colors.foregroundIconHover;
        }
        return colors.foregroundIconPrimary;
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
            color: colors.borderHover,
            width: borderWidths.w1,
          );
        } else if (states.contains(WidgetState.focused)) {
          borderSide = BorderSide(
            color: colors.borderSecondary,
            width: borderWidths.w2,
          );
        } else {
          borderSide = BorderSide(
            color: colors.borderPrimary,
            width: borderWidths.w1,
          );
        }

        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderSide,
        );
      }),

      overlayColor: WidgetStatePropertyAll(Colors.transparent),
    );

    return IconButton(
      onPressed: onPressed,
      style: style,
      icon: HugeIcon(icon: icon, size: layout.iconSize),
    );
  }
}
