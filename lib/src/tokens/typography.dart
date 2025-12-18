// lib/src/tokens/app_typography.dart

import 'package:flutter/material.dart';

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

  @override
  NasikoTypography copyWith({
    // Titles
    TextStyle? titlePrimary,
    TextStyle? titleSecondary,
    // Buttons
    TextStyle? buttonPrimary,
    TextStyle? buttonSecondary,
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

const _baseTitlePrimary = TextStyle(
  fontFamily: _chivoMonoFontFamily,
  fontWeight: FontWeight.w500, // Medium
  fontSize: 40,
  height: 48 / 40, // Line height calculation
  letterSpacing: -0.04 * 40, // -4%
);

const _baseTitleSecondary = TextStyle(
  fontFamily: _chivoMonoFontFamily,
  fontWeight: FontWeight.w500, // Medium
  fontSize: 32,
  height: 38 / 32, // Line height calculation
  letterSpacing: -0.04 * 32, // -4%
);

const _baseButtonPrimary = TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w500, // Medium
  fontSize: 20,
  height: 24 / 20,
  letterSpacing: 0.0016 * 20, // 0.16%
);

const _baseButtonSecondary = TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w500, // Medium
  fontSize: 16,
  height: 20 / 16,
  letterSpacing: 0.0016 * 16, // 0.16%
);

const _baseBodyPrimary = TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400, // Regular
  fontSize: 20,
  height: 24 / 20,
  letterSpacing: 0,
);

const _baseBodyPrimaryBold = TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w700, // bold
  fontSize: 20,
  height: 24 / 20,
  letterSpacing: 0,
);

const _baseBodySecondary = TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400, // Regular
  fontSize: 16,
  height: 20 / 16,
  letterSpacing: 0,
);

const _baseBodySecondaryBold = TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w700, // Bold
  fontSize: 16,
  height: 20 / 16,
  letterSpacing: 0,
);

const _baseBodyTertiary = TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400, // Regular
  fontSize: 12,
  height: 16 / 12,
  letterSpacing: 0,
);

const _baseBodyTertiaryBold = TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w700, // Bold
  fontSize: 12,
  height: 16 / 12,
  letterSpacing: 0,
);

const _baseLinkPrimary = TextStyle(
  fontFamily: _interFontFamily,
  fontWeight: FontWeight.w400, // Regular
  fontSize: 16,
  height: 20 / 16,
  letterSpacing: 0,
);

const _baseCaption = TextStyle(
  fontFamily: _interFontFamily,
  fontStyle: FontStyle.italic, // Regular Italics
  fontWeight: FontWeight.w400,
  fontSize: 12,
  height: 16 / 12,
  letterSpacing: 0.0004 * 12, // 0.04%
);

const _baseCode = TextStyle(
  fontFamily:
      _interFontFamily, // Typically a monospace font, but Inter is specified
  fontWeight: FontWeight.w400, // Regular
  fontSize: 16,
  height: 20 / 16,
  letterSpacing: 0,
);

// --- Concrete Default Instance for your Design System ---
// This is what you'll typically provide as your default AppTypography
// in your main application's ThemeData.
const NasikoTypography defaultNasikoTypography = NasikoTypography(
  // Titles
  titlePrimary: _baseTitlePrimary,
  titleSecondary: _baseTitleSecondary,
  // Buttons
  buttonPrimary: _baseButtonPrimary,
  buttonSecondary: _baseButtonSecondary,
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
