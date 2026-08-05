import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class TooltipPage extends StatelessWidget {
  const TooltipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Tooltip',
      description:
          'Hover (or long-press) targets to reveal. Waits 300ms by default.',
      children: [
        GallerySection(
          title: 'Placement',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'below (default)',
                child: NasikoTooltip(
                  message: 'Shown below the target',
                  child: SecondaryButton(
                    label: 'Hover me',
                    size: NasikoButtonSize.medium,
                    onPressed: () {},
                  ),
                ),
              ),
              LabeledExample(
                label: 'above',
                child: NasikoTooltip(
                  message: 'Shown above the target',
                  preferBelow: false,
                  child: SecondaryButton(
                    label: 'Hover me',
                    size: NasikoButtonSize.medium,
                    onPressed: () {},
                  ),
                ),
              ),
              LabeledExample(
                label: 'no wait',
                child: NasikoTooltip(
                  message: 'Appears immediately',
                  waitDuration: Duration.zero,
                  child: SecondaryIconButton(
                    icon: kIconInfo,
                    size: NasikoButtonSize.medium,
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'On plain content',
          child: NasikoTooltip(
            message: 'Tooltips wrap any widget',
            child: Text(
              'Hover this text',
              style: context.typography.linkPrimary.copyWith(
                color: context.colors.foregroundBrandLink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
