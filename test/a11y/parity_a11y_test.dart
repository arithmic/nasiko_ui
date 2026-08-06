// test/a11y/parity_a11y_test.dart
//
// Semantics coverage for the advanced interaction components: slider adjustable
// semantics (increase/decrease), toggle selected state, OTP per-slot
// labels, and context-menu item buttons.
//
// Conventions shared with a11y_test.dart:
//   * SemanticsHandles are disposed at the END of each test body, never via
//     addTearDown (flutter_test verifies handle disposal before tear-downs
//     run).
//   * Overlay surfaces fade in; at opacity 0 their subtree is dropped from
//     semantics — pump THROUGH the entrance (300ms covers motion.base)
//     before asserting.
//   * Nodes whose widgets exclude inner text are resolved by a manual
//     label DFS (semanticsByLabel) rather than tester.getSemantics.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsHandle, SemanticsNode;
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  SemanticsHandle enableSemantics(WidgetTester tester) =>
      tester.ensureSemantics();

  /// The semantics node carrying exactly [label], found by walking the
  /// whole semantics tree (copied from a11y_test.dart). On a miss, fails
  /// with every label present so the breakage is self-diagnosing.
  SemanticsNode semanticsByLabel(WidgetTester tester, String label) {
    final root =
        tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
    SemanticsNode? match;
    final present = <String>[];
    bool visit(SemanticsNode node) {
      if (node.label.isNotEmpty) present.add(node.label);
      match ??= node.label == label ? node : null;
      node.visitChildren(visit);
      return true;
    }

    visit(root);
    if (match == null) {
      fail('No semantics node labeled "$label". Labels present: $present');
    }
    return match!;
  }

  /// Prefix variant of [semanticsByLabel] for nodes whose label may have
  /// merged descendant text appended (labels join with a newline when
  /// configs merge — e.g. a filled OTP slot may read
  /// 'Character 1 of 4\n1').
  SemanticsNode semanticsByLabelPrefix(WidgetTester tester, String prefix) {
    final root =
        tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
    SemanticsNode? match;
    final present = <String>[];
    bool visit(SemanticsNode node) {
      if (node.label.isNotEmpty) present.add(node.label);
      match ??= node.label.startsWith(prefix) ? node : null;
      node.visitChildren(visit);
      return true;
    }

    visit(root);
    if (match == null) {
      fail('No semantics node with label prefix "$prefix". '
          'Labels present: $present');
    }
    return match!;
  }

  group('Slider semantics', () {
    testWidgets('exposes slider flag, value, and increase/decrease actions',
        (tester) async {
      final semantics = enableSemantics(tester);
      await pumpNasiko(
        tester,
        SizedBox(
          width: 300,
          child: NasikoSlider(
            value: 50,
            min: 0,
            max: 100,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(NasikoSlider)),
        containsSemantics(
          isSlider: true,
          hasEnabledState: true,
          isEnabled: true,
          value: '50',
          increasedValue: '51',
          decreasedValue: '49',
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('disabled slider drops the adjust actions', (tester) async {
      final semantics = enableSemantics(tester);
      await pumpNasiko(
        tester,
        const SizedBox(
          width: 300,
          child: NasikoSlider(value: 0.5, onChanged: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(NasikoSlider)),
        containsSemantics(
          isSlider: true,
          hasEnabledState: true,
          isEnabled: false,
          hasIncreaseAction: false,
          hasDecreaseAction: false,
        ),
      );
      semantics.dispose();
    });
  });

  group('Toggle semantics', () {
    testWidgets('toggle exposes button flag and selected state on/off',
        (tester) async {
      final semantics = enableSemantics(tester);
      await pumpNasiko(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NasikoToggle(label: 'Bold', value: true, onChanged: (_) {}),
            const SizedBox(width: 16),
            NasikoToggle(label: 'Italic', value: false, onChanged: (_) {}),
            const SizedBox(width: 16),
            const NasikoToggle(label: 'Under', value: true, onChanged: null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Bold')),
        containsSemantics(
          isButton: true,
          isSelected: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Italic')),
        containsSemantics(isButton: true, isSelected: false, isEnabled: true),
      );
      expect(
        tester.getSemantics(find.text('Under')),
        containsSemantics(
          isButton: true,
          isSelected: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      semantics.dispose();
    });

    testWidgets('single-mode group items are in a mutually exclusive group',
        (tester) async {
      final semantics = enableSemantics(tester);
      await pumpNasiko(
        tester,
        NasikoToggleGroup<String>.single(
          value: 'left',
          onChanged: (_) {},
          items: const [
            NasikoToggleGroupItem(value: 'left', label: 'Left'),
            NasikoToggleGroupItem(value: 'right', label: 'Right'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Left')),
        containsSemantics(
          isButton: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      semantics.dispose();
    });
  });

  group('Input OTP semantics', () {
    testWidgets('each slot announces its position and content',
        (tester) async {
      final semantics = enableSemantics(tester);
      final controller = TextEditingController(text: '12');
      await pumpNasiko(
        tester,
        NasikoInputOtp(length: 4, controller: controller),
      );
      await tester.pumpAndSettle();

      // Filled slots: prefix match, since the slot character's own text
      // label may merge onto the Semantics label.
      expect(
        semanticsByLabelPrefix(tester, 'Character 1 of 4'),
        containsSemantics(value: '1'),
      );
      expect(
        semanticsByLabelPrefix(tester, 'Character 2 of 4'),
        containsSemantics(value: '2'),
      );
      // Empty slot: nothing merges, the label is exact.
      expect(
        semanticsByLabel(tester, 'Character 3 of 4'),
        containsSemantics(value: 'empty'),
      );
      // The hidden text field carries the control's accessible name.
      expect(semanticsByLabel(tester, 'One-time code'), isNotNull);
      semantics.dispose();
    });
  });

  group('Context menu semantics', () {
    testWidgets('menu items are announced as buttons with enabled state',
        (tester) async {
      final semantics = enableSemantics(tester);
      await pumpNasikoOverlayHost(
        tester,
        NasikoContextMenu(
          items: const [
            NasikoContextMenuItem(label: 'Rename'),
            NasikoContextMenuDivider(),
            NasikoContextMenuItem(label: 'Archived', enabled: false),
            NasikoContextMenuItem(label: 'Delete', isDestructive: true),
          ],
          child: Container(
            width: 240,
            height: 120,
            alignment: Alignment.center,
            child: const Text('Target'),
          ),
        ),
      );

      await tester.tapAt(
        tester.getCenter(find.text('Target')),
        buttons: kSecondaryMouseButton,
      );
      // Two frames: portal sync happens post-frame, then the surface builds.
      await tester.pump();
      await tester.pump();
      // Pump THROUGH the entrance fade: at opacity 0 the menu subtree is
      // dropped from semantics.
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        semanticsByLabel(tester, 'Rename'),
        containsSemantics(isButton: true, hasEnabledState: true, isEnabled: true),
      );
      expect(
        semanticsByLabel(tester, 'Archived'),
        containsSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
      expect(
        semanticsByLabel(tester, 'Delete'),
        containsSemantics(isButton: true, isEnabled: true),
      );
      semantics.dispose();
    });
  });
}
