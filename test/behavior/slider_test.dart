// test/behavior/slider_test.dart
//
// Behavior tests for NasikoSlider: track tap jumps the value, drag scrubs,
// divisions snap, arrow keys step (Shift = 10x), disabled ignores input, and
// onChangeStart/onChangeEnd fire on drags only.
//
// Geometry note: the thumb travels inside the control, so a local pointer
// x maps to `fraction = (dx - thumbBox/2) / (width - thumbBox)` with
// thumbBox = spacing.s28 (28, unscaled). Tapping the horizontal center of
// the control therefore lands on exactly 0.5 of the range, independent of
// the thumb-box size.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  const double thumbBox = 28.0; // spacing.s28, used raw by the slider.

  Finder slider() => find.byType(NasikoSlider);

  /// Pumps a controlled slider and returns nothing; reads go through the
  /// [values] log and the StatefulBuilder-held current value via [readValue].
  Future<double Function()> pumpSlider(
    WidgetTester tester, {
    double initial = 0.5,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    bool enabled = true,
    List<double>? values,
    List<double>? starts,
    List<double>? ends,
    FocusNode? focusNode,
  }) async {
    var current = initial;
    await pumpNasiko(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 300,
          child: NasikoSlider(
            value: current,
            min: min,
            max: max,
            divisions: divisions,
            focusNode: focusNode,
            onChangeStart: starts?.add,
            onChangeEnd: ends?.add,
            onChanged: enabled
                ? (v) {
                    values?.add(v);
                    setState(() => current = v);
                  }
                : null,
          ),
        ),
      ),
    );
    return () => current;
  }

  /// Global tap position for [fraction] of the slider's range.
  Offset positionAtFraction(WidgetTester tester, double fraction) {
    final rect = tester.getRect(slider());
    final travel = rect.width - thumbBox;
    return Offset(
      rect.left + thumbBox / 2 + fraction * travel,
      rect.center.dy,
    );
  }

  group('NasikoSlider pointer', () {
    testWidgets('track tap jumps the value to the tapped fraction',
        (tester) async {
      final values = <double>[];
      final readValue = await pumpSlider(tester, values: values);

      await tester.tapAt(positionAtFraction(tester, 0.75));
      await tester.pump();

      expect(values, hasLength(1));
      expect(readValue(), closeTo(0.75, 0.01));
    });

    testWidgets('drag scrubs the value continuously', (tester) async {
      final values = <double>[];
      final readValue = await pumpSlider(tester, values: values);

      final gesture =
          await tester.startGesture(positionAtFraction(tester, 0.5));
      await tester.pump();
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump();
      final midDrag = readValue();
      expect(midDrag, greaterThan(0.5));

      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(readValue(), greaterThan(midDrag));

      await gesture.up();
      await tester.pump();
      // Settle the thumb-travel animation (motion.fast, 150ms).
      await tester.pump(const Duration(milliseconds: 200));

      expect(values.length, greaterThanOrEqualTo(2),
          reason: 'each drag update past slop commits a value');
    });

    testWidgets('divisions snap to the nearest division', (tester) async {
      final values = <double>[];
      final readValue = await pumpSlider(
        tester,
        initial: 0,
        min: 0,
        max: 100,
        divisions: 4, // allowed: 0, 25, 50, 75, 100.
        values: values,
      );

      // 30% of the range snaps down to 25.
      await tester.tapAt(positionAtFraction(tester, 0.3));
      await tester.pump();
      expect(readValue(), 25.0);

      // 90% snaps up to 100 — never an intermediate value.
      await tester.tapAt(positionAtFraction(tester, 0.9));
      await tester.pump();
      expect(readValue(), 100.0);
      expect(values, [25.0, 100.0]);
    });
  });

  group('NasikoSlider keyboard', () {
    testWidgets('arrow keys step by 1% of the range; Shift multiplies by 10',
        (tester) async {
      final focusNode = FocusNode(debugLabel: 'slider-under-test');
      final readValue = await pumpSlider(
        tester,
        initial: 50,
        min: 0,
        max: 100,
        focusNode: focusNode,
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(readValue(), 51.0);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(readValue(), 50.0);

      // Up/Down mirror Right/Left.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(readValue(), 51.0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(readValue(), 50.0);

      // Shift: 10x step.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(readValue(), 60.0);
    });

    testWidgets('arrow steps snap to divisions and clamp at the ends',
        (tester) async {
      final focusNode = FocusNode(debugLabel: 'slider-under-test');
      final readValue = await pumpSlider(
        tester,
        initial: 75,
        min: 0,
        max: 100,
        divisions: 4, // step = 25.
        focusNode: focusNode,
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(readValue(), 100.0);

      // Already at max: another step is a no-op (no onChanged).
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(readValue(), 100.0);
    });
  });

  group('NasikoSlider disabled', () {
    testWidgets('taps, drags, and keys are ignored when onChanged is null',
        (tester) async {
      final starts = <double>[];
      final ends = <double>[];
      final readValue = await pumpSlider(
        tester,
        enabled: false,
        starts: starts,
        ends: ends,
      );

      await tester.tapAt(positionAtFraction(tester, 0.9));
      await tester.pump();
      expect(readValue(), 0.5);

      await tester.drag(slider(), const Offset(80, 0));
      await tester.pump();
      expect(readValue(), 0.5);
      expect(starts, isEmpty);
      expect(ends, isEmpty);
    });
  });

  group('NasikoSlider onChangeStart / onChangeEnd', () {
    testWidgets('fire exactly once around a drag, not on taps',
        (tester) async {
      final starts = <double>[];
      final ends = <double>[];
      final values = <double>[];
      await pumpSlider(
        tester,
        values: values,
        starts: starts,
        ends: ends,
      );

      // A plain tap commits a value but is not a drag, so the
      // start/end drag callbacks stay silent.
      await tester.tapAt(positionAtFraction(tester, 0.25));
      await tester.pump();
      expect(values, hasLength(1));
      expect(starts, isEmpty);
      expect(ends, isEmpty);

      final gesture =
          await tester.startGesture(positionAtFraction(tester, 0.25));
      await tester.pump();
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();
      expect(starts, hasLength(1),
          reason: 'onChangeStart fires when the drag begins');
      expect(ends, isEmpty, reason: 'onChangeEnd waits for the drag to end');

      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      expect(starts, hasLength(1), reason: 'no repeat mid-drag');

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(ends, hasLength(1));
    });
  });
}
