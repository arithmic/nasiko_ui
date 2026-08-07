import 'package:flutter/material.dart';

import '_color_palette.dart';
import 'color_palette_type.dart';
import 'colors.dart';

/// Factory class for creating [NasikoColorTheme] instances based on
/// different color palettes.
///
/// Every brand mapping below is contrast-verified (WCAG 2.x ratios noted
/// inline; see test/contrast_guard_test.dart for the automated sweep).
///
/// Palettes split into two hue classes, which drive the brand mappings:
///
/// * LIGHT hues (yellow, orange, teal, green, sand) — bright fills that
///   need dark ink text ([sandInk]) on top. Ink on the 500 fill measures
///   5.7–8.3:1 across these palettes. Fills rest at the 500 weight; states
///   darken in the light theme (500 → 600 → 700) and lighten in the dark
///   theme (500 → 400 → 300), so hover always moves away from the page
///   background.
/// * DARK hues (red, purple, blue) — deep fills that need white text
///   (4.8–5.4:1 on the 600 weight). Fills rest at 600 and darken
///   (600 → 700 → 800) in both themes.
///
/// Feedback colors (success/warning/error) are fixed hues, and information
/// is a fixed blue in every palette: semantic colors must not change
/// meaning when the brand palette changes.
class NasikoColorThemeFactory {
  NasikoColorThemeFactory._();

  /// Palettes whose brand fills are light enough to need dark ink text.
  static bool _isLightHue(NasikoColorPalette palette) => switch (palette) {
    NasikoColorPalette.yellow ||
    NasikoColorPalette.orange ||
    NasikoColorPalette.teal ||
    NasikoColorPalette.green ||
    NasikoColorPalette.sand => true,
    NasikoColorPalette.red ||
    NasikoColorPalette.purple ||
    NasikoColorPalette.blue => false,
  };

