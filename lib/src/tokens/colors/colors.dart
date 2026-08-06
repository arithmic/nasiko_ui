import 'package:flutter/material.dart';

import '_color_palette.dart';

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
  }) : _foregroundPrimaryHover = foregroundPrimaryHover;

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

// --- Default Light Instance ---
// Mappings are now 1-to-1 with your "Nasiko Light" spec.
// "default" is assumed to be the 500-weight color.

final NasikoColorTheme lightColors = NasikoColorTheme(
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
  backgroundBrand: yellow600,
  backgroundBrandHover: yellow800,
  backgroundBrandActive: yellow600,
  backgroundBrandSubtle: yellow200,

  // Background Secondary
  backgroundSecondaryBrand: yellow100,
  backgroundSecondaryBrandHover: yellow200,
  backgroundSecondaryBrandActive: yellow100,

  // Background Feedback
  backgroundSuccess: green100,
  backgroundWarning: orange100,
  backgroundError: red100,
  backgroundInformation: yellow50,
  backgroundInformationOverlay: sand800,

  // Foreground Default
  foregroundPrimary: sand900,
  foregroundSecondary: sand700,
  foregroundDisabled: sand500,
  foregroundOnAction: white,
  foregroundIconPrimary: sand900,
  foregroundIconSecondary: yellow600,
  foregroundIconTertiary: sand500,
  foregroundIconHover: yellow800,

  // Foreground Constant
  // NOTE: Corrected based on swatches, spec labels had typos.
  foregroundConstantWhite: white,
  foregroundConstantBlack: sand900,
  foregroundConstantBlackSecondary: sand800,
  foregroundPrimaryHover: sand800,

  // Foreground Primary (Brand)
  foregroundBrand: yellow600,
  foregroundBrandHover: yellow800,
  foregroundBrandLink: yellow600,
  foregroundBrandHighlight: yellow500,

  // Foreground Feedback
  foregroundSuccess: green600,
  foregroundWarning: orange600,
  foregroundError: red600,
  foregroundInformation: yellow800,
  foregroundInformationOverlay: sand400,

  // Border Default
  borderPrimary: sand300,
  borderSecondary: yellow600,
  borderHover: yellow800,
  borderSuccess: green300,
  borderError: red200,
  borderWarning: orange300,
  borderDisabled: sand300,
  borderInformation: yellow300,
  borderInformationOverlay: sand800,
);

// --- Dark Instance ---
// This is an assumed dark theme, as no "Nasiko Dark" spec was provided.
// It logically inverts the light theme roles.

final NasikoColorTheme darkColors = NasikoColorTheme(
  // Background Default
  // Warm elevation ramp over a near-black base — see _color_palette.dart.
  backgroundBase: sandDark950,
  backgroundGroup: sandDark900,
  backgroundSurface: sandDark850,
  backgroundSurfaceHover: sandDark800,
  backgroundSurfaceActive: sand800,
  backgroundSurfaceSubtle: sandDark900,
  backgroundOverlay: black.withValues(alpha: 0.6),
  backgroundDisabled: sandDark800,

  // Background Primary
  backgroundBrand: yellow600,
  backgroundBrandHover: yellow400,
  backgroundBrandActive: yellow500,
  backgroundBrandSubtle: yellow900,

  // Background Secondary
  backgroundSecondaryBrand: yellow900,
  backgroundSecondaryBrandHover: yellow800,
  backgroundSecondaryBrandActive: yellow900,

  // Background Feedback
  backgroundSuccess: green900,
  backgroundWarning: orange900,
  backgroundError: red900,
  backgroundInformation: yellow900,
  backgroundInformationOverlay: sand200.withValues(alpha: 0.5),

  // Foreground Default
  foregroundPrimary: sand100,
  foregroundSecondary: sand400,
  foregroundDisabled: sand600,
  foregroundOnAction: sand900,
  foregroundIconPrimary: sand100,
  foregroundIconSecondary: yellow600,
  foregroundIconTertiary: sand400,
  foregroundIconHover: yellow400,

  // Foreground Constant
  foregroundConstantWhite: white,
  foregroundConstantBlack: black,
  foregroundConstantBlackSecondary: sand900,
  foregroundPrimaryHover: sand200,

  // Foreground Primary (Brand)
  foregroundBrand: yellow400,
  foregroundBrandHover: yellow300,
  foregroundBrandLink: yellow400,
  foregroundBrandHighlight: yellow400,

  // Foreground Feedback
  foregroundSuccess: green400,
  foregroundWarning: orange400,
  foregroundError: red400,
  foregroundInformation: yellow300,
  foregroundInformationOverlay: sand700,

  // Border Default — hairlines one ramp-step above their surfaces.
  borderPrimary: sand800,
  borderSecondary: yellow600,
  borderHover: yellow400,
  borderSuccess: green600,
  borderError: red600,
  borderWarning: orange600,
  borderDisabled: sandDark800,
  borderInformation: yellow700,
  borderInformationOverlay: sand200,
);

// --- BuildContext Extension ---
// Provides easy access like: `context.colors.foregroundPrimary`
extension NasikoColorThemeExtension on BuildContext {
  NasikoColorTheme get colors => Theme.of(this).extension<NasikoColorTheme>()!;
}
