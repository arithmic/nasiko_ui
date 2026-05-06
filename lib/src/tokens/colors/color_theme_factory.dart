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
      backgroundGroup: Color.fromRGBO(224, 217, 204, 1),
      backgroundSurface: neutral100,
      backgroundSurfaceHover: Color.fromRGBO(245, 240, 232, 1),
      backgroundSurfaceActive: Color.fromRGBO(255, 253, 247, 1),
      backgroundSurfaceSubtle: Color.fromRGBO(240, 235, 224, 1),
      backgroundOverlay: Color.fromRGBO(28, 24, 18, .45),
      backgroundDisabled: Color.fromRGBO(237, 232, 224, 1),

      // Background Primary
      backgroundBrand: Color.fromRGBO(200, 146, 10, 1),
      backgroundBrandHover: Color.fromRGBO(168, 120, 8, 1),
      backgroundBrandActive: Color.fromRGBO(138, 96, 6, 1),
      backgroundBrandSubtle: Color.fromRGBO(245, 228, 190, 1),

      // Background Secondary - uses selected palette
      backgroundSecondaryBrand: brandColors.primaryLightest,
      backgroundSecondaryBrandHover: brandColors.primaryLight,
      backgroundSecondaryBrandActive: brandColors.primaryLightest,

      // Background Tertiary
      backgroundTertiary: purple500,

      // Background Feedback
      backgroundSuccess: Color.fromRGBO(40, 164, 106, 1),
      backgroundWarning: Color.fromRGBO(186, 117, 23, 1),
      backgroundError: Color.fromRGBO(192, 68, 10, 1),
      backgroundInformation: Color.fromRGBO(46, 84, 112, 1),

      // Foreground Default
      foregroundPrimary: Color.fromRGBO(28, 24, 18, 1),
      foregroundSecondary: Color.fromRGBO(107, 101, 88, 1),
      foregroundDisabled: Color.fromRGBO(176, 168, 158, 1),
      foregroundOnAction: white,
      foregroundIconPrimary: Color.fromRGBO(28, 24, 18, 1),
      foregroundIconSecondary: Color.fromRGBO(187, 143, 6, 1),
      foregroundIconTertiary: Color.fromRGBO(100, 116, 139, 1),
      foregroundIconHover: Color.fromRGBO(105, 81, 4, 1),

      // Foreground Constant
      foregroundConstantWhite: white,
      foregroundConstantBlack: Color.fromRGBO(28, 24, 18, 1),
      foregroundConstantBlackSecondary: Color.fromRGBO(44, 39, 32, 1),

      // Foreground Primary (Brand)
      foregroundBrand: Color.fromRGBO(200, 146, 10, 1),
      foregroundBrandHover: Color.fromRGBO(168, 120, 8, 1),
      foregroundBrandLink: Color.fromRGBO(200, 146, 10, 1),
      foregroundBrandHighlight: Color.fromRGBO(245, 228, 190, 1),

      // Foreground Feedback
      foregroundSuccess: Color.fromRGBO(26, 112, 72, 1),
      foregroundWarning: Color.fromRGBO(122, 85, 0, 1),
      foregroundError: Color.fromRGBO(139, 46, 16, 1),
      foregroundInformation: Color.fromRGBO(28, 61, 90, 1),

      // Border Default
      borderPrimary: Color.fromRGBO(208, 201, 188, 1),
      borderSecondary: yellow600,
      borderHover: Color.fromRGBO(200, 146, 10, 1),
      borderSuccess: Color.fromRGBO(40, 164, 106, 1),
      borderError: Color.fromRGBO(192, 68, 10, 1),
      borderWarning: Color.fromRGBO(186, 117, 23, 1),
      borderInformation: Color.fromRGBO(46, 84, 112, 1),
      borderDisabled: Color.fromRGBO(224, 217, 204, 1),
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
