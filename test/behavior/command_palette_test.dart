// test/behavior/command_palette_test.dart
//
// Behavior tests for showNasikoCommandPalette: grouped rendering, the live
// filter (label prefix outranks substring matches; empty groups are hidden),
// ArrowDown + Enter selection — whose callback runs only AFTER the dialog
// has been popped — and Escape closing without a selection.
//
// Filtering is synchronous (no debounce), so plain pumps advance it. The
// palette's entrance fade/scale is one-shot, so pumpAndSettle is safe; the
// focused search field's caret blink is timer-driven and does not prevent
// settling.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Future<void> pumpPaletteHost(
    WidgetTester tester, {
    required List<NasikoCommandGroup> groups,
    required List<String> log,
  }) async {
    await pumpNasiko(
      tester,
      Builder(
        builder: (context) => PrimaryButton(
          label: 'Open palette',
          onPressed: () {
            showNasikoCommandPalette(context: context, groups: groups)
                .then((_) => log.add('closed'));
          },
        ),
      ),
    );
  }

  Future<void> openPalette(WidgetTester tester) async {
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
  }

  List<NasikoCommandGroup> buildGroups(List<String> log) => [
        NasikoCommandGroup(
          label: 'Navigation',
          items: [
            NasikoCommandItem(
              label: 'Go to dashboard',
              onSelected: () => log.add('selected:Go to dashboard'),
            ),
            NasikoCommandItem(
              label: 'Open settings',
              keywords: const ['preferences'],
              onSelected: () => log.add('selected:Open settings'),
            ),
          ],
        ),
        NasikoCommandGroup(
          label: 'Actions',
          items: [
            // Deliberate order: the substring match comes FIRST in source
            // order, so only scoring can put the prefix match above it.
            NasikoCommandItem(
              label: 'Reinvent flow', // 'inv' = substring (score 1)
              onSelected: () => log.add('selected:Reinvent flow'),
            ),
            NasikoCommandItem(
              label: 'Invert colors', // 'inv' = label prefix (score 3)
              onSelected: () => log.add('selected:Invert colors'),
            ),
            NasikoCommandItem(
              label: 'New invoice', // 'inv' = word-boundary prefix (score 2)
              onSelected: () => log.add('selected:New invoice'),
            ),
          ],
        ),
      ];

  testWidgets('opens with every group heading and item', (tester) async {
    final log = <String>[];
    await pumpPaletteHost(tester, groups: buildGroups(log), log: log);
    await openPalette(tester);

    expect(find.text('Navigation'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    for (final label in [
      'Go to dashboard',
      'Open settings',
      'Reinvent flow',
      'Invert colors',
      'New invoice',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets(
      'typing filters live: prefix outranks substring, empty groups hide',
      (tester) async {
    final log = <String>[];
    await pumpPaletteHost(tester, groups: buildGroups(log), log: log);
    await openPalette(tester);

    await tester.enterText(find.byType(TextField), 'inv');
    await tester.pump();

    // Non-matching items and their now-empty group disappear.
    expect(find.text('Go to dashboard'), findsNothing);
    expect(find.text('Open settings'), findsNothing);
    expect(find.text('Navigation'), findsNothing);

    // Ranking: prefix (3) > word-boundary prefix (2) > substring (1),
    // overriding the source order within the group.
    final invert = tester.getTopLeft(find.text('Invert colors'));
    final invoice = tester.getTopLeft(find.text('New invoice'));
    final reinvent = tester.getTopLeft(find.text('Reinvent flow'));
    expect(invert.dy, lessThan(invoice.dy),
        reason: 'label prefix must rank above word-boundary prefix');
    expect(invoice.dy, lessThan(reinvent.dy),
        reason: 'word-boundary prefix must rank above plain substring');
  });

  testWidgets('a query with no matches shows the empty row', (tester) async {
    final log = <String>[];
    await pumpPaletteHost(tester, groups: buildGroups(log), log: log);
    await openPalette(tester);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();

    expect(find.text('No results'), findsOneWidget);
    expect(find.text('Actions'), findsNothing);
  });

  testWidgets('keyword matches count as substring hits', (tester) async {
    final log = <String>[];
    await pumpPaletteHost(tester, groups: buildGroups(log), log: log);
    await openPalette(tester);

    await tester.enterText(find.byType(TextField), 'preferences');
    await tester.pump();

    expect(find.text('Open settings'), findsOneWidget);
    expect(find.text('Go to dashboard'), findsNothing);
  });

  testWidgets('ArrowDown + Enter selects; callback runs after the pop',
      (tester) async {
    final log = <String>[];
    await pumpPaletteHost(tester, groups: buildGroups(log), log: log);
    await openPalette(tester);

    // Highlight starts at flat index 0 ('Go to dashboard'); ArrowDown moves
    // it to 'Open settings' without stealing focus from the search field.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    // One pump starts the pop; the settle finishes the route animation and
    // runs the post-frame onSelected callback.
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Go to dashboard'), findsNothing,
        reason: 'palette must be closed after Enter');
    // The dialog future completed BEFORE the item callback ran, so
    // onSelected can navigate without fighting the closing route.
    expect(log, ['closed', 'selected:Open settings']);
  });

  testWidgets('Escape closes without running any selection', (tester) async {
    final log = <String>[];
    await pumpPaletteHost(tester, groups: buildGroups(log), log: log);
    await openPalette(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Go to dashboard'), findsNothing);
    expect(log, ['closed'],
        reason: 'no onSelected callback may run on Escape');
  });
}
