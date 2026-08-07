import 'package:flutter/material.dart';

import 'color_palette_type.dart';
import 'color_theme_factory.dart';

@immutable
class NasikoColorTheme extends ThemeExtension<NasikoColorTheme> {
  const NasikoColorTheme({
    // Background Default
    required this.backgroundBase,
    required this.backgroundGroup,
    required this.backgroundSurface,
    required this.backgroundSurfaceHover,
    required this.backgroundSurfaceActive,
    required this.backgroundSurfaceSubtle,
    required this.backgroundOverlay,
    required this.backgroundDisabled,

    // Background Primary
    required this.backgroundBrand,
    required this.backgroundBrandHover,
    required this.backgroundBrandActive,
    required this.backgroundBrandSubtle,

    // Background Secondary
    required this.backgroundSecondaryBrand,
    required this.backgroundSecondaryBrandHover,
    required this.backgroundSecondaryBrandActive,

    // Background Feedback
    required this.backgroundSuccess,
    required this.backgroundWarning,
    required this.backgroundError,
    required this.backgroundInformation,
    required this.backgroundInformationOverlay,

    // Foreground Default
    required this.foregroundPrimary,
    required this.foregroundSecondary,
    required this.foregroundDisabled,
    required this.foregroundOnAction,
    required this.foregroundIconPrimary,
    required this.foregroundIconSecondary,
    required this.foregroundIconTertiary,
    required this.foregroundIconHover,

    // Foreground Constant
    required this.foregroundConstantWhite,
    required this.foregroundConstantBlack,
    required this.foregroundConstantBlackSecondary,

    // Optional: hover shade of [foregroundPrimary] for inverse/primary
    // surfaces (e.g. the primary button fill). Falls back to
    // [foregroundConstantBlackSecondary], which matches the light theme's
    // historical hover; dark themes should set it to a light shade.
    Color? foregroundPrimaryHover,

    // Optional: text/icon color that sits ON brand fills ([backgroundBrand]
    // and its states). Distinct from [foregroundOnAction], which sits on the
    // inverse (foregroundPrimary-filled) surfaces such as the primary
    // button. Light-hued brand palettes need dark ink here while the
    // inverse surface needs white — one token cannot serve both.
    // Falls back to [foregroundOnAction] for backward compatibility.
    Color? foregroundOnBrand,

    // Optional: hover shade of [foregroundError] for quiet destructive
    // actions. Falls back to [foregroundError].
    Color? foregroundErrorHover,

    // Optional: keyboard focus-ring color. Must clear 3:1 against the page
    // background (WCAG 1.4.11 / 2.4.13). Falls back to [borderHover].
    Color? borderFocus,

    // Optional: resting border for form controls (inputs, selects) — the
    // functional-border tier, stronger than the decorative [borderPrimary]
    // hairline. Falls back to [borderPrimary].
    Color? borderInput,

    // Optional: extra-light feedback washes for large tinted areas
    // (diagram nodes, row highlights). Fall back to the standard feedback
    // backgrounds.
    Color? backgroundSuccessSubtle,
    Color? backgroundWarningSubtle,
    Color? backgroundErrorSubtle,

    // Foreground Primary (Brand)
    required this.foregroundBrand,
    required this.foregroundBrandHover,
    required this.foregroundBrandLink,
    required this.foregroundBrandHighlight,

    // Foreground Feedback
    required this.foregroundSuccess,
    required this.foregroundWarning,
    required this.foregroundError,
    required this.foregroundInformation,
    required this.foregroundInformationOverlay,

    // Border Default
    required this.borderPrimary,
    required this.borderSecondary,
    required this.borderHover,
    required this.borderSuccess,
    required this.borderError,
    required this.borderWarning,
    required this.borderDisabled,
    required this.borderInformation,
    required this.borderInformationOverlay,
  }) : _foregroundPrimaryHover = foregroundPrimaryHover,
       _foregroundOnBrand = foregroundOnBrand,
       _foregroundErrorHover = foregroundErrorHover,
       _borderFocus = borderFocus,
       _borderInput = borderInput,
       _backgroundSuccessSubtle = backgroundSuccessSubtle,
       _backgroundWarningSubtle = backgroundWarningSubtle,
       _backgroundErrorSubtle = backgroundErrorSubtle;

