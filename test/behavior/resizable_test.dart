// test/behavior/resizable_test.dart
//
// Behavior tests for NasikoResizablePanelGroup: dragging a divider
// redistributes space respecting min/max, double-tap resets the adjacent
// pair, arrow keys resize a focused divider by 2% steps, and
// onLayoutChanged reports normalized fractions.
//
// Assertions run against the onLayoutChanged fractions, not pixel sizes:
// fractions are exact (the component rounds to 6 decimals), whereas drag
// pixel math is offset by touch slop. Clamped drags land EXACTLY on the
// min/max bound, so those asserts stay slop-independent.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Finder divider() => find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_ResizableDivider',
      );

  /// Two panels of equal default flex. With the flexes below and total
  /// default flex 2.0, panel A is clamped to fractions [0.25, 0.7].
  Future<void> pumpTwoPanels(
    WidgetTester tester, {
    required List<List<double>> layouts,
    bool resetOnDoubleTap = true,
  }) async {
    await pumpNasiko(
      tester,
      SizedBox(
        width: 508, // 500 of panel space + one 8px divider.
        height: 160,
        child: NasikoResizablePanelGroup(
          resetOnDoubleTap: resetOnDoubleTap,
          onLayoutChanged: layouts.add,
          panels: [
            NasikoResizablePanel(
              defaultFlex: 1,
              minFlex: 0.5, // -> min fraction 0.25
              maxFlex: 1.4, // -> max fraction 0.7
              child: Container(key: const ValueKey('panel-a')),
            ),
            NasikoResizablePanel(
              defaultFlex: 1,
              child: Container(key: const ValueKey('panel-b')),
            ),
          ],
        ),
      ),
    );
  }

  void expectFractions(List<double> actual, List<double> expected) {
    expect(actual, hasLength(expected.length));
    for (var i = 0; i < expected.length; i++) {
      expect(actual[i], closeTo(expected[i], 0.001),
          reason: 'panel $i fraction');
    }
  }

  group('NasikoResizablePanelGroup dragging', () {
    testWidgets('dragging the divider redistributes and fires '
        'onLayoutChanged', (tester) async {
      final layouts = <List<double>>[];
      await pumpTwoPanels(tester, layouts: layouts);
      expect(layouts, isEmpty, reason: 'defaults do not fire the callback');

      await tester.drag(divider(), const Offset(-60, 0));
      await tester.pump();

      expect(layouts, isNotEmpty);
      final last = layouts.last;
      expect(last[0], lessThan(0.5));
      expect(last[1], greaterThan(0.5));
      expect(last[0] + last[1], closeTo(1.0, 0.0001));
    });

    testWidgets('a drag past the min clamps exactly at the min fraction',
        (tester) async {
      final layouts = <List<double>>[];
      await pumpTwoPanels(tester, layouts: layouts);

      // 400px on a 500px extent is a 0.8 delta — far beyond what panel A
      // can shrink; the layout stops at its min fraction.
      await tester.drag(divider(), const Offset(-400, 0));
      await tester.pump();

      expectFractions(layouts.last, [0.25, 0.75]);
    });

    testWidgets('a drag past the max clamps exactly at the max fraction',
        (tester) async {
      final layouts = <List<double>>[];
      await pumpTwoPanels(tester, layouts: layouts);

      await tester.drag(divider(), const Offset(400, 0));
      await tester.pump();

      expectFractions(layouts.last, [0.7, 0.3]);
    });

    testWidgets('with three panels, overflow cascades past a neighbor at '
        'its min', (tester) async {
      final layouts = <List<double>>[];
      await pumpNasiko(
        tester,
        SizedBox(
          width: 516, // 500 of panel space + two 8px dividers.
          height: 160,
          child: NasikoResizablePanelGroup(
            onLayoutChanged: layouts.add,
            panels: [
              NasikoResizablePanel(
                defaultFlex: 1,
                child: Container(key: const ValueKey('panel-a')),
              ),
              NasikoResizablePanel(
                defaultFlex: 1,
                minFlex: 0.75, // -> min fraction 0.25
                child: Container(key: const ValueKey('panel-b')),
              ),
              NasikoResizablePanel(
                defaultFlex: 1,
                minFlex: 0.3, // -> min fraction 0.1
                child: Container(key: const ValueKey('panel-c')),
              ),
            ],
          ),
        ),
      );

      // Drag the FIRST divider far right: panel B shrinks to its min
      // (0.25), the remainder cascades into panel C down to its min (0.1),
      // and panel A absorbs the total.
      await tester.drag(divider().first, const Offset(450, 0));
      await tester.pump();

      expectFractions(layouts.last, [0.65, 0.25, 0.1]);
    });
  });

  group('NasikoResizablePanelGroup double-tap reset', () {
    testWidgets('double-tapping the divider restores the default split',
        (tester) async {
      final layouts = <List<double>>[];
      await pumpTwoPanels(tester, layouts: layouts);

      await tester.drag(divider(), const Offset(-400, 0));
      await tester.pump();
      expectFractions(layouts.last, [0.25, 0.75]);

      await tester.tap(divider());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(divider());
      await tester.pump();
      // Flush the double-tap recognizer's window before the test ends.
      await tester.pump(const Duration(milliseconds: 400));

      expectFractions(layouts.last, [0.5, 0.5]);
    });

    testWidgets('resetOnDoubleTap: false leaves the layout untouched',
        (tester) async {
      final layouts = <List<double>>[];
      await pumpTwoPanels(
        tester,
        layouts: layouts,
        resetOnDoubleTap: false,
      );

      await tester.drag(divider(), const Offset(-400, 0));
      await tester.pump();
      final afterDrag = List<double>.of(layouts.last);

      await tester.tap(divider());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(divider());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expectFractions(layouts.last, afterDrag);
    });
  });

  group('NasikoResizablePanelGroup keyboard', () {
    testWidgets('arrow keys resize the focused divider by 2% per press',
        (tester) async {
      final layouts = <List<double>>[];
      await pumpTwoPanels(tester, layouts: layouts);

      final focusNode = tester
          .widget<Focus>(
            find
                .descendant(of: divider(), matching: find.byType(Focus))
                .first,
          )
          .focusNode!;
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expectFractions(layouts.last, [0.48, 0.52]);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expectFractions(layouts.last, [0.52, 0.48]);
    });

    testWidgets('vertical groups use Up/Down arrows', (tester) async {
      final layouts = <List<double>>[];
      await pumpNasiko(
        tester,
        SizedBox(
          width: 300,
          height: 408, // 400 of panel space + one 8px divider.
          child: NasikoResizablePanelGroup(
            axis: Axis.vertical,
            onLayoutChanged: layouts.add,
            panels: [
              NasikoResizablePanel(
                defaultFlex: 1,
                child: Container(key: const ValueKey('panel-top')),
              ),
              NasikoResizablePanel(
                defaultFlex: 1,
                child: Container(key: const ValueKey('panel-bottom')),
              ),
            ],
          ),
        ),
      );

      final focusNode = tester
          .widget<Focus>(
            find
                .descendant(of: divider(), matching: find.byType(Focus))
                .first,
          )
          .focusNode!;
      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expectFractions(layouts.last, [0.48, 0.52]);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expectFractions(layouts.last, [0.5, 0.5]);
    });
  });
}
