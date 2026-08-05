import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class SpinnerPage extends StatefulWidget {
  const SpinnerPage({super.key});

  @override
  State<SpinnerPage> createState() => _SpinnerPageState();
}

class _SpinnerPageState extends State<SpinnerPage> {
  int _replay = 0;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Spinner',
      description:
          'CircularProgressIndicator with a reveal delay so fast responses '
          'never flash a spinner (default 150ms).',
      children: [
        GallerySection(
          title: 'Sizes',
          child: ExampleWrap(
            children: const [
              LabeledExample(
                label: 'default',
                child: NasikoSpinner(delay: Duration.zero),
              ),
              LabeledExample(
                label: '16px',
                child: NasikoSpinner(delay: Duration.zero, size: 16),
              ),
              LabeledExample(
                label: '32px',
                child: NasikoSpinner(delay: Duration.zero, size: 32),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Custom color',
          child: NasikoSpinner(
            delay: Duration.zero,
            size: 24,
            color: context.colors.foregroundBrand,
          ),
        ),
        GallerySection(
          title: 'Delayed reveal',
          description:
              'This spinner waits 800ms before fading in — press replay '
              'and watch the gap.',
          child: Row(
            children: [
              SecondaryButton(
                label: 'Replay',
                size: NasikoButtonSize.small,
                onPressed: () => setState(() => _replay++),
              ),
              SizedBox(width: context.spacing.s16),
              KeyedSubtree(
                key: ValueKey(_replay),
                child: const NasikoSpinner(
                  delay: Duration(milliseconds: 800),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
