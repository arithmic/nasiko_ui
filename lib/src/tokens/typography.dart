// lib/src/tokens/app_typography.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';
import 'scale.dart';

// --- Tier layer ---
// font/size/* and font/lineheight/* tiers, each pointing at a raw scale/*
// primitive. Roles below compose their TextStyles from these tiers so the
// scale -> tier -> role -> text-style cascade holds.

// Size tiers (px). (xs 8 exists in the ramp but no text style consumes it.)
const double _sizeSm = scale12; // 12
const double _sizeMd = scale13; // 13
const double _sizeLg = scale14; // 14
const double _sizeXl = scale20; // 20
const double _size2xl = scale28; // 28
// (3xl 40 exists in the ramp but no text style consumes it post-rescale.)

// Line-height tiers (px)
const double _lhSm = scale16; // 16
const double _lhMd = scale18; // 18
const double _lhLg = scale20; // 20
const double _lhXl = scale28; // 28
const double _lh2xl = scale36; // 36

// Helper: Flutter `height` is a multiplier (lineHeightPx / fontSizePx).
double _heightFor(double sizePx, double lineHeightPx) => lineHeightPx / sizePx;

// Mark the class as immutable for performance and consistency
@immutable
class NasikoTypography extends ThemeExtension<NasikoTypography> {
  const NasikoTypography({
    // Titles
    required this.titlePrimary,
    required this.titleSecondary,
    // Buttons
    required this.buttonPrimary,
    required this.buttonSecondary,
    required this.buttonPrimaryBold,
    required this.buttonSecondaryBold,
    // Body Text
    required this.bodyPrimary,
    required this.bodyPrimaryBold,
    required this.bodySecondary,
    required this.bodySecondaryBold,
    required this.bodyTertiary,
    required this.bodyTertiaryBold,
    // Links
    required this.linkPrimary,
    // Caption
    required this.caption,
    // Code
    required this.code,
  });

  // Titles
  final TextStyle titlePrimary;
  final TextStyle titleSecondary;
  // Buttons
  final TextStyle buttonPrimary;
  final TextStyle buttonSecondary;
  final TextStyle buttonPrimaryBold;
  final TextStyle buttonSecondaryBold;
  // Body Text
  final TextStyle bodyPrimary;
  final TextStyle bodyPrimaryBold;
  final TextStyle bodySecondary;
  final TextStyle bodySecondaryBold;
  final TextStyle bodyTertiary;
  final TextStyle bodyTertiaryBold;
  // Links
  final TextStyle linkPrimary;
  // Caption
  final TextStyle caption;
  // Code
  final TextStyle code;

  NasikoTypography withColor(Color color) {
    return copyWith(
      titlePrimary: titlePrimary.copyWith(color: color),
      titleSecondary: titleSecondary.copyWith(color: color),
      buttonPrimary: buttonPrimary.copyWith(color: color),
      buttonSecondary: buttonSecondary.copyWith(color: color),
      buttonPrimaryBold: buttonPrimaryBold.copyWith(color: color),
      buttonSecondaryBold: buttonSecondaryBold.copyWith(color: color),
      bodyPrimary: bodyPrimary.copyWith(color: color),
      bodyPrimaryBold: bodyPrimaryBold.copyWith(color: color),
      bodySecondary: bodySecondary.copyWith(color: color),
      bodySecondaryBold: bodySecondaryBold.copyWith(color: color),
      bodyTertiary: bodyTertiary.copyWith(color: color),
      bodyTertiaryBold: bodyTertiaryBold.copyWith(color: color),
      linkPrimary: linkPrimary.copyWith(color: color, decorationColor: color),
      caption: caption.copyWith(color: color),
      code: code.copyWith(color: color),
    );
  }

