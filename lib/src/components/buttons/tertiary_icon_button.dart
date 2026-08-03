import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_layout.dart';
import 'button_press_scale.dart';

/// A tertiary icon button for Nasiko UI.
///
/// This is a low-emphasis icon-only button without an outline.
/// Supports three sizes: large, medium and small.
class TertiaryIconButton extends StatelessWidget {
  const TertiaryIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = NasikoButtonSize.large,
    this.statesController,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The icon to display on the button.
  final HugeIconsType icon;

  /// The size of the button. Defaults to [NasikoButtonSize.large].
  final NasikoButtonSize size;

  /// Optional external controller for driving widget states (e.g. hover,
  /// pressed) from outside the button — used when [AbsorbPointer] or similar
  /// blocks pointer events from reaching the button directly.
  final WidgetStatesController? statesController;

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
      animationDuration: context.motion.fast,
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.backgroundDisabled;
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.backgroundSecondaryBrand;
        }
        return Colors.transparent;
      }),

      // --- Foreground Color (Icon) ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.foregroundIconSecondary;
        }
        return colors.foregroundIconTertiary;
      }),

      // --- Shape & Border ---
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        BorderSide borderSide;

        if (states.contains(WidgetState.disabled)) {
          borderSide = BorderSide(
            color: colors.borderDisabled,
            width: borderWidths.w1,
          );
        } else if (states.contains(WidgetState.pressed)) {
          borderSide = BorderSide(
            color: Colors.transparent,
            width: borderWidths.w1,
          );
        } else if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          borderSide = BorderSide(
            color: colors.borderPrimary,
            width: borderWidths.w1,
          );
        } else {
          borderSide = BorderSide(
            color: Colors.transparent,
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

    final Widget button = IconButton(
      onPressed: onPressed,
      style: style,
      statesController: statesController,
      icon: HugeIcon(icon: icon),
      iconSize: layout.iconSize,
    );

    return ButtonPressScale(enabled: onPressed != null, child: button);
  }
}
