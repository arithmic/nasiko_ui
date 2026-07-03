import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A single data point in a line or area chart.
@immutable
class NasikoChartPoint {
  const NasikoChartPoint({required this.x, required this.y, this.label});

  /// Numeric x position (e.g. a day index or timestamp in ms).
  final double x;

  /// The plotted value.
  final double y;

  /// Optional label for this point, used for axis ticks and tooltips
  /// (e.g. "Mar 14"). When null, callers' `xLabelBuilder` is used instead.
  final String? label;
}

/// A named series of points for a line chart.
@immutable
class NasikoChartSeries {
  const NasikoChartSeries({
    required this.name,
    required this.points,
    this.color,
  });

  /// Display name, shown in legends and tooltips.
  final String name;

  /// The ordered points that make up the line.
  final List<NasikoChartPoint> points;

  /// Explicit series colour. When null the chart auto-assigns a categorical
  /// colour from [NasikoColorTheme.chartSeries] by series index.
  final Color? color;
}

/// Direction of a trend delta — drives the arrow glyph and colour.
enum NasikoTrendDirection { up, down, flat }

/// A small trend indicator shown next to a value (e.g. "↑ 12%").
@immutable
class NasikoTrendDelta {
  const NasikoTrendDelta({required this.label, required this.direction});

  /// The delta text, e.g. "12%".
  final String label;

  /// Up renders success/green, down renders error/red, flat renders muted.
  final NasikoTrendDirection direction;
}

/// One row of a horizontal bar chart.
@immutable
class NasikoBarDatum {
  const NasikoBarDatum({
    required this.label,
    required this.value,
    this.valueLabel,
    this.delta,
    this.color,
  });

  /// Row label shown at the start of the row (e.g. "gpt-4o").
  final String label;

  /// The bar's value, used to size the bar relative to the max in the set.
  final double value;

  /// Optional preformatted value label (e.g. "\$4.2k"). Falls back to a
  /// formatted [value] when null.
  final String? valueLabel;

  /// Optional trailing trend delta.
  final NasikoTrendDelta? delta;

  /// Optional explicit bar colour. Falls back to the chart's `barColor`.
  final Color? color;
}

/// One segment within a stacked bar.
@immutable
class NasikoStackedSegment {
  const NasikoStackedSegment({
    required this.name,
    required this.value,
    this.color,
  });

  /// Segment name, shown in the legend.
  final String name;

  /// The segment's value (its height within the stack).
  final double value;

  /// Explicit colour; falls back to a categorical colour by segment index.
  final Color? color;
}

/// One category (one bar) of a stacked bar chart.
@immutable
class NasikoStackedDatum {
  const NasikoStackedDatum({required this.label, required this.segments});

  /// Category label shown beneath the bar.
  final String label;

  /// The stacked segments, drawn bottom-to-top in order.
  final List<NasikoStackedSegment> segments;
}

/// One slice of a donut/pie chart.
@immutable
class NasikoDonutSegment {
  const NasikoDonutSegment({
    required this.label,
    required this.value,
    this.color,
  });

  /// Slice label, shown in the side legend.
  final String label;

  /// The slice's value; percentages are computed against the sum of all slices.
  final double value;

  /// Explicit colour; falls back to a categorical colour by slice index.
  final Color? color;
}

/// One row of a segmented-progress ("bar of dots") chart.
@immutable
class NasikoSegmentDatum {
  const NasikoSegmentDatum({
    required this.label,
    required this.percent,
    this.delta,
    this.color,
  });

  /// Row label (e.g. "Budget used").
  final String label;

  /// Progress as a fraction in the range 0.0–1.0.
  final double percent;

  /// Optional trailing trend delta.
  final NasikoTrendDelta? delta;

  /// Explicit filled-segment colour; falls back to the brand colour.
  final Color? color;
}
