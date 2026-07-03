import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '_chart_internals.dart';

/// A segmented-progress ("bar of dots") chart: one row per metric, each a label
/// followed by a row of small tick segments where the leading fraction is
/// filled, then a percentage and an optional trend delta.
///
/// This is a plain-layout widget (not fl_chart) — fl_chart has no row-of-ticks
/// primitive and this is simple, pixel-controllable layout.
class NasikoSegmentBar extends StatelessWidget {
  const NasikoSegmentBar({
    super.key,
    required this.rows,
    this.state = NasikoChartState.loaded,
    this.onRetry,
    this.height,
    this.segmentCount = 16,
    this.percentFormatter,
    this.labelWidth = 96,
  });

  /// The metric rows. [NasikoSegmentDatum.percent] is a 0.0–1.0 fraction.
  final List<NasikoSegmentDatum> rows;

  final NasikoChartState state;
  final VoidCallback? onRetry;

  /// Fixed height; when null, sized from the row count.
  final double? height;

  /// Number of tick segments per row.
  final int segmentCount;

  /// Formats a 0.0–1.0 fraction into the trailing label. Defaults to "NN%".
  final String Function(double fraction)? percentFormatter;

  /// Fixed width reserved for row labels.
  final double labelWidth;

  static const double _rowHeight = 32;

  /// Vertical padding the frame adds around the body (top + bottom).
  static const double _framePadding = 32;

  @override
  Widget build(BuildContext context) {
    final resolvedHeight = height ?? rows.length * _rowHeight + _framePadding;
    return NasikoChartFrame(
      state: state,
      height: resolvedHeight,
      onRetry: onRetry,
      builder: _buildRows,
    );
  }

  Widget _buildRows(BuildContext context) {
    final formatter = percentFormatter ?? defaultPercentFormatter;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < rows.length; i++)
          SizedBox(
            height: _rowHeight,
            child: _SegmentRow(
              datum: rows[i],
              segmentCount: segmentCount,
              percentLabel: formatter(rows[i].percent),
              labelWidth: labelWidth,
              // Per-row colour falls back to the categorical palette.
              fallbackColor: context.colors.chartSeriesColor(i),
            ),
          ),
      ],
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.datum,
    required this.segmentCount,
    required this.percentLabel,
    required this.labelWidth,
    required this.fallbackColor,
  });

  final NasikoSegmentDatum datum;
  final int segmentCount;
  final String percentLabel;
  final double labelWidth;

  /// Used for the filled ticks when [datum] has no explicit colour.
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;

    final fraction = datum.percent.clamp(0.0, 1.0);
    final filled = (fraction * segmentCount).round();
    final fillColor = datum.color ?? fallbackColor;
    final emptyColor = colors.backgroundSurfaceSubtle;

    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            datum.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.bodyTertiary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
        ),
        SizedBox(width: spacing.s12w),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 4.0;
              final totalGap = gap * (segmentCount - 1);
              final tickWidth =
                  ((constraints.maxWidth - totalGap) / segmentCount)
                      .clamp(3.0, 20.0);
              return Row(
                children: [
                  for (var i = 0; i < segmentCount; i++) ...[
                    if (i > 0) const SizedBox(width: gap),
                    Container(
                      width: tickWidth,
                      height: 18,
                      decoration: BoxDecoration(
                        color: i < filled ? fillColor : emptyColor,
                        borderRadius: BorderRadius.circular(radii.r4),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        SizedBox(width: spacing.s12w),
        SizedBox(
          width: 40,
          child: Text(
            percentLabel,
            textAlign: TextAlign.end,
            style: typography.bodyTertiaryBold.copyWith(
              color: colors.foregroundPrimary,
            ),
          ),
        ),
        if (datum.delta != null) ...[
          SizedBox(width: spacing.s8w),
          Text(
            '${trendArrow(datum.delta!.direction)}${datum.delta!.label}',
            style: typography.bodyTertiaryBold.copyWith(
              color: trendColor(context, datum.delta!.direction),
            ),
          ),
        ],
      ],
    );
  }
}
