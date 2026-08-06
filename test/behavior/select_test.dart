// test/behavior/select_test.dart
//
// Behavior tests for NasikoSelect: keyboard opening, arrow navigation with
// wrapping, single-character typeahead, Escape close + focus restore,
// onChanged, and the disabled / empty-items guard.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  const placeholder = 'Pick a fruit';
  const items = [
    NasikoSelectItem(value: 'apple', label: 'Apple'),
    NasikoSelectItem(value: 'banana', label: 'Banana'),
    NasikoSelectItem(value: 'cherry', label: 'Cherry'),
  ];

  Future<void> pumpSelect(
    WidgetTester tester, {
    List<NasikoSelectItem<String>> selectItems = items,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    String? value,
  }) async {
    await pumpNasikoOverlayHost(
      tester,
      SizedBox(
        width: 320,
        child: NasikoSelect<String>(
          placeholder: placeholder,
          items: selectItems,
          value: value,
          enabled: enabled,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }

  /// Focuses the trigger the way a keyboard user would land on it.
  Future<void> focusTrigger(WidgetTester tester) async {
    Focus.of(tester.element(find.text(placeholder))).requestFocus();
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'NasikoSelect',
      reason: 'trigger should own focus before keyboard interaction',
    );
  }

  /// Two pumps: one for the overlay portal frame, one for the menu's
  /// post-frame initial-focus callback.
  Future<void> pumpMenuOpen(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }

  bool menuIsOpen(WidgetTester tester) =>
      find.text('Apple').evaluate().isNotEmpty;

  group('NasikoSelect opening', () {
    for (final key in <LogicalKeyboardKey>[
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.arrowDown,
    ]) {
      testWidgets('opens on ${key.keyLabel}', (tester) async {
        await pumpSelect(tester);
        await focusTrigger(tester);

        await tester.sendKeyEvent(key);
        await pumpMenuOpen(tester);

        expect(menuIsOpen(tester), isTrue);
        expect(find.text('Banana'), findsOneWidget);
        expect(find.text('Cherry'), findsOneWidget);
      });
    }

    testWidgets('tap toggles the menu', (tester) async {
      await pumpSelect(tester);

      await tester.tap(find.text(placeholder));
      await pumpMenuOpen(tester);
      expect(menuIsOpen(tester), isTrue);

      await tester.tap(find.text(placeholder));
      // Two pumps: the anchored-overlay engine syncs its portal post-frame,
      // so the hide lands one frame after the rebuild (test/README #9).
      await tester.pump();
      await tester.pump();
      expect(menuIsOpen(tester), isFalse);
    });
  });

  group('NasikoSelect keyboard navigation', () {
    testWidgets('ArrowDown wraps past the last option', (tester) async {
      final picked = <String>[];
      await pumpSelect(tester, onChanged: picked.add);
      await focusTrigger(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await pumpMenuOpen(tester);
      // Initial focus is the first enabled option (no value selected).

      // 0 -> 1 -> 2 -> wraps to 0.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(picked, ['apple']);
    });

    testWidgets('ArrowUp from the first option wraps to the last',
        (tester) async {
      final picked = <String>[];
      await pumpSelect(tester, onChanged: picked.add);
      await focusTrigger(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await pumpMenuOpen(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(picked, ['cherry']);
    });

    testWidgets('typeahead jumps to the next label starting with the key',
        (tester) async {
      final picked = <String>[];
      await pumpSelect(tester, onChanged: picked.add);
      await focusTrigger(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await pumpMenuOpen(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(picked, ['cherry']);
    });
  });

  group('NasikoSelect Escape', () {
    testWidgets('closes the menu and restores focus to the trigger',
        (tester) async {
      await pumpSelect(tester);
      await focusTrigger(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await pumpMenuOpen(tester);
      expect(menuIsOpen(tester), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump();

      expect(menuIsOpen(tester), isFalse);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'NasikoSelect',
        reason: 'Escape must return focus to the trigger',
      );
    });
  });

  group('NasikoSelect selection', () {
    testWidgets('onChanged fires with the tapped option value',
        (tester) async {
      final picked = <String>[];
      String? value;
      await pumpNasikoOverlayHost(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 320,
            child: NasikoSelect<String>(
              placeholder: placeholder,
              items: items,
              value: value,
              onChanged: (v) {
                picked.add(v);
                setState(() => value = v);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text(placeholder));
      await pumpMenuOpen(tester);
      await tester.tap(find.text('Banana'));
      // Two pumps: the post-frame portal sync removes the menu one frame
      // after the rebuild (test/README #9).
      await tester.pump();
      await tester.pump();

      expect(picked, ['banana']);
      // Controlled value updated: the trigger now shows the label and the
      // menu is closed.
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });
  });

  group('NasikoSelect disabled / empty', () {
    testWidgets('disabled select never opens', (tester) async {
      await pumpSelect(tester, enabled: false);

      await tester.tap(find.text(placeholder));
      await pumpMenuOpen(tester);

      expect(menuIsOpen(tester), isFalse);
    });

    testWidgets('select with no items never opens', (tester) async {
      await pumpSelect(tester, selectItems: const []);

      await tester.tap(find.text(placeholder));
      await pumpMenuOpen(tester);

      // Nothing to pick means nothing to open — no option rows anywhere.
      expect(find.byType(ListView), findsNothing);
    });
  });
}
