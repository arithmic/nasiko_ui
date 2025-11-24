// lib/src/theme/color_schemes.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/colors/_color_palette.dart';

// This is the Material 3 Light Color Scheme
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  // Use your tokens to fill the Material scheme
  primary: yellow500,
  onPrimary: white,
  primaryContainer: yellow100,
  onPrimaryContainer: neutral700,

  secondary: neutral500,
  onSecondary: neutral700,
  secondaryContainer: neutral50,
  onSecondaryContainer: neutral700,

  tertiary: blue100,
  onTertiary: white,
  tertiaryContainer: blue100,
  onTertiaryContainer: blue500,

  error: red100,
  onError: red500,
  errorContainer: red100,
  onErrorContainer: red500,

  surface: neutral100,
  onSurface: neutral700,
  surfaceContainerHighest: neutral500,
  onSurfaceVariant: neutral500,

  outline: neutral300,
  outlineVariant: neutral200,
  shadow: black,
  scrim: black,

  // Mappings for dark theme colors
  inverseSurface: neutral800,
  onInverseSurface: neutral100,
  inversePrimary: yellow500,
  surfaceTint: yellow500,
);

// This is the Material 3 Dark Color Scheme
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // Use your dark tokens
  primary: yellow500,
  onPrimary: neutral900,
  primaryContainer: yellow900,
  onPrimaryContainer: neutral100,

  secondary: neutral700,
  onSecondary: neutral100,
  secondaryContainer: neutral900,
  onSecondaryContainer: neutral100,

  tertiary: blue900,
  onTertiary: neutral900,
  tertiaryContainer: blue900,
  onTertiaryContainer: blue400,

  error: red900,
  onError: red400,
  errorContainer: red900,
  onErrorContainer: red400,

  surface: neutral800,
  onSurface: neutral100,
  surfaceContainerHighest: neutral700,
  onSurfaceVariant: neutral400,

  outline: neutral700,
  outlineVariant: neutral700,
  shadow: black,
  scrim: black,

  // Mappings for light theme colors
  inverseSurface: neutral100,
  onInverseSurface: neutral800,
  inversePrimary: yellow500,
  surfaceTint: yellow500,
);
