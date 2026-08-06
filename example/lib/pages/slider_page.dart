import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  double _continuous = 0.4;
  double _divided = 60;
  double _ranged = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return GalleryPage(
      title: 'Slider',
      description:
          'Track tap jumps the thumb, dragging scrubs, arrow keys step. '
          'Disabled = onChanged: null.',
      children: [
        GallerySection(
          title: 'Continuous',
          description: 'Hover or drag to see the floating value label.',
          child: SizedBox(
            width: 320,
            child: NasikoSlider(
              value: _continuous,
              labelFormatter: (v) => '${(v * 100).round()}%',
              onChanged: (v) => setState(() => _continuous = v),
            ),
          ),
        ),
        GallerySection(
          title: 'Divisions',
          description: 'divisions: 10 — the value snaps and ticks are drawn.',
          child: SizedBox(
            width: 320,
            child: NasikoSlider(
              value: _divided,
              min: 0,
              max: 100,
              divisions: 10,
              labelFormatter: (v) => v.round().toString(),
              onChanged: (v) => setState(() => _divided = v),
            ),
          ),
        ),
        GallerySection(
          title: 'Custom min / max',
          description: 'Range -50 to 50.',
          child: SizedBox(
            width: 320,
            child: NasikoSlider(
              value: _ranged,
              min: -50,
              max: 50,
              labelFormatter: (v) => v.round().toString(),
              onChanged: (v) => setState(() => _ranged = v),
            ),
          ),
        ),
        const GallerySection(
          title: 'Disabled',
          child: SizedBox(
            width: 320,
            child: NasikoSlider(value: 0.5, onChanged: null),
          ),
        ),
        GallerySection(
          title: 'Keyboard',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NasikoKbd(keys: ['←', '→']),
              SizedBox(width: spacing.s8),
              Text(
                'step the value (1% of the range, or one division)',
                style: typography.bodyTertiary.copyWith(
                  color: colors.foregroundSecondary,
                ),
              ),
              SizedBox(width: spacing.s16),
              const NasikoKbd(keys: ['Shift', '←/→']),
              SizedBox(width: spacing.s8),
              Text(
                '10x step',
                style: typography.bodyTertiary.copyWith(
                  color: colors.foregroundSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
