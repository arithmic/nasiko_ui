import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_layout.dart';

/// A primary icon button for Nasiko UI.
///
/// This is a high-emphasis icon-only button with brand color fill.
/// Supports three sizes: large, medium and small.
class PrimaryIconButton extends StatelessWidget {
  const PrimaryIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = NasikoButtonSize.large,
    this.isLoading,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The icon to display on the button.
  final HugeIconsType icon;

  /// The size of the button. Defaults to [NasikoButtonSize.large].
  final NasikoButtonSize size;

  final bool? isLoading;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final layout = iconButtonLayout(context, size);
    final borderRadius = radii.r8;

    final style = ButtonStyle(
      padding: WidgetStateProperty.all(layout.padding),
      minimumSize: WidgetStateProperty.all(Size.zero),
      fixedSize: WidgetStateProperty.all(Size.square(layout.minHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.backgroundDisabled;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.backgroundSecondaryBrandHover;
        }
        return colors.backgroundSecondaryBrand;
      }),

      // --- Foreground Color (Icon) ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        return colors.foregroundIconPrimary;
      }),

      // --- Shape & Focus Ring ---
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        BorderSide borderSide = BorderSide.none;

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
            color: colors.borderSecondary,
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
      icon: (isLoading ?? false)
          ? SizedBox(
              width: layout.iconSize,
              height: layout.iconSize,
              child: CircularProgressIndicator(strokeWidth: borderWidths.w2),
            )
          : HugeIcon(icon: icon, size: layout.iconSize),
    );
  }
}
