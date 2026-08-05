// test/behavior/combobox_test.dart
//
// Behavior tests for NasikoCombobox: the 250 ms query debounce, keyboard
// highlight that never steals focus from the text field, Enter selection,
// the two-stage Escape (close popover, then clear field), the loading
// spinner row, and the empty-results row.
//
// NOTE ON PUMPS: the debounce is a real Timer — always advance it with
// explicit `tester.pump(Duration(...))` calls, and flush any pending timer
// before the test ends. The spinner row hosts a repeating
// CircularProgressIndicator, so that test uses fixed pumps only (never
// pumpAndSettle).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  const items = [
    NasikoSelectItem(value: 'apple', label: 'Apple'),
    NasikoSelectItem(value: 'apricot', label: 'Apricot'),
    NasikoSelectItem(value: 'banana', label: 'Banana'),
  ];

  Future<void> pumpCombobox(
    WidgetTester tester, {
    List<NasikoSelectItem<String>> comboItems = items,
    ValueChanged<String>? onQueryChanged,
    ValueChanged<NasikoSelectItem<String>>? onSelected,
    bool isLoading = false,
  }) async {
    await pumpNasikoOverlayHost(
      tester,
      SizedBox(
        width: 320,
        child: NasikoCombobox<String>(
          items: comboItems,
          isLoading: isLoading,
          onQueryChanged: onQueryChanged ?? (_) {},
          onSelected: onSelected ?? (_) {},
        ),
      ),
    );
  }

  group('NasikoCombobox debounce', () {
    testWidgets('onQueryChanged fires only after 250ms of quiet',
        (tester) async {
      final queries = <String>[];
      await pumpCombobox(tester, onQueryChanged: queries.add);

      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pump(const Duration(milliseconds: 249));
      expect(queries, isEmpty, reason: '249ms: debounce not elapsed yet');

      await tester.pump(const Duration(milliseconds: 1));
      expect(queries, ['ap'], reason: '250ms: debounce fired exactly once');
    });

    testWidgets('a new keystroke resets the debounce window', (tester) async {
      final queries = <String>[];
      await pumpCombobox(tester, onQueryChanged: queries.add);

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pump(const Duration(milliseconds: 200));
      expect(queries, isEmpty, reason: 'timer restarted by second edit');

      await tester.pump(const Duration(milliseconds: 50));
      expect(queries, ['ap']);
    });
  });

  group('NasikoCombobox keyboard', () {
    testWidgets(
        'ArrowDown highlights options without stealing TextField focus',
        (tester) async {
      await pumpCombobox(tester);

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 250)); // flush debounce
      await tester.pump(); // popover frame
      expect(find.text('Apple'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Focus never leaves the text field — the highlight is purely visual.
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'NasikoCombobox',
      );
      expect(tester.testTextInput.hasAnyClients, isTrue);
    });

    testWidgets('Enter selects the highlighted option', (tester) async {
      final selected = <String>[];
      await pumpCombobox(
        tester,
        onSelected: (item) => selected.add(item.value),
      );

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // Apple
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // Apricot
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(selected, ['apricot']);
      // Selection fills the field with the option label and closes the
      // popover.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Apricot');
      expect(find.text('Banana'), findsNothing);
    });
  });

  group('NasikoCombobox two-stage Escape', () {
    testWidgets('first Escape closes the popover, second clears the field',
        (tester) async {
      final queries = <String>[];
      await pumpCombobox(tester, onQueryChanged: queries.add);

      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(find.text('Apple'), findsOneWidget);
      expect(queries, ['ap']);

      // Stage 1: popover closes, text stays.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('Apple'), findsNothing);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'ap');

      // Stage 2: field clears and the parent is told about the empty query.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(queries, ['ap', '']);
    });
  });

  group('NasikoCombobox rows', () {
    testWidgets('isLoading shows the spinner row', (tester) async {
      await pumpCombobox(tester, comboItems: const [], isLoading: true);

      // Focusing an isLoading combobox opens the popover immediately.
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump();

      expect(find.byType(NasikoSpinner), findsOneWidget);
      // Fixed pumps only from here: the spinner repeats forever, so
      // pumpAndSettle would time out. Let the spinner's reveal delay pass to
      // prove the indicator actually appears.
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('empty items with a query shows the empty label row',
        (tester) async {
      await pumpCombobox(tester, comboItems: const []);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(find.text('No results'), findsOneWidget);
    });
  });
}
