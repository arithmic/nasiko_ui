import 'package:flutter/material.dart';

import '_color_palette.dart';
import 'color_palette_type.dart';
import 'colors.dart';

/// Factory class for creating [NasikoColorTheme] instances based on
/// different color palettes.
class NasikoColorThemeFactory {
  NasikoColorThemeFactory._();

  /// Creates a light theme using the specified [palette].
  ///
  /// Example:
  /// ```dart
  /// final blueTheme = NasikoColorThemeFactory.light(NasikoColorPalette.blue);
  /// ```
  static NasikoColorTheme light(NasikoColorPalette palette) {
    final brandColors = _getBrandColors(palette);

    return NasikoColorTheme(
      // Background Default
      backgroundBase: white,
      backgroundGroup: neutral50,
      backgroundSurface: neutral100,
      backgroundSurfaceHover: neutral200,
      backgroundSurfaceActive: neutral300,
      backgroundSurfaceSubtle: neutral500,
      backgroundOverlay: neutral500,
      backgroundDisabled: neutral200,

      // Background Primary - uses selected palette
      backgroundBrand: brandColors.primary,
      backgroundBrandHover: brandColors.primaryDark,
      backgroundBrandActive: brandColors.primaryMedium,
      backgroundBrandSubtle: brandColors.primaryLight,

      // Background Secondary - uses selected palette
      backgroundSecondaryBrand: brandColors.primaryLightest,
      backgroundSecondaryBrandHover: brandColors.primaryLight,
      backgroundSecondaryBrandActive: brandColors.primaryLightest,

      // Background Tertiary
      backgroundTertiary: purple500,

      // Background Feedback
      backgroundSuccess: green100,
      backgroundWarning: orange100,
      backgroundError: red100,
      backgroundInformation: blue100,

      // Foreground Default
      foregroundPrimary: neutral700,
      foregroundSecondary: neutral500,
      foregroundDisabled: neutral400,
      foregroundOnAction: white,
      foregroundIconPrimary: neutral700,
      foregroundIconSecondary: brandColors.primary,
      foregroundIconTertiary: neutral500,
      foregroundIconHover: brandColors.primaryDark,

      // Foreground Constant
      foregroundConstantWhite: white,
      foregroundConstantBlack: black,
      foregroundConstantBlackSecondary: neutral900,

      // Foreground Primary (Brand) - uses selected palette
      foregroundBrand: brandColors.primary,
      foregroundBrandHover: brandColors.primaryDark,
      foregroundBrandLink: brandColors.primary,
      foregroundBrandHighlight: brandColors.primaryMedium,

      // Foreground Feedback
      foregroundSuccess: green600,
      foregroundWarning: orange600,
      foregroundError: red600,
      foregroundInformation: blue600,

      // Border Default
      borderPrimary: neutral300,
      borderSecondary: brandColors.primary,
      borderHover: brandColors.primary,
      borderSuccess: green300,
      borderError: red300,
      borderWarning: orange300,
      borderInformation: blue300,
      borderDisabled: neutral200,
    );
  }

