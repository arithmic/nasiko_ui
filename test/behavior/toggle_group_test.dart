// test/behavior/toggle_group_test.dart
//
// Behavior tests for NasikoToggleGroup: single-mode selection (re-press
// deselects to null), multiple-mode set toggling, and arrow-key roving focus
// that skips disabled items and wraps, plus Home/End.
//
// Focus assertions target the group's own node debug labels
// ('NasikoToggleGroup[i]') so they survive visual refactors.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  /// Focuses the toggle rendering [label] the way a keyboard user would.
  Future<void> focusItem(WidgetTester tester, String label) async {
    Focus.of(tester.element(find.text(label))).requestFocus();
    await tester.pump();
  }

  String? focusedGroupLabel() =>
      FocusManager.instance.primaryFocus?.debugLabel;

  group('NasikoToggleGroup.single', () {
    testWidgets('tap selects; pressing the active item deselects (null)',
        (tester) async {
      final changes = <String?>[];
      String? value;
      await pumpNasiko(
        tester,
        StatefulBuilder(
          builder: (context, setState) => NasikoToggleGroup<String>.single(
            value: value,
            onChanged: (v) {
              changes.add(v);
              setState(() => value = v);
            },
            items: const [
              NasikoToggleGroupItem(value: 'left', label: 'Left'),
              NasikoToggleGroupItem(value: 'center', label: 'Center'),
              NasikoToggleGroupItem(value: 'right', label: 'Right'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Center'));
      await tester.pump();
      expect(changes, ['center']);

      // Switching selection reports the new value, not null.
      await tester.tap(find.text('Right'));
      await tester.pump();
      expect(changes, ['center', 'right']);

      // Re-pressing the active item clears the selection.
      await tester.tap(find.text('Right'));
      await tester.pump();
      expect(changes, ['center', 'right', null]);
    });
  });

  group('NasikoToggleGroup.multiple', () {
    testWidgets('taps toggle membership in the set independently',
        (tester) async {
      final changes = <Set<String>>[];
      var values = <String>{'bold'};
      await pumpNasiko(
        tester,
        StatefulBuilder(
          builder: (context, setState) => NasikoToggleGroup<String>.multiple(
            values: values,
            onValuesChanged: (v) {
              changes.add(v);
              setState(() => values = v);
            },
            items: const [
              NasikoToggleGroupItem(value: 'bold', label: 'Bold'),
              NasikoToggleGroupItem(value: 'italic', label: 'Italic'),
              NasikoToggleGroupItem(value: 'underline', label: 'Underline'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Italic'));
      await tester.pump();
      expect(changes.last, {'bold', 'italic'});

      await tester.tap(find.text('Underline'));
      await tester.pump();
      expect(changes.last, {'bold', 'italic', 'underline'});

      // Toggling an active item removes only that item.
      await tester.tap(find.text('Bold'));
      await tester.pump();
      expect(changes.last, {'italic', 'underline'});
    });
  });

  group('NasikoToggleGroup keyboard roving', () {
    const items = [
      NasikoToggleGroupItem(value: 'a', label: 'Alpha'),
      NasikoToggleGroupItem(value: 'b', label: 'Beta', enabled: false),
      NasikoToggleGroupItem(value: 'c', label: 'Gamma'),
      NasikoToggleGroupItem(value: 'd', label: 'Delta'),
    ];

    Future<void> pumpGroup(WidgetTester tester) async {
      await pumpNasiko(
        tester,
        NasikoToggleGroup<String>.single(
          value: null,
          onChanged: (_) {},
          items: items,
        ),
      );
    }

    testWidgets('ArrowRight skips disabled items and wraps at the end',
        (tester) async {
      await pumpGroup(tester);
      await focusItem(tester, 'Alpha');
      expect(focusedGroupLabel(), 'NasikoToggleGroup[0]');

      // 0 -> 2: Beta (index 1) is disabled and skipped.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedGroupLabel(), 'NasikoToggleGroup[2]');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedGroupLabel(), 'NasikoToggleGroup[3]');

      // Wraps past the last enabled item back to the first.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedGroupLabel(), 'NasikoToggleGroup[0]');
    });

    testWidgets('ArrowLeft from the first enabled item wraps to the last',
        (tester) async {
      await pumpGroup(tester);
      await focusItem(tester, 'Alpha');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedGroupLabel(), 'NasikoToggleGroup[3]');

      // And back again, skipping the disabled Beta.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedGroupLabel(), 'NasikoToggleGroup[2]');
    });

    testWidgets('Home and End jump to the first / last enabled item',
        (tester) async {
      await pumpGroup(tester);
      await focusItem(tester, 'Gamma');
      expect(focusedGroupLabel(), 'NasikoToggleGroup[2]');

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(focusedGroupLabel(), 'NasikoToggleGroup[3]');

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(focusedGroupLabel(), 'NasikoToggleGroup[0]');
    });
  });
}
