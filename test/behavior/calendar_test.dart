// test/behavior/calendar_test.dart
//
// Behavior tests for NasikoCalendar, pinned to August 2026 so every
// assertion is deterministic (never derived from DateTime.now()):
//   * month-grid layout — Aug 1 2026 is a SATURDAY, so a Monday-first grid
//     leads with Jul 27–31 and trails with Sep 1–6 (42 cells),
//   * tap selection reporting through onChanged,
//   * arrow-key movement of the focused day + Enter/Space activation,
//   * PageUp / PageDown month navigation,
//   * minDate / maxDate clamping (taps ignored, chevrons disabled,
//     keyboard focus clamped into range).
//
// The month-swap AnimatedSwitcher (motion.base) is one-shot, so
// pumpAndSettle is safe throughout this file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  final august = DateTime(2026, 8);

  Future<void> pumpCalendar(
    WidgetTester tester, {
    DateTime? selected,
    DateTime? minDate,
    DateTime? maxDate,
    ValueChanged<DateTime>? onChanged,
  }) async {
    await pumpNasiko(
      tester,
      NasikoCalendar(
        selected: selected,
        minDate: minDate,
        maxDate: maxDate,
        initialMonth: august,
        onChanged: onChanged ?? (_) {},
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Focuses the calendar grid the way a keyboard user would land on it.
  /// Any in-month day text sits under the grid's FocusableActionDetector,
  /// so its nearest Focus ancestor is the grid's single focus stop.
  Future<void> focusGrid(WidgetTester tester) async {
    Focus.of(tester.element(find.text('15').first)).requestFocus();
    await tester.pump();
  }

  group('NasikoCalendar month grid (August 2026)', () {
    testWidgets('renders the pinned month with Monday-first lead/trail days',
        (tester) async {
      await pumpCalendar(tester);

      expect(find.text('August 2026'), findsOneWidget);

      // Lead-in July days and trailing September days each appear once more
      // than their August counterparts:
      //   '27'..'31' → Jul 27–31 (row 0) AND Aug 27–31.
      //   '1'..'6'   → Aug 1–6 AND Sep 1–6 (row 5).
      expect(find.text('31'), findsNWidgets(2));
      expect(find.text('27'), findsNWidgets(2));
      expect(find.text('6'), findsNWidgets(2));
      // A mid-month day appears exactly once.
      expect(find.text('15'), findsOneWidget);

      // Row 0 layout: Jul 27 (Monday, col 0) … Aug 1 (Saturday, col 5).
      // In tree order the FIRST '27' is Jul 27 and the FIRST '1' is Aug 1.
      // Day texts are centered inside fixed-size cells, so a text's CENTER
      // equals its cell's center regardless of digit count.
      final jul27 = tester.getCenter(find.text('27').first);
      final jul28 = tester.getCenter(find.text('28').first);
      final aug1 = tester.getCenter(find.text('1').first);
      expect(aug1.dy, moreOrLessEquals(jul27.dy, epsilon: 0.5),
          reason: 'Aug 1 shares row 0 with the July lead-in days');
      final cellWidth = jul28.dx - jul27.dx;
      expect(aug1.dx - jul27.dx, moreOrLessEquals(5 * cellWidth, epsilon: 1.0),
          reason: 'Aug 1 2026 is a Saturday: column index 5 of a '
              'Monday-first week');

      // Aug 31 (Monday) lands on a later row than Jul 31 (row 0).
      final jul31 = tester.getCenter(find.text('31').first);
      final aug31 = tester.getCenter(find.text('31').last);
      expect(aug31.dy, greaterThan(jul31.dy));
    });

    testWidgets('out-of-month days are not tappable', (tester) async {
      final picked = <DateTime>[];
      await pumpCalendar(tester, onChanged: picked.add);

      // First '27' is July 27 — dimmed lead-in, non-interactive.
      await tester.tap(find.text('27').first, warnIfMissed: false);
      await tester.pump();
      expect(picked, isEmpty);
    });
  });

  group('NasikoCalendar tap selection', () {
    testWidgets('tapping a day reports the date-only value', (tester) async {
      final picked = <DateTime>[];
      await pumpCalendar(tester, onChanged: picked.add);

      await tester.tap(find.text('15'));
      await tester.pump();

      expect(picked, [DateTime(2026, 8, 15)]);
    });
  });

  group('NasikoCalendar keyboard', () {
    testWidgets('arrow keys move the focused day; Enter selects it',
        (tester) async {
      final picked = <DateTime>[];
      await pumpCalendar(
        tester,
        // Anchors the internal focused day deterministically.
        selected: DateTime(2026, 8, 15),
        onChanged: picked.add,
      );
      await focusGrid(tester);

      // 15 → 16 (right) → 23 (down a week).
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked, [DateTime(2026, 8, 23)]);

      // 23 → 22 (left) → 15 (up a week); Space also activates.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(picked, [DateTime(2026, 8, 23), DateTime(2026, 8, 15)]);
    });

    testWidgets('PageDown/PageUp navigate months and carry the focused day',
        (tester) async {
      final picked = <DateTime>[];
      await pumpCalendar(
        tester,
        selected: DateTime(2026, 8, 15),
        onChanged: picked.add,
      );
      await focusGrid(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(find.text('September 2026'), findsOneWidget);

      // The focused day travelled with the month: Enter picks Sep 15.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked, [DateTime(2026, 9, 15)]);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();
      expect(find.text('August 2026'), findsOneWidget);
    });
  });

  group('NasikoCalendar min/max clamping', () {
    testWidgets('days outside minDate/maxDate are disabled', (tester) async {
      final picked = <DateTime>[];
      await pumpCalendar(
        tester,
        minDate: DateTime(2026, 8, 10),
        maxDate: DateTime(2026, 8, 20),
        onChanged: picked.add,
      );

      // Before the range and after the range: taps are ignored.
      await tester.tap(find.text('5').first, warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.text('25'), warnIfMissed: false);
      await tester.pump();
      expect(picked, isEmpty);

      // Inside the range: selection works.
      await tester.tap(find.text('15'));
      await tester.pump();
      expect(picked, [DateTime(2026, 8, 15)]);
    });

    testWidgets('month chevrons are disabled at the range boundary',
        (tester) async {
      await pumpCalendar(
        tester,
        minDate: DateTime(2026, 8, 10),
        maxDate: DateTime(2026, 8, 20),
      );

      // Both min and max live in the visible month, so neither chevron can
      // navigate. Header order: previous chevron first, next chevron last.
      final chevrons = find.byType(TertiaryIconButton);
      expect(chevrons, findsNWidgets(2));
      expect(tester.widget<TertiaryIconButton>(chevrons.first).onPressed,
          isNull);
      expect(
          tester.widget<TertiaryIconButton>(chevrons.last).onPressed, isNull);
    });

    testWidgets('keyboard focus clamps to minDate', (tester) async {
      final picked = <DateTime>[];
      await pumpCalendar(
        tester,
        selected: DateTime(2026, 8, 10),
        minDate: DateTime(2026, 8, 10),
        maxDate: DateTime(2026, 8, 20),
        onChanged: picked.add,
      );
      await focusGrid(tester);

      // ArrowLeft from the minimum day clamps in place.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(picked, [DateTime(2026, 8, 10)]);
    });
  });
}
