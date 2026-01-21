import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/theme/color_scheme_factory.dart';
import 'package:nasiko_ui/src/tokens/colors/color_palette_type.dart';
import 'package:nasiko_ui/src/tokens/colors/color_theme_factory.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

class NasikoTheme {
  NasikoTheme._();

  /// Returns the default light theme (using yellow palette).
  static ThemeData get lightTheme {
    return fromPalette(
      palette: NasikoColorPalette.yellow,
      brightness: Brightness.light,
    );
  }

  /// Returns the default dark theme (using yellow palette).
  static ThemeData get darkTheme {
    return fromPalette(
      palette: NasikoColorPalette.yellow,
      brightness: Brightness.dark,
    );
  }

  /// Creates a theme using a specific color palette.
  ///
  /// This allows consumers to dynamically switch between different color schemes.
  ///
  /// Example:
  /// ```dart
  /// MaterialApp(
  ///   theme: NasikoTheme.fromPalette(
  ///     palette: NasikoColorPalette.blue,
  ///     brightness: Brightness.light,
  ///   ),
  ///   darkTheme: NasikoTheme.fromPalette(
  ///     palette: NasikoColorPalette.blue,
  ///     brightness: Brightness.dark,
  ///   ),
  /// )
  /// ```
  static ThemeData fromPalette({
    required NasikoColorPalette palette,
    Brightness brightness = Brightness.light,
  }) {
    final isLight = brightness == Brightness.light;

    // Generate color theme based on palette
    final nasikoColors = isLight
        ? NasikoColorThemeFactory.light(palette)
        : NasikoColorThemeFactory.dark(palette);

    // Generate Material color scheme based on palette
    final materialColorScheme = isLight
        ? NasikoColorSchemeFactory.light(palette)
        : NasikoColorSchemeFactory.dark(palette);

    return ThemeData(
      brightness: brightness,
      colorScheme: materialColorScheme,
      scaffoldBackgroundColor: nasikoColors.backgroundBase,
      appBarTheme: AppBarTheme(
        backgroundColor: nasikoColors.backgroundSurface,
        foregroundColor: nasikoColors.foregroundPrimary,
        elevation: 0,
      ),
      extensions: <ThemeExtension<dynamic>>[
        nasikoColors,
        defaultNasikoSpacing,
        defaultNasikoTypography,
        defaultNasikoBorderRadius,
        defaultNasikoBorderWidth,
        defaultNasikoIconSize,
      ],
    );
  }

  /// Creates a light theme with the specified palette.
  ///
  /// Convenience method equivalent to:
  /// ```dart
  /// NasikoTheme.fromPalette(palette: palette, brightness: Brightness.light)
  /// ```
  static ThemeData light(NasikoColorPalette palette) {
    return fromPalette(palette: palette, brightness: Brightness.light);
  }

  /// Creates a dark theme with the specified palette.
  ///
  /// Convenience method equivalent to:
  /// ```dart
  /// NasikoTheme.fromPalette(palette: palette, brightness: Brightness.dark)
  /// ```
  static ThemeData dark(NasikoColorPalette palette) {
    return fromPalette(palette: palette, brightness: Brightness.dark);
  }
}
