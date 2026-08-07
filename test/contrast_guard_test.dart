// test/contrast_guard_test.dart
//
// WCAG 2.x contrast guard for the Nasiko color system.
//
// Sweeps every meaningful token pairing across all 16 theme variants
// (8 brand palettes × light/dark) so a token change that breaks text or
// UI-component contrast fails CI instead of shipping. Thresholds:
//   * 4.5:1 — normal text (WCAG 1.4.3 AA)
//   * 3.0:1 — large text, icons, and UI-component boundaries (1.4.11)
//
// Deliberately NOT covered (documented trade-offs, not oversights):
//   * borderPrimary / surface-vs-surface steps — decorative hairlines and
//     layering tints; WCAG requires no minimum for non-functional
//     boundaries, and cards carry border + shadow redundancy.
//   * backgroundOverlay — a translucent scrim, not a content surface.
//   * foregroundDisabled — disabled content is exempt from 1.4.3.
//   * backgroundBrand vs base — bright brand fills (yellow500 on white is
//     1.92:1) rely on their verified onBrand label for affordance, the
//     standard trade-off for light-hued brand buttons.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// WCAG relative-luminance contrast ratio between two opaque colors.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const textAA = 4.5;
  const nonText = 3.0;

  for (final palette in NasikoColorPalette.values) {
    for (final brightness in Brightness.values) {
      final isLight = brightness == Brightness.light;
      final variant = '${palette.name}-${isLight ? 'light' : 'dark'}';
      final c = isLight
          ? NasikoColorThemeFactory.light(palette)
          : NasikoColorThemeFactory.dark(palette);

      group('contrast [$variant]', () {
        void expectContrast(
          String label,
          Color fg,
          Color bg,
          double min,
        ) {
          final r = contrast(fg, bg);
          expect(
            r,
            greaterThanOrEqualTo(min),
            reason:
                '$variant: $label measured ${r.toStringAsFixed(2)}:1, '
                'needs ≥$min:1',
          );
        }

        test('primary text on every standard surface', () {
          for (final (name, surface) in [
            ('backgroundBase', c.backgroundBase),
            ('backgroundGroup', c.backgroundGroup),
            ('backgroundSurface', c.backgroundSurface),
            ('backgroundSurfaceHover', c.backgroundSurfaceHover),
            ('backgroundSurfaceActive', c.backgroundSurfaceActive),
          ]) {
            expectContrast(
              'foregroundPrimary on $name',
              c.foregroundPrimary,
              surface,
              textAA,
            );
          }
          for (final (name, surface) in [
            ('backgroundBase', c.backgroundBase),
            ('backgroundGroup', c.backgroundGroup),
            ('backgroundSurface', c.backgroundSurface),
          ]) {
            expectContrast(
              'foregroundSecondary on $name',
              c.foregroundSecondary,
              surface,
              textAA,
            );
          }
        });

        test('action and brand fills', () {
          // The primary button's inverse fill.
          expectContrast(
            'foregroundOnAction on foregroundPrimary fill',
            c.foregroundOnAction,
            c.foregroundPrimary,
            textAA,
          );
          expectContrast(
            'foregroundOnAction on foregroundPrimaryHover fill',
            c.foregroundOnAction,
            c.foregroundPrimaryHover,
            textAA,
          );
          // Content on brand fills (checkmarks, selected days, avatars).
          expectContrast(
            'foregroundOnBrand on backgroundBrand',
            c.foregroundOnBrand,
            c.backgroundBrand,
            textAA,
          );
          expectContrast(
            'foregroundOnBrand on backgroundBrandHover',
            c.foregroundOnBrand,
            c.backgroundBrandHover,
            nonText,
          );
          // Secondary (tinted) button text across its states.
          for (final (name, surface) in [
            ('backgroundSecondaryBrand', c.backgroundSecondaryBrand),
            ('backgroundSecondaryBrandHover', c.backgroundSecondaryBrandHover),
            (
              'backgroundSecondaryBrandActive',
              c.backgroundSecondaryBrandActive,
            ),
          ]) {
            expectContrast(
              'foregroundPrimary on $name',
              c.foregroundPrimary,
              surface,
              textAA,
            );
          }
        });

        test('brand text and links on the page background', () {
          expectContrast(
            'foregroundBrand on base',
            c.foregroundBrand,
            c.backgroundBase,
            textAA,
          );
          expectContrast(
            'foregroundBrandLink on base',
            c.foregroundBrandLink,
            c.backgroundBase,
            textAA,
          );
          expectContrast(
            'foregroundBrandHover on base',
            c.foregroundBrandHover,
            c.backgroundBase,
            textAA,
          );
          expectContrast(
            'foregroundIconSecondary on base (icons)',
            c.foregroundIconSecondary,
            c.backgroundBase,
            nonText,
          );
        });

        test('feedback foregrounds on their tinted backgrounds', () {
          expectContrast(
            'foregroundSuccess on backgroundSuccess',
            c.foregroundSuccess,
            c.backgroundSuccess,
            textAA,
          );
          expectContrast(
            'foregroundWarning on backgroundWarning',
            c.foregroundWarning,
            c.backgroundWarning,
            textAA,
          );
          expectContrast(
            'foregroundError on backgroundError',
            c.foregroundError,
            c.backgroundError,
            textAA,
          );
          expectContrast(
            'foregroundInformation on backgroundInformation',
            c.foregroundInformation,
            c.backgroundInformation,
            textAA,
          );
          expectContrast(
            'foregroundError on base (destructive text)',
            c.foregroundError,
            c.backgroundBase,
            textAA,
          );
          expectContrast(
            'foregroundErrorHover on base',
            c.foregroundErrorHover,
            c.backgroundBase,
            textAA,
          );
          expectContrast(
            'tooltip: foregroundInformationOverlay on its surface',
            c.foregroundInformationOverlay,
            c.backgroundInformationOverlay,
            textAA,
          );
        });

        test('functional borders and focus ring clear 3:1', () {
          expectContrast(
            'borderFocus vs base',
            c.borderFocus,
            c.backgroundBase,
            nonText,
          );
          expectContrast(
            'borderInput vs base',
            c.borderInput,
            c.backgroundBase,
            nonText,
          );
          expectContrast(
            'borderSecondary vs base',
            c.borderSecondary,
            c.backgroundBase,
            nonText,
          );
          for (final (name, border) in [
            ('borderError', c.borderError),
            ('borderWarning', c.borderWarning),
            ('borderSuccess', c.borderSuccess),
            ('borderInformation', c.borderInformation),
          ]) {
            expectContrast('$name vs base', border, c.backgroundBase, nonText);
          }
        });

        test('derived Material ColorScheme stays readable', () {
          final scheme = NasikoColorSchemeFactory.fromNasikoColors(
            c,
            brightness,
          );
          expectContrast(
            'onPrimary on primary',
            scheme.onPrimary,
            scheme.primary,
            textAA,
          );
          expectContrast(
            'onError on error',
            scheme.onError,
            scheme.error,
            textAA,
          );
          expectContrast(
            'onSurface on surface',
            scheme.onSurface,
            scheme.surface,
            textAA,
          );
          expectContrast(
            'onSurfaceVariant on surface',
            scheme.onSurfaceVariant,
            scheme.surface,
            textAA,
          );
          expectContrast(
            'onSecondary on secondary',
            scheme.onSecondary,
            scheme.secondary,
            textAA,
          );
          expectContrast(
            'onErrorContainer on errorContainer',
            scheme.onErrorContainer,
            scheme.errorContainer,
            textAA,
          );
          expectContrast(
            'onInverseSurface on inverseSurface',
            scheme.onInverseSurface,
            scheme.inverseSurface,
            textAA,
          );
        });
      });
    }
  }

  test('constant tokens are identical across themes', () {
    final light = NasikoColorThemeFactory.light(NasikoColorPalette.yellow);
    final dark = NasikoColorThemeFactory.dark(NasikoColorPalette.yellow);
    expect(light.foregroundConstantWhite, dark.foregroundConstantWhite);
    expect(light.foregroundConstantBlack, dark.foregroundConstantBlack);
    expect(
      light.foregroundConstantBlackSecondary,
      dark.foregroundConstantBlackSecondary,
    );
  });

  test('default themes are the factory yellow output (no drift)', () {
    final factoryLight = NasikoColorThemeFactory.light(
      NasikoColorPalette.yellow,
    );
    expect(lightColors.backgroundBrand, factoryLight.backgroundBrand);
    expect(lightColors.foregroundPrimary, factoryLight.foregroundPrimary);
    final factoryDark = NasikoColorThemeFactory.dark(
      NasikoColorPalette.yellow,
    );
    expect(darkColors.backgroundBrand, factoryDark.backgroundBrand);
    expect(darkColors.foregroundPrimary, factoryDark.foregroundPrimary);
  });
}
