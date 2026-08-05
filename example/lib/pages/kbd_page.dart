import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class KbdPage extends StatelessWidget {
  const KbdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Kbd',
      description:
          'Keyboard shortcut hints rendered as key caps. Purely visual.',
      children: [
        GallerySection(
          title: 'Examples',
          child: ExampleWrap(
            children: const [
              LabeledExample(
                label: 'single key',
                child: NasikoKbd(keys: ['Esc']),
              ),
              LabeledExample(
                label: 'two keys',
                child: NasikoKbd(keys: ['⌘', 'K']),
              ),
              LabeledExample(
                label: 'three keys',
                child: NasikoKbd(keys: ['Ctrl', 'Shift', 'P']),
              ),
              LabeledExample(
                label: 'arrows',
                child: NasikoKbd(keys: ['↑', '↓', '↵']),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Inline usage',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Press ',
                style: context.typography.bodySecondary.copyWith(
                  color: context.colors.foregroundSecondary,
                ),
              ),
              const NasikoKbd(keys: ['⌘', 'K']),
              Text(
                ' to open the command palette.',
                style: context.typography.bodySecondary.copyWith(
                  color: context.colors.foregroundSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
