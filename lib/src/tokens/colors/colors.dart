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

    // Background Tertiary
    required this.backgroundTertiary,

    // Background Feedback
    required this.backgroundSuccess,
    required this.backgroundWarning,
    required this.backgroundError,
    required this.backgroundInformation,

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

    // Border Default
    required this.borderPrimary,
    required this.borderSecondary,
    required this.borderHover,
    required this.borderSuccess,
    required this.borderError,
    required this.borderWarning,
    required this.borderInformation,
    required this.borderDisabled,
  });

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

  // Background Tertiary
  final Color backgroundTertiary;

  // Background Feedback
  final Color backgroundSuccess;
  final Color backgroundWarning;
  final Color backgroundError;
  final Color backgroundInformation;

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

  // Border Default
  final Color borderPrimary;
  final Color borderSecondary;
  final Color borderHover;
  final Color borderSuccess;
  final Color borderError;
  final Color borderWarning;
  final Color borderInformation;
  final Color borderDisabled;

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
    Color? foregroundBrand,
    Color? foregroundBrandHover,
    Color? foregroundBrandLink,
    Color? foregroundBrandHighlight,
    Color? foregroundSuccess,
    Color? foregroundWarning,
    Color? foregroundError,
    Color? foregroundInformation,
    Color? borderPrimary,
    Color? borderSecondary,
    Color? borderHover,
    Color? borderSuccess,
    Color? borderError,
    Color? borderWarning,
    Color? borderInformation,
    Color? borderDisabled,
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
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      backgroundSuccess: backgroundSuccess ?? this.backgroundSuccess,
      backgroundWarning: backgroundWarning ?? this.backgroundWarning,
      backgroundError: backgroundError ?? this.backgroundError,
      backgroundInformation:
          backgroundInformation ?? this.backgroundInformation,
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
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      borderHover: borderHover ?? this.borderHover,
      borderSuccess: borderSuccess ?? this.borderSuccess,
      borderError: borderError ?? this.borderError,
      borderWarning: borderWarning ?? this.borderWarning,
      borderInformation: borderInformation ?? this.borderInformation,
      borderDisabled: borderDisabled ?? this.borderDisabled,
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
      backgroundTertiary: Color.lerp(
        backgroundTertiary,
        other.backgroundTertiary,
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
      foregroundIconTertiary: Color.lerp(
        foregroundIconTertiary,
        other.foregroundIconTertiary,
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
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      borderHover: Color.lerp(borderHover, other.borderHover, t)!,
      borderSuccess: Color.lerp(borderSuccess, other.borderSuccess, t)!,
      borderError: Color.lerp(borderError, other.borderError, t)!,
      borderWarning: Color.lerp(borderWarning, other.borderWarning, t)!,
      borderInformation: Color.lerp(
        borderInformation,
        other.borderInformation,
        t,
      )!,
      borderDisabled: Color.lerp(borderDisabled, other.borderDisabled, t)!,
    );
  }
}

// --- Default Light Instance ---
// Mappings are now 1-to-1 with your "Nasiko Light" spec.
// "default" is assumed to be the 500-weight color.

