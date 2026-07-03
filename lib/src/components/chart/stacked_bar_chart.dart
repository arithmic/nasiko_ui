import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '_chart_internals.dart';
import 'chart_tooltip_overlay.dart';

/// A stacked bar chart with rounded, gapped segments per category — matching
/// the "Total spend" stacked screenshot.
///
/// Segment colours are resolved by segment index from the theme's chart-series
/// palette (consistent across categories) unless overridden per segment. Gaps
/// between segments are produced by inserting small transparent stack items.
class NasikoStackedBarChart extends StatefulWidget {
  const NasikoStackedBarChart({
    super.key,
    required this.data,
    this.state = NasikoChartState.loaded,
    this.onRetry,
    this.height = 260,
    this.showLegend = true,
    this.segmentGap = 2,
    this.barWidth = 44,
    this.valueFormatter,
  });

  /// One entry per category (per bar).
  final List<NasikoStackedDatum> data;

  final NasikoChartState state;
  final VoidCallback? onRetry;
  final double height;
  final bool showLegend;

  /// Vertical gap (in chart units relative to the stack values) between
  /// segments.
  final double segmentGap;

  final double barWidth;

  /// Formats a segment value for the hover tooltip. Defaults to
  /// [defaultValueFormatter].
  final String Function(double value)? valueFormatter;

  @override
  State<NasikoStackedBarChart> createState() => _NasikoStackedBarChartState();
}

class _NasikoStackedBarChartState extends State<NasikoStackedBarChart>
    with ChartTooltipOverlay {
  /// Index of the currently-hovered bar group (category), or null.
  int? _touchedGroupIndex;

  @override
  Widget build(BuildContext context) {
    return NasikoChartFrame(
      state: widget.state,
      height: widget.height,
      onRetry: widget.onRetry,
      builder: _build,
    );
  }

  /// Stable colour for the segment at [index], honouring a per-segment override.
  /// When [highlighted], the colour is lightened to mark the hovered bar.
  Color _segmentColor(
    BuildContext context,
    int index,
    Color? override, {
    bool highlighted = false,
  }) {
    final base = resolveSeriesColor(context, index, override);
    if (!highlighted) return base;
    return Color.lerp(base, Colors.white, 0.12) ?? base;
  }

  Widget _build(BuildContext context) {
    final spacing = context.spacing;

    // Max *rendered* rod top across categories drives maxY. Each rod's top is
    // its segment total plus the transparent gaps inserted between segments, so
    // maxY must include those gaps or the tallest bar overflows the plot area.
    final maxRodTop = widget.data.fold<double>(0, (m, d) {
      final total = d.segments.fold<double>(0, (s, seg) => s + seg.value);
      final gaps = widget.segmentGap * (d.segments.length - 1).clamp(0, 999);
      final top = total + gaps;
      return top > m ? top : m;
    });

    final chart = composeTooltipTarget(
      BarChart(
        duration: kChartAnimationDuration,
        curve: kChartAnimationCurve,
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxRodTop <= 0 ? 1 : maxRodTop,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            // Suppress fl_chart's built-in tooltip — we render our own.
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
            ),
            touchCallback: (event, response) {
              final index = response?.spot?.touchedBarGroupIndex;
              final next =
                  (event.isInterestedForInteractions && index != null && index >= 0)
                      ? index
                      : null;
              if (next != _touchedGroupIndex) {
                setState(() => _touchedGroupIndex = next);
              }
              if (next == null) {
                hideChartTooltip();
                return;
              }
              final datum = widget.data[next];
              final formatter = widget.valueFormatter ?? defaultValueFormatter;
              showChartTooltip(
                anchor: Offset(
                  event.localPosition?.dx ?? 0,
                  event.localPosition?.dy ?? 0,
                ),
                title: datum.label,
                rows: [
                  for (var i = 0; i < datum.segments.length; i++)
                    NasikoChartTooltipRow(
                      color: _segmentColor(context, i, datum.segments[i].color),
                      label: datum.segments[i].name,
                      value: formatter(datum.segments[i].value),
                    ),
                ],
              );
            },
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // X-axis labels are hidden — only the bars and the legend are shown.
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: [
            for (var c = 0; c < widget.data.length; c++)
              BarChartGroupData(
                x: c,
                // Vertically-grouped rods stack on top of each other; each rod is
                // independent so it can have its own rounded caps (rod stack items
                // can't be rounded).
                groupVertically: true,
                barRods: _buildRods(
                  context,
                  widget.data[c],
                  highlighted: c == _touchedGroupIndex,
                ),
              ),
          ],
        ),
      ),
    );

    if (!widget.showLegend) return chart;

    // Legend uses the first category's segment names (segment order is shared).
    final legendSource = widget.data.isNotEmpty
        ? widget.data.first.segments
        : <NasikoStackedSegment>[];

    return Column(
      children: [
        Expanded(child: chart),
        SizedBox(height: spacing.s12h),
        NasikoChartLegend(
          items: [
            for (var i = 0; i < legendSource.length; i++)
              NasikoChartLegendItem(
                label: legendSource[i].name,
                color: _segmentColor(context, i, legendSource[i].color),
              ),
          ],
        ),
      ],
    );
  }

  /// Builds one rounded rod per segment for a category, stacked vertically with
  /// a small transparent gap between them.
  List<BarChartRodData> _buildRods(
    BuildContext context,
    NasikoStackedDatum datum, {
    bool highlighted = false,
  }) {
    // A fixed, modest corner radius so segments read as rounded blocks rather
    // than full pills/circles.
    const radius = BorderRadius.all(Radius.circular(6));
    final rods = <BarChartRodData>[];

    var cursor = 0.0;
    for (var i = 0; i < datum.segments.length; i++) {
      final seg = datum.segments[i];
      final from = cursor;
      final to = cursor + seg.value;
      rods.add(
        BarChartRodData(
          fromY: from,
          toY: to,
          width: widget.barWidth,
          color: _segmentColor(context, i, seg.color, highlighted: highlighted),
          // Each segment is an independent rod, so it gets its own rounded caps.
          borderRadius: radius,
        ),
      );
      cursor = to;
      // Transparent gap above each segment except the last.
      if (i < datum.segments.length - 1) cursor += widget.segmentGap;
    }

    return rods;
  }
}
