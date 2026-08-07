import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/colors/color_palette_type.dart';
import 'package:nasiko_ui/src/tokens/colors/color_theme_factory.dart';
import 'package:nasiko_ui/src/tokens/colors/colors.dart';

/// Factory class for creating Material [ColorScheme] instances based on
/// different color palettes.
///
/// The scheme is derived 1:1 from [NasikoColorTheme] rather than
/// hand-authored, so stock Material widgets (dialogs, date pickers,
/// snackbars, ripples, text selection) can never drift from Nasiko
/// components. The previous hand-written scheme had inverted error roles
/// (error: red100 / onError: red500), a 500-weight primary while Nasiko
/// used 600, and onSurfaceVariant equal to surfaceContainerHighest (1.00:1).
class NasikoColorSchemeFactory {
  NasikoColorSchemeFactory._();

  /// Creates a Material light color scheme using the specified [palette].
  static ColorScheme light(NasikoColorPalette palette) {
    return fromNasikoColors(
      NasikoColorThemeFactory.light(palette),
      Brightness.light,
    );
  }

  /// Creates a Material dark color scheme using the specified [palette].
  static ColorScheme dark(NasikoColorPalette palette) {
    return fromNasikoColors(
      NasikoColorThemeFactory.dark(palette),
      Brightness.dark,
    );
  }

  /// Maps a [NasikoColorTheme] onto the Material roles.
  ///
  /// Mapping rules:
  /// * `primary`/`onPrimary` — the brand fill and its verified on-color.
  /// * `*Container` roles — the corresponding tinted/subtle surfaces with
  ///   their verified foregrounds.
  /// * `secondary` — the neutral emphasis fill (foregroundSecondary works
  ///   as a fill against the base background in both themes).
  /// * `tertiary` — the information pair (fixed blue), Material's closest
  ///   analogue for a non-brand accent.
  /// * `error` — the strong feedback foreground as the fill (red700 light /
  ///   red300 dark), with the page base as text on it (6.47 / 9.66).
  /// * `surface`/`onSurface` — the scaffold base and primary text.
  /// * `outline` — the functional border tier; `outlineVariant` the
  ///   decorative hairline.
  /// * `inverseSurface` — the opposite theme's tooltip/overlay pair.
  static ColorScheme fromNasikoColors(
    NasikoColorTheme colors,
    Brightness brightness,
  ) {
    return ColorScheme(
      brightness: brightness,
      primary: colors.backgroundBrand,
      onPrimary: colors.foregroundOnBrand,
      primaryContainer: colors.backgroundBrandSubtle,
      onPrimaryContainer: colors.foregroundPrimary,
      secondary: colors.foregroundSecondary,
      onSecondary: colors.backgroundBase,
      secondaryContainer: colors.backgroundSecondaryBrand,
      onSecondaryContainer: colors.foregroundPrimary,
      tertiary: colors.foregroundInformation,
      onTertiary: colors.backgroundInformation,
      tertiaryContainer: colors.backgroundInformation,
      onTertiaryContainer: colors.foregroundInformation,
      error: colors.foregroundError,
      onError: colors.backgroundBase,
      errorContainer: colors.backgroundError,
      onErrorContainer: colors.foregroundError,
      surface: colors.backgroundBase,
      onSurface: colors.foregroundPrimary,
      surfaceContainerLowest: colors.backgroundBase,
      surfaceContainerLow: colors.backgroundGroup,
      surfaceContainer: colors.backgroundSurface,
      surfaceContainerHigh: colors.backgroundSurfaceHover,
      surfaceContainerHighest: colors.backgroundSurfaceActive,
      onSurfaceVariant: colors.foregroundSecondary,
      outline: colors.borderInput,
      outlineVariant: colors.borderPrimary,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: colors.backgroundInformationOverlay,
      onInverseSurface: colors.foregroundInformationOverlay,
      inversePrimary: colors.foregroundBrandHighlight,
      surfaceTint: colors.backgroundBrand,
    );
  }
}
