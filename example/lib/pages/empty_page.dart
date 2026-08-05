import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Empty',
      description:
          'Centered empty-state placeholder with optional icon, description, '
          'and call-to-action. Enters with a one-shot fade + rise.',
      children: [
        const GallerySection(
          title: 'Title only',
          child: NasikoEmpty(title: 'No results'),
        ),
        GallerySection(
          title: 'Icon + description',
          child: NasikoEmpty(
            icon: kIconInbox,
            title: 'No invoices yet',
            description: 'Invoices you create will show up here.',
          ),
        ),
        GallerySection(
          title: 'With action',
          child: NasikoEmpty(
            icon: kIconSearch,
            title: 'Nothing matches your filters',
            description: 'Try broadening the date range or clearing filters.',
            action: PrimaryButton(
              label: 'Clear filters',
              size: NasikoButtonSize.medium,
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
