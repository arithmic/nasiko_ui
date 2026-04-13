// lib/src/components/buttons/secondary_text_button.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_layout.dart';

/// A secondary text button for Nasiko UI with optional icons.
///
/// This button displays text with an optional underline on hover/focus.
/// It uses the brand color for a "link" like appearance.
class SecondaryTextButton extends StatelessWidget {
  const SecondaryTextButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final borderWidth = context.borderWidth;
    final layout = textButtonLayout(context);

    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(layout.padding),
        fixedSize: WidgetStateProperty.all(Size.fromHeight(layout.minHeight)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(Colors.transparent),

        // --- Foreground Color (For Icons) ---
        // This will color the icons based on the button state
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.foregroundBrand; // Darker brand color (yellow/800)
          }
          if (states.contains(WidgetState.focused)) {
            return colors.foregroundIconHover;
          }
          return colors.foregroundPrimary; // Default brand color (yellow/600)
        }),

        // --- TextStyle (For Text & Underline) ---
        // This will style the text *and* apply the underline
        textStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final baseStyle = typography.bodySecondary;

          if (states.contains(WidgetState.disabled)) {
            return baseStyle.copyWith(color: colors.foregroundDisabled);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return baseStyle.copyWith(
              color: colors.foregroundBrandHover,
              decoration: TextDecoration.underline,
              decorationColor: colors.foregroundBrandHover,
              decorationThickness: borderWidth.w1,
            );
          }
          // Default state
          return baseStyle.copyWith(
            color: colors.foregroundBrand,
            decoration: TextDecoration.none,
          );
        }),
      ),
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
