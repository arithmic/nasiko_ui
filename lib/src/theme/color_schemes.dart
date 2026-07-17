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

  // Mappings for dark theme colors
  inverseSurface: sand800,
  onInverseSurface: sand100,
  inversePrimary: yellow500,
  surfaceTint: yellow500,
);

// This is the Material 3 Dark Color Scheme
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // Use your dark tokens
  primary: yellow500,
  onPrimary: sand900,
  primaryContainer: yellow900,
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

  // Mappings for light theme colors
  inverseSurface: sand100,
  onInverseSurface: sand800,
  inversePrimary: yellow500,
  surfaceTint: yellow500,
);
