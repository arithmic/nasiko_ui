import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';
import 'button_layout.dart';

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
    final typography = context.typography;
    final radii = context.radius;
    final layout = standardButtonLayout(context, size);
    final textStyle = switch (size) {
      NasikoButtonSize.large => typography.buttonPrimary,
      NasikoButtonSize.medium || NasikoButtonSize.small =>
        typography.buttonSecondary,
    };
    final borderRadius = size == NasikoButtonSize.large ? radii.r10 : radii.r8;

    final style = ButtonStyle(
      padding: WidgetStateProperty.all(layout.padding),
      fixedSize: WidgetStateProperty.all(Size.fromHeight(layout.minHeight)),
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
