import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class ToastPage extends StatelessWidget {
  const ToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Toast',
      description:
          'NasikoToastService shows one floating toast at a time (a new one '
          'replaces the current). Entrance/exit follow the motion tokens.',
      children: [
        GallerySection(
          title: 'Types',
          child: Row(
            children: [
              SecondaryButton(
                label: 'Success',
                size: NasikoButtonSize.medium,
                onPressed: () =>
                    NasikoToastService.showSuccess(context, 'Agent deployed.'),
              ),
              SizedBox(width: context.spacing.s8),
              SecondaryButton(
                label: 'Error',
                size: NasikoButtonSize.medium,
                onPressed: () =>
                    NasikoToastService.showError(context, 'Deploy failed.'),
              ),
              SizedBox(width: context.spacing.s8),
              SecondaryButton(
                label: 'Warning',
                size: NasikoButtonSize.medium,
                onPressed: () => NasikoToastService.showWarning(
                  context,
                  'Token quota at 90%.',
                ),
              ),
              SizedBox(width: context.spacing.s8),
              SecondaryButton(
                label: 'Info',
                size: NasikoButtonSize.medium,
                onPressed: () => NasikoToastService.showInfo(
                  context,
                  'A new version is available.',
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Options',
          child: Row(
            children: [
              SecondaryButton(
                label: 'In progress',
                size: NasikoButtonSize.medium,
                onPressed: () => NasikoToastService.show(
                  context,
                  message: 'Uploading 3 files…',
                  type: NasikoToastType.info,
                  inProgress: true,
                  duration: const Duration(seconds: 5),
                ),
              ),
              SizedBox(width: context.spacing.s8),
              SecondaryButton(
                label: 'No cancel button',
                size: NasikoButtonSize.medium,
                onPressed: () => NasikoToastService.show(
                  context,
                  message: 'Saved.',
                  type: NasikoToastType.success,
                  showCancel: false,
                ),
              ),
            ],
          ),
        ),
        const GallerySection(
          title: 'Inline NasikoToast widget',
          description: 'The raw widget the service wraps in a SnackBar.',
          child: NasikoToast(
            type: NasikoToastType.warning,
            message: 'This toast is embedded in the page.',
            showCancel: false,
          ),
        ),
      ],
    );
  }
}
