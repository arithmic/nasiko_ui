import 'package:flutter/material.dart';

import 'scale.dart';

@immutable
class NasikoIconSizeTheme extends ThemeExtension<NasikoIconSizeTheme> {
  const NasikoIconSizeTheme({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  /// 12 — tiny / secondary (small inputs & search, secondary list icon).
  final double xs;

  /// 16 — default workhorse (inputs, search, menu, most controls).
  final double sm;

  /// 20 — emphasis / large controls.
  final double md;

  /// 24 — headers, avatars.
  final double lg;

  /// 32 — empty states / feature.
  final double xl;

  @override
  NasikoIconSizeTheme copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return NasikoIconSizeTheme(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
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

    double lerpDouble(double a, double b, double t) {
      return a + (b - a) * t;
    }

    return NasikoIconSizeTheme(
      xs: lerpDouble(xs, other.xs, t),
      sm: lerpDouble(sm, other.sm, t),
      md: lerpDouble(md, other.md, t),
      lg: lerpDouble(lg, other.lg, t),
      xl: lerpDouble(xl, other.xl, t),
    );
  }
}

// --- Default Icon Size Instance ---
// Aliases scale/* primitives — no raw values.
const NasikoIconSizeTheme defaultNasikoIconSize = NasikoIconSizeTheme(
  xs: scale12,
  sm: scale16,
  md: scale20,
  lg: scale24,
  xl: scale32,
);

// --- BuildContext Extension ---
// Provides easy access like: `context.iconSize.sm`
extension NasikoIconSizeThemeExtension on BuildContext {
  NasikoIconSizeTheme get iconSize =>
      Theme.of(this).extension<NasikoIconSizeTheme>()!;
}