  @override
  NasikoTypography copyWith({
    // Titles
    TextStyle? titlePrimary,
    TextStyle? titleSecondary,
    // Buttons
    TextStyle? buttonPrimary,
    TextStyle? buttonSecondary,
    TextStyle? buttonPrimaryBold,
    TextStyle? buttonSecondaryBold,
    // Body Text
    TextStyle? bodyPrimary,
    TextStyle? bodyPrimaryBold,
    TextStyle? bodySecondary,
    TextStyle? bodySecondaryBold,
    TextStyle? bodyTertiary,
    TextStyle? bodyTertiaryBold,
    // Links
    TextStyle? linkPrimary,
    // Caption
    TextStyle? caption,
    // Code
    TextStyle? code,
  }) {
    return NasikoTypography(
      titlePrimary: titlePrimary ?? this.titlePrimary,
      titleSecondary: titleSecondary ?? this.titleSecondary,
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      buttonSecondary: buttonSecondary ?? this.buttonSecondary,
      buttonPrimaryBold: buttonPrimaryBold ?? this.buttonPrimaryBold,
      buttonSecondaryBold: buttonSecondaryBold ?? this.buttonSecondaryBold,
      bodyPrimary: bodyPrimary ?? this.bodyPrimary,
      bodyPrimaryBold: bodyPrimaryBold ?? this.bodyPrimaryBold,
      bodySecondary: bodySecondary ?? this.bodySecondary,
      bodySecondaryBold: bodySecondaryBold ?? this.bodySecondaryBold,
      bodyTertiary: bodyTertiary ?? this.bodyTertiary,
      bodyTertiaryBold: bodyTertiaryBold ?? this.bodyTertiaryBold,
      linkPrimary: linkPrimary ?? this.linkPrimary,
      caption: caption ?? this.caption,
      code: code ?? this.code,
    );
  }

  @override
  NasikoTypography lerp(ThemeExtension<NasikoTypography>? other, double t) {
    if (other is! NasikoTypography) {
      return this;
    }
    return NasikoTypography(
      titlePrimary: TextStyle.lerp(titlePrimary, other.titlePrimary, t)!,
      titleSecondary: TextStyle.lerp(titleSecondary, other.titleSecondary, t)!,
      buttonPrimary: TextStyle.lerp(buttonPrimary, other.buttonPrimary, t)!,
      buttonSecondary: TextStyle.lerp(
        buttonSecondary,
        other.buttonSecondary,
        t,
      )!,
      buttonPrimaryBold: TextStyle.lerp(
        buttonPrimaryBold,
        other.buttonPrimaryBold,
        t,
      )!,
      buttonSecondaryBold: TextStyle.lerp(
        buttonSecondaryBold,
        other.buttonSecondaryBold,
        t,
      )!,
      bodyPrimary: TextStyle.lerp(bodyPrimary, other.bodyPrimary, t)!,
      bodyPrimaryBold: TextStyle.lerp(
        bodyPrimaryBold,
        other.bodyPrimaryBold,
        t,
      )!,
      bodySecondary: TextStyle.lerp(bodySecondary, other.bodySecondary, t)!,
      bodySecondaryBold: TextStyle.lerp(
        bodySecondaryBold,
        other.bodySecondaryBold,
        t,
      )!,
      bodyTertiary: TextStyle.lerp(bodyTertiary, other.bodyTertiary, t)!,
      bodyTertiaryBold: TextStyle.lerp(
        bodyTertiaryBold,
        other.bodyTertiaryBold,
        t,
      )!,
      linkPrimary: TextStyle.lerp(linkPrimary, other.linkPrimary, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      code: TextStyle.lerp(code, other.code, t)!,
    );
  }
}

// Helper extension on BuildContext to easily access AppTypography
extension NasikoTypographyExtension on BuildContext {
  NasikoTypography get typography =>
      Theme.of(this).extension<NasikoTypography>()!;
}

// --- Default Typography Definitions ---
// You will need to ensure these fonts are included in your pubspec.yaml
// and available in your project.

// Chivo Mono is for Titles and Buttons
const String _chivoMonoFontFamily = 'Chivo Mono';
// Inter is for Body, Links, Caption, and Code
const String _interFontFamily = 'Inter';

// Letter spacing values are multiplied by font size,
// so 0.016 is 1.6% of the font size.

// title/primary — 28 / 36
TextStyle get _baseTitlePrimary => TextStyle(
  fontFamily: _chivoMonoFontFamily,
  fontWeight: FontWeight.w500, // Medium
  fontSize: _size2xl.sp.clamp(24, 32),
  height: _heightFor(_size2xl, _lh2xl),
  letterSpacing: 0.16,
);

// title/secondary — 20 / 28
TextStyle get _baseTitleSecondary => TextStyle(
  fontFamily: _chivoMonoFontFamily,
  fontWeight: FontWeight.w500, // Medium
  fontSize: _sizeXl.sp.clamp(18, 24),
  height: _heightFor(_sizeXl, _lhXl),
  letterSpacing: 0.16,
);

// buttons/primary — 14 / 20
TextStyle get _baseButtonPrimary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w500, // Medium
  fontSize: _sizeLg.sp.clamp(12, 16),
  height: _heightFor(_sizeLg, _lhLg),
  letterSpacing: 0.16,
);

