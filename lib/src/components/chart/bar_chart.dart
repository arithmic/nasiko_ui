import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '_chart_internals.dart';

/// A horizontal bar chart rendered as a table of rows: a row label, an
/// fl_chart bar sized relative to the largest value, a value label, and an
/// optional trend delta — matching the "Total spend" breakdown screenshot.
///
/// Each row's bar is a single-rod horizontal [BarChart]; the surrounding label,
/// value and delta are design-system text so they sit inline with the bar.
class NasikoBarChart extends StatelessWidget {
  const NasikoBarChart({
    super.key,
    required this.data,
    this.state = NasikoChartState.loaded,
    this.onRetry,
    this.height,
    this.valueFormatter,
    this.barColor,
    this.labelWidth = 96,
  });

  /// The rows to render.
  final List<NasikoBarDatum> data;

  final NasikoChartState state;
  final VoidCallback? onRetry;

  /// Fixed height. When null, sized from the row count so the frame matches
  /// the content.
  final double? height;

  /// Formats a value into [NasikoBarDatum.valueLabel] when one isn't supplied.
  final String Function(double value)? valueFormatter;

  /// Default bar colour for rows without an explicit colour. Defaults to brand.
  final Color? barColor;

  /// Fixed width reserved for the row labels.
  final double labelWidth;

  static const double _rowHeight = 28;

  /// Vertical padding the frame adds around the body (top + bottom).
  static const double _framePadding = 32;

  @override
  Widget build(BuildContext context) {
    final resolvedHeight = height ?? data.length * _rowHeight + _framePadding;
    return NasikoChartFrame(
      state: state,
      height: resolvedHeight,
      onRetry: onRetry,
      builder: _buildRows,
    );
  }

  Widget _buildRows(BuildContext context) {
    final maxValue = data.fold<double>(
      0,
      (m, d) => d.value > m ? d.value : m,
    );
    final formatter = valueFormatter ?? defaultValueFormatter;
    final defaultColor = barColor ?? context.colors.chartSeries3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final datum in data)
          SizedBox(
            height: _rowHeight,
            child: _BarRow(
              datum: datum,
              maxValue: maxValue,
              // Single shared colour for all rows; an explicit per-row colour
              // still wins.
              barColor: datum.color ?? defaultColor,
              valueLabel: datum.valueLabel ?? formatter(datum.value),
              labelWidth: labelWidth,
            ),
          ),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.datum,
    required this.maxValue,
    required this.barColor,
    required this.valueLabel,
    required this.labelWidth,
  });

  final NasikoBarDatum datum;
  final double maxValue;
  final Color barColor;
  final String valueLabel;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

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
          // fl_chart draws bars vertically; rotating a quarter turn makes the
          // rod grow left-to-right within the row.
          child: BarChart(
            BarChartData(
              rotationQuarterTurns: 1,
              alignment: BarChartAlignment.center,
              maxY: maxValue <= 0 ? 1 : maxValue,
              minY: 0,
              groupsSpace: 0,
              titlesData: const FlTitlesData(show: false),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: datum.value,
                      color: barColor,
                      width: 12,
                      // Fully-rounded pill caps on a 12px-tall rod.
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            duration: const Duration(milliseconds: 150),
          ),
        ),
        SizedBox(width: spacing.s12w),
        Text(
          valueLabel,
          style: typography.bodyTertiaryBold.copyWith(
            color: colors.foregroundPrimary,
          ),
        ),
        if (datum.delta != null) ...[
          SizedBox(width: spacing.s12w),
          _DeltaLabel(delta: datum.delta!),
        ],
      ],
    );
  }
}

class _DeltaLabel extends StatelessWidget {
  const _DeltaLabel({required this.delta});

  final NasikoTrendDelta delta;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final color = trendColor(context, delta.direction);

    return Text(
      '${trendArrow(delta.direction)}${delta.label}',
      style: typography.bodyTertiaryBold.copyWith(color: color),
    );
  }
}
