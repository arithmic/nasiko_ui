// lib/src/components/checkbox/nasiko_checkbox_row.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A labeled row for a checkbox, optionally with a leading icon.
///
/// This component is the equivalent of a `CheckboxListTile`.
/// Tapping anywhere on the row will toggle the checkbox.
class NasikoCheckboxTile extends StatelessWidget {
  const NasikoCheckboxTile({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onChanged,
    this.icon,
  });

  /// The text label for the row.
  final String label;

  /// Whether the checkbox is currently checked.
  final bool isChecked;

  /// The callback to invoke when the row is tapped.
  /// If `null`, the row will be disabled.
  final ValueChanged<bool?>? onChanged;

  /// An optional icon to display between the checkbox and the label.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    final bool isDisabled = onChanged == null;

    final Color contentColor = isDisabled
        ? colors.foregroundDisabled
        : colors.foregroundPrimary;

    return InkWell(
      onTap: isDisabled ? null : () => onChanged!(!isChecked),
      borderRadius: BorderRadius.circular(context.radius.r4),
      splashColor: colors.backgroundBrandSubtle,
      highlightColor: colors.backgroundBrandSubtle,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s4,
          vertical: spacing.s8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NasikoCheckbox(isChecked: isChecked, onChanged: onChanged),
            SizedBox(width: spacing.s12),
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSizes.m, // 24px
                color: contentColor,
              ),
              SizedBox(width: spacing.s8),
            ],
            Text(
              label,
              style: typography.bodySecondary.copyWith(color: contentColor),
            ),
          ],
        ),
      ),
    );
  }
}
