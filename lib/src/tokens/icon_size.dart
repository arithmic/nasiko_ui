// lib/src/tokens/nasiko_icon_size.dart

import 'package:flutter/material.dart';

@immutable
class NasikoIconSizeTheme extends ThemeExtension<NasikoIconSizeTheme> {
  const NasikoIconSizeTheme({
    required this.l,
    required this.m,
    required this.s,
    required this.xs,
  });

  // Define your icon size properties
  final double l;
  final double m;
  final double s;
  final double xs;

  @override
  NasikoIconSizeTheme copyWith({double? l, double? m, double? s, double? xs}) {
    return NasikoIconSizeTheme(
      l: l ?? this.l,
      m: m ?? this.m,
      s: s ?? this.s,
      xs: xs ?? this.xs,
    );
  }

  @override
  NasikoIconSizeTheme lerp(
    ThemeExtension<NasikoIconSizeTheme>? other,
    double t,
  ) {
    if (other is! NasikoIconSizeTheme) {
      return this;
    }

    // Helper for linear interpolation of doubles
    double lerpDouble(double a, double b, double t) {
      return a + (b - a) * t;
    }

    return NasikoIconSizeTheme(
      l: lerpDouble(l, other.l, t),
      m: lerpDouble(m, other.m, t),
      s: lerpDouble(s, other.s, t),
      xs: lerpDouble(xs, other.xs, t),
    );
  }
}

// --- Default Icon Size Instance ---
const NasikoIconSizeTheme defaultNasikoIconSize = NasikoIconSizeTheme(
  l: 28.0,
  m: 24.0,
  s: 20.0,
  xs: 16.0,
);

// --- BuildContext Extension ---
// Provides easy access like: `context.iconSize.l`
extension NasikoIconSizeThemeExtension on BuildContext {
  NasikoIconSizeTheme get iconSize =>
      Theme.of(this).extension<NasikoIconSizeTheme>()!;
}
