import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A destructive call-to-action button for Nasiko UI.
///
/// This is a high-emphasis button that uses the 'error' color to indicate
/// destructive or dangerous actions like delete, remove, or cancel operations.
/// It should be used sparingly for critical destructive actions.
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
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

    final EdgeInsets padding;
    final TextStyle textStyle;
    final double iconSize;
    final double borderRadius;
    final double iconSpacing;
    final double minHeight;

    switch (size) {
      case NasikoButtonSize.large:
        padding = EdgeInsets.symmetric(
          vertical: spacing.s20h,
          horizontal: spacing.s24w,
        );
        textStyle = typography.buttonPrimary;
        iconSize = iconSizes.l; // 28px
        borderRadius = radii.r10; // 10px radius
        iconSpacing = spacing.s12w; // 12px spacing
        minHeight = spacing.s64h;
        break;
      case NasikoButtonSize.medium:
        padding = EdgeInsets.symmetric(
          vertical: spacing.s12h,
          horizontal: spacing.s16w,
        );
        textStyle = typography.buttonSecondary;
        iconSize = iconSizes.s; // 20px
        borderRadius = radii.r8; // 8px radius
        iconSpacing = spacing.s8w; // 8px spacing
        minHeight = spacing.s48h;
        break;
      case NasikoButtonSize.small:
        padding = EdgeInsets.symmetric(
          vertical: spacing.s8h,
          horizontal: spacing.s12w,
        );
        textStyle = typography.buttonSecondary;
        iconSize = iconSizes.s; // 20px
        borderRadius = radii.r8; // 8px radius
        iconSpacing = spacing.s8w; // 8px spacing
        minHeight = spacing.s36h;
        break;
    }

    final style = ButtonStyle(
      // --- Base Properties ---
      padding: WidgetStateProperty.all(padding),
      fixedSize: WidgetStateProperty.all(Size.fromHeight(minHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStateProperty.all(textStyle),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color (Handles Default, Hover, Disabled) ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.backgroundDisabled;
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFFB91C1C); // red700 for hover
        }
        if (states.contains(WidgetState.pressed)) {
          return const Color(0xFFDC2626); // red600
        }
        // Default state
        return const Color(0xFFDC2626); // red600
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
            color: colors.borderError,
            width: context.borderWidth.w2,
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
