import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_layout.dart';

/// A destructive secondary button for Nasiko UI.
///
/// This is a medium-emphasis button that uses a light error background with error borders.
/// It should be used for destructive secondary actions on a screen.
class DestructiveSecondaryButton extends StatelessWidget {
  const DestructiveSecondaryButton({
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
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final layout = standardButtonLayout(context, size);
    final textStyle = switch (size) {
      NasikoButtonSize.large => typography.buttonPrimary,
      NasikoButtonSize.medium ||
      NasikoButtonSize.small => typography.buttonSecondary,
    };
    final borderRadius = size == NasikoButtonSize.large ? radii.r10 : radii.r8;

    final style = ButtonStyle(
      padding: WidgetStateProperty.all(layout.padding),
      fixedSize: WidgetStateProperty.all(Size.fromHeight(layout.minHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStateProperty.all(textStyle),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color (Default, Hover, Focused, Disabled) ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.backgroundDisabled;
        }
        // Default, Focused, Pressed states
        return colors.backgroundError; 
      }),

      // --- Foreground Color (Text & Icons) ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        // Default, Hover, Focus, Pressed
        return colors.foregroundError;
      }),

      // --- Border ---
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
            color: colors.borderDisabled,
            width: borderWidths.w1,
          );
        } else if (states.contains(WidgetState.focused)) {
          // Focused state with border outside and 2px gap
          return BorderSide(
            color: colors.borderError,
            width: borderWidths.w2,
            strokeAlign: BorderSide.strokeAlignOutside,
          );
        } else if (states.contains(WidgetState.hovered)) {
          return BorderSide(
            color: const Color(0xFFDC2626), // red600
            width: borderWidths.w1,
          );
        } else {
          // Default state
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

    return OutlinedButton(
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
  }
}
