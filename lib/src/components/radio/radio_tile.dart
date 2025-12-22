import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

class NasikoRadioTile<T> extends StatelessWidget {
  const NasikoRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
    this.icon,
  });

  final T value;
  final T? groupValue;
  final String label;
  final ValueChanged<T?>? onChanged;
  final IconData? icon;
  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final Color contentColor = !_enabled
        ? colors.foregroundDisabled
        : colors.foregroundPrimary;
    return InkWell(
      onTap: _enabled ? () => onChanged!(value) : null,
      borderRadius: BorderRadius.circular(context.radius.r8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: spacing.s4,
          horizontal: spacing.s4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NasikoRadio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
             SizedBox(width: spacing.s8),
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
              style: typography.bodyPrimary.copyWith(
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
