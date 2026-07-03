import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A single legend entry: a coloured dot, a label, and an optional value/percent.
@immutable
class NasikoChartLegendItem {
  const NasikoChartLegendItem({
    required this.label,
    required this.color,
    this.percentLabel,
  });

  final String label;
  final Color color;

  /// Optional trailing value, e.g. "35%". Rendered in bold when present.
  final String? percentLabel;
}

/// A legend for a chart — a row (or column) of [NasikoChartLegendItem]s, each
/// a coloured dot + label (+ optional percent).
///
/// Use [Axis.horizontal] (default) for a wrapping row beneath line/bar charts,
/// or [Axis.vertical] for the side legend of a donut chart.
class NasikoChartLegend extends StatelessWidget {
  const NasikoChartLegend({
    super.key,
    required this.items,
    this.axis = Axis.horizontal,
  });

  final List<NasikoChartLegendItem> items;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final rows = [for (final item in items) _LegendRow(item: item)];

    if (axis == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.s8h),
            rows[i],
          ],
        ],
      );
    }

    return Wrap(
      spacing: spacing.s16w,
      runSpacing: spacing.s8h,
      children: rows,
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item});

  final NasikoChartLegendItem item;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final typography = context.typography;
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        SizedBox(width: spacing.s8w),
        // Long labels (e.g. an agent UUID) would otherwise push the row past
        // its allotted width and overflow — especially the donut's side legend,
        // where each row lives in a width-bounded Flexible. Ellipsize instead.
        Flexible(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.bodyTertiary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
        ),
        if (item.percentLabel != null) ...[
          SizedBox(width: spacing.s8w),
          Text(
            item.percentLabel!,
            style: typography.bodyTertiaryBold.copyWith(
              color: colors.foregroundPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