  // Background Default
  final Color backgroundBase;
  final Color backgroundGroup;
  final Color backgroundSurface;
  final Color backgroundSurfaceHover;
  final Color backgroundSurfaceActive;
  final Color backgroundSurfaceSubtle;
  final Color backgroundOverlay;
  final Color backgroundDisabled;

  // Background Primary
  final Color backgroundBrand;
  final Color backgroundBrandHover;
  final Color backgroundBrandActive;
  final Color backgroundBrandSubtle;

  // Background Secondary
  final Color backgroundSecondaryBrand;
  final Color backgroundSecondaryBrandHover;
  final Color backgroundSecondaryBrandActive;

  // Background Feedback
  final Color backgroundSuccess;
  final Color backgroundWarning;
  final Color backgroundError;
  final Color backgroundInformation;
  final Color backgroundInformationOverlay;

  // Foreground Default
  final Color foregroundPrimary;
  final Color foregroundSecondary;
  final Color foregroundDisabled;
  final Color foregroundOnAction;
  final Color foregroundIconPrimary;
  final Color foregroundIconSecondary;
  final Color foregroundIconTertiary;
  final Color foregroundIconHover;

  // Foreground Constant
  final Color foregroundConstantWhite;
  final Color foregroundConstantBlack;
  final Color foregroundConstantBlackSecondary;

  final Color? _foregroundPrimaryHover;

  /// Hover shade of [foregroundPrimary] for inverse/primary surfaces.
  /// Defaults to [foregroundConstantBlackSecondary] when unset (the light
  /// theme's historical primary-button hover).
  Color get foregroundPrimaryHover =>
      _foregroundPrimaryHover ?? foregroundConstantBlackSecondary;

  final Color? _foregroundOnBrand;
  final Color? _foregroundErrorHover;
  final Color? _borderFocus;
  final Color? _borderInput;
  final Color? _backgroundSuccessSubtle;
  final Color? _backgroundWarningSubtle;
  final Color? _backgroundErrorSubtle;

  /// Text/icon color on brand fills ([backgroundBrand] and its states):
  /// checkmarks, selected calendar days, brand avatars. Distinct from
  /// [foregroundOnAction] (which pairs with the inverse, near-black/near-
  /// white primary-button fill). Defaults to [foregroundOnAction].
  Color get foregroundOnBrand => _foregroundOnBrand ?? foregroundOnAction;

  /// Hover shade of [foregroundError] for quiet destructive actions.
  /// Defaults to [foregroundError].
  Color get foregroundErrorHover => _foregroundErrorHover ?? foregroundError;

  /// Keyboard focus-ring color, ≥3:1 against the page background.
  /// Defaults to [borderHover].
  Color get borderFocus => _borderFocus ?? borderHover;

  /// Resting border for form controls — the functional-border tier.
  /// Defaults to [borderPrimary].
  Color get borderInput => _borderInput ?? borderPrimary;

  /// Extra-light success wash for large tinted areas.
  /// Defaults to [backgroundSuccess].
  Color get backgroundSuccessSubtle =>
      _backgroundSuccessSubtle ?? backgroundSuccess;

  /// Extra-light warning wash for large tinted areas.
  /// Defaults to [backgroundWarning].
  Color get backgroundWarningSubtle =>
      _backgroundWarningSubtle ?? backgroundWarning;

  /// Extra-light error wash for large tinted areas.
  /// Defaults to [backgroundError].
  Color get backgroundErrorSubtle =>
      _backgroundErrorSubtle ?? backgroundError;

