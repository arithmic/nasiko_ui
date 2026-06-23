import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Pumps [child] under ScreenUtilInit + NasikoTheme so tokens resolve.
Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(1728, 1117),
      builder: (context, _) => MaterialApp(
        theme: NasikoTheme.lightTheme,
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
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

  group('NasikoSearchSize', () {
    test('has medium and small', () {
      expect(NasikoSearchSize.values, hasLength(2));
      expect(
        NasikoSearchSize.values,
        containsAll(<NasikoSearchSize>[
          NasikoSearchSize.medium,
          NasikoSearchSize.small,
        ]),
      );
    });
  });

  group('searchLayout', () {
    testWidgets('medium resolves the default density values', (tester) async {
      late NasikoSearchLayout layout;
      await _pump(
        tester,
        Builder(builder: (context) {
          layout = searchLayout(context, NasikoSearchSize.medium);
          return const SizedBox();
        }),
      );
      final ctx = tester.element(find.byType(SizedBox));
      expect(layout.height, ctx.spacing.s36);
      expect(layout.horizontalPadding, ctx.spacing.s12);
      expect(layout.contentGap, ctx.spacing.s8);
      expect(layout.iconSize, ctx.iconSize.sm);
      expect(layout.bodyRadius, ctx.radius.r8);
      expect(layout.focusRadius, ctx.radius.r10);
    });

    testWidgets('small resolves the compact density values', (tester) async {
      late NasikoSearchLayout layout;
      await _pump(
        tester,
        Builder(builder: (context) {
          layout = searchLayout(context, NasikoSearchSize.small);
          return const SizedBox();
        }),
      );
      final ctx = tester.element(find.byType(SizedBox));
      expect(layout.height, ctx.spacing.s28);
      expect(layout.horizontalPadding, ctx.spacing.s8);
      expect(layout.contentGap, ctx.spacing.s6);
      expect(layout.iconSize, ctx.iconSize.xs);
      expect(layout.bodyRadius, ctx.radius.r6);
      expect(layout.focusRadius, ctx.radius.r8);
    });
  });

  group('resolveSearchColors', () {
    testWidgets('default/hover/focus fills are white (base)', (tester) async {
      late NasikoSearchColors def;
      late NasikoSearchColors hover;
      late NasikoSearchColors focus;
      await _pump(
        tester,
        Builder(builder: (context) {
          def = resolveSearchColors(context, NasikoSearchVisualState.normal);
          hover = resolveSearchColors(context, NasikoSearchVisualState.hover);
          focus = resolveSearchColors(context, NasikoSearchVisualState.focus);
          return const SizedBox();
        }),
      );
      final ctx = tester.element(find.byType(SizedBox));
      expect(def.fill, ctx.colors.backgroundBase);
      expect(def.border, ctx.colors.borderPrimary);
      expect(def.ring, isNull);
      expect(hover.border, ctx.colors.borderSecondary); // gold
      expect(focus.border, ctx.colors.borderPrimary);
      expect(focus.ring, ctx.colors.borderSecondary); // gold ring
    });

    testWidgets('disabled + loading map to semantic tokens', (tester) async {
      late NasikoSearchColors dis;
      late NasikoSearchColors load;
      await _pump(
        tester,
        Builder(builder: (context) {
          dis = resolveSearchColors(context, NasikoSearchVisualState.disabled);
          load = resolveSearchColors(context, NasikoSearchVisualState.loading);
          return const SizedBox();
        }),
      );
      final ctx = tester.element(find.byType(SizedBox));
      expect(dis.fill, ctx.colors.backgroundDisabled);
      expect(dis.border, ctx.colors.borderDisabled);
      expect(dis.text, ctx.colors.foregroundDisabled);
      expect(load.fill, ctx.colors.backgroundBase);
      expect(load.border, ctx.colors.borderPrimary);
      expect(load.ring, isNull);
    });
  });

  group('NasikoSearch rendering', () {
    testWidgets('renders placeholder, a TextField and the leading icon',
        (tester) async {
      await _pump(tester, const NasikoSearch());
      expect(find.text('Search'), findsOneWidget); // default placeholder
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(HugeIcon), findsOneWidget); // leading only (empty)
    });

    testWidgets('custom placeholder renders', (tester) async {
      await _pump(tester, const NasikoSearch(placeholder: 'Find anything'));
      expect(find.text('Find anything'), findsOneWidget);
    });

    testWidgets('typing reveals the clear icon', (tester) async {
      await _pump(tester, const NasikoSearch());
      expect(find.byType(HugeIcon), findsOneWidget); // leading only
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(find.byType(HugeIcon), findsNWidgets(2)); // leading + clear
    });

    testWidgets('tapping clear empties the field and fires onClear',
        (tester) async {
      var cleared = false;
      final controller = TextEditingController(text: 'hello');
      addTearDown(controller.dispose);
      await _pump(
        tester,
        NasikoSearch(controller: controller, onClear: () => cleared = true),
      );
      expect(find.byType(HugeIcon), findsNWidgets(2));
      await tester.tap(find.byType(HugeIcon).last);
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(cleared, isTrue);
      expect(find.byType(HugeIcon), findsOneWidget); // clear gone
    });

    testWidgets('loading shows a spinner and hides the clear icon',
        (tester) async {
      final controller = TextEditingController(text: 'hello');
      addTearDown(controller.dispose);
      await _pump(
        tester,
        NasikoSearch(controller: controller, isLoading: true),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(HugeIcon), findsOneWidget); // leading only, no clear
    });

    testWidgets('disabled disables the TextField and hides clear',
        (tester) async {
      final controller = TextEditingController(text: 'hello');
      addTearDown(controller.dispose);
      await _pump(
        tester,
        NasikoSearch(controller: controller, enabled: false),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
      expect(find.byType(HugeIcon), findsOneWidget); // leading only
    });

    testWidgets('medium box uses the 36 height', (tester) async {
      await _pump(tester, const NasikoSearch(size: NasikoSearchSize.medium));
      final ctx = tester.element(find.byType(NasikoSearch));
      final box = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(NasikoSearch),
            matching: find.byType(Container),
          ))
          .firstWhere((c) =>
              c.decoration is BoxDecoration &&
              (c.decoration as BoxDecoration).border != null &&
              c.constraints?.maxHeight == ctx.spacing.s36);
      expect(box.constraints?.maxHeight, ctx.spacing.s36);
    });

    testWidgets('small box uses the 28 height', (tester) async {
      await _pump(tester, const NasikoSearch(size: NasikoSearchSize.small));
      final ctx = tester.element(find.byType(NasikoSearch));
      final box = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(NasikoSearch),
            matching: find.byType(Container),
          ))
          .firstWhere((c) =>
              c.decoration is BoxDecoration &&
              (c.decoration as BoxDecoration).border != null &&
              c.constraints?.maxHeight == ctx.spacing.s28);
      expect(box.constraints?.maxHeight, ctx.spacing.s28);
    });
  });
}