  /// Creates a light theme using the specified [palette].
  ///
  /// Example:
  /// ```dart
  /// final blueTheme = NasikoColorThemeFactory.light(NasikoColorPalette.blue);
  /// ```
  static NasikoColorTheme light(NasikoColorPalette palette) {
    final ramp = _ramp(palette);
    final lightHue = _isLightHue(palette);

    // Brand fill states: light hues rest bright and darken on interaction;
    // dark hues rest at 600 and darken.
    final brandRest = lightHue ? ramp.c500 : ramp.c600;
    final brandHover = lightHue ? ramp.c600 : ramp.c700;
    final brandActive = lightHue ? ramp.c700 : ramp.c800;

    // Text/icons ON the brand fill: ink for light hues, white for dark.
    final onBrand = lightHue ? sandInk : white;

    // Brand-colored text/icons on light surfaces: one weight deeper for
    // light hues (700: 4.98–6.57 on white) than dark hues (600: 4.8–5.4).
    final brandText = lightHue ? ramp.c700 : ramp.c600;
    final brandTextHover = lightHue ? ramp.c800 : ramp.c700;

    return NasikoColorTheme(
      // Background Default.
      // Note the tight neutral ramp (white → sand300) carries seven roles;
      // disabled shares sand100 with surface on purpose — disabled controls
      // are distinguished by their weaker border (borderDisabled) and
      // foregroundDisabled content, not by fill alone.
      backgroundBase: white,
      backgroundGroup: sand50,
      backgroundSurface: sand100,
      backgroundSurfaceHover: sand200,
      backgroundSurfaceActive: sand300,
      backgroundSurfaceSubtle: sand200,
      // Scrim: neutral black, matching the dark theme's rule (which uses
      // 0.60). The old warm sand600 @ 0.4 washed out instead of dimming.
      backgroundOverlay: black.withValues(alpha: 0.45),
      backgroundDisabled: sand100,

      // Background Primary (brand fill + interaction states).
      backgroundBrand: brandRest,
      backgroundBrandHover: brandHover,
      backgroundBrandActive: brandActive,
      backgroundBrandSubtle: ramp.c200,

      // Background Secondary (tinted brand surfaces), adjacent ramp steps:
      // rest 100 → hover 200 → active 300.
      backgroundSecondaryBrand: ramp.c100,
      backgroundSecondaryBrandHover: ramp.c200,
      backgroundSecondaryBrandActive: ramp.c300,

      // Background Feedback. Fixed hues — never brand-derived.
      backgroundSuccess: green100,
      backgroundWarning: orange100,
      backgroundError: red100,
      backgroundSuccessSubtle: green50,
      backgroundWarningSubtle: orange50,
      backgroundErrorSubtle: red50,
      // Information is a fixed blue: an "info" that changed hue with the
      // brand (or matched the warning family) carried no meaning.
      backgroundInformation: blue50,
      backgroundInformationOverlay: sand800,

      // Foreground Default.
      // sandInk is the warm near-black (15.95:1 on white) — hue-matched to
      // the sand surfaces, unlike the cool-tinted sand900.
      foregroundPrimary: sandInk,
      foregroundSecondary: sand700, // 6.57 on white, 5.34 on sand100
      foregroundDisabled: sand500,
      // On the inverse (ink-filled) action surface, e.g. the primary button.
      foregroundOnAction: white, // 15.95 on sandInk
      // On brand fills (checkmarks, selected days, brand avatars).
      foregroundOnBrand: onBrand,
      foregroundIconPrimary: sandInk,
      foregroundIconSecondary: brandText,
      foregroundIconTertiary: sand500,
      foregroundIconHover: brandTextHover,

      // Foreground Constant — identical in both themes by definition.
      foregroundConstantWhite: white,
      foregroundConstantBlack: sandInk,
      foregroundConstantBlackSecondary: sand800,
      foregroundPrimaryHover: sand800,

      // Foreground Primary (Brand). 700-weight for light hues so links and
      // brand text clear 4.5:1 on white (the 600s measured 2.98–3.76).
      foregroundBrand: brandText,
      foregroundBrandHover: brandTextHover,
      foregroundBrandLink: brandText,
      foregroundBrandHighlight: ramp.c500,

      // Foreground Feedback: 700-weight on the 100-weight tinted
      // backgrounds (4.52–5.30; the 600s only reached 3.00–3.95).
      foregroundSuccess: green700,
      foregroundWarning: orange700,
      foregroundError: red700,
      foregroundErrorHover: red800,
      foregroundInformation: blue700, // 6.16 on blue50, 6.70 on white
      foregroundInformationOverlay: sand100, // 12.34 on sand800 (tooltips)

      // Border Default. borderPrimary stays a decorative hairline;
      // borderInput is the functional tier for form-control affordances
      // (sand600: 3.76 vs white — clears the 3:1 non-text minimum, like
      // Material's outline role).
      borderPrimary: sand300,
      borderInput: sand600,
      borderSecondary: brandText,
      borderHover: brandTextHover,
      borderFocus: brandTextHover, // ≥4.98 on white
      // Feedback borders at the 600 weight so every one clears 3:1 against
      // white (3.30–5.17; the old 200–300s measured 1.40–1.69 and the 500s
      // still failed for orange/green).
      borderSuccess: green600,
      borderError: red600, // 4.83 vs white
      borderWarning: orange600,
      borderDisabled: sand200,
      borderInformation: blue600,
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
    final ramp = _ramp(palette);
    final lightHue = _isLightHue(palette);

    // Light hues lighten on interaction in the dark theme (away from the
    // dark canvas); dark hues darken, keeping white text ≥4.8:1.
    final brandRest = lightHue ? ramp.c500 : ramp.c600;
    final brandHover = lightHue ? ramp.c400 : ramp.c700;
    final brandActive = lightHue ? ramp.c300 : ramp.c800;

    final onBrand = lightHue ? sandInk : white;

    // Brand text/icons on dark surfaces: the 300 weight measures
    // 9.7–12.2:1 on the base canvas for every palette.
    final brandText = ramp.c300;
    final brandTextHover = ramp.c200;

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
      // Disabled shares the group surface; the weaker borderDisabled and
      // foregroundDisabled carry the affordance.
      backgroundDisabled: sandDark900,

      // Background Primary.
      backgroundBrand: brandRest,
      backgroundBrandHover: brandHover,
      backgroundBrandActive: brandActive,
      backgroundBrandSubtle: ramp.c900,

      // Background Secondary: rest 900 → hover 800. Active stays at 800 —
      // the 700 step drops foregroundPrimary below 4.5:1 on the light-hued
      // palettes (4.04–4.45 measured); pressed feedback is carried by the
      // press-scale animation instead.
      backgroundSecondaryBrand: ramp.c900,
      backgroundSecondaryBrandHover: ramp.c800,
      backgroundSecondaryBrandActive: ramp.c800,

      // Background Feedback. Fixed hues; information is a fixed blue.
      backgroundSuccess: green900,
      backgroundWarning: orange900,
      backgroundError: red900,
      backgroundInformation: blue900,
      // Inverse tooltip surface: opaque light sand. The old translucent
      // sand200 @ 0.5 composited to ~1.6:1 under its own foreground and
      // shifted with whatever sat beneath it.
      backgroundInformationOverlay: sand100,

      // Foreground Default.
      foregroundPrimary: sand100, // 14.90 on base
      foregroundSecondary: sand400, // 9.56 on base
      foregroundDisabled: sand600,
      // On the inverse (sand100-filled) action surface. 12.96:1.
      foregroundOnAction: sandInk,
      foregroundOnBrand: onBrand,
      foregroundIconPrimary: sand100,
      foregroundIconSecondary: brandText,
      foregroundIconTertiary: sand400,
      foregroundIconHover: brandTextHover,

      // Foreground Constant — identical to the light theme by definition.
      foregroundConstantWhite: white,
      foregroundConstantBlack: sandInk,
      foregroundConstantBlackSecondary: sand800,
      foregroundPrimaryHover: sand200,

      // Foreground Primary (Brand).
      foregroundBrand: brandText,
      foregroundBrandHover: brandTextHover,
      foregroundBrandLink: brandText,
      foregroundBrandHighlight: ramp.c400,

      // Foreground Feedback: 300-weight on the 900-weight backgrounds
      // (5.28–7.89; red400/orange400 only reached 3.62–4.14).
      foregroundSuccess: green400, // 5.23 on green900 — already passing
      foregroundWarning: orange300,
      foregroundError: red300,
      foregroundErrorHover: red200,
      foregroundInformation: blue300, // 5.74 on blue900
      foregroundInformationOverlay: sand800, // 9.96 on sand100

      // Border Default — hairlines one ramp-step above their surfaces;
      // borderInput is the stronger functional tier (4.87 vs base).
      borderPrimary: sand800,
      borderInput: sand600,
      borderSecondary: brandRest,
      borderHover: ramp.c400,
      borderFocus: ramp.c400, // ≥6.0 on the base canvas for every palette
      borderSuccess: green600,
      borderError: red600,
      borderWarning: orange600,
      borderDisabled: sandDark800,
      borderInformation: blue600, // 3.55 vs base
      borderInformationOverlay: sand300,
    );
  }

