// test/goldens/inputs_golden_test.dart
//
// Golden frames for NasikoInputField and NasikoTextBox in idle and focused
// states, light and dark.
//
// Focused frames pin `EditableText.debugDeterministicCursor` so the caret is
// always painted (a blinking caret is not golden-stable). We use fixed pumps
// rather than pumpAndSettle after focusing — the caret blink is a repeating
// animation and pumpAndSettle would time out.
//
// Generate baselines with: flutter test --update-goldens test/goldens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  setUp(() {
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() {
    EditableText.debugDeterministicCursor = false;
  });

  Widget inputField() {
    return goldenFrame(
      SizedBox(
        width: 360,
        child: NasikoInputField(
          label: 'Email',
          hintText: 'you@nasiko.com',
          helperText: 'We only use this for sign-in.',
        ),
      ),
    );
  }

  Widget textBox() {
    return goldenFrame(
      SizedBox(
        width: 480,
        child: NasikoTextBox(
          hintText: 'Type a message…',
        ),
      ),
    );
  }

  Future<void> unfocus(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
  }

  for (final mode in kGoldenThemeModes) {
    final suffix = brightnessSuffix(mode);

    testWidgets('input field idle – $suffix', (tester) async {
      await pumpNasiko(tester, inputField(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'input_field_idle_$suffix');
    });

    testWidgets('input field focused – $suffix', (tester) async {
      await pumpNasiko(tester, inputField(), brightness: mode);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextFormField));
      // Fixed pumps: the focused caret blink repeats, so never settle here.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await expectGolden(tester, 'input_field_focused_$suffix');
      await unfocus(tester);
    });

    testWidgets('text box idle – $suffix', (tester) async {
      await pumpNasiko(tester, textBox(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'text_box_idle_$suffix');
    });

    testWidgets('text box focused – $suffix', (tester) async {
      await pumpNasiko(tester, textBox(), brightness: mode);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      // Fixed pumps: the focused caret blink repeats, so never settle here.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await expectGolden(tester, 'text_box_focused_$suffix');
      await unfocus(tester);
    });
  }
}
