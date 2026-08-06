// test/behavior/time_picker_test.dart
//
// Behavior tests for NasikoTimePicker / NasikoTimeField: digit entry with
// clamping and auto-advance, Up/Down stepping with wrap-around, the AM/PM
// segment, min/max snapping of completed values, and the field's popover
// open-and-commit flow.
//
// Segments are custom Focus widgets (debug labels 'NasikoTimePicker hour' /
// 'minute' / 'second' / 'period'); tests focus them via Focus.of on the
// rendered segment text, mirroring select_test's trigger focusing.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  String? focusedLabel() => FocusManager.instance.primaryFocus?.debugLabel;

  /// Focuses the segment currently rendering [text] (e.g. '13', '--', 'AM').
  Future<void> focusSegmentShowing(WidgetTester tester, String text,
      {int index = 0}) async {
    Focus.of(tester.element(find.text(text).at(index))).requestFocus();
    await tester.pump();
  }

  Future<void> typeDigits(WidgetTester tester, String digits) async {
    const keys = <String, LogicalKeyboardKey>{
      '0': LogicalKeyboardKey.digit0,
      '1': LogicalKeyboardKey.digit1,
      '2': LogicalKeyboardKey.digit2,
      '3': LogicalKeyboardKey.digit3,
      '4': LogicalKeyboardKey.digit4,
      '5': LogicalKeyboardKey.digit5,
      '6': LogicalKeyboardKey.digit6,
      '7': LogicalKeyboardKey.digit7,
      '8': LogicalKeyboardKey.digit8,
      '9': LogicalKeyboardKey.digit9,
    };
    for (final char in digits.split('')) {
      await tester.sendKeyEvent(keys[char]!);
      await tester.pump();
    }
  }

  Future<List<NasikoTimeOfDay>> pumpPicker(
    WidgetTester tester, {
    NasikoTimeOfDay? value,
    NasikoTimePickerMode mode = NasikoTimePickerMode.h24,
    NasikoTimeOfDay? minTime,
    NasikoTimeOfDay? maxTime,
    bool showSeconds = false,
    bool enabled = true,
  }) async {
    final changes = <NasikoTimeOfDay>[];
    var current = value;
    await pumpNasiko(
      tester,
      StatefulBuilder(
        builder: (context, setState) => NasikoTimePicker(
          value: current,
          mode: mode,
          minTime: minTime,
          maxTime: maxTime,
          showSeconds: showSeconds,
          enabled: enabled,
          onChanged: (v) {
            changes.add(v);
            setState(() => current = v);
          },
        ),
      ),
    );
    return changes;
  }

  group('NasikoTimePicker digit entry', () {
    testWidgets('two digits fill the hour and auto-advance to the minute',
        (tester) async {
      final changes = await pumpPicker(tester);

      // Both segments render '--' when empty; the first is the hour.
      await focusSegmentShowing(tester, '--');
      expect(focusedLabel(), 'NasikoTimePicker hour');

      await typeDigits(tester, '13');
      expect(find.text('13'), findsOneWidget);
      expect(focusedLabel(), 'NasikoTimePicker minute');
      expect(changes, isEmpty, reason: 'no complete time yet');

      // onChanged fires live as complete times form: the first minute digit
      // already completes a time (13:04), the second refines it (13:45).
      await typeDigits(tester, '45');
      expect(find.text('45'), findsOneWidget);
      expect(changes.first, const NasikoTimeOfDay(hour: 13, minute: 4));
      expect(changes.last, const NasikoTimeOfDay(hour: 13, minute: 45));
    });

    testWidgets('an over-range second digit clamps to the segment max and '
        'still advances', (tester) async {
      await pumpPicker(tester);
      await focusSegmentShowing(tester, '--');

      // '5' then '9' would be 59 — the 24h hour clamps to 23.
      await typeDigits(tester, '59');
      expect(find.text('23'), findsOneWidget);
      expect(focusedLabel(), 'NasikoTimePicker minute');
    });

    testWidgets('a single high digit stays put until the entry completes',
        (tester) async {
      await pumpPicker(tester);
      await focusSegmentShowing(tester, '--');

      await typeDigits(tester, '2');
      expect(find.text('02'), findsOneWidget);
      expect(focusedLabel(), 'NasikoTimePicker hour',
          reason: 'one digit does not advance');
    });
  });

  group('NasikoTimePicker arrow stepping', () {
    testWidgets('Up wraps the hour 23 -> 0; Down wraps back', (tester) async {
      final changes = await pumpPicker(
        tester,
        value: const NasikoTimeOfDay(hour: 23, minute: 59),
      );

      await focusSegmentShowing(tester, '23');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(find.text('00'), findsOneWidget);
      expect(changes.last, const NasikoTimeOfDay(hour: 0, minute: 59));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(find.text('23'), findsOneWidget);
      expect(changes.last, const NasikoTimeOfDay(hour: 23, minute: 59));
    });

    testWidgets('Down wraps the minute 0 -> 59', (tester) async {
      final changes = await pumpPicker(
        tester,
        value: const NasikoTimeOfDay(hour: 12, minute: 0),
      );

      await focusSegmentShowing(tester, '00');
      expect(focusedLabel(), 'NasikoTimePicker minute');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(changes.last, const NasikoTimeOfDay(hour: 12, minute: 59));
    });

    testWidgets('Left/Right move between segments', (tester) async {
      await pumpPicker(
        tester,
        value: const NasikoTimeOfDay(hour: 10, minute: 20, second: 30),
        showSeconds: true,
      );

      await focusSegmentShowing(tester, '10');
      expect(focusedLabel(), 'NasikoTimePicker hour');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedLabel(), 'NasikoTimePicker minute');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedLabel(), 'NasikoTimePicker second');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedLabel(), 'NasikoTimePicker minute');
    });
  });

  group('NasikoTimePicker AM/PM', () {
    testWidgets('tapping the period toggles it and rewrites the 24h hour',
        (tester) async {
      final changes = await pumpPicker(
        tester,
        mode: NasikoTimePickerMode.amPm,
        value: const NasikoTimeOfDay(hour: 9, minute: 30),
      );

      expect(find.text('AM'), findsOneWidget);
      await tester.tap(find.text('AM'));
      await tester.pump();

      expect(find.text('PM'), findsOneWidget);
      expect(changes.last, const NasikoTimeOfDay(hour: 21, minute: 30));
      expect(find.text('09'), findsOneWidget,
          reason: 'the displayed 12h hour is unchanged');
    });

    testWidgets('A and P keys set the period directly', (tester) async {
      final changes = await pumpPicker(
        tester,
        mode: NasikoTimePickerMode.amPm,
        value: const NasikoTimeOfDay(hour: 9, minute: 30),
      );

      await focusSegmentShowing(tester, 'AM');
      expect(focusedLabel(), 'NasikoTimePicker period');

      await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
      await tester.pump();
      expect(changes.last, const NasikoTimeOfDay(hour: 21, minute: 30));

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(changes.last, const NasikoTimeOfDay(hour: 9, minute: 30));
    });
  });

  group('NasikoTimePicker min/max clamping', () {
    testWidgets('a completed time below minTime snaps to the bound',
        (tester) async {
      final changes = await pumpPicker(
        tester,
        minTime: const NasikoTimeOfDay(hour: 9, minute: 0),
        maxTime: const NasikoTimeOfDay(hour: 17, minute: 0),
      );

      await focusSegmentShowing(tester, '--');
      await typeDigits(tester, '0800');

      expect(changes, [const NasikoTimeOfDay(hour: 9, minute: 0)]);
      expect(find.text('09'), findsOneWidget,
          reason: 'the segments rewrite to the clamped value');
    });

    testWidgets('a completed time above maxTime snaps to the bound',
        (tester) async {
      final changes = await pumpPicker(
        tester,
        minTime: const NasikoTimeOfDay(hour: 9, minute: 0),
        maxTime: const NasikoTimeOfDay(hour: 17, minute: 0),
      );

      await focusSegmentShowing(tester, '--');
      await typeDigits(tester, '2115');

      expect(changes, [const NasikoTimeOfDay(hour: 17, minute: 0)]);
      expect(find.text('17'), findsOneWidget);
    });
  });

  group('NasikoTimePicker disabled', () {
    testWidgets('ignores taps and keys when enabled: false', (tester) async {
      final changes = await pumpPicker(
        tester,
        value: const NasikoTimeOfDay(hour: 10, minute: 15),
        enabled: false,
      );

      await tester.tap(find.text('10'), warnIfMissed: false);
      await tester.pump();
      expect(focusedLabel(), isNot('NasikoTimePicker hour'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(changes, isEmpty);
      expect(find.text('10'), findsOneWidget);
    });
  });

  group('NasikoTimeField', () {
    testWidgets('tap opens the picker popover; typing commits to the field',
        (tester) async {
      final changes = <NasikoTimeOfDay>[];
      NasikoTimeOfDay? value;
      await pumpNasikoOverlayHost(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 240,
            child: NasikoTimeField(
              value: value,
              onChanged: (v) {
                changes.add(v);
                setState(() => value = v);
              },
            ),
          ),
        ),
      );

      expect(find.byType(NasikoTimePicker), findsNothing);

      await tester.tap(find.text('Select time'));
      // Portal frame + the picker's post-frame hour autofocus.
      await tester.pump();
      await tester.pump();

      expect(find.byType(NasikoTimePicker), findsOneWidget);
      expect(focusedLabel(), 'NasikoTimePicker hour',
          reason: 'the popover picker autofocuses its hour segment');

      await typeDigits(tester, '1030');

      // Live commits: 10:03 after the first minute digit, then 10:30.
      expect(changes.last, const NasikoTimeOfDay(hour: 10, minute: 30));
      // The field shows the committed time (h24 default format).
      expect(find.text('10:30'), findsOneWidget);
      // The popover stays open for further edits (times are set segment by
      // segment); Escape closes it.
      expect(find.byType(NasikoTimePicker), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump();
      expect(find.byType(NasikoTimePicker), findsNothing);
    });
  });
}