const NasikoColorTheme lightColors = NasikoColorTheme(
  // Background Default
  backgroundBase: white,
  backgroundGroup: neutral50,
  backgroundSurface: neutral100,
  backgroundSurfaceHover: neutral200,
  backgroundSurfaceActive: neutral300,
  backgroundSurfaceSubtle: neutral500,
  backgroundOverlay: neutral500,
  backgroundDisabled: neutral200,

  // Background Primary
  backgroundBrand: yellow600,
  backgroundBrandHover: yellow800,
  backgroundBrandActive: yellow500,
  backgroundBrandSubtle: yellow200,

  // Background Secondary
  backgroundSecondaryBrand: yellow100,
  backgroundSecondaryBrandHover: yellow200,
  backgroundSecondaryBrandActive: yellow100,

  // Backgorund Tertiary
  backgroundTertiary: purple500,

  // Background Feedback
  backgroundSuccess: green100,
  backgroundWarning: orange100,
  backgroundError: red100,
  backgroundInformation: blue100,

  // Foreground Default
  foregroundPrimary: neutral700,
  foregroundSecondary: neutral500,
  foregroundDisabled: neutral400,
  foregroundOnAction: white,
  foregroundIconPrimary: neutral700,
  foregroundIconSecondary: yellow600,
  foregroundIconTertiary: neutral500,
  foregroundIconHover: yellow800,

  // Foreground Constant
  // NOTE: Corrected based on swatches, spec labels had typos.
  foregroundConstantWhite: white,
  foregroundConstantBlack: black,
  foregroundConstantBlackSecondary: neutral900,

  // Foreground Primary (Brand)
  foregroundBrand: yellow600,
  foregroundBrandHover: yellow800,
  foregroundBrandLink: yellow600,
  foregroundBrandHighlight: yellow500,

  // Foreground Feedback
  foregroundSuccess: green600,
  foregroundWarning: orange600,
  foregroundError: red600,
  foregroundInformation: blue600,

  // Border Default
  borderPrimary: neutral300,
  borderSecondary: yellow600,
  borderHover: yellow600,
  borderSuccess: green300,
  borderError: red300,
  borderWarning: orange300,
  borderInformation: blue300,
  borderDisabled: neutral200,
);

// --- Dark Instance ---
// This is an assumed dark theme, as no "Nasiko Dark" spec was provided.
// It logically inverts the light theme roles.

const NasikoColorTheme darkColors = NasikoColorTheme(
  // Background Default
  backgroundBase: black,
  backgroundGroup: neutral900,
  backgroundSurface: neutral800,
  backgroundSurfaceHover: neutral700,
  backgroundSurfaceActive: neutral600,
  backgroundSurfaceSubtle: neutral700,
  backgroundOverlay: neutral900,
  backgroundDisabled: neutral700,

  // Background Primary
  backgroundBrand: yellow600, // Brand colors often remain vibrant
  backgroundBrandHover: yellow400, // Lighter for hover on dark
  backgroundBrandActive: yellow500,
  backgroundBrandSubtle: yellow900, // Darker subtle background
  // Background Secondary
  backgroundSecondaryBrand: yellow900,
  backgroundSecondaryBrandHover: yellow800,
  backgroundSecondaryBrandActive: yellow900,

  // Backgorund Tertiary
  backgroundTertiary: purple500,

  // Background Feedback
  backgroundSuccess: green900,
  backgroundWarning: orange900,
  backgroundError: red900,
  backgroundInformation: blue900,

  // Foreground Default
  foregroundPrimary: neutral100, // Light text on dark
  foregroundSecondary: neutral400,
  foregroundDisabled: neutral600,
  foregroundOnAction: neutral900, // Dark text on light brand button
  foregroundIconPrimary: neutral100,
  foregroundIconSecondary: yellow600,
  foregroundIconTertiary: neutral400,
  foregroundIconHover: yellow400,

  // Foreground Constant
  foregroundConstantWhite: white,
  foregroundConstantBlack: black,
  foregroundConstantBlackSecondary: neutral900,

  // Foreground Primary (Brand)
  foregroundBrand: yellow400, // Lighter text for dark background
  foregroundBrandHover: yellow300,
  foregroundBrandLink: yellow400,
  foregroundBrandHighlight: yellow400,

  // Foreground Feedback
  foregroundSuccess: green400,
  foregroundWarning: orange400,
  foregroundError: red400,
  foregroundInformation: blue400,

  // Border Default
  borderPrimary: neutral700,
  borderSecondary: yellow600,
  borderHover: yellow400,
  borderSuccess: green600,
  borderError: red600,
  borderWarning: orange600,
  borderInformation: blue600,
  borderDisabled: neutral700,
);

// --- BuildContext Extension ---
// Provides easy access like: `context.colors.foregroundPrimary`
extension NasikoColorThemeExtension on BuildContext {
  NasikoColorTheme get colors => Theme.of(this).extension<NasikoColorTheme>()!;
}
