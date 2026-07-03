import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A single row in a [NasikoChartTooltip]: a coloured dot, a series label, a
/// thin divider, and a value.
@immutable
class NasikoChartTooltipRow {
  const NasikoChartTooltipRow({
    required this.color,
    this.label,
    required this.value,
  });

  final Color color;

  /// Optional series/segment label. When null, the row renders just the
  /// coloured dot and the value (no label text and no divider).
  final String? label;
  final String value;
}

/// The tooltip content shown when a chart point is touched — a bold title
/// (typically a date) followed by `dot | label | value` rows.
///
/// Styled as a light surface card (matching the screenshots): white background,
/// subtle border, r12 corners. Used inside the line chart's custom overlay and
/// reusable standalone.
class NasikoChartTooltip extends StatelessWidget {
  const NasikoChartTooltip({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<NasikoChartTooltipRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;

    return Container(
      padding: EdgeInsets.all(spacing.s16),
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: colors.backgroundBase,
        borderRadius: BorderRadius.circular(radii.r12),
        border: Border.all(color: colors.borderPrimary),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.bodyPrimaryBold.copyWith(
              color: colors.foregroundPrimary,
            ),
          ),
          for (final row in rows) ...[
            SizedBox(height: spacing.s12h),
            _TooltipRow(row: row),
          ],
        ],
      ),
    );
  }
}

class _TooltipRow extends StatelessWidget {
  const _TooltipRow({required this.row});

  final NasikoChartTooltipRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: row.color, shape: BoxShape.circle),
        ),
        SizedBox(width: spacing.s8w),
        if (row.label != null) ...[
          Text(
            row.label!,
            style: typography.bodyTertiary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
          SizedBox(width: spacing.s12w),
          Container(
            width: 1,
            height: 12,
            color: colors.borderSecondary,
          ),
          SizedBox(width: spacing.s12w),
        ],
        Text(
          row.value,
          style: typography.bodyTertiaryBold.copyWith(
            color: colors.foregroundPrimary,
          ),
        ),
      ],
    );
  }
}
