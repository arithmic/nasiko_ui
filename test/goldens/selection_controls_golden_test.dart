// test/goldens/selection_controls_golden_test.dart
//
// Golden frames for NasikoCheckbox, NasikoRadio, and NasikoSwitch in
// on / off / disabled states, light and dark.
//
// Generate baselines with: flutter test --update-goldens test/goldens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Widget labelled(String label, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget grid() {
    void noopBool(bool? _) {}
    void noopSwitch(bool _) {}
    void noopRadio(int? _) {}

    return goldenFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkboxes: off / on / disabled-off / disabled-on.
          Wrap(
            spacing: 24,
            children: [
              labelled(
                'off',
                NasikoCheckbox(isChecked: false, onChanged: noopBool),
              ),
              labelled(
                'on',
                NasikoCheckbox(isChecked: true, onChanged: noopBool),
              ),
              labelled(
                'disabled off',
                const NasikoCheckbox(isChecked: false, onChanged: null),
              ),
              labelled(
                'disabled on',
                const NasikoCheckbox(isChecked: true, onChanged: null),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Radios: unselected / selected / disabled variants.
          Wrap(
            spacing: 24,
            children: [
              labelled(
                'off',
                NasikoRadio<int>(
                  value: 1,
                  groupValue: 2,
                  onChanged: noopRadio,
                ),
              ),
              labelled(
                'on',
                NasikoRadio<int>(
                  value: 1,
                  groupValue: 1,
                  onChanged: noopRadio,
                ),
              ),
              labelled(
                'disabled off',
                const NasikoRadio<int>(
                  value: 1,
                  groupValue: 2,
                  onChanged: null,
                ),
              ),
              labelled(
                'disabled on',
                const NasikoRadio<int>(
                  value: 1,
                  groupValue: 1,
                  onChanged: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Switches: off / on / disabled, both sizes.
          Wrap(
            spacing: 24,
            children: [
              labelled(
                'off',
                NasikoSwitch(value: false, onChanged: noopSwitch),
              ),
              labelled(
                'on',
                NasikoSwitch(value: true, onChanged: noopSwitch),
              ),
              labelled(
                'disabled off',
                const NasikoSwitch(value: false, onChanged: null),
              ),
              labelled(
                'disabled on',
                const NasikoSwitch(value: true, onChanged: null),
              ),
              labelled(
                'small on',
                NasikoSwitch(
                  value: true,
                  size: NasikoSwitchSize.small,
                  onChanged: noopSwitch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  for (final mode in kGoldenThemeModes) {
    final suffix = brightnessSuffix(mode);

    testWidgets('checkbox / radio / switch – $suffix', (tester) async {
      await pumpNasiko(tester, grid(), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'selection_controls_$suffix');
    });
  }
}
