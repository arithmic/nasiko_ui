import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  group('NasikoDivider enums', () {
    test('Type has default and thick', () {
      expect(NasikoDividerType.values, hasLength(2));
      expect(
        NasikoDividerType.values,
        containsAll(<NasikoDividerType>[
          NasikoDividerType.defaultType,
          NasikoDividerType.thick,
        ]),
      );
    });

    test('Style has solid, dashed, dotted', () {
      expect(NasikoDividerStyle.values, hasLength(3));
      expect(
        NasikoDividerStyle.values,
        containsAll(<NasikoDividerStyle>[
          NasikoDividerStyle.solid,
          NasikoDividerStyle.dashed,
          NasikoDividerStyle.dotted,
        ]),
      );
    });

    test('Tone has default and subtle', () {
      expect(NasikoDividerTone.values, hasLength(2));
      expect(
        NasikoDividerTone.values,
        containsAll(<NasikoDividerTone>[
          NasikoDividerTone.defaultTone,
          NasikoDividerTone.subtle,
        ]),
      );
    });
  });

  group('NasikoDivider solid rendering', () {
    testWidgets('default renders built-in Divider, w1, borderPrimary',
        (tester) async {
      await _pump(tester, const NasikoDivider());
      final divider = tester.widget<Divider>(find.byType(Divider));
      final colors = NasikoTheme.lightTheme.extension<NasikoColorTheme>()!;
      expect(divider.thickness, 1);
      expect(divider.color, colors.borderPrimary);
    });

    testWidgets('thick type uses w2', (tester) async {
      await _pump(
        tester,
        const NasikoDivider(type: NasikoDividerType.thick),
      );
      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.thickness, 2);
    });

    testWidgets('subtle tone uses borderSecondary', (tester) async {
      await _pump(
        tester,
        const NasikoDivider(tone: NasikoDividerTone.subtle),
      );
      final divider = tester.widget<Divider>(find.byType(Divider));
      final colors = NasikoTheme.lightTheme.extension<NasikoColorTheme>()!;
      expect(divider.color, colors.borderSecondary);
    });

    testWidgets('vertical default renders built-in VerticalDivider',
        (tester) async {
      await _pump(
        tester,
        const SizedBox(
          height: 40,
          child: NasikoDivider(axis: NasikoDividerAxis.vertical),
        ),
      );
      expect(find.byType(VerticalDivider), findsOneWidget);
    });
  });

  group('NasikoDivider dashed/dotted rendering', () {
    testWidgets('dashed does NOT use the built-in Divider', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 100,
          child: NasikoDivider(style: NasikoDividerStyle.dashed),
        ),
      );
      expect(find.byType(Divider), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('dotted does NOT use the built-in Divider', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 100,
          child: NasikoDivider(style: NasikoDividerStyle.dotted),
        ),
      );
      expect(find.byType(Divider), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('dashed vertical paints without error', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          height: 100,
          child: NasikoDivider(
            axis: NasikoDividerAxis.vertical,
            style: NasikoDividerStyle.dashed,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('NasikoDivider label', () {
    testWidgets('showLabel renders the label text', (tester) async {
      await _pump(
        tester,
        const SizedBox(width: 200, child: NasikoDivider(
          showLabel: true,
          label: 'Section',
        )),
      );
      expect(find.text('Section'), findsOneWidget);
    });

    testWidgets('label uses foregroundSecondary color', (tester) async {
      await _pump(
        tester,
        const SizedBox(width: 200, child: NasikoDivider(
          showLabel: true,
          label: 'Section',
        )),
      );
      final colors = NasikoTheme.lightTheme.extension<NasikoColorTheme>()!;
      final text = tester.widget<Text>(find.text('Section'));
      expect(text.style?.color, colors.foregroundSecondary);
    });

    testWidgets('no label when showLabel is false', (tester) async {
      await _pump(
        tester,
        const SizedBox(width: 200, child: NasikoDivider(label: 'Section')),
      );
      expect(find.text('Section'), findsNothing);
    });

    testWidgets('label is ignored on the vertical axis', (tester) async {
      await _pump(
        tester,
        const SizedBox(height: 200, child: NasikoDivider(
          axis: NasikoDividerAxis.vertical,
          showLabel: true,
          label: 'Section',
        )),
      );
      expect(find.text('Section'), findsNothing);
    });
  });
}
