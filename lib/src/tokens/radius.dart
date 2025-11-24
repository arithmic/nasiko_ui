import 'package:flutter/material.dart';

@immutable
class NasikoBorderRadiusTheme extends ThemeExtension<NasikoBorderRadiusTheme> {
  const NasikoBorderRadiusTheme({
    required this.r0,
    required this.r4,
    required this.r6,
    required this.r8,
    required this.r10,
    required this.r12,
    required this.r16,
    required this.r40,
  });

  // Define your border radius properties
  final double r0;
  final double r4;
  final double r6;
  final double r8;
  final double r10;
  final double r12;
  final double r16;
  final double r40;

  @override
  NasikoBorderRadiusTheme copyWith({
    double? r0,
    double? r4,
    double? r6,
    double? r8,
    double? r10,
    double? r12,
    double? r16,
    double? r40,
  }) {
    return NasikoBorderRadiusTheme(
      r0: r0 ?? this.r0,
      r4: r4 ?? this.r4,
      r6: r6 ?? this.r6,
      r8: r8 ?? this.r8,
      r10: r10 ?? this.r10,
      r12: r12 ?? this.r12,
      r16: r16 ?? this.r16,
      r40: r40 ?? this.r40,
    );
  }

  @override
  NasikoBorderRadiusTheme lerp(
    ThemeExtension<NasikoBorderRadiusTheme>? other,
    double t,
  ) {
    if (other is! NasikoBorderRadiusTheme) {
      return this;
    }

    // Helper for linear interpolation of doubles
    double lerpDouble(double a, double b, double t) {
      return a + (b - a) * t;
    }

    return NasikoBorderRadiusTheme(
      r0: lerpDouble(r0, other.r0, t),
      r4: lerpDouble(r4, other.r4, t),
      r6: lerpDouble(r6, other.r6, t),
      r8: lerpDouble(r8, other.r8, t),
      r10: lerpDouble(r10, other.r10, t),
      r12: lerpDouble(r12, other.r12, t),
      r16: lerpDouble(r16, other.r16, t),
      r40: lerpDouble(r40, other.r40, t),
    );
  }
}

// --- Default Border Radius Instance ---
const NasikoBorderRadiusTheme defaultNasikoBorderRadius =
    NasikoBorderRadiusTheme(
      r0: 0.0,
      r4: 4.0,
      r6: 6.0,
      r8: 8.0,
      r10: 10.0,
      r12: 12.0,
      r16: 16.0,
      r40: 40.0,
    );

// --- BuildContext Extension ---
// Provides easy access like: `context.radius.r8`
extension NasikoBorderRadiusThemeExtension on BuildContext {
  NasikoBorderRadiusTheme get radius =>
      Theme.of(this).extension<NasikoBorderRadiusTheme>()!;
}
