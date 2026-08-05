import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double _value = 0.4;

  void _bump(double delta) =>
      setState(() => _value = (_value + delta).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Progress',
      description:
          'Determinate bars animate value changes at motion.base; pass null '
          'for the indeterminate loop.',
      children: [
        GallerySection(
          title: 'Determinate — driven by buttons',
          description: 'Currently ${(_value * 100).round()}%.',
          child: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NasikoProgress(value: _value),
                SizedBox(height: context.spacing.s12),
                Row(
                  children: [
                    SecondaryButton(
                      label: '−10%',
                      size: NasikoButtonSize.small,
                      onPressed: () => _bump(-0.1),
                    ),
                    SizedBox(width: context.spacing.s8),
                    SecondaryButton(
                      label: '+10%',
                      size: NasikoButtonSize.small,
                      onPressed: () => _bump(0.1),
                    ),
                    SizedBox(width: context.spacing.s8),
                    SecondaryButton(
                      label: 'Reset',
                      size: NasikoButtonSize.small,
                      onPressed: () => setState(() => _value = 0),
                    ),
                    SizedBox(width: context.spacing.s8),
                    SecondaryButton(
                      label: 'Complete',
                      size: NasikoButtonSize.small,
                      onPressed: () => setState(() => _value = 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const GallerySection(
          title: 'Indeterminate',
          child: SizedBox(width: 420, child: NasikoProgress()),
        ),
        GallerySection(
          title: 'Thicker bar',
          description: 'minHeight overrides the default s4 thickness.',
          child: SizedBox(
            width: 420,
            child: NasikoProgress(value: 0.66, minHeight: 12),
          ),
        ),
      ],
    );
  }
}
