import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '_chart_internals.dart';
import 'chart_tooltip_overlay.dart';

/// A donut chart with a centre total label and an optional side legend showing
/// each slice's share as a percentage.
///
/// Slices without an explicit `color` are auto-assigned a categorical colour
/// from the theme's chart-series palette by index.
class NasikoDonutChart extends StatefulWidget {
  const NasikoDonutChart({
    super.key,
    required this.segments,
    required this.centerLabel,
    this.centerSubLabel = 'total',
    this.showLegend = true,
    this.thickness = 28,
    this.state = NasikoChartState.loaded,
    this.onRetry,
    this.height = 220,
  });

  /// The slices, drawn clockwise in order.
  final List<NasikoDonutSegment> segments;

  /// Big centre label, e.g. "\$11.4k".
  final String centerLabel;

  /// Smaller label beneath [centerLabel], e.g. "total".
  final String centerSubLabel;

  /// Whether to render the side legend with per-slice percentages.
  final bool showLegend;

  /// Ring thickness.
  final double thickness;

  final NasikoChartState state;
  final VoidCallback? onRetry;
  final double height;

  @override
  State<NasikoDonutChart> createState() => _NasikoDonutChartState();
}

class _NasikoDonutChartState extends State<NasikoDonutChart>
    with ChartTooltipOverlay {
  /// Index of the currently-hovered slice, or null.
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    return NasikoChartFrame(
      state: widget.state,
      height: widget.height,
      onRetry: widget.onRetry,
      builder: _buildChart,
    );
  }

  Widget _buildChart(BuildContext context) {
    final spacing = context.spacing;
    final total = widget.segments.fold<double>(0, (sum, s) => sum + s.value);

    final ring = LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final centerSpaceRadius = (side / 2) - widget.thickness;
        return Stack(
          alignment: Alignment.center,
          children: [
            composeTooltipTarget(
              PieChart(
                duration: kChartAnimationDuration,
                curve: kChartAnimationCurve,
                PieChartData(
                  // A wider gap between slices reads as rounded separations,
                  // matching the dashboard donut.
                  sectionsSpace: 4,
                  centerSpaceRadius: centerSpaceRadius.clamp(0, side),
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final section = response?.touchedSection;
                      final index = section?.touchedSectionIndex;
                      final next = (event.isInterestedForInteractions &&
                              index != null &&
                              index >= 0)
                          ? index
                          : null;
                      if (next != _touchedIndex) {
                        setState(() => _touchedIndex = next);
                      }
                      if (next == null) {
                        hideChartTooltip();
                        return;
                      }
                      final seg = widget.segments[next];
                      showChartTooltip(
                        anchor: Offset(
                          event.localPosition?.dx ?? 0,
                          event.localPosition?.dy ?? 0,
                        ),
                        title: seg.label,
                        rows: [
                          NasikoChartTooltipRow(
                            color: resolveSeriesColor(context, next, seg.color),
                            value: total <= 0
                                ? '0%'
                                : '${(seg.value / total * 100).round()}%',
                          ),
                        ],
                      );
                    },
                  ),
                  sections: [
                    for (var i = 0; i < widget.segments.length; i++)
                      PieChartSectionData(
                        value: widget.segments[i].value,
                        color: resolveSeriesColor(
                          context,
                          i,
                          widget.segments[i].color,
                        ),
                        // Hovered slice grows outward by 6px.
                        radius: i == _touchedIndex
                            ? widget.thickness + 6
                            : widget.thickness,
                        showTitle: false,
                        // Rounded slice caps, matching the dashboard donut.
                        cornerRadius: widget.thickness / 2,
                      ),
                  ],
                ),
              ),
            ),
            _CenterLabel(
              label: widget.centerLabel,
              subLabel: widget.centerSubLabel,
            ),
          ],
        );
      },
    );

    if (!widget.showLegend) return Center(child: ring);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: ring),
        SizedBox(width: spacing.s24w),
        Flexible(
          child: NasikoChartLegend(
            axis: Axis.vertical,
            items: [
              for (var i = 0; i < widget.segments.length; i++)
                NasikoChartLegendItem(
                  label: widget.segments[i].label,
                  color: resolveSeriesColor(
                    context,
                    i,
                    widget.segments[i].color,
                  ),
                  percentLabel: total <= 0
                      ? null
                      : '${(widget.segments[i].value / total * 100).round()}%',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenterLabel extends StatelessWidget {
  const _CenterLabel({required this.label, required this.subLabel});

  final String label;
  final String subLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: typography.bodySecondaryBold.copyWith(
            color: colors.foregroundPrimary,
          ),
        ),
        Text(
          subLabel,
          style: typography.bodyTertiary.copyWith(
            color: colors.foregroundSecondary,
          ),
        ),
      ],
    );
  }
}
