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
      backgroundGroup: sand50,
      backgroundSurface: sand100,
      backgroundSurfaceHover: sand200,
      backgroundSurfaceActive: sand300,
      backgroundSurfaceSubtle: sand200,
      backgroundOverlay: sand600.withValues(alpha: 0.4),
      backgroundDisabled: sand200,

      // Background Primary
      backgroundBrand: brandColors.primary,
      backgroundBrandHover: brandColors.primaryDark,
      backgroundBrandActive: brandColors.primary,
      backgroundBrandSubtle: brandColors.primaryLight,

      // Background Secondary
      backgroundSecondaryBrand: brandColors.primaryLightest,
      backgroundSecondaryBrandHover: brandColors.primaryLight,
      backgroundSecondaryBrandActive: brandColors.primaryLightest,

      // Background Feedback
      backgroundSuccess: green100,
      backgroundWarning: orange100,
      backgroundError: red100,
      backgroundInformation: brandColors.primaryLightest50,
      backgroundInformationOverlay: sand800,

      // Foreground Default
      foregroundPrimary: sand900,
      foregroundSecondary: sand700,
      foregroundDisabled: sand500,
      foregroundOnAction: white,
      foregroundIconPrimary: sand900,
      foregroundIconSecondary: brandColors.primary,
      foregroundIconTertiary: sand500,
      foregroundIconHover: brandColors.primaryDark,

      // Foreground Constant
      foregroundConstantWhite: white,
      foregroundConstantBlack: sand900,
      foregroundConstantBlackSecondary: sand800,
      foregroundPrimaryHover: sand800,

      // Foreground Primary (Brand)
      foregroundBrand: brandColors.primary,
      foregroundBrandHover: brandColors.primaryDark,
      foregroundBrandLink: brandColors.primary,
      foregroundBrandHighlight: brandColors.primaryMedium,

      // Foreground Feedback
      foregroundSuccess: green600,
      foregroundWarning: orange600,
      foregroundError: red600,
      foregroundInformation: brandColors.primaryDark,
      foregroundInformationOverlay: sand400,

      // Border Default
      borderPrimary: sand300,
      borderSecondary: brandColors.primary,
      borderHover: brandColors.primaryDark,
      borderSuccess: green300,
      borderError: red200,
      borderWarning: orange300,
      borderDisabled: sand300,
      borderInformation: brandColors.primaryHover,
      borderInformationOverlay: sand800,
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
      // Background Default — warm elevation ramp over a near-black base
      // (pure black reads harsh and kills the sense of surface depth).
      backgroundBase: sandDark950,
      backgroundGroup: sandDark900,
      backgroundSurface: sandDark850,
      backgroundSurfaceHover: sandDark800,
      backgroundSurfaceActive: sand800,
      backgroundSurfaceSubtle: sandDark900,
      backgroundOverlay: black.withValues(alpha: 0.6),
      backgroundDisabled: sandDark800,

      // Background Primary
      backgroundBrand: brandColors.primary,
      backgroundBrandHover: brandColors.primaryAccent,
      backgroundBrandActive: brandColors.primaryMedium,
      backgroundBrandSubtle: brandColors.primaryDarkest,

      // Background Secondary
      backgroundSecondaryBrand: brandColors.primaryDarkest,
      backgroundSecondaryBrandHover: brandColors.primaryDark,
      backgroundSecondaryBrandActive: brandColors.primaryDarkest,

      // Background Feedback
      backgroundSuccess: green900,
      backgroundWarning: orange900,
      backgroundError: red900,
      backgroundInformation: brandColors.primaryDarkest,
      backgroundInformationOverlay: sand200.withValues(alpha: 0.5),

      // Foreground Default
      foregroundPrimary: sand100,
      foregroundSecondary: sand400,
      foregroundDisabled: sand600,
      foregroundOnAction: sand900,
      foregroundIconPrimary: sand100,
      foregroundIconSecondary: brandColors.primary,
      foregroundIconTertiary: sand400,
      foregroundIconHover: brandColors.primaryAccent,

      // Foreground Constant
      foregroundConstantWhite: white,
      foregroundConstantBlack: black,
      foregroundConstantBlackSecondary: sand900,
      foregroundPrimaryHover: sand200,

      // Foreground Primary (Brand)
      foregroundBrand: brandColors.primaryAccent,
      foregroundBrandHover: brandColors.primaryHover,
      foregroundBrandLink: brandColors.primaryAccent,
      foregroundBrandHighlight: brandColors.primaryAccent,

      // Foreground Feedback
      foregroundSuccess: green400,
      foregroundWarning: orange400,
      foregroundError: red400,
      foregroundInformation: brandColors.primaryHover,
      foregroundInformationOverlay: sand700,

      // Border Default — hairlines one ramp-step above their surfaces;
      // sand700 is a mid-tone brown that overpowered dark hairlines.
      borderPrimary: sand800,
      borderSecondary: brandColors.primary,
      borderHover: brandColors.primaryAccent,
      borderSuccess: green600,
      borderError: red600,
      borderWarning: orange600,
      borderDisabled: sandDark800,
      borderInformation: brandColors.primaryDarkAccent,
      borderInformationOverlay: sand200,
    );
  }

  static _BrandColors _getBrandColors(NasikoColorPalette palette) {
    switch (palette) {
      case NasikoColorPalette.yellow:
        return _BrandColors(
          primaryLightest50: yellow50,
          primaryLightest: yellow100,
          primaryLight: yellow200,
          primaryHover: yellow300,
          primaryAccent: yellow400,
          primaryMedium: yellow500,
          primary: yellow600,
          primaryDarkAccent: yellow700,
          primaryDark: yellow800,
          primaryDarkest: yellow900,
        );
      case NasikoColorPalette.orange:
        return _BrandColors(
          primaryLightest50: orange50,
          primaryLightest: orange100,
          primaryLight: orange200,
          primaryHover: orange300,
          primaryAccent: orange400,
          primaryMedium: orange500,
          primary: orange600,
          primaryDarkAccent: orange700,
          primaryDark: orange800,
          primaryDarkest: orange900,
        );
      case NasikoColorPalette.red:
        return _BrandColors(
          primaryLightest50: red50,
          primaryLightest: red100,
          primaryLight: red200,
          primaryHover: red300,
          primaryAccent: red400,
          primaryMedium: red500,
          primary: red600,
          primaryDarkAccent: red700,
          primaryDark: red800,
          primaryDarkest: red900,
        );
      case NasikoColorPalette.purple:
        return _BrandColors(
          primaryLightest50: purple50,
          primaryLightest: purple100,
          primaryLight: purple200,
          primaryHover: purple300,
          primaryAccent: purple400,
          primaryMedium: purple500,
          primary: purple600,
          primaryDarkAccent: purple700,
          primaryDark: purple800,
          primaryDarkest: purple900,
        );
      case NasikoColorPalette.blue:
        return _BrandColors(
          primaryLightest50: blue50,
          primaryLightest: blue100,
          primaryLight: blue200,
          primaryHover: blue300,
          primaryAccent: blue400,
          primaryMedium: blue500,
          primary: blue600,
          primaryDarkAccent: blue700,
          primaryDark: blue800,
          primaryDarkest: blue900,
        );
      case NasikoColorPalette.teal:
        return _BrandColors(
          primaryLightest50: teal50,
          primaryLightest: teal100,
          primaryLight: teal200,
          primaryHover: teal300,
          primaryAccent: teal400,
          primaryMedium: teal500,
          primary: teal600,
          primaryDarkAccent: teal700,
          primaryDark: teal800,
          primaryDarkest: teal900,
        );
      case NasikoColorPalette.green:
        return _BrandColors(
          primaryLightest50: green50,
          primaryLightest: green100,
          primaryLight: green200,
          primaryHover: green300,
          primaryAccent: green400,
          primaryMedium: green500,
          primary: green600,
          primaryDarkAccent: green700,
          primaryDark: green800,
          primaryDarkest: green900,
        );
      case NasikoColorPalette.sand:
        return _BrandColors(
          primaryLightest50: sand50,
          primaryLightest: sand100,
          primaryLight: sand200,
          primaryHover: sand300,
          primaryAccent: sand400,
          primaryMedium: sand500,
          primary: sand600,
          primaryDarkAccent: sand700,
          primaryDark: sand800,
          primaryDarkest: sand900,
        );
    }
  }
}

class _BrandColors {
  final Color primaryLightest50; // 50
  final Color primaryLightest;   // 100
  final Color primaryLight;      // 200
  final Color primaryHover;      // 300
  final Color primaryAccent;     // 400
  final Color primaryMedium;     // 500
  final Color primary;           // 600
  final Color primaryDarkAccent; // 700
  final Color primaryDark;       // 800
  final Color primaryDarkest;    // 900

  _BrandColors({
    required this.primaryLightest50,
    required this.primaryLightest,
    required this.primaryLight,
    required this.primaryHover,
    required this.primaryAccent,
    required this.primaryMedium,
    required this.primary,
    required this.primaryDarkAccent,
    required this.primaryDark,
    required this.primaryDarkest,
  });
}
