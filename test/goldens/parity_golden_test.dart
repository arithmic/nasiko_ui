// test/goldens/parity_golden_test.dart
//
// Golden frames for the advanced interaction components: NasikoSlider,
// NasikoToggle / NasikoToggleGroup, NasikoInputOtp, and NasikoAlert —
// light and dark.
//
// Generate baselines with: flutter test --update-goldens test/goldens
//
// Determinism: nothing here is focused, so the OTP caret (the only
// repeating animation among these widgets) never mounts and pumpAndSettle
// is safe. Slot content is pre-filled through a TextEditingController.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Widget labelled(String label, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  void noop(double _) {}

  Widget sliderGrid() {
    return goldenFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelled(
            'continuous 40%',
            SizedBox(
              width: 240,
              child: NasikoSlider(value: 0.4, onChanged: noop),
            ),
          ),
          const SizedBox(height: 24),
          labelled(
            'divisions (10), value 60',
            SizedBox(
              width: 240,
              child: NasikoSlider(
                value: 60,
                min: 0,
                max: 100,
                divisions: 10,
                onChanged: noop,
              ),
            ),
          ),
          const SizedBox(height: 24),
          labelled(
            'disabled',
            const SizedBox(
              width: 240,
              child: NasikoSlider(value: 0.5, onChanged: null),
            ),
          ),
        ],
      ),
    );
  }

  Widget toggleGroupGrid() {
    return goldenFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelled(
            'single, one selected',
            NasikoToggleGroup<String>.single(
              value: 'center',
              onChanged: (_) {},
              items: const [
                NasikoToggleGroupItem(value: 'left', label: 'Left'),
                NasikoToggleGroupItem(value: 'center', label: 'Center'),
                NasikoToggleGroupItem(value: 'right', label: 'Right'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          labelled(
            'multiple, two selected, small',
            NasikoToggleGroup<String>.multiple(
              size: NasikoButtonSize.small,
              values: const {'bold', 'italic'},
              onValuesChanged: (_) {},
              items: const [
                NasikoToggleGroupItem(value: 'bold', label: 'Bold'),
                NasikoToggleGroupItem(value: 'italic', label: 'Italic'),
                NasikoToggleGroupItem(value: 'underline', label: 'Underline'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          labelled(
            'disabled item + disabled group',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NasikoToggleGroup<String>.single(
                  value: 'list',
                  onChanged: (_) {},
                  items: const [
                    NasikoToggleGroupItem(value: 'list', label: 'List'),
                    NasikoToggleGroupItem(
                      value: 'board',
                      label: 'Board',
                      enabled: false,
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                NasikoToggleGroup<String>.single(
                  enabled: false,
                  value: 'list',
                  onChanged: (_) {},
                  items: const [
                    NasikoToggleGroupItem(value: 'list', label: 'List'),
                    NasikoToggleGroupItem(value: 'board', label: 'Board'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget otpGrid(TextEditingController prefilled) {
    return goldenFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelled(
            'empty, grouped [3, 3]',
            const NasikoInputOtp(length: 6, groups: [3, 3]),
          ),
          const SizedBox(height: 24),
          labelled(
            'partially filled',
            NasikoInputOtp(length: 6, controller: prefilled),
          ),
          const SizedBox(height: 24),
          labelled(
            'error',
            const NasikoInputOtp(length: 6, groups: [3, 3], hasError: true),
          ),
          const SizedBox(height: 24),
          labelled(
            'disabled',
            const NasikoInputOtp(length: 6, enabled: false),
          ),
        ],
      ),
    );
  }

  Widget alertGrid() {
    return goldenFrame(
      SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            NasikoAlert(
              title: 'Heads up',
              description: 'Neutral callout.',
            ),
            SizedBox(height: 12),
            NasikoAlert.destructive(
              title: 'Deploy failed',
              description: 'The build step exited with a non-zero status.',
            ),
            SizedBox(height: 12),
            NasikoAlert.success(
              title: 'Agent deployed',
              description: 'All health checks passed.',
            ),
            SizedBox(height: 12),
            NasikoAlert.warning(
              title: 'Certificate expiring',
              description: 'Renew before June 30.',
            ),
            SizedBox(height: 12),
            NasikoAlert.info(
              title: 'New version available',
              description: 'Version 2.4 adds streaming tool output.',
            ),
          ],
        ),
      ),
    );
  }

  for (final mode in kGoldenThemeModes) {
    final suffix = brightnessSuffix(mode);

    testWidgets('slider states – $suffix', (tester) async {
      await pumpNasiko(tester, sliderGrid(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'slider_states_$suffix');
    });

    testWidgets('toggle group states – $suffix', (tester) async {
      await pumpNasiko(tester, toggleGroupGrid(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'toggle_group_states_$suffix');
    });

    testWidgets('input otp states – $suffix', (tester) async {
      // Never focused in this frame, so no caret blinks and the controller
      // text simply renders into the first slots.
      final prefilled = TextEditingController(text: '12');
      await pumpNasiko(tester, otpGrid(prefilled), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'input_otp_states_$suffix');
    });

    testWidgets('alert variants – $suffix', (tester) async {
      await pumpNasiko(tester, alertGrid(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'alert_variants_$suffix');
    });
  }
}
