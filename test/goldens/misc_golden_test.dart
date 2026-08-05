// test/goldens/misc_golden_test.dart
//
// Golden frames for NasikoProgress (determinate only), NasikoEmpty,
// NasikoKbd, NasikoBanner, and the NasikoTooltip trigger — light and dark.
//
// No golden is captured for the INDETERMINATE progress bar or an open
// tooltip: both are animating states (indeterminate loops forever; the
// tooltip has hover timing), and animating states are not golden-stable.
//
// Generate baselines with: flutter test --update-goldens test/goldens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Widget progressGrid() {
    return goldenFrame(
      SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            NasikoProgress(value: 0.25),
            SizedBox(height: 16),
            NasikoProgress(value: 0.6),
            SizedBox(height: 16),
            NasikoProgress(value: 1.0),
          ],
        ),
      ),
    );
  }

  Widget empty() {
    return goldenFrame(
      SizedBox(
        width: 420,
        child: NasikoEmpty(
          icon: HugeIcons.strokeRoundedSearch01,
          title: 'No agents yet',
          description: 'Create your first agent to get started.',
          action: PrimaryButton(
            label: 'Create agent',
            size: NasikoButtonSize.small,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget kbd() {
    return goldenFrame(
      const Wrap(
        spacing: 16,
        children: [
          NasikoKbd(keys: ['⌘', 'K']),
          NasikoKbd(keys: ['Ctrl', 'Shift', 'P']),
          NasikoKbd(keys: ['Esc']),
        ],
      ),
    );
  }

  Widget banners() {
    return goldenFrame(
      SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NasikoBanner(
              title: 'Trial ending soon',
              content: 'Your workspace trial ends in 3 days.',
              bannerIconData: HugeIcons.strokeRoundedAlert02,
              action: PrimaryButton(
                label: 'Upgrade',
                size: NasikoButtonSize.small,
                onPressed: () {},
              ),
              onClose: () {},
            ),
            const SizedBox(height: 16),
            NasikoBanner(
              title: 'New model available',
              content: 'Route traffic to the latest model release.',
              bannerType: NasikoBannerType.vertical,
              action: PrimaryButton(
                label: 'Review',
                size: NasikoButtonSize.small,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tooltipTrigger() {
    return goldenFrame(
      NasikoTooltip(
        message: 'More information',
        child: SecondaryIconButton(
          icon: HugeIcons.strokeRoundedSearch01,
          onPressed: () {},
        ),
      ),
    );
  }

  for (final mode in kGoldenThemeModes) {
    final suffix = brightnessSuffix(mode);

    testWidgets('progress determinate – $suffix', (tester) async {
      await pumpNasiko(tester, progressGrid(), brightness: mode);
      // Determinate fill tween is one-shot; settling is safe.
      await tester.pumpAndSettle();
      await expectGolden(tester, 'progress_determinate_$suffix');
    });

    testWidgets('empty state – $suffix', (tester) async {
      await pumpNasiko(tester, empty(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'empty_$suffix');
    });

    testWidgets('kbd – $suffix', (tester) async {
      await pumpNasiko(tester, kbd(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'kbd_$suffix');
    });

    testWidgets('banner – $suffix', (tester) async {
      await pumpNasiko(tester, banners(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'banner_$suffix');
    });

    testWidgets('tooltip trigger – $suffix', (tester) async {
      await pumpNasiko(tester, tooltipTrigger(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'tooltip_trigger_$suffix');
    });
  }
}
