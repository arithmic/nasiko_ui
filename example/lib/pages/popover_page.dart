import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class PopoverPage extends StatefulWidget {
  const PopoverPage({super.key});

  @override
  State<PopoverPage> createState() => _PopoverPageState();
}

class _PopoverPageState extends State<PopoverPage> {
  final _startController = NasikoPopoverController();
  final _centerController = NasikoPopoverController();
  final _fixedController = NasikoPopoverController();

  @override
  void dispose() {
    _startController.dispose();
    _centerController.dispose();
    _fixedController.dispose();
    super.dispose();
  }

  Widget _content(BuildContext context, String text) => Padding(
        padding: EdgeInsets.all(context.spacing.s16),
        child: Text(
          text,
          style: context.typography.bodySecondary.copyWith(
            color: context.colors.foregroundPrimary,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Popover',
      description:
          'Anchored non-modal overlay driven by a NasikoPopoverController. '
          'Outside tap or Escape dismisses; it flips above the anchor when '
          'space below runs out.',
      children: [
        GallerySection(
          title: 'Alignments',
          child: Row(
            children: [
              NasikoPopover(
                controller: _startController,
                popoverBuilder: (context) =>
                    _content(context, 'Aligned to the start edge.'),
                child: SecondaryButton(
                  label: 'Start (default)',
                  size: NasikoButtonSize.medium,
                  onPressed: _startController.toggle,
                ),
              ),
              SizedBox(width: context.spacing.s12),
              NasikoPopover(
                controller: _centerController,
                alignment: NasikoPopoverAlignment.center,
                popoverBuilder: (context) =>
                    _content(context, 'Centered under the anchor.'),
                child: SecondaryButton(
                  label: 'Center',
                  size: NasikoButtonSize.medium,
                  onPressed: _centerController.toggle,
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Fixed width',
          child: NasikoPopover(
            controller: _fixedController,
            width: 320,
            popoverBuilder: (context) => _content(
              context,
              'This surface is fixed at 320 logical pixels wide regardless '
              'of its content.',
            ),
            child: SecondaryButton(
              label: 'Open 320px popover',
              size: NasikoButtonSize.medium,
              onPressed: _fixedController.toggle,
            ),
          ),
        ),
      ],
    );
  }
}