  /// Creates a dark theme using the specified [palette].
  ///
  /// Example:
  /// ```dart
  /// final blueDarkTheme = NasikoColorThemeFactory.dark(NasikoColorPalette.blue);
  /// ```
  static NasikoColorTheme dark(NasikoColorPalette palette) {
    final brandColors = _getBrandColors(palette);

    return NasikoColorTheme(
      // Background Default
      backgroundBase: black,
      backgroundGroup: neutral900,
      backgroundSurface: neutral800,
      backgroundSurfaceHover: neutral700,
      backgroundSurfaceActive: neutral600,
      backgroundSurfaceSubtle: neutral700,
      backgroundOverlay: neutral900,
      backgroundDisabled: neutral700,

      // Background Primary - uses selected palette
      backgroundBrand: brandColors.primary,
      backgroundBrandHover: brandColors.primaryLightest,
      backgroundBrandActive: brandColors.primaryMedium,
      backgroundBrandSubtle: brandColors.primaryDarkest,

      // Background Secondary - uses selected palette
      backgroundSecondaryBrand: brandColors.primaryDarkest,
      backgroundSecondaryBrandHover: brandColors.primaryDark,
      backgroundSecondaryBrandActive: brandColors.primaryDarkest,

      // Background Tertiary
      backgroundTertiary: purple500,

      // Background Feedback
      backgroundSuccess: green900,
      backgroundWarning: orange900,
      backgroundError: red900,
      backgroundInformation: blue900,

      // Foreground Default
      foregroundPrimary: neutral100,
      foregroundSecondary: neutral400,
      foregroundDisabled: neutral600,
      foregroundOnAction: neutral900,
      foregroundIconPrimary: neutral100,
      foregroundIconSecondary: brandColors.primary,
      foregroundIconTertiary: neutral400,
      foregroundIconHover: brandColors.primaryLightest,

      // Foreground Constant
      foregroundConstantWhite: white,
      foregroundConstantBlack: black,
      foregroundConstantBlackSecondary: neutral900,

      // Foreground Primary (Brand) - uses selected palette
      foregroundBrand: brandColors.primaryLightest,
      foregroundBrandHover: brandColors.primaryLight,
      foregroundBrandLink: brandColors.primaryLightest,
      foregroundBrandHighlight: brandColors.primaryLightest,

      // Foreground Feedback
      foregroundSuccess: green400,
      foregroundWarning: orange400,
      foregroundError: red400,
      foregroundInformation: blue400,

      // Border Default
      borderPrimary: neutral700,
      borderSecondary: brandColors.primary,
      borderHover: brandColors.primaryLightest,
      borderSuccess: green600,
      borderError: red600,
      borderWarning: orange600,
      borderInformation: blue600,
      borderDisabled: neutral700,
    );
  }

  /// Helper method to get the color mappings for a specific palette.
  static _BrandColors _getBrandColors(NasikoColorPalette palette) {
    switch (palette) {
      case NasikoColorPalette.yellow:
        return _BrandColors(
          primaryLightest: yellow100,
          primaryLight: yellow200,
          primaryMedium: yellow500,
          primary: yellow600,
          primaryDark: yellow800,
          primaryDarkest: yellow900,
        );
      case NasikoColorPalette.orange:
        return _BrandColors(
          primaryLightest: orange100,
          primaryLight: orange200,
          primaryMedium: orange500,
          primary: orange600,
          primaryDark: orange800,
          primaryDarkest: orange900,
        );
      case NasikoColorPalette.red:
        return _BrandColors(
          primaryLightest: red100,
          primaryLight: red200,
          primaryMedium: red500,
          primary: red600,
          primaryDark: red800,
          primaryDarkest: red900,
        );
      case NasikoColorPalette.purple:
        return _BrandColors(
          primaryLightest: purple100,
          primaryLight: purple200,
          primaryMedium: purple500,
          primary: purple600,
          primaryDark: purple800,
          primaryDarkest: purple900,
        );
      case NasikoColorPalette.blue:
        return _BrandColors(
          primaryLightest: blue100,
          primaryLight: blue200,
          primaryMedium: blue500,
          primary: blue600,
          primaryDark: blue800,
          primaryDarkest: blue900,
        );
      case NasikoColorPalette.teal:
        return _BrandColors(
          primaryLightest: teal100,
          primaryLight: teal200,
          primaryMedium: teal500,
          primary: teal600,
          primaryDark: teal800,
          primaryDarkest: teal900,
        );
      case NasikoColorPalette.green:
        return _BrandColors(
          primaryLightest: green100,
          primaryLight: green200,
          primaryMedium: green500,
          primary: green600,
          primaryDark: green800,
          primaryDarkest: green900,
        );
    }
  }
}

/// Internal helper class to hold brand color mappings
class _BrandColors {
  final Color primaryLightest; // 100
  final Color primaryLight; // 200
  final Color primaryMedium; // 500
  final Color primary; // 600
  final Color primaryDark; // 800
  final Color primaryDarkest; // 900

  _BrandColors({
    required this.primaryLightest,
    required this.primaryLight,
    required this.primaryMedium,
    required this.primary,
    required this.primaryDark,
    required this.primaryDarkest,
  });
}
