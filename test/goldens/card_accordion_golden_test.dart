// test/goldens/card_accordion_golden_test.dart
//
// Golden frames for NasikoCard variants and NasikoAccordion
// (collapsed / expanded), light and dark.
//
// The card frame uses FIXED pumps (not pumpAndSettle): the settingUp variant
// may host progress affordances, and fixed explicit pumps keep the frame
// deterministic whether or not anything is still animating at capture time.
//
// Generate baselines with: flutter test --update-goldens test/goldens

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  Widget cardGrid(ValueListenable<double> progress) {
    return goldenFrame(
      SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NasikoCard(
              title: 'Invoice agent',
              version: 'v1.2',
              subtitle: 'Billing',
              description: 'Creates and reconciles invoices.',
              tags: [NasikoCardTag('3 tools'), NasikoCardTag('connected')],
              showMore: false,
            ),
            const SizedBox(height: 16),
            NasikoCard(
              title: 'Router agent',
              variant: NasikoCardVariant.settingUp,
              settingUpTitle: 'Setting up',
              settingUpBody: 'Deploying model routes…',
              settingUpProgressListenable: progress,
              showMore: false,
            ),
            const SizedBox(height: 16),
            const NasikoCard(
              title: 'Support agent',
              variant: NasikoCardVariant.active,
              description: 'Live and healthy.',
              showMore: false,
            ),
            const SizedBox(height: 16),
            NasikoCard(
              title: 'Sync agent',
              variant: NasikoCardVariant.error,
              errorTitle: 'Failed to start',
              errorBody: 'The container exited during boot.',
              onRetry: () {},
              onDelete: () {},
              showMore: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget accordion({required bool expanded}) {
    const items = [
      NasikoAccordionItem(
        title: 'What is Nasiko?',
        content: Text('An agent platform.'),
      ),
      NasikoAccordionItem(
        title: 'How does billing work?',
        content: Text('Per-seat, monthly.'),
      ),
      NasikoAccordionItem(
        title: 'Can I self-host?',
        content: Text('Yes, on Kubernetes.'),
      ),
    ];
    return goldenFrame(
      SizedBox(
        width: 420,
        child: NasikoAccordion(
          items: items,
          // Passing null explicitly overrides the default (first item open).
          initialOpenIndex: expanded ? 0 : null,
        ),
      ),
    );
  }

  for (final mode in kGoldenThemeModes) {
    final suffix = brightnessSuffix(mode);

    testWidgets('card variants – $suffix', (tester) async {
      final progress = ValueNotifier<double>(0.55);
      addTearDown(progress.dispose);
      await pumpNasiko(tester, cardGrid(progress), brightness: mode);
      // Fixed pumps — do not settle (see file header).
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await expectGolden(tester, 'card_variants_$suffix');
    });

    testWidgets('accordion collapsed – $suffix', (tester) async {
      await pumpNasiko(tester, accordion(expanded: false), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'accordion_collapsed_$suffix');
    });

    testWidgets('accordion expanded – $suffix', (tester) async {
      await pumpNasiko(tester, accordion(expanded: true), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'accordion_expanded_$suffix');
    });
  }
}