  static _Ramp _ramp(NasikoColorPalette palette) {
    switch (palette) {
      case NasikoColorPalette.yellow:
        return const _Ramp(
          c50: yellow50, c100: yellow100, c200: yellow200, c300: yellow300,
          c400: yellow400, c500: yellow500, c600: yellow600, c700: yellow700,
          c800: yellow800, c900: yellow900,
        );
      case NasikoColorPalette.orange:
        return const _Ramp(
          c50: orange50, c100: orange100, c200: orange200, c300: orange300,
          c400: orange400, c500: orange500, c600: orange600, c700: orange700,
          c800: orange800, c900: orange900,
        );
      case NasikoColorPalette.red:
        return const _Ramp(
          c50: red50, c100: red100, c200: red200, c300: red300,
          c400: red400, c500: red500, c600: red600, c700: red700,
          c800: red800, c900: red900,
        );
      case NasikoColorPalette.purple:
        return const _Ramp(
          c50: purple50, c100: purple100, c200: purple200, c300: purple300,
          c400: purple400, c500: purple500, c600: purple600, c700: purple700,
          c800: purple800, c900: purple900,
        );
      case NasikoColorPalette.blue:
        return const _Ramp(
          c50: blue50, c100: blue100, c200: blue200, c300: blue300,
          c400: blue400, c500: blue500, c600: blue600, c700: blue700,
          c800: blue800, c900: blue900,
        );
      case NasikoColorPalette.teal:
        return const _Ramp(
          c50: teal50, c100: teal100, c200: teal200, c300: teal300,
          c400: teal400, c500: teal500, c600: teal600, c700: teal700,
          c800: teal800, c900: teal900,
        );
      case NasikoColorPalette.green:
        return const _Ramp(
          c50: green50, c100: green100, c200: green200, c300: green300,
          c400: green400, c500: green500, c600: green600, c700: green700,
          c800: green800, c900: green900,
        );
      case NasikoColorPalette.sand:
        return const _Ramp(
          c50: sand50, c100: sand100, c200: sand200, c300: sand300,
          c400: sand400, c500: sand500, c600: sand600, c700: sand700,
          c800: sand800, c900: sand900,
        );
    }
  }
}

/// A brand palette's full 50–900 ramp.
class _Ramp {
  const _Ramp({
    required this.c50,
    required this.c100,
    required this.c200,
    required this.c300,
    required this.c400,
    required this.c500,
    required this.c600,
    required this.c700,
    required this.c800,
    required this.c900,
  });

  final Color c50;
  final Color c100;
  final Color c200;
  final Color c300;
  final Color c400;
  final Color c500;
  final Color c600;
  final Color c700;
  final Color c800;
  final Color c900;
}
