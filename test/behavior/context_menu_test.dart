// test/behavior/context_menu_test.dart
//
// Behavior tests for NasikoContextMenu: a secondary tap (right-click) opens
// the menu at the pointer position, Escape closes it and restores focus,
// arrow keys rove across enabled items (skipping disabled, wrapping),
// Enter activates, and dividers render.
//
// Platform note: the test platform is non-Windows, so the menu opens on
// secondary-tap DOWN (Windows would open on up). tapAt with
// buttons: kSecondaryMouseButton drives both down and up.
//
// The entrance reveal is a one-shot 200ms fade (motion.base): behavior
// asserts use widget finders (present regardless of opacity); no repeating
// animations or timers are involved.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Finder menuSurface() => find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_NasikoContextMenuSurface',
      );

  Finder divider() => find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_NasikoContextMenuDividerTile',
      );

  /// Pumps a right-clickable region. Item layout: Open, Rename, ── divider,
  /// Archived (disabled), Delete (destructive) — enabled indices [0, 1, 4].
  Future<void> pumpRegion(
    WidgetTester tester, {
    List<String>? selections,
    FocusNode? outsideFocus,
  }) async {
    await pumpNasikoOverlayHost(
      tester,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (outsideFocus != null)
            Focus(
              focusNode: outsideFocus,
              child: const SizedBox(width: 40, height: 20),
            ),
          NasikoContextMenu(
            items: [
              NasikoContextMenuItem(
                label: 'Open',
                onSelected: () => selections?.add('open'),
              ),
              NasikoContextMenuItem(
                label: 'Rename',
                onSelected: () => selections?.add('rename'),
              ),
              const NasikoContextMenuDivider(),
              const NasikoContextMenuItem(label: 'Archived', enabled: false),
              NasikoContextMenuItem(
                label: 'Delete',
                isDestructive: true,
                onSelected: () => selections?.add('delete'),
              ),
            ],
            child: Container(
              width: 240,
              height: 120,
              alignment: Alignment.center,
              child: const Text('Target'),
            ),
          ),
        ],
      ),
    );
  }

  /// Right-clicks [position] and pumps the portal frame plus the surface's
  /// post-frame focus callback.
  Future<void> rightClickAt(WidgetTester tester, Offset position) async {
    await tester.tapAt(position, buttons: kSecondaryMouseButton);
    await tester.pump();
    await tester.pump();
  }

  bool menuIsOpen(WidgetTester tester) => menuSurface().evaluate().isNotEmpty;

  group('NasikoContextMenu opening', () {
    testWidgets('secondary tap opens the menu at the pointer position',
        (tester) async {
      await pumpRegion(tester);
      expect(menuIsOpen(tester), isFalse);

      final position = tester.getCenter(find.text('Target'));
      await rightClickAt(tester, position);

      expect(menuIsOpen(tester), isTrue);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Anchored below-right of the pointer (bottom/start, no gap): the
      // surface's top-left sits at the click point (space permitting here).
      final topLeft = tester.getTopLeft(menuSurface());
      expect(topLeft.dx, closeTo(position.dx, 1.0));
      expect(topLeft.dy, closeTo(position.dy, 1.0));
    });

    testWidgets('primary tap does NOT open the menu', (tester) async {
      await pumpRegion(tester);

      await tester.tap(find.text('Target'), warnIfMissed: false);
      await tester.pump();
      await tester.pump();

      expect(menuIsOpen(tester), isFalse);
    });

    testWidgets('divider entries render as rules, not items', (tester) async {
      await pumpRegion(tester);
      await rightClickAt(tester, tester.getCenter(find.text('Target')));

      expect(divider(), findsOneWidget);
    });
  });

  group('NasikoContextMenu Escape', () {
    testWidgets('closes the menu and restores the previous focus',
        (tester) async {
      final outside = FocusNode(debugLabel: 'outside-node');
      await pumpRegion(tester, outsideFocus: outside);

      outside.requestFocus();
      await tester.pump();
      expect(outside.hasPrimaryFocus, isTrue);

      await rightClickAt(tester, tester.getCenter(find.text('Target')));
      expect(menuIsOpen(tester), isTrue);
      expect(outside.hasPrimaryFocus, isFalse,
          reason: 'the open menu owns focus');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump();

      expect(menuIsOpen(tester), isFalse);
      expect(outside.hasFocus, isTrue,
          reason: 'Escape must hand focus back to where it lived');
    });
  });

  group('NasikoContextMenu keyboard', () {
    testWidgets('arrows rove enabled items, skipping disabled and wrapping',
        (tester) async {
      await pumpRegion(tester);
      await rightClickAt(tester, tester.getCenter(find.text('Target')));

      String? focused() => FocusManager.instance.primaryFocus?.debugLabel;

      // Down enters at the first enabled item.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(), 'NasikoContextMenu item 0');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(), 'NasikoContextMenu item 1');

      // Skips the divider (2) and the disabled item (3).
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(), 'NasikoContextMenu item 4');

      // Wraps from the last enabled item back to the first.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(), 'NasikoContextMenu item 0');

      // And Up wraps backwards, skipping the same entries.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focused(), 'NasikoContextMenu item 4');
    });

    testWidgets('Enter activates the focused item and closes the menu',
        (tester) async {
      final selections = <String>[];
      await pumpRegion(tester, selections: selections);
      await rightClickAt(tester, tester.getCenter(find.text('Target')));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump();

      expect(selections, ['rename']);
      expect(menuIsOpen(tester), isFalse);
    });

    testWidgets('disabled items cannot be activated by tap', (tester) async {
      final selections = <String>[];
      await pumpRegion(tester, selections: selections);
      await rightClickAt(tester, tester.getCenter(find.text('Target')));

      await tester.tap(find.text('Archived'), warnIfMissed: false);
      await tester.pump();

      expect(selections, isEmpty);
      expect(menuIsOpen(tester), isTrue,
          reason: 'a disabled item neither selects nor dismisses');
    });
  });
}
