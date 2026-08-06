import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return GalleryPage(
      title: 'Alert',
      description:
          'Inline status callout: icon, title, optional description. '
          'Status-colored, non-dismissable by default (unlike a banner).',
      children: [
        GallerySection(
          title: 'Variants',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const NasikoAlert(
                title: 'Heads up',
                description:
                    'The neutral variant, for callouts with no status.',
              ),
              SizedBox(height: spacing.s12),
              const NasikoAlert.destructive(
                title: 'Deploy failed',
                description: 'The build step exited with a non-zero status.',
              ),
              SizedBox(height: spacing.s12),
              const NasikoAlert.success(
                title: 'Agent deployed',
                description: 'All health checks passed.',
              ),
              SizedBox(height: spacing.s12),
              const NasikoAlert.warning(
                title: 'Certificate expiring',
                description: 'Renew before June 30 to avoid downtime.',
              ),
              SizedBox(height: spacing.s12),
              const NasikoAlert.info(
                title: 'New version available',
                description: 'Version 2.4 adds streaming tool output.',
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Title only',
          child: const NasikoAlert.success(title: 'Saved.'),
        ),
        GallerySection(
          title: 'Dismissable',
          description:
              'onDismiss shows a close button; dismissal collapses the alert '
              'in place before the callback removes it.',
          child: _dismissed
              ? SecondaryButton(
                  label: 'Reset demo',
                  size: NasikoButtonSize.medium,
                  onPressed: () => setState(() => _dismissed = false),
                )
              : NasikoAlert.info(
                  title: 'Tip',
                  description: 'You can pin frequently used agents.',
                  onDismiss: () => setState(() => _dismissed = true),
                ),
        ),
      ],
    );
  }
}
