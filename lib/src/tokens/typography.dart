// lib/src/tokens/app_typography.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

@immutable
class NasikoTypography extends ThemeExtension<NasikoTypography> {
  const NasikoTypography({
    required this.titlePrimary,
    required this.titleSecondary,
    required this.buttonPrimary,
    required this.buttonSecondary,
    required this.bodyPrimary,
    required this.bodyPrimaryBold,
    required this.bodySecondary,
    required this.bodySecondaryBold,
    required this.bodyTertiary,
    required this.bodyTertiaryBold,
    required this.linkPrimary,
    required this.caption,
    required this.code,
  });

  final TextStyle titlePrimary;
  final TextStyle titleSecondary;

  final TextStyle buttonPrimary;
  final TextStyle buttonSecondary;

  final TextStyle bodyPrimary;
  final TextStyle bodyPrimaryBold;
  final TextStyle bodySecondary;
  final TextStyle bodySecondaryBold;
  final TextStyle bodyTertiary;
  final TextStyle bodyTertiaryBold;

  final TextStyle linkPrimary;
  final TextStyle caption;
  final TextStyle code;

  @override
  NasikoTypography copyWith({
    TextStyle? titlePrimary,
    TextStyle? titleSecondary,
    TextStyle? buttonPrimary,
    TextStyle? buttonSecondary,
    TextStyle? bodyPrimary,
    TextStyle? bodyPrimaryBold,
    TextStyle? bodySecondary,
    TextStyle? bodySecondaryBold,
    TextStyle? bodyTertiary,
    TextStyle? bodyTertiaryBold,
    TextStyle? linkPrimary,
    TextStyle? caption,
    TextStyle? code,
  }) {
    return NasikoTypography(
      titlePrimary: titlePrimary ?? this.titlePrimary,
      titleSecondary: titleSecondary ?? this.titleSecondary,
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      buttonSecondary: buttonSecondary ?? this.buttonSecondary,
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
    if (other is! NasikoTypography) return this;

    return NasikoTypography(
      titlePrimary: TextStyle.lerp(titlePrimary, other.titlePrimary, t)!,
      titleSecondary: TextStyle.lerp(titleSecondary, other.titleSecondary, t)!,
      buttonPrimary: TextStyle.lerp(buttonPrimary, other.buttonPrimary, t)!,
      buttonSecondary: TextStyle.lerp(
        buttonSecondary,
        other.buttonSecondary,
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

extension NasikoTypographyExtension on BuildContext {
  NasikoTypography get typography =>
      Theme.of(this).extension<NasikoTypography>()!;
}

// -----------------------------------------------------------------------------
// Font families
// -----------------------------------------------------------------------------

const String _chivoMonoFontFamily = 'Chivo Mono';
const String _interFontFamily = 'Inter';

// -----------------------------------------------------------------------------
// Base text styles (PARTIAL FONT SCALING APPLIED)
// -----------------------------------------------------------------------------

TextStyle get _baseTitlePrimary => TextStyle(
  fontFamily: _chivoMonoFontFamily,
  fontWeight: FontWeight.w500,
  fontSize: 40.sp.clamp(32, 44),
  height: 1.2,
  letterSpacing: 0.4,
);

TextStyle get _baseTitleSecondary => TextStyle(
  fontFamily: _chivoMonoFontFamily,
  fontWeight: FontWeight.w500,
  fontSize: 32.sp.clamp(26, 36),
  height: 1.15,
  letterSpacing: 0.3,
);

TextStyle get _baseButtonPrimary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w500,
  fontSize: 18.sp.clamp(16, 20),
  height: 1.2,
  letterSpacing: 0.2,
);

TextStyle get _baseButtonSecondary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w500,
  fontSize: 16.sp.clamp(14, 18),
  height: 1.25,
  letterSpacing: 0.2,
);

TextStyle get _baseBodyPrimary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400,
  fontSize: 16.sp.clamp(14, 18),
  height: 1.4,
);

TextStyle get _baseBodyPrimaryBold =>
    _baseBodyPrimary.copyWith(fontWeight: FontWeight.w700);

TextStyle get _baseBodySecondary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400,
  fontSize: 14.sp.clamp(13, 16),
  height: 1.4,
);

TextStyle get _baseBodySecondaryBold =>
    _baseBodySecondary.copyWith(fontWeight: FontWeight.w700);

TextStyle get _baseBodyTertiary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400,
  fontSize: 12.sp.clamp(11, 14),
  height: 1.35,
);

TextStyle get _baseBodyTertiaryBold =>
    _baseBodyTertiary.copyWith(fontWeight: FontWeight.w700);

TextStyle get _baseLinkPrimary => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w500,
  fontSize: 14.sp.clamp(13, 16),
  height: 1.3,
  decoration: TextDecoration.underline,
);

TextStyle get _baseCaption => TextStyle(
  fontFamily: _interFontFamily,
  fontStyle: FontStyle.italic,
  fontWeight: FontWeight.w400,
  fontSize: 12.sp.clamp(11, 13),
  height: 1.3,
  letterSpacing: -0.2,
);

TextStyle get _baseCode => TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400,
  fontSize: 14.sp.clamp(13, 16),
  height: 1.4,
);

// -----------------------------------------------------------------------------
// Default instance
// -----------------------------------------------------------------------------

NasikoTypography get defaultNasikoTypography => NasikoTypography(
  titlePrimary: _baseTitlePrimary,
  titleSecondary: _baseTitleSecondary,
  buttonPrimary: _baseButtonPrimary,
  buttonSecondary: _baseButtonSecondary,
  bodyPrimary: _baseBodyPrimary,
  bodyPrimaryBold: _baseBodyPrimaryBold,
  bodySecondary: _baseBodySecondary,
  bodySecondaryBold: _baseBodySecondaryBold,
  bodyTertiary: _baseBodyTertiary,
  bodyTertiaryBold: _baseBodyTertiaryBold,
  linkPrimary: _baseLinkPrimary,
  caption: _baseCaption,
  code: _baseCode,
);
