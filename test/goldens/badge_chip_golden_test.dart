// test/goldens/badge_chip_golden_test.dart
//
// Golden frames for NasikoBadge (every intent) and NasikoChip (variants ×
// sizes × shapes, plus deletable and disabled examples), light and dark.
//
// Generate baselines with: flutter test --update-goldens test/goldens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Widget badgeGrid() {
    return goldenFrame(
      Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const [
          NasikoBadge(label: 'Neutral'),
          NasikoBadge(label: 'Success', intent: NasikoBadgeIntent.success),
          NasikoBadge(label: 'Warning', intent: NasikoBadgeIntent.warning),
          NasikoBadge(label: 'Error', intent: NasikoBadgeIntent.error),
          NasikoBadge(label: 'Info', intent: NasikoBadgeIntent.info),
        ],
      ),
    );
  }

  Widget chipGrid() {
    void noop() {}
    return goldenFrame(
      Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Variants, small rectangle.
          NasikoChip(label: 'Neutral', onTap: noop),
          NasikoChip(
            label: 'Brand',
            variant: NasikoChipVariant.brand,
            onTap: noop,
          ),
          NasikoChip(
            label: 'Base',
            variant: NasikoChipVariant.base,
            shape: NasikoChipShape.rounded,
            onTap: noop,
          ),
          NasikoChip(
            label: 'Tag',
            variant: NasikoChipVariant.tag,
            onTap: noop,
          ),
          // Sizes.
          NasikoChip(
            label: 'Large',
            size: NasikoChipSize.large,
            onTap: noop,
          ),
          // Rounded shape.
          NasikoChip(
            label: 'Rounded',
            shape: NasikoChipShape.rounded,
            onTap: noop,
          ),
          // Leading icon + deletable.
          NasikoChip(
            label: 'Deletable',
            leadingIcon: HugeIcons.strokeRoundedSearch01,
            onDelete: noop,
          ),
          // Disabled.
          const NasikoChip(label: 'Disabled', enabled: false),
        ],
      ),
    );
  }

  for (final mode in kGoldenThemeModes) {
    final suffix = brightnessSuffix(mode);

    testWidgets('badge intents – $suffix', (tester) async {
      await pumpNasiko(tester, badgeGrid(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'badge_$suffix');
    });

    testWidgets('chip matrix – $suffix', (tester) async {
      await pumpNasiko(tester, chipGrid(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'chips_$suffix');
    });
  }
}
