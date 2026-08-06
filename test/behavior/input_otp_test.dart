// test/behavior/input_otp_test.dart
//
// Behavior tests for NasikoInputOtp: typing fills slots left-to-right,
// pasted/multi-character input distributes, backspace steps back,
// onCompleted fires once per completion, the error state recolors the slot
// borders, and input is filtered (digits by default, alphanumeric opt-in).
//
// The component drives all slots from ONE invisible TextField, so text entry
// goes through that field; per-slot rendering is asserted via the visible
// slot characters.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Finder hiddenField() => find.byType(TextField);

  /// A rendered slot character. find.text also matches the hidden
  /// EditableText's value (e.g. find.text('1') when the code IS '1'), so
  /// slot assertions match [Text] widgets only.
  Finder slotText(String character) => find.byWidgetPredicate(
        (w) => w is Text && w.data == character,
      );

  Future<void> pumpOtp(
    WidgetTester tester, {
    int length = 6,
    List<int>? groups,
    bool alphanumeric = false,
    bool hasError = false,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onCompleted,
  }) async {
    await pumpNasiko(
      tester,
      NasikoInputOtp(
        length: length,
        groups: groups,
        alphanumeric: alphanumeric,
        hasError: hasError,
        enabled: enabled,
        onChanged: onChanged,
        onCompleted: onCompleted,
      ),
    );
  }

  group('NasikoInputOtp typing', () {
    testWidgets('typing fills slots left to right and advances the active '
        'slot', (tester) async {
      final changes = <String>[];
      await pumpOtp(tester, onChanged: changes.add);

      await tester.enterText(hiddenField(), '1');
      await tester.pump();
      expect(slotText('1'), findsOneWidget);
      expect(changes, ['1']);

      await tester.enterText(hiddenField(), '12');
      await tester.pump();
      expect(slotText('1'), findsOneWidget);
      expect(slotText('2'), findsOneWidget);
      expect(changes, ['1', '12']);
    });

    testWidgets('pasted input distributes across the slots', (tester) async {
      final changes = <String>[];
      await pumpOtp(tester, groups: const [3, 3], onChanged: changes.add);

      // A single editing update carrying the full code — the paste path.
      await tester.enterText(hiddenField(), '123456');
      await tester.pump();

      for (final char in ['1', '2', '3', '4', '5', '6']) {
        expect(slotText(char), findsOneWidget);
      }
      expect(changes, ['123456']);
    });

    testWidgets('input is hard-capped at length', (tester) async {
      await pumpOtp(tester, length: 4);

      await tester.enterText(hiddenField(), '123456');
      await tester.pump();

      expect(slotText('4'), findsOneWidget);
      expect(slotText('5'), findsNothing);
      expect(tester.widget<TextField>(hiddenField()).controller!.text, '1234');
    });
  });

  group('NasikoInputOtp backspace', () {
    testWidgets('backspace clears the last character, stepping back',
        (tester) async {
      final changes = <String>[];
      await pumpOtp(tester, onChanged: changes.add);

      await tester.enterText(hiddenField(), '123');
      await tester.pump();
      expect(slotText('3'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(slotText('3'), findsNothing);
      expect(slotText('2'), findsOneWidget);
      expect(changes.last, '12');
    });
  });

  group('NasikoInputOtp onCompleted', () {
    testWidgets('fires once when the code reaches length, not again while '
        'complete', (tester) async {
      final completions = <String>[];
      await pumpOtp(tester, onCompleted: completions.add);

      await tester.enterText(hiddenField(), '123456');
      await tester.pump();
      expect(completions, ['123456']);

      // Same text again: no change event, no re-fire.
      await tester.enterText(hiddenField(), '123456');
      await tester.pump();
      expect(completions, ['123456']);

      // Re-completing after an edit fires again (a new completion).
      await tester.enterText(hiddenField(), '12345');
      await tester.pump();
      await tester.enterText(hiddenField(), '123459');
      await tester.pump();
      expect(completions, ['123456', '123459']);
    });
  });

  group('NasikoInputOtp error state', () {
    testWidgets('hasError renders every slot border in the error color',
        (tester) async {
      await pumpOtp(tester, hasError: true);
      final colors = tester.element(find.byType(NasikoInputOtp)).colors;

      bool slotWithBorder(Widget widget, Color color) {
        if (widget is! AnimatedContainer) return false;
        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) return false;
        final border = decoration.border;
        return border is Border && border.top.color == color;
      }

      expect(
        find.byWidgetPredicate(
          (w) => slotWithBorder(w, colors.borderError),
        ),
        findsNWidgets(6),
      );
      expect(
        find.byWidgetPredicate(
          (w) => slotWithBorder(w, colors.borderPrimary),
        ),
        findsNothing,
      );
    });
  });

  group('NasikoInputOtp filtering', () {
    testWidgets('digits-only by default: letters and symbols are dropped',
        (tester) async {
      final changes = <String>[];
      await pumpOtp(tester, onChanged: changes.add);

      await tester.enterText(hiddenField(), 'a1b2!');
      await tester.pump();

      expect(slotText('1'), findsOneWidget);
      expect(slotText('2'), findsOneWidget);
      expect(slotText('a'), findsNothing);
      expect(changes, ['12']);
    });

    testWidgets('alphanumeric accepts letters and digits, drops symbols',
        (tester) async {
      final changes = <String>[];
      await pumpOtp(tester, alphanumeric: true, onChanged: changes.add);

      await tester.enterText(hiddenField(), 'a1!B2');
      await tester.pump();

      expect(slotText('a'), findsOneWidget);
      expect(slotText('B'), findsOneWidget);
      expect(slotText('!'), findsNothing);
      expect(changes, ['a1B2']);
    });
  });
}
