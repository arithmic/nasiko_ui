import 'package:flutter/widgets.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Standard transition duration for chart touch/hover state changes, so all
/// charts animate their hovered-item highlight consistently.
const Duration kChartAnimationDuration = Duration(milliseconds: 250);

/// Standard easing for chart touch/hover state changes.
const Curve kChartAnimationCurve = Curves.easeOut;

/// Resolves the colour for the [index]-th series/segment: an explicit
/// [override] always wins, otherwise a categorical colour is taken from the
/// theme's chart-series palette (wrapping by index).
Color resolveSeriesColor(BuildContext context, int index, [Color? override]) {
  return override ?? context.colors.chartSeriesColor(index);
}

/// Formats a numeric value into a compact currency-ish label, e.g.
/// `1240 -> "$1.2k"`, `940000 -> "$940k"`. Used as the default formatter
/// when callers don't supply their own.
String defaultValueFormatter(double value) {
  final abs = value.abs();
  if (abs >= 1000000) {
    return '\$${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (abs >= 1000) {
    return '\$${(value / 1000).toStringAsFixed(1)}k';
  }
  return '\$${value.toStringAsFixed(0)}';
}

/// Formats a 0.0–1.0 fraction as a whole-number percentage, e.g. `0.72 -> "72%"`.
String defaultPercentFormatter(double fraction) {
  return '${(fraction * 100).round()}%';
}

/// The leading glyph for a [NasikoTrendDirection] (▲ / ▼ / —).
String trendArrow(NasikoTrendDirection direction) {
  switch (direction) {
    case NasikoTrendDirection.up:
      return '↑';
    case NasikoTrendDirection.down:
      return '↓';
    case NasikoTrendDirection.flat:
      return '→';
  }
}

/// The foreground colour for a [NasikoTrendDirection]: success (up),
/// error (down), or secondary (flat).
Color trendColor(BuildContext context, NasikoTrendDirection direction) {
  final colors = context.colors;
  switch (direction) {
    case NasikoTrendDirection.up:
      return colors.foregroundSuccess;
    case NasikoTrendDirection.down:
      return colors.foregroundError;
    case NasikoTrendDirection.flat:
      return colors.foregroundSecondary;
  }
}
