import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '_chart_internals.dart';
import 'chart_tooltip_overlay.dart';

/// Default area-chart line/fill colour (yellow/500).
const Color _areaLineColor = Color(0xFFEAB308);

/// Threshold/indicator line colour (purple/500).
const Color _thresholdColor = Color(0xFFA855F7);

/// A single-series area line chart with a gradient fill, an optional dashed
/// threshold line, an optional dotted "projection" tail, and point dots.
///
/// On touch/hover it shows a custom overlay tooltip (a [NasikoChartTooltip])
/// with the point's x-label as the title and a single value row.
///
/// Matches the dashboard "Total spend" projection screenshot:
/// - solid line + gradient fill for the actual data,
/// - a dotted continuation from [projectionFromIndex] onward (no fill),
/// - a dashed horizontal [threshold] line labelled with [thresholdLabel].
class NasikoAreaChart extends StatefulWidget {
  const NasikoAreaChart({
    super.key,
    required this.points,
    this.color,
    this.threshold,
    this.thresholdLabel,
    this.projectionFromIndex,
    this.showDots = true,
    this.showGrid = true,
    this.state = NasikoChartState.loaded,
    this.onRetry,
    this.height = 220,
    this.valueFormatter,
    this.xLabelBuilder,
  });

  /// The ordered points of the single line.
  final List<NasikoChartPoint> points;

  /// Line/fill colour. Defaults to the brand (gold) colour.
  final Color? color;

  /// When set, draws a dashed horizontal line at this y value.
  final double? threshold;

  /// Label shown on the threshold line (e.g. "\$53,200").
  final String? thresholdLabel;

  /// Index into [points] where the dotted projection begins. The solid +
  /// filled segment covers `[0..projectionFromIndex]` and the dotted segment
  /// covers `[projectionFromIndex..end]` (they share the boundary point).
  final int? projectionFromIndex;

  final bool showDots;

  /// Whether to draw horizontal background grid lines (dashed). Defaults to on.
  final bool showGrid;

  final NasikoChartState state;
  final VoidCallback? onRetry;
  final double height;
  final String Function(double value)? valueFormatter;
  final String Function(double x)? xLabelBuilder;

  @override
  State<NasikoAreaChart> createState() => _NasikoAreaChartState();
}

class _NasikoAreaChartState extends State<NasikoAreaChart>
    with ChartTooltipOverlay {
  String _formatValue(double v) =>
      (widget.valueFormatter ?? defaultValueFormatter)(v);

  /// Title for the point at [index]: its explicit label, else the formatted x,
  /// else the raw x — same precedence as the line chart.
  String _titleFor(NasikoChartPoint p) =>
      p.label ?? widget.xLabelBuilder?.call(p.x) ?? p.x.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    return NasikoChartFrame(
      state: widget.state,
      height: widget.height,
      onRetry: widget.onRetry,
      builder: (context) => composeTooltipTarget(_buildChart(context)),
    );
  }

  Widget _buildChart(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final lineColor = widget.color ?? _areaLineColor;

    final spots = [for (final p in widget.points) FlSpot(p.x, p.y)];
    final splitAt = widget.projectionFromIndex;
    final hasProjection =
        splitAt != null && splitAt > 0 && splitAt < spots.length;

    final solidSpots = hasProjection ? spots.sublist(0, splitAt + 1) : spots;
    final projectionSpots = hasProjection ? spots.sublist(splitAt) : <FlSpot>[];

    FlDotData dotData(Color c) => FlDotData(
      show: widget.showDots,
      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
        radius: 3.5,
        color: c,
        strokeWidth: 2,
        strokeColor: colors.backgroundBase,
      ),
    );

    return LineChart(
      duration: kChartAnimationDuration,
      curve: kChartAnimationCurve,
      LineChartData(
        lineBarsData: [
          // Solid actual segment with gradient fill.
          LineChartBarData(
            spots: solidSpots,
            isCurved: false,
            barWidth: 2,
            color: lineColor,
            dotData: dotData(lineColor),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.25),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Dotted projection tail (no fill).
          if (hasProjection)
            LineChartBarData(
              spots: projectionSpots,
              isCurved: false,
              barWidth: 2,
              color: lineColor,
              dashArray: const [2, 4],
              dotData: dotData(lineColor),
            ),
        ],
        extraLinesData: widget.threshold == null
            ? const ExtraLinesData()
            : ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: widget.threshold!,
                    color: _thresholdColor,
                    strokeWidth: 1.5,
                    dashArray: const [6, 4],
                    label: HorizontalLineLabel(
                      show: widget.thresholdLabel != null,
                      alignment: Alignment.topLeft,
                      style: typography.caption.copyWith(
                        color: colors.foregroundSecondary,
                      ),
                      labelResolver: (_) => widget.thresholdLabel ?? '',
                    ),
                  ),
                ],
              ),
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colors.borderPrimary.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: widget.xLabelBuilder != null,
              reservedSize: 24,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.xLabelBuilder!(value),
                  style: typography.caption.copyWith(
                    color: colors.foregroundSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            // No built-in tooltip; we render our own overlay.
            getTooltipItems: (spots) =>
                List<LineTooltipItem?>.filled(spots.length, null),
            getTooltipColor: (_) => Colors.transparent,
          ),
          getTouchedSpotIndicator: (barData, indexes) => [
            for (final _ in indexes)
              TouchedSpotIndicatorData(
                FlLine(color: lineColor, strokeWidth: 1),
                FlDotData(
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 4,
                        color: lineColor,
                        strokeWidth: 2,
                        strokeColor: colors.backgroundBase,
                      ),
                ),
              ),
          ],
          touchCallback: (event, response) {
            final spot = response?.lineBarSpots?.first;
            if (spot == null || event is FlPointerExitEvent) {
              hideChartTooltip();
              return;
            }
            // The chart may have two bars (solid + projection), so map back to
            // the source point by x rather than the bar-relative spotIndex.
            final pointIndex = widget.points.indexWhere((p) => p.x == spot.x);
            if (pointIndex < 0) {
              hideChartTooltip();
              return;
            }
            final point = widget.points[pointIndex];
            showChartTooltip(
              anchor: Offset(
                event.localPosition?.dx ?? 0,
                event.localPosition?.dy ?? 0,
              ),
              title: _titleFor(point),
              rows: [
                NasikoChartTooltipRow(
                  color: lineColor,
                  value: _formatValue(point.y),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
