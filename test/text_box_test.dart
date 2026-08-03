import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

void main() {
  setUpAll(() {
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(390, 844)),
      designSize: const Size(390, 844),
      splitScreenMode: false,
      minTextAdapt: true,
    );
  });

  Widget buildTextBox(FocusNode focusNode) {
    return MaterialApp(
      theme: NasikoTheme.lightTheme,
      home: Scaffold(
        body: NasikoTextBox(focusNode: focusNode),
      ),
    );
  }

  group('NasikoTextBox tap-to-focus', () {
    testWidgets('tapping the box padding focuses the field', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(buildTextBox(focusNode));

      expect(focusNode.hasFocus, isFalse);

      // Tap inside the container but outside the TextField's own hit area.
      await tester.tapAt(
        tester.getTopLeft(find.byType(NasikoTextBox)) + const Offset(4, 4),
      );
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
      expect(tester.testTextInput.hasAnyClients, isTrue);
    });

    testWidgets(
      'tapping the box while already focused re-requests the keyboard '
      '(heals web phantom focus)',
      (tester) async {
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);
        await tester.pumpWidget(buildTextBox(focusNode));

        await tester.tap(find.byType(TextField));
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);
        expect(tester.testTextInput.hasAnyClients, isTrue);

        // Web phantom-focus state: the engine's input connection dies
        // without notifying the framework, so the node stays focused and
        // requestFocus is a no-op. The heal is re-sending TextInput.show
        // to the engine, which only EditableTextState.requestKeyboard does.
        tester.testTextInput.log.clear();

        await tester.tapAt(
          tester.getTopLeft(find.byType(NasikoTextBox)) + const Offset(4, 4),
        );
        await tester.pump();

        expect(focusNode.hasFocus, isTrue);
        expect(
          tester.testTextInput.log.map((MethodCall c) => c.method),
          contains('TextInput.show'),
        );
      },
    );

    testWidgets('tapping a disabled box does not focus', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: NasikoTheme.lightTheme,
          home: Scaffold(
            body: NasikoTextBox(focusNode: focusNode, enabled: false),
          ),
        ),
      );

      await tester.tapAt(
        tester.getTopLeft(find.byType(NasikoTextBox)) + const Offset(4, 4),
      );
      await tester.pump();

      expect(focusNode.hasFocus, isFalse);
    });
  });
}
