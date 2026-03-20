import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// The secondary call-to-action button for Nasiko UI.
///
/// This is a medium-emphasis button that uses an outlined style with the 'brand' color.
/// It should be used for secondary actions on a screen.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
    final borderWidths = context.borderWidth;

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
        textStyle = typography.buttonPrimaryBold;
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
        textStyle = typography.buttonSecondaryBold;
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
        textStyle = typography.buttonSecondaryBold;
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

      // --- Background Color (Default, Hover, Focused, Disabled) ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.backgroundDisabled;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.backgroundSecondaryBrandHover;
        }
        // Default, Focused, Pressed states
        return colors.backgroundSecondaryBrand;
      }),

      // --- Foreground Color (Text & Icons) ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        // Default, Hover, Focus, Pressed
        return colors.foregroundPrimary;
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
            color: colors.borderSecondary,
            width: borderWidths.w2,
            strokeAlign: BorderSide.strokeAlignOutside,
          );
        } else if (states.contains(WidgetState.hovered)) {
          return BorderSide(color: colors.borderHover, width: borderWidths.w1);
        } else {
          // Default state
          return BorderSide(
            color: colors.borderSecondary,
            width: borderWidths.w1,
          );
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
