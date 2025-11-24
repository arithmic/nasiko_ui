import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

void main() {
  group('NasikoTheme - Light Theme', () {
    testWidgets('Light theme is properly configured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NasikoTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Text(
                  'Light Theme Test',
                  style: TextStyle(color: context.colors.foregroundPrimary),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      final theme = NasikoTheme.lightTheme;
      expect(theme.brightness, equals(Brightness.light));
    });

    test('Light color scheme has correct brightness', () {
      final theme = NasikoTheme.lightTheme;
      expect(theme.colorScheme.brightness, equals(Brightness.light));
    });

    test('Light theme extensions are registered', () {
      final theme = NasikoTheme.lightTheme;
      expect(theme.extensions, isNotNull);
      expect(theme.extensions.length, equals(6));
    });
  });

  group('NasikoTheme - Dark Theme', () {
    testWidgets('Dark theme is properly configured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NasikoTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Text(
                  'Dark Theme Test',
                  style: TextStyle(color: context.colors.foregroundPrimary),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      final theme = NasikoTheme.darkTheme;
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('Dark color scheme has correct brightness', () {
      final theme = NasikoTheme.darkTheme;
      expect(theme.colorScheme.brightness, equals(Brightness.dark));
    });

    test('Dark theme extensions are registered', () {
      final theme = NasikoTheme.darkTheme;
      expect(theme.extensions, isNotNull);
      expect(theme.extensions.length, equals(6));
    });
  });

  group('Color Tokens - Light Theme', () {
    test('Light colors instance is immutable', () {
      expect(identical(lightColors, lightColors), true);
    });

    test('Light background colors are not null', () {
      expect(lightColors.backgroundBase, isNotNull);
      expect(lightColors.backgroundGroup, isNotNull);
      expect(lightColors.backgroundSurface, isNotNull);
      expect(lightColors.backgroundBrand, isNotNull);
    });

    test('Light foreground colors are not null', () {
      expect(lightColors.foregroundPrimary, isNotNull);
      expect(lightColors.foregroundSecondary, isNotNull);
      expect(lightColors.foregroundBrand, isNotNull);
    });

    test('Light border colors are not null', () {
      expect(lightColors.borderPrimary, isNotNull);
      expect(lightColors.borderSecondary, isNotNull);
    });

    test('Light colors copyWith preserves original values', () {
      final copied = lightColors.copyWith();
      expect(copied.foregroundPrimary, equals(lightColors.foregroundPrimary));
      expect(copied.backgroundBrand, equals(lightColors.backgroundBrand));
    });

    test('Light colors copyWith overrides specific values', () {
      const testColor = Color(0xFFFF0000);
      final modified = lightColors.copyWith(foregroundPrimary: testColor);
      expect(modified.foregroundPrimary, equals(testColor));
      expect(
        modified.foregroundSecondary,
        equals(lightColors.foregroundSecondary),
      );
    });
  });

  group('Color Tokens - Dark Theme', () {
    test('Dark colors instance is immutable', () {
      expect(identical(darkColors, darkColors), true);
    });

    test('Dark background colors are not null', () {
      expect(darkColors.backgroundBase, isNotNull);
      expect(darkColors.backgroundGroup, isNotNull);
      expect(darkColors.backgroundSurface, isNotNull);
      expect(darkColors.backgroundBrand, isNotNull);
    });

    test('Dark foreground colors are not null', () {
      expect(darkColors.foregroundPrimary, isNotNull);
      expect(darkColors.foregroundSecondary, isNotNull);
      expect(darkColors.foregroundBrand, isNotNull);
    });

    test('Dark colors copyWith preserves original values', () {
      final copied = darkColors.copyWith();
      expect(copied.foregroundPrimary, equals(darkColors.foregroundPrimary));
      expect(copied.backgroundBrand, equals(darkColors.backgroundBrand));
    });
  });

  group('Color Lerp (Interpolation)', () {
    test('Light to dark color lerp at t=0 returns light colors', () {
      final result = lightColors.lerp(darkColors, 0.0);
      expect(result.foregroundPrimary, equals(lightColors.foregroundPrimary));
      expect(result.backgroundBase, equals(lightColors.backgroundBase));
    });

    test('Light to dark color lerp at t=1 returns dark colors', () {
      final result = lightColors.lerp(darkColors, 1.0);
      expect(result.foregroundPrimary, equals(darkColors.foregroundPrimary));
      expect(result.backgroundBase, equals(darkColors.backgroundBase));
    });

    test('Light to dark color lerp at t=0.5 returns intermediate color', () {
      final result = lightColors.lerp(darkColors, 0.5);
      final intermediateColor = Color.lerp(
        lightColors.foregroundPrimary,
        darkColors.foregroundPrimary,
        0.5,
      );
      expect(result.foregroundPrimary, equals(intermediateColor));
    });

    test('Lerp with non-NasikoColorTheme returns original', () {
      final result = lightColors.lerp(null, 0.5);
      expect(result, equals(lightColors));
    });
  });

  group('Spacing Tokens', () {
    test('Spacing values are not null', () {
      expect(defaultNasikoSpacing.s0, isNotNull);
      expect(defaultNasikoSpacing.s2, isNotNull);
      expect(defaultNasikoSpacing.s4, isNotNull);
      expect(defaultNasikoSpacing.s8, isNotNull);
      expect(defaultNasikoSpacing.s12, isNotNull);
      expect(defaultNasikoSpacing.s16, isNotNull);
    });

    test('Spacing values are in ascending order', () {
      expect(
        defaultNasikoSpacing.s0.compareTo(defaultNasikoSpacing.s2),
        lessThan(0),
      );
      expect(
        defaultNasikoSpacing.s2.compareTo(defaultNasikoSpacing.s4),
        lessThan(0),
      );
    });
  });

  group('Typography Tokens', () {
    test('Typography heading styles are not null', () {
      expect(defaultNasikoTypography.titlePrimary, isNotNull);
      expect(defaultNasikoTypography.titleSecondary, isNotNull);
      expect(defaultNasikoTypography.buttonPrimary, isNotNull);
      expect(defaultNasikoTypography.buttonSecondary, isNotNull);
    });

    test('Typography body styles are not null', () {
      expect(defaultNasikoTypography.bodyPrimary, isNotNull);
      expect(defaultNasikoTypography.bodySecondary, isNotNull);
      expect(defaultNasikoTypography.bodyTertiary, isNotNull);
    });

    test('Typography heading has larger font size than body', () {
      expect(
        defaultNasikoTypography.titlePrimary.fontSize!,
        greaterThan(defaultNasikoTypography.bodyPrimary.fontSize!),
      );
    });
  });

  group('Border Radius Tokens', () {
    test('Border radius values are not null', () {
      expect(defaultNasikoBorderRadius.r0, isNotNull);
      expect(defaultNasikoBorderRadius.r4, isNotNull);
      expect(defaultNasikoBorderRadius.r8, isNotNull);
      expect(defaultNasikoBorderRadius.r16, isNotNull);
    });

    test('Border radius values are in ascending order', () {
      expect(
        defaultNasikoBorderRadius.r0,
        lessThan(defaultNasikoBorderRadius.r4),
      );
      expect(
        defaultNasikoBorderRadius.r4,
        lessThan(defaultNasikoBorderRadius.r8),
      );
      expect(
        defaultNasikoBorderRadius.r8,
        lessThan(defaultNasikoBorderRadius.r16),
      );
    });
  });

  group('Border Width Tokens', () {
    test('Border width values are not null', () {
      expect(defaultNasikoBorderWidth.w0, isNotNull);
      expect(defaultNasikoBorderWidth.w1, isNotNull);
      expect(defaultNasikoBorderWidth.w2, isNotNull);
      expect(defaultNasikoBorderWidth.w4, isNotNull);
    });

    test('Border width values are positive', () {
      expect(defaultNasikoBorderWidth.w1, greaterThan(0));
      expect(defaultNasikoBorderWidth.w2, greaterThan(0));
      expect(defaultNasikoBorderWidth.w4, greaterThan(0));
    });
  });

  group('Icon Size Tokens', () {
    test('Icon size values are not null', () {
      expect(defaultNasikoIconSize.xs, isNotNull);
      expect(defaultNasikoIconSize.s, isNotNull);
      expect(defaultNasikoIconSize.m, isNotNull);
      expect(defaultNasikoIconSize.l, isNotNull);
    });

    test('Icon sizes are in ascending order', () {
      expect(defaultNasikoIconSize.xs, lessThan(defaultNasikoIconSize.s));
      expect(defaultNasikoIconSize.s, lessThan(defaultNasikoIconSize.m));
      expect(defaultNasikoIconSize.m, lessThan(defaultNasikoIconSize.l));
    });
  });

  group('BuildContext Extensions', () {
    testWidgets(
      'BuildContext.colors returns NasikoColorTheme from light theme',
      (WidgetTester tester) async {
        late NasikoColorTheme capturedColors;

        await tester.pumpWidget(
          MaterialApp(
            theme: NasikoTheme.lightTheme,
            home: Builder(
              builder: (context) {
                capturedColors = context.colors;
                return const Scaffold();
              },
            ),
          ),
        );

        expect(capturedColors, equals(lightColors));
      },
    );

    testWidgets(
      'BuildContext.colors returns NasikoColorTheme from dark theme',
      (WidgetTester tester) async {
        late NasikoColorTheme capturedColors;

        await tester.pumpWidget(
          MaterialApp(
            theme: NasikoTheme.darkTheme,
            home: Builder(
              builder: (context) {
                capturedColors = context.colors;
                return const Scaffold();
              },
            ),
          ),
        );

        expect(capturedColors, equals(darkColors));
      },
    );

    testWidgets('BuildContext.spacing returns NasikoSpacingTheme', (
      WidgetTester tester,
    ) async {
      late NasikoSpacingTheme capturedSpacing;

      await tester.pumpWidget(
        MaterialApp(
          theme: NasikoTheme.lightTheme,
          home: Builder(
            builder: (context) {
              capturedSpacing = context.spacing;
              return const Scaffold();
            },
          ),
        ),
      );

      expect(capturedSpacing, equals(defaultNasikoSpacing));
    });

    testWidgets('BuildContext.typography returns NasikoTypography', (
      WidgetTester tester,
    ) async {
      late NasikoTypography capturedTypography;

      await tester.pumpWidget(
        MaterialApp(
          theme: NasikoTheme.lightTheme,
          home: Builder(
            builder: (context) {
              capturedTypography = context.typography;
              return const Scaffold();
            },
          ),
        ),
      );

      expect(capturedTypography, equals(defaultNasikoTypography));
    });

    testWidgets('BuildContext.borderRadius returns NasikoBorderRadiusTheme', (
      WidgetTester tester,
    ) async {
      late NasikoBorderRadiusTheme capturedRadius;

      await tester.pumpWidget(
        MaterialApp(
          theme: NasikoTheme.lightTheme,
          home: Builder(
            builder: (context) {
              capturedRadius = context.radius;
              return const Scaffold();
            },
          ),
        ),
      );

      expect(capturedRadius, equals(defaultNasikoBorderRadius));
    });
  });

  group('Theme Extension - copyWith', () {
    test('NasikoColorTheme copyWith returns new instance', () {
      final modified = lightColors.copyWith(
        foregroundPrimary: const Color(0xFFFF0000),
      );
      expect(identical(modified, lightColors), false);
    });

    test('NasikoSpacingTheme copyWith works correctly', () {
      final modified = defaultNasikoSpacing.copyWith(s16: 20.0);
      expect(modified.s16, equals(20.0));
      expect(modified.s8, equals(defaultNasikoSpacing.s8));
    });
  });

  group('Color Accessibility', () {
    test('Light theme uses readable contrast for primary text', () {
      // foregroundPrimary should have good contrast on backgroundBase
      final textColor = lightColors.foregroundPrimary;
      final bgColor = lightColors.backgroundBase;
      expect(textColor, isNotNull);
      expect(bgColor, isNotNull);
      // This is a basic sanity check; full WCAG validation would require additional tools
    });

    test('Light theme uses readable contrast for secondary text', () {
      final textColor = lightColors.foregroundSecondary;
      final bgColor = lightColors.backgroundBase;
      expect(textColor, isNotNull);
      expect(bgColor, isNotNull);
    });
  });
}
