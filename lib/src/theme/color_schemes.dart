// lib/src/theme/color_schemes.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/theme/color_scheme_factory.dart';
import 'package:nasiko_ui/src/tokens/colors/color_palette_type.dart';

/// The Material 3 light color scheme for the default (yellow) palette.
///
/// Delegated to [NasikoColorSchemeFactory], which derives every Material
/// role from the Nasiko semantic tokens — the two can no longer drift.
final ColorScheme lightColorScheme = NasikoColorSchemeFactory.light(
  NasikoColorPalette.yellow,
);

/// The Material 3 dark color scheme for the default (yellow) palette.
final ColorScheme darkColorScheme = NasikoColorSchemeFactory.dark(
  NasikoColorPalette.yellow,
);
