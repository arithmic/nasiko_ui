import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class ChipsPage extends StatelessWidget {
  const ChipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Chips',
      description:
          'Variants × sizes × shapes, actionable (tap/delete) and disabled, '
          'plus NasikoChipGroup for rows of chips.',
      children: [
        GallerySection(
          title: 'Variants',
          child: ExampleWrap(
            children: [
              const LabeledExample(
                label: 'neutral',
                child: NasikoChip(label: 'Neutral'),
              ),
              const LabeledExample(
                label: 'brand',
                child: NasikoChip(
                  label: 'Brand',
                  variant: NasikoChipVariant.brand,
                ),
              ),
              const LabeledExample(
                label: 'base',
                child: NasikoChip(
                  label: 'Base',
                  variant: NasikoChipVariant.base,
                  shape: NasikoChipShape.rounded,
                ),
              ),
              const LabeledExample(
                label: 'tag',
                child: NasikoChip(
                  label: 'Tag',
                  variant: NasikoChipVariant.tag,
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Sizes & shapes',
          child: ExampleWrap(
            children: const [
              LabeledExample(
                label: 'small · rectangle',
                child: NasikoChip(label: 'Small'),
              ),
              LabeledExample(
                label: 'large · rectangle',
                child: NasikoChip(label: 'Large', size: NasikoChipSize.large),
              ),
              LabeledExample(
                label: 'small · rounded',
                child: NasikoChip(
                  label: 'Rounded',
                  shape: NasikoChipShape.rounded,
                ),
              ),
              LabeledExample(
                label: 'large · rounded',
                child: NasikoChip(
                  label: 'Rounded',
                  size: NasikoChipSize.large,
                  shape: NasikoChipShape.rounded,
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Actionable & disabled',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'tappable',
                child: NasikoChip(
                  label: 'Filter: active',
                  onTap: () =>
                      NasikoToastService.showInfo(context, 'Chip tapped'),
                ),
              ),
              LabeledExample(
                label: 'deletable',
                child: NasikoChip(
                  label: 'python',
                  leadingIcon: kIconFile,
                  onDelete: () =>
                      NasikoToastService.showInfo(context, 'Delete tapped'),
                ),
              ),
              const LabeledExample(
                label: 'disabled',
                child: NasikoChip(label: 'Disabled', enabled: false),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Chip group',
          description: 'Scrollable row with token spacing.',
          child: SizedBox(
            width: 420,
            child: NasikoChipGroup(
              children: [
                for (final label in [
                  'design',
                  'frontend',
                  'flutter',
                  'tokens',
                  'dark-mode',
                  'motion',
                  'a11y',
                ])
                  NasikoChip(label: label, onTap: () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
