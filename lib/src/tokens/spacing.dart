import 'package:flutter/material.dart';

@immutable
class NasikoSpacingTheme extends ThemeExtension<NasikoSpacingTheme> {
  const NasikoSpacingTheme({
    required this.s0,
    required this.s2,
    required this.s4,
    required this.s8,
    required this.s12,
    required this.s16,
    required this.s20,
    required this.s24,
    required this.s28,
    required this.s36,
    required this.s48,
    required this.s64,
    required this.s80,
  });

  final double s0;
  final double s2;
  final double s4;
  final double s8;
  final double s12;
  final double s16;
  final double s20;
  final double s24;
  final double s28;
  final double s36;
  final double s48;
  final double s64;
  final double s80;

  @override
  NasikoSpacingTheme copyWith({
    double? s0,
    double? s2,
    double? s4,
    double? s8,
    double? s12,
    double? s16,
    double? s20,
    double? s24,
    double? s28,
    double? s36,
    double? s48,
    double? s64,
    double? s80,
  }) {
    return NasikoSpacingTheme(
      s0: s0 ?? this.s0,
      s2: s2 ?? this.s2,
      s4: s4 ?? this.s4,
      s8: s8 ?? this.s8,
      s12: s12 ?? this.s12,
      s16: s16 ?? this.s16,
      s20: s20 ?? this.s20,
      s24: s24 ?? this.s24,
      s28: s28 ?? this.s28,
      s36: s36 ?? this.s36,
      s48: s48 ?? this.s48,
      s64: s64 ?? this.s64,
      s80: s80 ?? this.s80,
    );
  }

  @override
  NasikoSpacingTheme lerp(ThemeExtension<NasikoSpacingTheme>? other, double t) {
    if (other is! NasikoSpacingTheme) {
      return this;
    }

    // Helper for linear interpolation of doubles
    double lerpDouble(double a, double b, double t) {
      return a + (b - a) * t;
    }

    return NasikoSpacingTheme(
      s0: lerpDouble(s0, other.s0, t),
      s2: lerpDouble(s2, other.s2, t),
      s4: lerpDouble(s4, other.s4, t),
      s8: lerpDouble(s8, other.s8, t),
      s12: lerpDouble(s12, other.s12, t),
      s16: lerpDouble(s16, other.s16, t),
      s20: lerpDouble(s20, other.s20, t),
      s24: lerpDouble(s24, other.s24, t),
      s28: lerpDouble(s28, other.s28, t),
      s36: lerpDouble(s36, other.s36, t),
      s48: lerpDouble(s48, other.s48, t),
      s64: lerpDouble(s64, other.s64, t),
      s80: lerpDouble(s80, other.s80, t),
    );
  }
}

// --- Default Spacing Instance ---
// This is the single source of truth for your spacing values
const NasikoSpacingTheme defaultNasikoSpacing = NasikoSpacingTheme(
  s0: 0.0,
  s2: 2.0,
  s4: 4.0,
  s8: 8.0,
  s12: 12.0,
  s16: 16.0,
  s20: 20.0,
  s24: 24.0,
  s28: 28.0,
  s36: 36.0,
  s48: 48.0,
  s64: 64.0,
  s80: 80.0,
);

// --- BuildContext Extension ---
// Provides easy access like: `context.spacing.s16`
extension NasikoSpacingThemeExtension on BuildContext {
  NasikoSpacingTheme get spacing =>
      Theme.of(this).extension<NasikoSpacingTheme>()!;
}
