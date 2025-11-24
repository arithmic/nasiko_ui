import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/theme/color_schemes.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

class NasikoTheme {
  NasikoTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      // 1. Use the imported lightColorScheme
      colorScheme: lightColorScheme,

      // 2. Set other global properties
      scaffoldBackgroundColor: lightColors.backgroundBase, // Use token directly
      appBarTheme: AppBarTheme(
        backgroundColor: lightColors.backgroundSurface,
        foregroundColor: lightColors.foregroundPrimary,
        elevation: 0,
      ),

      // 3. Register all your custom theme extensions
      extensions: const <ThemeExtension<dynamic>>[
        lightColors,
        defaultNasikoSpacing,
        defaultNasikoTypography,
        defaultNasikoBorderRadius,
        defaultNasikoBorderWidth,
        defaultNasikoIconSize,
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      // 1. Use the imported darkColorScheme
      colorScheme: darkColorScheme,

      // 2. Set other global properties
      scaffoldBackgroundColor: darkColors.backgroundBase, // Use token directly
      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.backgroundSurface,
        foregroundColor: darkColors.foregroundPrimary,
        elevation: 0,
      ),

      // 3. Register all your custom theme extensions
      extensions: const <ThemeExtension<dynamic>>[
        darkColors,
        defaultNasikoSpacing,
        defaultNasikoTypography,
        defaultNasikoBorderRadius,
        defaultNasikoBorderWidth,
        defaultNasikoIconSize,
      ],
    );
  }
}