  // Foreground Primary (Brand)
  final Color foregroundBrand;
  final Color foregroundBrandHover;
  final Color foregroundBrandLink;
  final Color foregroundBrandHighlight;

  // Foreground Feedback
  final Color foregroundSuccess;
  final Color foregroundWarning;
  final Color foregroundError;
  final Color foregroundInformation;
  final Color foregroundInformationOverlay;

  // Border Default
  final Color borderPrimary;
  final Color borderSecondary;
  final Color borderHover;
  final Color borderSuccess;
  final Color borderError;
  final Color borderWarning;
  final Color borderDisabled;
  final Color borderInformation;
  final Color borderInformationOverlay;

  @override
  NasikoColorTheme copyWith({
    Color? backgroundBase,
    Color? backgroundGroup,
    Color? backgroundSurface,
    Color? backgroundSurfaceHover,
    Color? backgroundSurfaceActive,
    Color? backgroundSurfaceSubtle,
    Color? backgroundOverlay,
    Color? backgroundDisabled,
    Color? backgroundBrand,
    Color? backgroundBrandHover,
    Color? backgroundBrandActive,
    Color? backgroundBrandSubtle,
    Color? backgroundSecondaryBrand,
    Color? backgroundSecondaryBrandHover,
    Color? backgroundSecondaryBrandActive,
    Color? backgroundTertiary,
    Color? backgroundSuccess,
    Color? backgroundWarning,
    Color? backgroundError,
    Color? backgroundInformation,
    Color? backgroundInformationOverlay,
    Color? foregroundPrimary,
    Color? foregroundSecondary,
    Color? foregroundDisabled,
    Color? foregroundOnAction,
    Color? foregroundIconPrimary,
    Color? foregroundIconSecondary,
    Color? foregroundIconTertiary,
    Color? foregroundIconHover,
    Color? foregroundConstantWhite,
    Color? foregroundConstantBlack,
    Color? foregroundConstantBlackSecondary,
    Color? foregroundPrimaryHover,
    Color? foregroundOnBrand,
    Color? foregroundErrorHover,
    Color? borderFocus,
    Color? borderInput,
    Color? backgroundSuccessSubtle,
    Color? backgroundWarningSubtle,
    Color? backgroundErrorSubtle,
    Color? foregroundBrand,
    Color? foregroundBrandHover,
    Color? foregroundBrandLink,
    Color? foregroundBrandHighlight,
    Color? foregroundSuccess,
    Color? foregroundWarning,
    Color? foregroundError,
    Color? foregroundInformation,
    Color? foregroundInformationOverlay,
    Color? borderPrimary,
    Color? borderSecondary,
    Color? borderHover,
    Color? borderSuccess,
    Color? borderError,
    Color? borderWarning,
    Color? borderDisabled,
    Color? borderInformation,
    Color? borderInformationOverlay,
  }) {
    return NasikoColorTheme(
      backgroundBase: backgroundBase ?? this.backgroundBase,
      backgroundGroup: backgroundGroup ?? this.backgroundGroup,
      backgroundSurface: backgroundSurface ?? this.backgroundSurface,
      backgroundSurfaceHover:
          backgroundSurfaceHover ?? this.backgroundSurfaceHover,
      backgroundSurfaceActive:
          backgroundSurfaceActive ?? this.backgroundSurfaceActive,
      backgroundSurfaceSubtle:
          backgroundSurfaceSubtle ?? this.backgroundSurfaceSubtle,
      backgroundOverlay: backgroundOverlay ?? this.backgroundOverlay,
      backgroundDisabled: backgroundDisabled ?? this.backgroundDisabled,
      backgroundBrand: backgroundBrand ?? this.backgroundBrand,
      backgroundBrandHover: backgroundBrandHover ?? this.backgroundBrandHover,
      backgroundBrandActive:
          backgroundBrandActive ?? this.backgroundBrandActive,
      backgroundBrandSubtle:
          backgroundBrandSubtle ?? this.backgroundBrandSubtle,
      backgroundSecondaryBrand:
          backgroundSecondaryBrand ?? this.backgroundSecondaryBrand,
      backgroundSecondaryBrandHover:
          backgroundSecondaryBrandHover ?? this.backgroundSecondaryBrandHover,
      backgroundSecondaryBrandActive:
          backgroundSecondaryBrandActive ?? this.backgroundSecondaryBrandActive,
      backgroundSuccess: backgroundSuccess ?? this.backgroundSuccess,
      backgroundWarning: backgroundWarning ?? this.backgroundWarning,
      backgroundError: backgroundError ?? this.backgroundError,
      backgroundInformation:
          backgroundInformation ?? this.backgroundInformation,
      backgroundInformationOverlay:
          backgroundInformationOverlay ?? this.backgroundInformationOverlay,
      foregroundPrimary: foregroundPrimary ?? this.foregroundPrimary,
      foregroundSecondary: foregroundSecondary ?? this.foregroundSecondary,
      foregroundDisabled: foregroundDisabled ?? this.foregroundDisabled,
      foregroundOnAction: foregroundOnAction ?? this.foregroundOnAction,
      foregroundIconPrimary:
          foregroundIconPrimary ?? this.foregroundIconPrimary,
      foregroundIconSecondary:
          foregroundIconSecondary ?? this.foregroundIconSecondary,
      foregroundIconTertiary:
          foregroundIconTertiary ?? this.foregroundIconTertiary,
      foregroundIconHover: foregroundIconHover ?? this.foregroundIconHover,
      foregroundConstantWhite:
          foregroundConstantWhite ?? this.foregroundConstantWhite,
      foregroundConstantBlack:
          foregroundConstantBlack ?? this.foregroundConstantBlack,
      foregroundConstantBlackSecondary:
          foregroundConstantBlackSecondary ??
          this.foregroundConstantBlackSecondary,
      foregroundPrimaryHover: foregroundPrimaryHover ?? _foregroundPrimaryHover,
      foregroundOnBrand: foregroundOnBrand ?? _foregroundOnBrand,
      foregroundErrorHover: foregroundErrorHover ?? _foregroundErrorHover,
      borderFocus: borderFocus ?? _borderFocus,
      borderInput: borderInput ?? _borderInput,
      backgroundSuccessSubtle:
          backgroundSuccessSubtle ?? _backgroundSuccessSubtle,
      backgroundWarningSubtle:
          backgroundWarningSubtle ?? _backgroundWarningSubtle,
      backgroundErrorSubtle: backgroundErrorSubtle ?? _backgroundErrorSubtle,
      foregroundBrand: foregroundBrand ?? this.foregroundBrand,
      foregroundBrandHover: foregroundBrandHover ?? this.foregroundBrandHover,
      foregroundBrandLink: foregroundBrandLink ?? this.foregroundBrandLink,
      foregroundBrandHighlight:
          foregroundBrandHighlight ?? this.foregroundBrandHighlight,
      foregroundSuccess: foregroundSuccess ?? this.foregroundSuccess,
      foregroundWarning: foregroundWarning ?? this.foregroundWarning,
      foregroundError: foregroundError ?? this.foregroundError,
      foregroundInformation:
          foregroundInformation ?? this.foregroundInformation,
      foregroundInformationOverlay:
          foregroundInformationOverlay ?? this.foregroundInformationOverlay,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      borderHover: borderHover ?? this.borderHover,
      borderSuccess: borderSuccess ?? this.borderSuccess,
      borderError: borderError ?? this.borderError,
      borderWarning: borderWarning ?? this.borderWarning,
      borderDisabled: borderDisabled ?? this.borderDisabled,
      borderInformation: borderInformation ?? this.borderInformation,
      borderInformationOverlay:
          borderInformationOverlay ?? this.borderInformationOverlay,
    );
  }

