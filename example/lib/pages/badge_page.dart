import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Badge',
      description:
          'Small non-interactive status pills. One badge per intent; colors '
          'come from the feedback tokens.',
      children: [
        GallerySection(
          title: 'Intents',
          child: ExampleWrap(
            children: const [
              LabeledExample(
                label: 'neutral',
                child: NasikoBadge(label: 'Draft'),
              ),
              LabeledExample(
                label: 'success',
                child: NasikoBadge(
                  label: 'Active',
                  intent: NasikoBadgeIntent.success,
                ),
              ),
              LabeledExample(
                label: 'warning',
                child: NasikoBadge(
                  label: 'Expiring',
                  intent: NasikoBadgeIntent.warning,
                ),
              ),
              LabeledExample(
                label: 'error',
                child: NasikoBadge(
                  label: 'Failed',
                  intent: NasikoBadgeIntent.error,
                ),
              ),
              LabeledExample(
                label: 'info',
                child: NasikoBadge(
                  label: 'Beta',
                  intent: NasikoBadgeIntent.info,
                ),
              ),
            ],
          ),
        ),
        const GallerySection(
          title: 'Animated intent change',
          description:
              'Tap to cycle the intent — colors cross-fade at motion.hover.',
          child: _CyclingBadge(),
        ),
      ],
    );
  }
}

class _CyclingBadge extends StatefulWidget {
  const _CyclingBadge();

  @override
  State<_CyclingBadge> createState() => _CyclingBadgeState();
}

class _CyclingBadgeState extends State<_CyclingBadge> {
  int _index = 0;

  static const _labels = ['Draft', 'Active', 'Expiring', 'Failed', 'Beta'];

  @override
  Widget build(BuildContext context) {
    final intent = NasikoBadgeIntent.values[_index];
    return Row(
      children: [
        NasikoBadge(label: _labels[_index], intent: intent),
        SizedBox(width: context.spacing.s16),
        SecondaryButton(
          label: 'Cycle intent',
          size: NasikoButtonSize.small,
          onPressed: () => setState(
            () => _index = (_index + 1) % NasikoBadgeIntent.values.length,
          ),
        ),
      ],
    );
  }
}
