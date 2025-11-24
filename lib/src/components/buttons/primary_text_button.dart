import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A primary text button for Nasiko UI with optional icons.
///
/// This button displays text with an optional underline on hover/focus.
/// Uses brand color (yellow500) for emphasis.
class PrimaryTextButton extends StatelessWidget {
  const PrimaryTextButton({
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
  final IconData? leadingIcon;

  /// An optional icon to display after the label.
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final borderRadius = context.radius;
    final borderWidth = context.borderWidth;

    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        // --- Base Properties ---
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(vertical: spacing.s8, horizontal: spacing.s12),
        ),
        textStyle: WidgetStateProperty.all(typography.buttonSecondary),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(Colors.transparent),

        // --- Foreground Color (Text & Icons) ---
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          return colors.foregroundBrand;
        }),

        shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius.r10)),
              side: BorderSide(
                color: colors.foregroundBrand,
                width: borderWidth.w1,
              ),
            );
          }
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius.r10)),
          );
        }),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Leading Icon
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: iconSizes.m, color: null),
            SizedBox(width: spacing.s8),
          ],

          // Label
          Text(label),

          // Trailing Icon
          if (trailingIcon != null) ...[
            SizedBox(width: spacing.s8),
            Icon(trailingIcon, size: iconSizes.m, color: null),
          ],
        ],
      ),
    );
  }
}
