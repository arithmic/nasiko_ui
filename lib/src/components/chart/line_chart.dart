import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '_chart_internals.dart';
import 'chart_tooltip_overlay.dart';

/// A multi-series line chart with an interactive, design-system-styled tooltip.
///
/// On touch/hover the chart highlights the nearest x position across every
/// series and shows a custom overlay tooltip (a [NasikoChartTooltip]) with a
/// date/x header and one `dot | label | value` row per series — matching the
/// dashboard screenshots, rather than fl_chart's plain built-in tooltip.
///
/// Series without an explicit `color` are auto-assigned a categorical colour
/// from the theme's chart-series palette by index.
class NasikoLineChart extends StatefulWidget {
  const NasikoLineChart({
    super.key,
    required this.series,
    this.state = NasikoChartState.loaded,
    this.onRetry,
    this.height = 220,
    this.showLegend = true,
    this.showGrid = true,
    this.xLabelBuilder,
    this.yLabelBuilder,
    this.valueFormatter,
  });

  /// The series to plot (typically 2–3).
  final List<NasikoChartSeries> series;

  final NasikoChartState state;
  final VoidCallback? onRetry;
  final double height;
  final bool showLegend;
  final bool showGrid;

  /// Maps an x value to an axis/tooltip label (e.g. a formatted date).
  final String Function(double x)? xLabelBuilder;

  /// Maps a y value to a left-axis label.
  final String Function(double y)? yLabelBuilder;

  /// Formats a y value for the tooltip rows. Falls back to a currency-ish
  /// default.
  final String Function(double value)? valueFormatter;

  @override
  State<NasikoLineChart> createState() => _NasikoLineChartState();
}

/// Default line-series colours when a series doesn't specify its own, applied
/// by series index: primary gold then a muted sand.
const List<Color> _lineSeriesColors = [Color(0xFF8C6B05), Color(0xFFC2BAB0)];

/// Colour of the vertical/horizontal indicator line shown on touch (purple/500).
const Color _indicatorColor = Color(0xFFA855F7);

class _NasikoLineChartState extends State<NasikoLineChart>
    with ChartTooltipOverlay {

  /// Resolves the colour for series [index]: explicit override wins, otherwise
  /// the line-chart default palette (wrapping by index).
  Color _seriesColor(int index, Color? override) =>
      override ?? _lineSeriesColors[index % _lineSeriesColors.length];

  /// The currently-touched x index (a position shared across series), or null.
  int? _touchedIndex;

  String _formatValue(double v) =>
      (widget.valueFormatter ?? defaultValueFormatter)(v);

  String _formatX(double x) =>
      widget.xLabelBuilder?.call(x) ?? x.toStringAsFixed(0);

  String _tooltipTitle(int index) {
    for (final s in widget.series) {
      if (index < s.points.length) {
        final p = s.points[index];
        return p.label ?? _formatX(p.x);
      }
    }
    return '';
  }

  List<NasikoChartTooltipRow> _tooltipRows(int index) {
    final rows = <NasikoChartTooltipRow>[];
    for (var i = 0; i < widget.series.length; i++) {
      final s = widget.series[i];
      if (index >= s.points.length) continue;
      rows.add(
        NasikoChartTooltipRow(
          color: _seriesColor(i, s.color),
          label: s.name,
          value: _formatValue(s.points[index].y),
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NasikoChartFrame(
          state: widget.state,
          height: widget.height,
          onRetry: widget.onRetry,
          builder: (context) => composeTooltipTarget(_buildChart(context)),
        ),
        if (widget.showLegend && widget.state == NasikoChartState.loaded) ...[
          SizedBox(height: context.spacing.s12h),
          NasikoChartLegend(items: _legendItems(context)),
        ],
      ],
    );
  }

  List<NasikoChartLegendItem> _legendItems(BuildContext context) {
    return [
      for (var i = 0; i < widget.series.length; i++)
        NasikoChartLegendItem(
          label: widget.series[i].name,
          color: _seriesColor(i, widget.series[i].color),
        ),
    ];
  }

  Widget _buildChart(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return LineChart(
      duration: kChartAnimationDuration,
      curve: kChartAnimationCurve,
      LineChartData(
        lineBarsData: [
          for (var i = 0; i < widget.series.length; i++)
            LineChartBarData(
              spots: [
                for (final p in widget.series[i].points) FlSpot(p.x, p.y),
              ],
              isCurved: false,
              barWidth: 2,
              color: _seriesColor(i, widget.series[i].color),
              dotData: const FlDotData(show: false),
            ),
        ],
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colors.borderPrimary.withValues(alpha: 0.5),
            strokeWidth: 1,
            dashArray: const [4, 4],
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: widget.yLabelBuilder != null,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                widget.yLabelBuilder!(value),
                style: typography.caption.copyWith(
                  color: colors.foregroundSecondary,
                ),
              ),
            ),
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
            // Suppress fl_chart's built-in tooltip; we render our own overlay.
            getTooltipItems: (spots) =>
                List<LineTooltipItem?>.filled(spots.length, null),
            getTooltipColor: (_) => Colors.transparent,
          ),
          getTouchedSpotIndicator: (barData, indexes) => [
            for (final _ in indexes)
              TouchedSpotIndicatorData(
                FlLine(color: _indicatorColor, strokeWidth: 1),
                FlDotData(
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 4,
                        color: bar.color ?? colors.backgroundBrand,
                        strokeWidth: 2,
                        strokeColor: colors.backgroundBase,
                      ),
                ),
              ),
          ],
          touchCallback: (event, response) {
            final spot = response?.lineBarSpots?.first;
            if (spot == null || event is FlPointerExitEvent) {
              if (_touchedIndex != null) {
                setState(() => _touchedIndex = null);
                hideChartTooltip();
              }
              return;
            }
            final index = spot.spotIndex;
            setState(() => _touchedIndex = index);
            showChartTooltip(
              anchor: Offset(
                event.localPosition?.dx ?? 0,
                event.localPosition?.dy ?? 0,
              ),
              title: _tooltipTitle(index),
              rows: _tooltipRows(index),
            );
          },
        ),
      ),
    );
  }
}
