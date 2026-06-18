import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';
import 'scale.dart';

extension NasikoSpacingResolved on NasikoSpacingTheme {
  // Vertical
  double get s2h => s2.h;
  double get s4h => s4.h;
  double get s5h => s5.h;
  double get s6h => s6.h;
  double get s7h => s7.h;
  double get s8h => s8.h;
  double get s12h => s12.h;
  double get s16h => s16.h;
  double get s20h => s20.h;
  double get s24h => s24.h;
  double get s28h => s28.h;
  double get s36h => s36.h;
  double get s48h => s48.h;
  double get s64h => s64.h;
  double get s80h => s80.h;

  // Horizontal
  double get s2w => s2.w;
  double get s4w => s4.w;
  double get s5w => s5.w;
  double get s6w => s6.w;
  double get s7w => s7.w;
  double get s8w => s8.w;
  double get s12w => s12.w;
  double get s16w => s16.w;
  double get s20w => s20.w;
  double get s24w => s24.w;
  double get s28w => s28.w;
  double get s36w => s36.w;
  double get s48w => s48.w;
  double get s64w => s64.w;
  double get s80w => s80.w;

  // Uniform
  double get s2r => s2.r;
  double get s4r => s4.r;
  double get s5r => s5.r;
  double get s6r => s6.r;
  double get s7r => s7.r;
  double get s8r => s8.r;
  double get s12r => s12.r;
  double get s16r => s16.r;
  double get s20r => s20.r;
  double get s24r => s24.r;
  double get s28r => s28.r;
  double get s36r => s36.r;
  double get s48r => s48.r;
  double get s64r => s64.r;
  double get s80r => s80.r;
}

@immutable
class NasikoSpacingTheme extends ThemeExtension<NasikoSpacingTheme> {
  const NasikoSpacingTheme({
    required this.s0,
    required this.s2,
    required this.s4,
    required this.s5,
    required this.s6,
    required this.s7,
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
  final double s5;
  final double s6;
  final double s7;
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
    double? s5,
    double? s6,
    double? s7,
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
      s5: s5 ?? this.s5,
      s6: s6 ?? this.s6,
      s7: s7 ?? this.s7,
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
      s5: lerpDouble(s5, other.s5, t),
      s6: lerpDouble(s6, other.s6, t),
      s7: lerpDouble(s7, other.s7, t),
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
  s0: scale0,
  s2: scale2,
  s4: scale4,
  s5: scale5,
  s6: scale6,
  s7: scale7,
  s8: scale8,
  s12: scale12,
  s16: scale16,
  s20: scale20,
  s24: scale24,
  s28: scale28,
  s36: scale36,
  s48: scale48,
  s64: scale64,
  s80: scale80,
);

// --- BuildContext Extension ---
// Provides easy access like: `context.spacing.s16`
extension NasikoSpacingThemeExtension on BuildContext {
  NasikoSpacingTheme get spacing =>
      Theme.of(this).extension<NasikoSpacingTheme>()!;
}
