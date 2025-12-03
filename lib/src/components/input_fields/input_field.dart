// lib/src/components/input_fields/nasiko_input_field.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A standardized input field for the Nasiko Design System.
///
/// This component wraps a [TextFormField] and applies Nasiko styling
/// for labels, hints, icons, and borders.
class NasikoInputField extends StatelessWidget {
  const NasikoInputField({
    super.key,
    this.controller,
    this.label,
    this.labelInfoIcon,
    this.hintText,
    this.helperText,
    this.leadingIcon,
    this.trailingIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// The text label displayed above the input field.
  final String? label;

  /// An optional icon displayed next to the label.
  /// Only Hugeicons library is used. For ex: `HugeIcons.strokeRoundedAddCircle`.
  final HugeIconsType? labelInfoIcon;

  /// Text displayed inside the field when it's empty.
  final String? hintText;

  /// Text displayed below the input field.
  final String? helperText;

  /// An icon displayed at the beginning of the input field.
  /// Only Hugeicons library is used. For ex: `HugeIcons.strokeRoundedAddCircle`.
  final HugeIconsType? leadingIcon;

  /// An icon displayed at the end of the input field.
  /// Only Hugeicons library is used. For ex: `HugeIcons.strokeRoundedAddCircle`.
  final HugeIconsType? trailingIcon;

  /// Whether to obscure the text (e.g., for passwords).
  final bool obscureText;

  /// The type of keyboard to display.
  final TextInputType? keyboardType;

  /// An optional validator function.
  final FormFieldValidator<String>? validator;

  /// Called when the user initiates a change to the field's value.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    // Get all design tokens from the theme
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;

    // Define the border styles
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radii.r8),
      borderSide: BorderSide(
        color: colors.borderPrimary,
        width: borderWidths.w1,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radii.r8),
      borderSide: BorderSide(
        color: colors.borderSecondary, // Your brand border color
        width: borderWidths.w1, // Thicker border on focus
      ),
    );

    // Add error/disabled borders for a complete component
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radii.r8),
      borderSide: BorderSide(color: colors.borderError, width: borderWidths.w1),
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radii.r8),
      borderSide: BorderSide(
        color: colors.borderDisabled,
        width: borderWidths.w1,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Optional Label (outside the field)
        if (label != null) ...[
          _buildLabel(context),
          SizedBox(height: spacing.s12),
        ],

        // 2. The Text Field
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: colors.borderSecondary,
          style: typography.bodySecondary.copyWith(
            color: colors.foregroundPrimary, // Input text style
          ),
          decoration: InputDecoration(
            // --- Content ---
            hintText: hintText,
            hintStyle: typography.bodySecondary.copyWith(
              color: colors.foregroundSecondary, // Hint text style
            ),

            // --- Icons ---
            prefixIcon: leadingIcon != null
                ? HugeIcon(
                    icon: leadingIcon!,
                    size: iconSizes.s, // 20px
                    color: colors.foregroundIconPrimary,
                  )
                : null,
            suffixIcon: trailingIcon != null
                ? HugeIcon(
                    icon: trailingIcon!,
                    size: iconSizes.s, // 20px
                    color: colors.foregroundIconPrimary,
                  )
                : null,

            // --- Styling ---
            filled: true,
            fillColor: colors.backgroundGroup, // neutral50
            hoverColor: colors.backgroundSurface,
            contentPadding: EdgeInsets.all(spacing.s12),

            // --- Borders ---
            border: defaultBorder,
            enabledBorder: defaultBorder,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            disabledBorder: disabledBorder,
          ),
        ),

        // 3. Optional Helper Text (below the field)
        if (helperText != null) ...[
          SizedBox(height: spacing.s8),
          Text(
            helperText!,
            style: typography.bodyTertiary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;
    final iconSizes = context.iconSize;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: typography.bodySecondaryBold.copyWith(
            color: colors.foregroundPrimary,
          ),
        ),
        if (labelInfoIcon != null) ...[
          SizedBox(width: spacing.s8),
          HugeIcon(
            icon: labelInfoIcon!,
            size: iconSizes.s, // 20px
            color: colors.foregroundIconPrimary,
          ),
        ],
      ],
    );
  }
}

typedef HugeIconsType = List<List<dynamic>>;
