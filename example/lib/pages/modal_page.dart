import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class ModalPage extends StatelessWidget {
  const ModalPage({super.key});

  Widget _modalBody(BuildContext context, String text) => Text(
        text,
        style: context.typography.bodySecondary.copyWith(
          color: context.colors.foregroundSecondary,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Modal, Confirm & Sheet',
      description:
          'showNasikoModal (fade + scale), showNasikoConfirmDialog '
          '(opinionated confirm/cancel), and showNasikoSheet (side panel, '
          'slides at motion.panel). All dismiss with Escape or barrier tap.',
      children: [
        GallerySection(
          title: 'Modal',
          child: Row(
            children: [
              PrimaryButton(
                label: 'Basic modal',
                size: NasikoButtonSize.medium,
                onPressed: () => showNasikoModal<void>(
                  context: context,
                  title: 'Rename agent',
                  content: _modalBody(
                    context,
                    'Renaming does not affect existing runs or logs.',
                  ),
                  primaryButtonLabel: 'Save',
                  onPrimaryAction: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  secondaryButtonLabel: 'Cancel',
                  onSecondaryAction: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                ),
              ),
              SizedBox(width: context.spacing.s12),
              SecondaryButton(
                label: 'Error title + vertical buttons',
                size: NasikoButtonSize.medium,
                onPressed: () => showNasikoModal<void>(
                  context: context,
                  title: 'Deployment failed',
                  titleType: NasikoModalTitleType.error,
                  titleIcon: kIconAlert,
                  buttonLayout: NasikoModalVariant.vertical,
                  content: _modalBody(
                    context,
                    'The build step exited with a non-zero status.',
                  ),
                  primaryButtonLabel: 'Retry',
                  primaryButtonLeadingIcon: kIconReload,
                  onPrimaryAction: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  secondaryButtonLabel: 'View logs',
                  onSecondaryAction: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Confirm dialog',
          child: Row(
            children: [
              SecondaryButton(
                label: 'Confirm',
                size: NasikoButtonSize.medium,
                onPressed: () async {
                  final ok = await showNasikoConfirmDialog(
                    context: context,
                    title: 'Publish changes?',
                    message: 'Everyone in the workspace will see them.',
                    confirmLabel: 'Publish',
                  );
                  if (context.mounted) {
                    NasikoToastService.showInfo(
                      context,
                      ok ? 'Confirmed' : 'Cancelled',
                    );
                  }
                },
              ),
              SizedBox(width: context.spacing.s12),
              DestructiveSecondaryButton(
                label: 'Destructive confirm',
                size: NasikoButtonSize.medium,
                onPressed: () async {
                  final ok = await showNasikoConfirmDialog(
                    context: context,
                    title: 'Delete project?',
                    message: 'This action cannot be undone.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                  if (context.mounted) {
                    NasikoToastService.showInfo(
                      context,
                      ok ? 'Deleted' : 'Kept',
                    );
                  }
                },
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Sheet',
          child: Row(
            children: [
              SecondaryButton(
                label: 'Right sheet',
                size: NasikoButtonSize.medium,
                onPressed: () => showNasikoSheet<void>(
                  context: context,
                  builder: (sheetContext) => _SheetBody(
                    title: 'Filters',
                    onClose: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
              ),
              SizedBox(width: context.spacing.s12),
              SecondaryButton(
                label: 'Left sheet (narrow)',
                size: NasikoButtonSize.medium,
                onPressed: () => showNasikoSheet<void>(
                  context: context,
                  side: NasikoSheetSide.left,
                  width: 320,
                  builder: (sheetContext) => _SheetBody(
                    title: 'Navigation',
                    onClose: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.spacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.typography.titleSecondary.copyWith(
              color: context.colors.foregroundPrimary,
            ),
          ),
          SizedBox(height: context.spacing.s8),
          Text(
            'Sheet content goes here. Escape or the barrier dismisses.',
            style: context.typography.bodySecondary.copyWith(
              color: context.colors.foregroundSecondary,
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Close',
            size: NasikoButtonSize.medium,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