  @override
  NasikoColorTheme lerp(ThemeExtension<NasikoColorTheme>? other, double t) {
    if (other is! NasikoColorTheme) {
      return this;
    }
    return NasikoColorTheme(
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      backgroundGroup: Color.lerp(backgroundGroup, other.backgroundGroup, t)!,
      backgroundSurface: Color.lerp(
        backgroundSurface,
        other.backgroundSurface,
        t,
      )!,
      backgroundSurfaceHover: Color.lerp(
        backgroundSurfaceHover,
        other.backgroundSurfaceHover,
        t,
      )!,
      backgroundSurfaceActive: Color.lerp(
        backgroundSurfaceActive,
        other.backgroundSurfaceActive,
        t,
      )!,
      backgroundSurfaceSubtle: Color.lerp(
        backgroundSurfaceSubtle,
        other.backgroundSurfaceSubtle,
        t,
      )!,
      backgroundOverlay: Color.lerp(
        backgroundOverlay,
        other.backgroundOverlay,
        t,
      )!,
      backgroundDisabled: Color.lerp(
        backgroundDisabled,
        other.backgroundDisabled,
        t,
      )!,
      backgroundBrand: Color.lerp(backgroundBrand, other.backgroundBrand, t)!,
      backgroundBrandHover: Color.lerp(
        backgroundBrandHover,
        other.backgroundBrandHover,
        t,
      )!,
      backgroundBrandActive: Color.lerp(
        backgroundBrandActive,
        other.backgroundBrandActive,
        t,
      )!,
      backgroundBrandSubtle: Color.lerp(
        backgroundBrandSubtle,
        other.backgroundBrandSubtle,
        t,
      )!,
      backgroundSecondaryBrand: Color.lerp(
        backgroundSecondaryBrand,
        other.backgroundSecondaryBrand,
        t,
      )!,
      backgroundSecondaryBrandHover: Color.lerp(
        backgroundSecondaryBrandHover,
        other.backgroundSecondaryBrandHover,
        t,
      )!,
      backgroundSecondaryBrandActive: Color.lerp(
        backgroundSecondaryBrandActive,
        other.backgroundSecondaryBrandActive,
        t,
      )!,
      backgroundSuccess: Color.lerp(
        backgroundSuccess,
        other.backgroundSuccess,
        t,
      )!,
      backgroundWarning: Color.lerp(
        backgroundWarning,
        other.backgroundWarning,
        t,
      )!,
      backgroundError: Color.lerp(backgroundError, other.backgroundError, t)!,
      backgroundInformation: Color.lerp(
        backgroundInformation,
        other.backgroundInformation,
        t,
      )!,
      backgroundInformationOverlay: Color.lerp(
        backgroundInformationOverlay,
        other.backgroundInformationOverlay,
        t,
      )!,
      foregroundPrimary: Color.lerp(
        foregroundPrimary,
        other.foregroundPrimary,
        t,
      )!,
      foregroundSecondary: Color.lerp(
        foregroundSecondary,
        other.foregroundSecondary,
        t,
      )!,
      foregroundIconTertiary: Color.lerp(
        foregroundIconTertiary,
        other.foregroundIconTertiary,
        t,
      )!,
      foregroundDisabled: Color.lerp(
        foregroundDisabled,
        other.foregroundDisabled,
        t,
      )!,
      foregroundOnAction: Color.lerp(
        foregroundOnAction,
        other.foregroundOnAction,
        t,
      )!,
      foregroundIconPrimary: Color.lerp(
        foregroundIconPrimary,
        other.foregroundIconPrimary,
        t,
      )!,
      foregroundIconSecondary: Color.lerp(
        foregroundIconSecondary,
        other.foregroundIconSecondary,
        t,
      )!,
      foregroundIconHover: Color.lerp(
        foregroundIconHover,
        other.foregroundIconHover,
        t,
      )!,
      foregroundConstantWhite: Color.lerp(
        foregroundConstantWhite,
        other.foregroundConstantWhite,
        t,
      )!,
      foregroundConstantBlack: Color.lerp(
        foregroundConstantBlack,
        other.foregroundConstantBlack,
        t,
      )!,
      foregroundConstantBlackSecondary: Color.lerp(
        foregroundConstantBlackSecondary,
        other.foregroundConstantBlackSecondary,
        t,
      )!,
      foregroundPrimaryHover: Color.lerp(
        foregroundPrimaryHover,
        other.foregroundPrimaryHover,
        t,
      ),
      foregroundOnBrand: Color.lerp(
        foregroundOnBrand,
        other.foregroundOnBrand,
        t,
      ),
      foregroundErrorHover: Color.lerp(
        foregroundErrorHover,
        other.foregroundErrorHover,
        t,
      ),
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t),
      borderInput: Color.lerp(borderInput, other.borderInput, t),
      backgroundSuccessSubtle: Color.lerp(
        backgroundSuccessSubtle,
        other.backgroundSuccessSubtle,
        t,
      ),
      backgroundWarningSubtle: Color.lerp(
        backgroundWarningSubtle,
        other.backgroundWarningSubtle,
        t,
      ),
      backgroundErrorSubtle: Color.lerp(
        backgroundErrorSubtle,
        other.backgroundErrorSubtle,
        t,
      ),
      foregroundBrand: Color.lerp(foregroundBrand, other.foregroundBrand, t)!,
      foregroundBrandHover: Color.lerp(
        foregroundBrandHover,
        other.foregroundBrandHover,
        t,
      )!,
      foregroundBrandLink: Color.lerp(
        foregroundBrandLink,
        other.foregroundBrandLink,
        t,
      )!,
      foregroundBrandHighlight: Color.lerp(
        foregroundBrandHighlight,
        other.foregroundBrandHighlight,
        t,
      )!,
      foregroundSuccess: Color.lerp(
        foregroundSuccess,
        other.foregroundSuccess,
        t,
      )!,
      foregroundWarning: Color.lerp(
        foregroundWarning,
        other.foregroundWarning,
        t,
      )!,
      foregroundError: Color.lerp(foregroundError, other.foregroundError, t)!,
      foregroundInformation: Color.lerp(
        foregroundInformation,
        other.foregroundInformation,
        t,
      )!,
      foregroundInformationOverlay: Color.lerp(
        foregroundInformationOverlay,
        other.foregroundInformationOverlay,
        t,
      )!,
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      borderHover: Color.lerp(borderHover, other.borderHover, t)!,
      borderSuccess: Color.lerp(borderSuccess, other.borderSuccess, t)!,
      borderError: Color.lerp(borderError, other.borderError, t)!,
      borderWarning: Color.lerp(borderWarning, other.borderWarning, t)!,
      borderDisabled: Color.lerp(borderDisabled, other.borderDisabled, t)!,
      borderInformation: Color.lerp(
        borderInformation,
        other.borderInformation,
        t,
      )!,
      borderInformationOverlay: Color.lerp(
        borderInformationOverlay,
        other.borderInformationOverlay,
        t,
      )!,
    );
  }
}

// --- Default instances (yellow brand palette) ---
// Delegated to [NasikoColorThemeFactory] so the default themes and the
// palette factory can never drift apart: these ARE the factory's yellow
// output. See color_theme_factory.dart for every value and its measured
// WCAG contrast ratio.

final NasikoColorTheme lightColors = NasikoColorThemeFactory.light(
  NasikoColorPalette.yellow,
);

final NasikoColorTheme darkColors = NasikoColorThemeFactory.dark(
  NasikoColorPalette.yellow,
);

// --- BuildContext Extension ---
// Provides easy access like: `context.colors.foregroundPrimary`
extension NasikoColorThemeExtension on BuildContext {
  NasikoColorTheme get colors => Theme.of(this).extension<NasikoColorTheme>()!;
}
