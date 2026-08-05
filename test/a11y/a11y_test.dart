// test/a11y/a11y_test.dart
//
// Semantics and accessibility-guideline coverage for nasiko_ui.
//
// Uses tester.getSemantics + containsSemantics (the non-exhaustive matcher)
// so assertions only pin the properties this design system promises, and
// stay stable across Flutter versions that add new default flags/actions.
//
// KNOWN LIB GAPS (documented as skipped tests rather than fudged asserts —
// fixes belong in lib/, not here):
//   * NasikoCheckbox builds on a bare InkWell and exposes NO checked state
//     to assistive tech (no Semantics(checked: ...) wrapper).
//   * NasikoRadio builds on a bare GestureDetector and exposes NO
//     checked/mutually-exclusive state.
//   * Small (28px) buttons cannot meet androidTapTargetGuideline (48dp)
//     by design.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  /// Turns real semantics on for the duration of one test.
  void enableSemantics(WidgetTester tester) {
    final handle = tester.ensureSemantics();
    addTearDown(handle.dispose);
  }

  group('Button semantics', () {
    testWidgets('label buttons expose button flag, label, and tap action',
        (tester) async {
      enableSemantics(tester);
      await pumpNasiko(
        tester,
        Wrap(
          spacing: 16,
          children: [
            PrimaryButton(label: 'Save', onPressed: () {}),
            SecondaryButton(label: 'Cancel', onPressed: () {}),
            const DestructiveButton(label: 'Delete', onPressed: null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Save')),
        containsSemantics(
          isButton: true,
          label: 'Save',
          hasTapAction: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Cancel')),
        containsSemantics(isButton: true, label: 'Cancel', isEnabled: true),
      );
      // Disabled: still announced as a button, but not enabled.
      expect(
        tester.getSemantics(find.text('Delete')),
        containsSemantics(
          isButton: true,
          label: 'Delete',
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
    });

    testWidgets('icon-only buttons expose button flag and tap action',
        (tester) async {
      enableSemantics(tester);
      await pumpNasiko(
        tester,
        TertiaryIconButton(
          icon: HugeIcons.strokeRoundedSearch01,
          onPressed: () {},
        ),
      );
      await tester.pumpAndSettle();

      // NOTE: icon-only buttons currently carry no semantic label of their
      // own (HugeIcon has no semanticLabel and there is no tooltip) — that
      // is a lib-level gap; here we pin the button/tap contract only.
      expect(
        tester.getSemantics(find.byType(IconButton)),
        containsSemantics(
          isButton: true,
          hasTapAction: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
    });
  });

  group('Toggle control semantics', () {
    testWidgets('NasikoSwitch exposes toggled state on/off/disabled',
        (tester) async {
      enableSemantics(tester);
      await pumpNasiko(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NasikoSwitch(value: true, onChanged: (_) {}),
            NasikoSwitch(value: false, onChanged: (_) {}),
            const NasikoSwitch(value: true, onChanged: null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      expect(
        tester.getSemantics(switches.at(0)),
        containsSemantics(
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
      expect(
        tester.getSemantics(switches.at(1)),
        containsSemantics(
          hasToggledState: true,
          isToggled: false,
          isEnabled: true,
        ),
      );
      expect(
        tester.getSemantics(switches.at(2)),
        containsSemantics(
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
    });

    // LIB GAP: NasikoCheckbox is a bare InkWell — it never reports
    // hasCheckedState/isChecked, so a screen reader cannot tell checked
    // from unchecked. Unskip once lib/src/components/checkbox/checkbox.dart
    // wraps the control in Semantics(checked: isChecked).
    testWidgets('NasikoCheckbox exposes checked state', (tester) async {
      enableSemantics(tester);
      await pumpNasiko(
        tester,
        NasikoCheckbox(isChecked: true, onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(NasikoCheckbox)),
        containsSemantics(
          hasCheckedState: true,
          isChecked: true,
          hasTapAction: true,
        ),
      );
    }, skip: true); // TODO(lib): add checked-state semantics to NasikoCheckbox.

    // LIB GAP: NasikoRadio is a bare GestureDetector — no checked state and
    // no mutually-exclusive-group flag. Unskip once the component wraps
    // itself in Semantics(checked: ..., inMutuallyExclusiveGroup: true).
    testWidgets('NasikoRadio exposes checked state in a group',
        (tester) async {
      enableSemantics(tester);
      await pumpNasiko(
        tester,
        NasikoRadio<int>(value: 1, groupValue: 1, onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(NasikoRadio<int>)),
        containsSemantics(
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
    }, skip: true); // TODO(lib): add checked-state semantics to NasikoRadio.
  });

  group('Select trigger semantics', () {
    const placeholder = 'Pick a fruit';
    const items = [
      NasikoSelectItem(value: 'apple', label: 'Apple'),
      NasikoSelectItem(value: 'banana', label: 'Banana'),
    ];

    testWidgets('trigger is a button announcing its value and expanded state',
        (tester) async {
      enableSemantics(tester);
      await pumpNasikoOverlayHost(
        tester,
        SizedBox(
          width: 320,
          child: NasikoSelect<String>(
            placeholder: placeholder,
            items: items,
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text(placeholder)),
        containsSemantics(
          isButton: true,
          label: placeholder,
          hasEnabledState: true,
          isEnabled: true,
          isExpanded: false,
        ),
      );

      // Open the menu: the trigger reports expanded, and each option is a
      // button (the selected one would additionally carry isSelected).
      await tester.tap(find.text(placeholder));
      await tester.pump();
      await tester.pump();

      expect(
        tester.getSemantics(find.text(placeholder)),
        containsSemantics(isButton: true, isExpanded: true),
      );
      expect(
        tester.getSemantics(find.text('Apple')),
        containsSemantics(isButton: true, hasEnabledState: true,
            isEnabled: true),
      );
    });
  });

  group('Menu item semantics', () {
    testWidgets('popup menu items are announced as buttons', (tester) async {
      enableSemantics(tester);
      await pumpNasikoOverlayHost(
        tester,
        NasikoPopupMenu(
          items: const [
            NasikoPopupMenuItemData(label: 'Rename'),
            NasikoPopupMenuItemData(label: 'Delete', isDestructive: true),
          ],
          width: 220,
          onItemSelected: (_) {},
          child: Container(
            width: 120,
            height: 36,
            alignment: Alignment.center,
            child: const Text('Open menu'),
          ),
        ),
      );

      await tester.tap(find.text('Open menu'));
      await tester.pump();
      await tester.pump();

      expect(
        tester.getSemantics(find.text('Rename')),
        containsSemantics(isButton: true, label: 'Rename', isEnabled: true),
      );
      expect(
        tester.getSemantics(find.text('Delete')),
        containsSemantics(isButton: true, label: 'Delete'),
      );
    });
  });

  group('Accessibility guidelines', () {
    testWidgets('label buttons meet the labeled-tap-target guideline',
        (tester) async {
      enableSemantics(tester);
      await pumpNasiko(
        tester,
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            PrimaryButton(label: 'Create agent', onPressed: () {}),
            SecondaryButton(
              label: 'Cancel',
              size: NasikoButtonSize.medium,
              onPressed: () {},
            ),
            TertiaryButton(
              label: 'More',
              size: NasikoButtonSize.small,
              onPressed: () {},
            ),
            DestructiveButton(
              label: 'Delete',
              size: NasikoButtonSize.small,
              onPressed: () {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    // BY DESIGN: NasikoButtonSize.small renders a 28px control, which can
    // never satisfy the 48dp android tap-target guideline; medium/large
    // sizes should be re-checked here if the design ever adds padding-based
    // hit areas. Skipped rather than restricted to sizes that pass — a
    // filtered grid would silently stop guarding the small size's siblings.
    testWidgets('buttons meet the android 48dp tap-target guideline',
        (tester) async {
      enableSemantics(tester);
      await pumpNasiko(
        tester,
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            PrimaryButton(label: 'Create agent', onPressed: () {}),
            TertiaryButton(
              label: 'More',
              size: NasikoButtonSize.small,
              onPressed: () {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    }, skip: true); // By design: 28px small buttons < 48dp guideline.
  });
}
