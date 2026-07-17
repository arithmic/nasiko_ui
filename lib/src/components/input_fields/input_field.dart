// lib/src/components/input_fields/nasiko_input_field.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

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
    this.isRequired = false,
    this.isReadOnly = false,
    this.maxLines = 1,
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

  final bool? isRequired;

  final bool? isReadOnly;


  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;

    final iconSize = iconSizes.s;
    final textStyle = typography.bodySecondary;
    final contentPadding = EdgeInsets.symmetric(
      horizontal: spacing.s12,
      vertical: spacing.s16,
    );

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
        color: colors.borderSecondary,
        width: borderWidths.w1,
      ),
    );

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
        if (label != null) ...[
          _buildLabel(context),
          SizedBox(height: spacing.s12),
        ],

        TextFormField(
          controller: controller,
          readOnly: isReadOnly!,
          enabled: !isReadOnly!,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: colors.borderSecondary,
          style: textStyle.copyWith(color: colors.foregroundPrimary),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: textStyle.copyWith(color: colors.foregroundSecondary),
            prefixIconConstraints: BoxConstraints(
              minWidth: iconSize,
              minHeight: iconSize,
            ),
            prefixIcon: leadingIcon != null
                ? Padding(
                    padding: EdgeInsets.only(
                      left: spacing.s12,
                      right: spacing.s4,
                    ),
                    child: IconTheme(
                      data: IconThemeData(size: iconSize),
                      child: HugeIcon(
                        icon: leadingIcon!,
                        size: iconSize,
                        color: colors.foregroundIconTertiary,
                      ),
                    ),
                  )
                : null,

            suffixIconConstraints: BoxConstraints(
              minWidth: iconSize,
              minHeight: iconSize,
            ),

            suffixIcon: trailingIcon != null
                ? Padding(
                    padding: EdgeInsets.only(
                      left: spacing.s4,
                      right: spacing.s12,
                    ),
                    child: IconTheme(
                      data: IconThemeData(size: iconSize),
                      child: HugeIcon(
                        icon: trailingIcon!,
                        size: iconSize,
                        color: colors.foregroundIconTertiary,
                      ),
                    ),
                  )
                : null,

            filled: true,
            fillColor: isReadOnly!
                  ? colors.backgroundDisabled
                : colors.backgroundGroup,
            hoverColor: colors.backgroundSurface,
            contentPadding: contentPadding,

            border: defaultBorder,
            enabledBorder: defaultBorder,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            disabledBorder: disabledBorder,

            errorStyle: typography.bodyTertiary.copyWith(
              color: colors.foregroundError,
            ),
          ),
        ),

        if (helperText != null) ...[
          SizedBox(height: spacing.s8),
          Padding(
            padding: EdgeInsets.only(left: spacing.s4),
            child: Text(
              helperText!,
              style: typography.bodyTertiary.copyWith(
                color: colors.foregroundSecondary,
              ),
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
        if (isRequired!)
          Text.rich(
            TextSpan(
              text: '* ', // The asterisk part
              style: TextStyle(
                color: colors.foregroundError, // Style for the asterisk
                fontWeight: FontWeight.bold,
              ),

              children: [
                TextSpan(
                  text: label!,
                  style: typography.bodySecondaryBold.copyWith(
                    color: colors.foregroundPrimary,
                  ),
                ),
              ],
            ),
          )
        else
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
            size: iconSizes.s,
            color: colors.foregroundIconPrimary,
          ),
        ],
      ],
    );
  }
}
