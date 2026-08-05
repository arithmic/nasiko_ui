// test/behavior/modal_test.dart
//
// Behavior tests for showNasikoModal: rendering of title/content/buttons,
// primary-action autofocus (Enter confirms immediately), and Escape
// dismissal honoring isDismissible.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Future<void> pumpModalHost(
    WidgetTester tester, {
    VoidCallback? onPrimaryAction,
    VoidCallback? onSecondaryAction,
    bool isDismissible = true,
  }) async {
    await pumpNasiko(
      tester,
      Builder(
        builder: (context) => PrimaryButton(
          label: 'Open modal',
          onPressed: () {
            showNasikoModal<void>(
              context: context,
              title: 'Delete agent',
              content: const Text('This cannot be undone.'),
              primaryButtonLabel: 'Delete',
              onPrimaryAction: onPrimaryAction,
              primaryButtonIsDanger: true,
              secondaryButtonLabel: 'Cancel',
              onSecondaryAction: onSecondaryAction,
              isDismissible: isDismissible,
            );
          },
        ),
      ),
    );
  }

  Future<void> openModal(WidgetTester tester) async {
    await tester.tap(find.text('Open modal'));
    // Dialog entrance is a one-shot fade/scale — settling is safe. The
    // settle also runs the primary button's post-frame autofocus.
    await tester.pumpAndSettle();
  }

  bool modalIsOpen(WidgetTester tester) =>
      find.text('Delete agent').evaluate().isNotEmpty;

  testWidgets('renders title, content, and both action buttons',
      (tester) async {
    await pumpModalHost(tester);
    await openModal(tester);

    expect(find.text('Delete agent'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('primary action is autofocused: Enter triggers it directly',
      (tester) async {
    var primaryCalls = 0;
    await pumpModalHost(tester, onPrimaryAction: () => primaryCalls++);
    await openModal(tester);

    // No tab-stops traversed: the primary button already owns focus.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(primaryCalls, 1);
  });

  testWidgets('Escape pops the modal when dismissible', (tester) async {
    await pumpModalHost(tester);
    await openModal(tester);
    expect(modalIsOpen(tester), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(modalIsOpen(tester), isFalse);
  });

  testWidgets('Escape does NOT pop the modal when not dismissible',
      (tester) async {
    await pumpModalHost(tester, isDismissible: false);
    await openModal(tester);
    expect(modalIsOpen(tester), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(modalIsOpen(tester), isTrue,
        reason: 'isDismissible: false must swallow Escape');

    // Close via the header close button so the test ends with a clean tree.
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(modalIsOpen(tester), isFalse);
  });

  testWidgets('secondary button runs its action', (tester) async {
    var secondaryCalls = 0;
    await pumpModalHost(tester, onSecondaryAction: () => secondaryCalls++);
    await openModal(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(secondaryCalls, 1);
  });
}
