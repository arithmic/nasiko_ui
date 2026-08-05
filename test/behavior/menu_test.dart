// test/behavior/menu_test.dart
//
// Behavior tests for NasikoPopupMenu: tap-to-open, Escape dismissal with
// focus restore, arrow-key roving focus (with wrapping), and Enter
// activation reporting the item index through onItemSelected.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  const itemLabels = ['Rename', 'Duplicate', 'Delete'];
  const menuItems = [
    NasikoPopupMenuItemData(label: 'Rename'),
    NasikoPopupMenuItemData(label: 'Duplicate'),
    NasikoPopupMenuItemData(label: 'Delete', isDestructive: true),
  ];

  Future<void> pumpMenu(
    WidgetTester tester, {
    ValueChanged<int>? onItemSelected,
    FocusNode? anchorNode,
  }) async {
    await pumpNasikoOverlayHost(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (anchorNode != null)
            Focus(
              focusNode: anchorNode,
              child: const SizedBox(width: 80, height: 24),
            ),
          NasikoPopupMenu(
            items: menuItems,
            width: 220,
            onItemSelected: onItemSelected ?? (_) {},
            child: Container(
              width: 120,
              height: 36,
              alignment: Alignment.center,
              child: const Text('Open menu'),
            ),
          ),
        ],
      ),
    );
  }

  /// One pump inserts the overlay entry; the second runs the surface's
  /// post-frame focus-scope claim.
  ///
  /// warnIfMissed: false — NasikoPopupMenu wraps its child in an
  /// AbsorbPointer, so the inner Text never hit-tests; the tap is handled
  /// by the wrapper's own GestureDetector (the menu does open).
  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.text('Open menu'), warnIfMissed: false);
    await tester.pump();
    await tester.pump();
  }

  bool menuIsOpen(WidgetTester tester) =>
      find.text('Rename').evaluate().isNotEmpty;

  testWidgets('opens on tap and renders every item', (tester) async {
    await pumpMenu(tester);

    expect(menuIsOpen(tester), isFalse);
    await openMenu(tester);

    for (final label in itemLabels) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('Escape dismisses and restores previous focus', (tester) async {
    final anchor = FocusNode(debugLabel: 'restore-anchor');
    addTearDown(anchor.dispose);
    await pumpMenu(tester, anchorNode: anchor);

    // Focus something before opening — the menu must give it back on close.
    anchor.requestFocus();
    await tester.pump();
    expect(anchor.hasFocus, isTrue);

    await openMenu(tester);
    expect(menuIsOpen(tester), isTrue);
    // The menu's focus scope owns keyboard focus while open.
    expect(anchor.hasPrimaryFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump();

    expect(menuIsOpen(tester), isFalse);
    expect(anchor.hasFocus, isTrue,
        reason: 'Escape must restore focus to where it was before opening');
  });

  testWidgets('arrow keys rove focus across items and wrap', (tester) async {
    await pumpMenu(tester);
    await openMenu(tester);

    String? focusLabel() => FocusManager.instance.primaryFocus?.debugLabel;

    // First ArrowDown enters the list at item 0.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focusLabel(), 'NasikoPopupMenu item 0');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focusLabel(), 'NasikoPopupMenu item 1');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focusLabel(), 'NasikoPopupMenu item 2');

    // Wraps from the last item back to the first.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focusLabel(), 'NasikoPopupMenu item 0');

    // And ArrowUp wraps backwards from the first to the last.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(focusLabel(), 'NasikoPopupMenu item 2');
  });

  testWidgets('Enter activates the focused item with its index',
      (tester) async {
    final selections = <int>[];
    await pumpMenu(tester, onItemSelected: selections.add);
    await openMenu(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // item 0
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // item 1
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selections, [1]);
    expect(menuIsOpen(tester), isFalse,
        reason: 'activation closes the menu before reporting the index');
  });

  testWidgets('tapping an item reports its index and closes', (tester) async {
    final selections = <int>[];
    await pumpMenu(tester, onItemSelected: selections.add);
    await openMenu(tester);

    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(selections, [2]);
    expect(menuIsOpen(tester), isFalse);
  });
}
