import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/colors/_color_palette.dart';
import 'package:nasiko_ui/src/tokens/colors/color_palette_type.dart';

/// Factory class for creating Material [ColorScheme] instances based on
/// different color palettes.
class NasikoColorSchemeFactory {
  NasikoColorSchemeFactory._();

  /// Creates a Material light color scheme using the specified [palette].
  static ColorScheme light(NasikoColorPalette palette) {
    final brandColors = _getPaletteColors(palette);

    return ColorScheme(
      brightness: Brightness.light,
      primary: brandColors.primary,
      onPrimary: white,
      primaryContainer: brandColors.primaryLightest,
      onPrimaryContainer: sand700,
      secondary: sand500,
      onSecondary: sand700,
      secondaryContainer: sand50,
      onSecondaryContainer: sand700,
      tertiary: blue100,
      onTertiary: white,
      tertiaryContainer: blue100,
      onTertiaryContainer: blue500,
      error: red100,
      onError: red500,
      errorContainer: red100,
      onErrorContainer: red500,
      surface: sand100,
      onSurface: sand700,
      surfaceContainerHighest: sand500,
      onSurfaceVariant: sand500,
      outline: sand300,
      outlineVariant: sand200,
      shadow: black,
      scrim: black,
      inverseSurface: sand800,
      onInverseSurface: sand100,
      inversePrimary: brandColors.primary,
      surfaceTint: brandColors.primary,
    );
  }

  /// Creates a Material dark color scheme using the specified [palette].
  static ColorScheme dark(NasikoColorPalette palette) {
    final brandColors = _getPaletteColors(palette);

    return ColorScheme(
      brightness: Brightness.dark,
      primary: brandColors.primary,
      onPrimary: sand900,
      primaryContainer: brandColors.primaryDarkest,
      onPrimaryContainer: sand100,
      secondary: sand700,
      onSecondary: sand100,
      secondaryContainer: sand900,
      onSecondaryContainer: sand100,
      tertiary: blue900,
      onTertiary: sand900,
      tertiaryContainer: blue900,
      onTertiaryContainer: blue400,
      error: red900,
      onError: red400,
      errorContainer: red900,
      onErrorContainer: red400,
      surface: sand800,
      onSurface: sand100,
      surfaceContainerHighest: sand700,
      onSurfaceVariant: sand400,
      outline: sand700,
      outlineVariant: sand700,
      shadow: black,
      scrim: black,
      inverseSurface: sand100,
      onInverseSurface: sand800,
      inversePrimary: brandColors.primary,
      surfaceTint: brandColors.primary,
    );
  }

  /// Helper method to get palette-specific colors
  static _PaletteColors _getPaletteColors(NasikoColorPalette palette) {
    switch (palette) {
      case NasikoColorPalette.yellow:
        return _PaletteColors(
          primaryLightest: yellow100,
          primary: yellow500,
          primaryDarkest: yellow900,
        );
      case NasikoColorPalette.orange:
        return _PaletteColors(
          primaryLightest: orange100,
          primary: orange500,
          primaryDarkest: orange900,
        );
      case NasikoColorPalette.red:
        return _PaletteColors(
          primaryLightest: red100,
          primary: red500,
          primaryDarkest: red900,
        );
      case NasikoColorPalette.purple:
        return _PaletteColors(
          primaryLightest: purple100,
          primary: purple500,
          primaryDarkest: purple900,
        );
      case NasikoColorPalette.blue:
        return _PaletteColors(
          primaryLightest: blue100,
          primary: blue500,
          primaryDarkest: blue900,
        );
      case NasikoColorPalette.teal:
        return _PaletteColors(
          primaryLightest: teal100,
          primary: teal500,
          primaryDarkest: teal900,
        );
      case NasikoColorPalette.green:
        return _PaletteColors(
          primaryLightest: green100,
          primary: green500,
          primaryDarkest: green900,
        );
      case NasikoColorPalette.sand:
        return _PaletteColors(
          primaryLightest: sand100,
          primary: sand500,
          primaryDarkest: sand900,
        );
    }
  }
}

/// Internal helper class for palette color references
class _PaletteColors {
  final Color primaryLightest;
  final Color primary;
  final Color primaryDarkest;

  _PaletteColors({
    required this.primaryLightest,
    required this.primary,
    required this.primaryDarkest,
  });
}
