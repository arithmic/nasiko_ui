import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class BreadcrumbPage extends StatelessWidget {
  const BreadcrumbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Breadcrumb',
      description:
          'Navigation hierarchy. Items with onTap are interactive; the last '
          'item (onTap: null) renders as the current page.',
      children: [
        GallerySection(
          title: 'Default',
          child: NasikoBreadcrumb(
            items: [
              NasikoBreadcrumbItem(label: 'Workspace', onTap: () {}),
              NasikoBreadcrumbItem(label: 'Agents', onTap: () {}),
              const NasikoBreadcrumbItem(label: 'Invoice parser'),
            ],
          ),
        ),
        GallerySection(
          title: 'With leading icon',
          description: 'leadingIcon takes a Material IconData.',
          child: NasikoBreadcrumb(
            leadingIcon: Icons.home_outlined,
            items: [
              NasikoBreadcrumbItem(label: 'Home', onTap: () {}),
              NasikoBreadcrumbItem(label: 'Settings', onTap: () {}),
              const NasikoBreadcrumbItem(label: 'Members'),
            ],
          ),
        ),
        const GallerySection(
          title: 'Single (current only)',
          child: NasikoBreadcrumb(
            items: [NasikoBreadcrumbItem(label: 'Dashboard')],
          ),
        ),
      ],
    );
  }
}
