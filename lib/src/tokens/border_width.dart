import 'package:flutter/material.dart';

@immutable
class NasikoBorderWidthTheme extends ThemeExtension<NasikoBorderWidthTheme> {
  const NasikoBorderWidthTheme({
    required this.w0,
    required this.w1,
    required this.w2,
    required this.w4,
    required this.w8,
  });

  // Define your border width properties
  final double w0;
  final double w1;
  final double w2;
  final double w4;
  final double w8;

  @override
  NasikoBorderWidthTheme copyWith({
    double? w0,
    double? w1,
    double? w2,
    double? w4,
    double? w8,
  }) {
    return NasikoBorderWidthTheme(
      w0: w0 ?? this.w0,
      w1: w1 ?? this.w1,
      w2: w2 ?? this.w2,
      w4: w4 ?? this.w4,
      w8: w8 ?? this.w8,
    );
  }

  @override
  NasikoBorderWidthTheme lerp(
    ThemeExtension<NasikoBorderWidthTheme>? other,
    double t,
  ) {
    if (other is! NasikoBorderWidthTheme) {
      return this;
    }

    // Helper for linear interpolation of doubles
    double lerpDouble(double a, double b, double t) {
      return a + (b - a) * t;
    }

    return NasikoBorderWidthTheme(
      w0: lerpDouble(w0, other.w0, t),
      w1: lerpDouble(w1, other.w1, t),
      w2: lerpDouble(w2, other.w2, t),
      w4: lerpDouble(w4, other.w4, t),
      w8: lerpDouble(w8, other.w8, t),
    );
  }
}

// --- Default Border Width Instance ---
const NasikoBorderWidthTheme defaultNasikoBorderWidth = NasikoBorderWidthTheme(
  w0: 0.0,
  w1: 1.0,
  w2: 2.0,
  w4: 4.0,
  w8: 8.0,
);

// --- BuildContext Extension ---
// Provides easy access like: `context.borderWidth.w1`
extension NasikoBorderWidthThemeExtension on BuildContext {
  NasikoBorderWidthTheme get borderWidth =>
      Theme.of(this).extension<NasikoBorderWidthTheme>()!;
}
