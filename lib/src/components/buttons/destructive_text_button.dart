import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_layout.dart';
import 'button_press_scale.dart';

/// A destructive outlined button for Nasiko UI.
///
/// This is a medium-emphasis button that uses an outlined style with the 'error' color.
/// It should be used for destructive tertiary actions on a screen.
class DestructiveTextButton extends StatelessWidget {
  const DestructiveTextButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.size = NasikoButtonSize.large,
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

  /// The size of the button. Defaults to [NasikoButtonSize.large].
  final NasikoButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final layout = quietButtonLayout(context, size);
    final textStyle = switch (size) {
      NasikoButtonSize.large => typography.buttonPrimary,
      NasikoButtonSize.medium ||
      NasikoButtonSize.small => typography.buttonSecondary,
    };
    final borderRadius = radii.r8;

    final style = ButtonStyle(
      padding: WidgetStateProperty.all(layout.padding),
      fixedSize: WidgetStateProperty.all(Size.fromHeight(layout.minHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      animationDuration: context.motion.fast,
      textStyle: WidgetStateProperty.all(textStyle),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color (Default outline, Hover filled, Disabled filled light) ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        return colors.backgroundBase;
      }),

      // --- Foreground Color (Text & Icons) ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFFB91C1C); // red700 for hover
        }
        // Default, Focus, Pressed
        return colors.foregroundError;
      }),

      // --- Border ---
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
            color: colors.borderDisabled,
            width: borderWidths.w1,
          );
        } else if (states.contains(WidgetState.hovered)) {
          return BorderSide(
            color: const Color(0xFFB91C1C), // red700
            width: borderWidths.w1,
          );
        } else if (states.contains(WidgetState.focused)) {
          return BorderSide(color: colors.borderError, width: borderWidths.w2);
        } else {
          // Default, Focus states
          return BorderSide(color: colors.borderError, width: borderWidths.w1);
        }
      }),

      // --- Shape ---
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );

    final Widget button = OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Leading Icon
          if (leadingIcon != null) ...[
            HugeIcon(icon: leadingIcon!, size: layout.iconSize),
            SizedBox(width: layout.iconSpacing),
          ],

          // Label
          Text(label),

          // Trailing Icon
          if (trailingIcon != null) ...[
            SizedBox(width: layout.iconSpacing),
            HugeIcon(icon: trailingIcon!, size: layout.iconSize),
          ],
        ],
      ),
    );

    return ButtonPressScale(enabled: onPressed != null, child: button);
  }
}