TextStyle get _baseButtonPrimaryBold =>
    _baseButtonPrimary.copyWith(fontWeight: FontWeight.w700);

// buttons/secondary — 13 / 18
TextStyle get _baseButtonSecondary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w500, // Medium
  fontSize: _sizeMd.sp.clamp(11, 15),
  height: _heightFor(_sizeMd, _lhMd),
  letterSpacing: 0.16,
);

TextStyle get _baseButtonSecondaryBold =>
    _baseButtonSecondary.copyWith(fontWeight: FontWeight.w700);

// body/primary — 14 / 20
TextStyle get _baseBodyPrimary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400, // Regular
  fontSize: _sizeLg.sp.clamp(12, 16),
  height: _heightFor(_sizeLg, _lhLg),
);

TextStyle get _baseBodyPrimaryBold =>
    _baseBodyPrimary.copyWith(fontWeight: FontWeight.w700);

// body/secondary — 13 / 18
TextStyle get _baseBodySecondary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400, // Regular
  fontSize: _sizeMd.sp.clamp(11, 15),
  height: _heightFor(_sizeMd, _lhMd),
);

TextStyle get _baseBodySecondaryBold =>
    _baseBodySecondary.copyWith(fontWeight: FontWeight.w700);

// body/tertiary — 12 / 16 (unchanged)
TextStyle get _baseBodyTertiary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400, // Regular
  fontSize: _sizeSm.sp.clamp(10, 14),
  height: _heightFor(_sizeSm, _lhSm),
);

TextStyle get _baseBodyTertiaryBold =>
    _baseBodyTertiary.copyWith(fontWeight: FontWeight.w700);

// link/primary — 14 / 20
TextStyle get _baseLinkPrimary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400, // Regular
  fontSize: _sizeLg.sp.clamp(12, 16),
  height: _heightFor(_sizeLg, _lhLg),
  decoration: TextDecoration.underline,
);

// caption — 12 / 16 (unchanged)
TextStyle get _baseCaption => TextStyle(
  fontFamily: _interFontFamily,
  fontStyle: FontStyle.italic, // Regular Italics
  fontWeight: FontWeight.w400,
  fontSize: _sizeSm.sp.clamp(10, 14),
  height: _heightFor(_sizeSm, _lhSm),
  letterSpacing: -0.04,
);

// code/primary — 13 / 18
TextStyle get _baseCode => TextStyle(
  fontFamily: _chivoMonoFontFamily,
  fontWeight: FontWeight.w400, // Regular
  fontSize: _sizeMd.sp.clamp(11, 15),
  height: _heightFor(_sizeMd, _lhMd),
  letterSpacing: 0,
);

// --- Concrete Default Instance for your Design System ---
// This is what you'll typically provide as your default AppTypography
// in your main application's ThemeData.
NasikoTypography get defaultNasikoTypography => NasikoTypography(
  // Titles
  titlePrimary: _baseTitlePrimary,
  titleSecondary: _baseTitleSecondary,
  // Buttons
  buttonPrimary: _baseButtonPrimary,
  buttonSecondary: _baseButtonSecondary,
  buttonPrimaryBold: _baseButtonPrimaryBold,
  buttonSecondaryBold: _baseButtonSecondaryBold,
  // Body Text
  bodyPrimary: _baseBodyPrimary,
  bodyPrimaryBold: _baseBodyPrimaryBold,
  bodySecondary: _baseBodySecondary,
  bodySecondaryBold: _baseBodySecondaryBold,
  bodyTertiary: _baseBodyTertiary,
  bodyTertiaryBold: _baseBodyTertiaryBold,
  // Links
  linkPrimary: _baseLinkPrimary,
  // Caption
  caption: _baseCaption,
  // Code
  code: _baseCode,
);

NasikoTypography defaultNasikoTypographyWithColor(Color color) {
  return defaultNasikoTypography.withColor(color);
}
