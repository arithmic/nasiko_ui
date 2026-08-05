// test/goldens/select_golden_test.dart
//
// Golden frames for the NasikoSelect trigger: closed (widget-level boundary)
// and open (full-screen capture, because the menu renders in the app
// overlay, outside any widget-level RepaintBoundary).
//
// Generate baselines with: flutter test --update-goldens test/goldens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  const items = [
    NasikoSelectItem(value: 'anthropic', label: 'Anthropic'),
    NasikoSelectItem(value: 'openai', label: 'OpenAI'),
    NasikoSelectItem(value: 'google', label: 'Google'),
  ];

  for (final mode in kGoldenThemeModes) {
    final suffix = brightnessSuffix(mode);

    testWidgets('select trigger closed – $suffix', (tester) async {
      await pumpNasiko(
        tester,
        goldenFrame(
          NasikoSelect<String>(
            width: 320,
            placeholder: 'Choose a provider',
            items: items,
            value: 'openai',
            onChanged: (_) {},
          ),
        ),
        brightness: mode,
      );
      await tester.pumpAndSettle();
      await expectGolden(tester, 'select_trigger_closed_$suffix');
    });

    testWidgets('select menu open – $suffix', (tester) async {
      await pumpNasikoOverlayHost(
        tester,
        NasikoSelect<String>(
          width: 320,
          placeholder: 'Choose a provider',
          items: items,
          value: 'openai',
          onChanged: (_) {},
        ),
        brightness: mode,
        // Small surface so the full-screen golden stays compact.
        surface: const Size(480, 400),
      );
      await tester.tap(find.text('OpenAI'));
      // Overlay reveal + chevron rotation are one-shot: settling is safe.
      await tester.pumpAndSettle();
      await expectFullScreenGolden(tester, 'select_menu_open_$suffix');
    });
  }
}
