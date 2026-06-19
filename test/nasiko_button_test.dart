import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Pumps [child] under ScreenUtilInit + NasikoTheme so tokens resolve.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
}) {
  return tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(1728, 1117),
      builder: (context, _) => MaterialApp(
        theme: theme ?? NasikoTheme.lightTheme,
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

/// Valid (type, tone) pairs. `destructive` is only supported for primary and
/// secondary; pairing it with other types trips a debug assert by design.
Iterable<(NasikoButtonType, NasikoButtonTone)> _validCombos() sync* {
  for (final type in NasikoButtonType.values) {
    for (final tone in NasikoButtonTone.values) {
      final destructiveAllowed = type == NasikoButtonType.primary ||
          type == NasikoButtonType.secondary;
      if (tone == NasikoButtonTone.destructive && !destructiveAllowed) {
        continue;
      }
      yield (type, tone);
    }
  }
}

void main() {
  setUpAll(() {
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(390, 844)),
      designSize: const Size(390, 844),
      splitScreenMode: false,
      minTextAdapt: true,
    );
  });

  group('NasikoButton enums', () {
    test('type has the five emphasis values', () {
      expect(NasikoButtonType.values, hasLength(5));
      expect(NasikoButtonType.values, containsAll(<NasikoButtonType>[
        NasikoButtonType.primary,
        NasikoButtonType.secondary,
        NasikoButtonType.tertiary,
        NasikoButtonType.ghost,
        NasikoButtonType.link,
      ]));
    });

    test('tone has default and destructive', () {
      expect(NasikoButtonTone.values, hasLength(2));
      expect(NasikoButtonTone.values, containsAll(<NasikoButtonTone>[
        NasikoButtonTone.default_,
        NasikoButtonTone.destructive,
      ]));
    });
  });

  group('buttonLayoutV2', () {
    testWidgets('heights are 28 / 32 / 36 by size', (tester) async {
      late NasikoButtonLayoutV2 small, medium, large;
      await _pump(
        tester,
        Builder(builder: (context) {
          small = buttonLayoutV2(context, NasikoButtonSize.small);
          medium = buttonLayoutV2(context, NasikoButtonSize.medium);
          large = buttonLayoutV2(context, NasikoButtonSize.large);
          return const SizedBox();
        }),
      );
      expect(small.height, 28);
      expect(medium.height, 32);
      expect(large.height, 36);
    });

    testWidgets('radius is size-based and bound to the radius tokens',
        (tester) async {
      // Radius tokens pass through screenutil `.r` scaling, so assert the
      // layout binds the right token (not a raw literal): small => r6/r8,
      // medium & large => r8/r10.
      late NasikoButtonLayoutV2 s, m, l;
      late NasikoBorderRadiusTheme radii;
      await _pump(
        tester,
        Builder(builder: (context) {
          radii = context.radius;
          s = buttonLayoutV2(context, NasikoButtonSize.small);
          m = buttonLayoutV2(context, NasikoButtonSize.medium);
          l = buttonLayoutV2(context, NasikoButtonSize.large);
          return const SizedBox();
        }),
      );
      expect(s.bodyRadius, radii.r6);
      expect(s.focusRadius, radii.r8);
      expect(m.bodyRadius, radii.r8);
      expect(m.focusRadius, radii.r10);
      expect(l.bodyRadius, radii.r8);
      expect(l.focusRadius, radii.r10);
    });

    testWidgets('content gap is 6 / 6 / 8 and icon size 12 / 16 / 20',
        (tester) async {
      late NasikoButtonLayoutV2 s, m, l;
      await _pump(
        tester,
        Builder(builder: (context) {
          s = buttonLayoutV2(context, NasikoButtonSize.small);
          m = buttonLayoutV2(context, NasikoButtonSize.medium);
          l = buttonLayoutV2(context, NasikoButtonSize.large);
          return const SizedBox();
        }),
      );
      expect(s.contentGap, 6);
      expect(m.contentGap, 6);
      expect(l.contentGap, 8);
      expect(s.iconSize, 12);
      expect(m.iconSize, 16);
      expect(l.iconSize, 20);
    });
  });

  group('resolveButtonColors', () {
    late NasikoColorTheme colors;
    setUp(() {
      colors = lightColors;
    });

    test('primary default is charcoal fill with white text', () {
      final c = resolveButtonColors(
        colors,
        NasikoButtonType.primary,
        NasikoButtonTone.default_,
        NasikoButtonState.defaultState,
      );
      expect(c.fill, colors.foregroundConstantBlackSecondary);
      expect(c.foreground, colors.foregroundConstantWhite);
      expect(c.focusRing, isNull);
    });

    test('primary active uses the neutral-700 fill', () {
      final c = resolveButtonColors(
        colors,
        NasikoButtonType.primary,
        NasikoButtonTone.default_,
        NasikoButtonState.active,
      );
      expect(c.fill, colors.backgroundNeutralActive);
    });

    test('focused state exposes the secondary border as a focus ring', () {
      final c = resolveButtonColors(
        colors,
        NasikoButtonType.primary,
        NasikoButtonTone.default_,
        NasikoButtonState.focused,
      );
      expect(c.focusRing, colors.borderSecondary);
      // focused keeps the default fill.
      expect(c.fill, colors.foregroundConstantBlackSecondary);
    });

    test('primary destructive ramps error -> red700 -> red900', () {
      final hover = resolveButtonColors(
        colors,
        NasikoButtonType.primary,
        NasikoButtonTone.destructive,
        NasikoButtonState.hovered,
      );
      final active = resolveButtonColors(
        colors,
        NasikoButtonType.primary,
        NasikoButtonTone.destructive,
        NasikoButtonState.active,
      );
      expect(hover.fill, colors.backgroundErrorHover);
      expect(active.fill, colors.backgroundErrorActive);
      expect(hover.foreground, colors.foregroundConstantWhite);
    });

    test('secondary destructive is outlined with the strong red border', () {
      final c = resolveButtonColors(
        colors,
        NasikoButtonType.secondary,
        NasikoButtonTone.destructive,
        NasikoButtonState.defaultState,
      );
      expect(c.fill, colors.backgroundBase);
      expect(c.border, colors.borderErrorStrong);
      expect(c.foreground, colors.foregroundError);
    });

    test('link is a neutral underlined text link with transparent fill', () {
      final c = resolveButtonColors(
        colors,
        NasikoButtonType.link,
        NasikoButtonTone.default_,
        NasikoButtonState.defaultState,
      );
      expect(c.fill, Colors.transparent);
      expect(c.foreground, colors.foregroundPrimary);
    });

    test('link darkens to brand-hover on hover', () {
      final c = resolveButtonColors(
        colors,
        NasikoButtonType.link,
        NasikoButtonTone.default_,
        NasikoButtonState.hovered,
      );
      expect(c.foreground, colors.foregroundBrandHover);
    });

    test('disabled overrides every type', () {
      final c = resolveButtonColors(
        colors,
        NasikoButtonType.primary,
        NasikoButtonTone.default_,
        NasikoButtonState.disabled,
      );
      expect(c.fill, colors.backgroundDisabled);
      expect(c.foreground, colors.foregroundDisabled);
    });

    test('secondary default has brand fill', () {
      final c = resolveButtonColors(
        colors,
        NasikoButtonType.secondary,
        NasikoButtonTone.default_,
        NasikoButtonState.defaultState,
      );
      expect(c.fill, colors.backgroundSecondaryBrand);
    });
  });

  group('NasikoButton widget', () {
    testWidgets('renders label and is tappable', (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        NasikoButton(
          type: NasikoButtonType.primary,
          label: 'Save',
          onPressed: () => tapped++,
        ),
      );
      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.byType(NasikoButton));
      expect(tapped, 1);
    });

    testWidgets('null onPressed renders disabled (not tappable)',
        (tester) async {
      await _pump(
        tester,
        const NasikoButton(
          type: NasikoButtonType.primary,
          label: 'Off',
          onPressed: null,
        ),
      );
      await tester.tap(find.byType(NasikoButton), warnIfMissed: false);
      expect(find.text('Off'), findsOneWidget);
    });

    testWidgets('builds for every valid type x tone x size', (tester) async {
      for (final (type, tone) in _validCombos()) {
        for (final size in NasikoButtonSize.values) {
          await _pump(
            tester,
            NasikoButton(
              type: type,
              tone: tone,
              size: size,
              label: 'X',
              onPressed: () {},
            ),
          );
          expect(find.text('X'), findsOneWidget);
        }
      }
    });
  });

  group('NasikoIconButton widget', () {
    testWidgets('renders an icon and is tappable', (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        NasikoIconButton(
          type: NasikoButtonType.primary,
          icon: HugeIcons.strokeRoundedAdd01,
          onPressed: () => tapped++,
        ),
      );
      expect(find.byType(HugeIcon), findsOneWidget);
      await tester.tap(find.byType(NasikoIconButton));
      expect(tapped, 1);
    });

    testWidgets('is square (width == height) for each size', (tester) async {
      for (final size in NasikoButtonSize.values) {
        await _pump(
          tester,
          NasikoIconButton(
            type: NasikoButtonType.secondary,
            size: size,
            icon: HugeIcons.strokeRoundedAdd01,
            onPressed: () {},
          ),
        );
        final box = tester.getSize(find.byType(NasikoIconButton));
        expect(box.width, box.height,
            reason: 'icon button must be square for size $size');
      }
    });

    testWidgets('builds for every valid type x tone x size', (tester) async {
      for (final (type, tone) in _validCombos()) {
        for (final size in NasikoButtonSize.values) {
          await _pump(
            tester,
            NasikoIconButton(
              type: type,
              tone: tone,
              size: size,
              icon: HugeIcons.strokeRoundedAdd01,
              onPressed: () {},
            ),
          );
          expect(find.byType(HugeIcon), findsOneWidget);
        }
      }
    });
  });
}
