import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class BannerPage extends StatelessWidget {
  const BannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Banner',
      description:
          'Prominent message with a single action. Horizontal and vertical '
          'layouts, optional icon and close button. Banners animate in with '
          'the shared overlay reveal.',
      children: [
        GallerySection(
          title: 'Horizontal (default)',
          child: NasikoBanner(
            title: 'Workspace upgraded',
            content:
                'Your workspace is now on the Team plan. New seats are '
                'available immediately.',
            bannerIconData: kIconInfo,
            action: PrimaryButton(
              label: 'View plan',
              size: NasikoButtonSize.medium,
              onPressed: () {},
            ),
          ),
        ),
        GallerySection(
          title: 'Horizontal with close',
          child: NasikoBanner(
            title: 'Scheduled maintenance',
            content: 'The API will be read-only on Sunday from 02:00–03:00.',
            bannerIconData: kIconAlert,
            onClose: () => NasikoToastService.showInfo(
              context,
              'Banner close tapped (banner stays; state is yours to own).',
            ),
            action: SecondaryButton(
              label: 'Details',
              size: NasikoButtonSize.medium,
              onPressed: () {},
            ),
          ),
        ),
        GallerySection(
          title: 'Vertical',
          description: 'Compact layout for narrow spaces.',
          child: SizedBox(
            width: 360,
            child: NasikoBanner(
              bannerType: NasikoBannerType.vertical,
              title: 'Try the new router',
              content: 'Route requests across providers with live preview.',
              bannerIconData: kIconSend,
              action: PrimaryButton(
                label: 'Enable',
                size: NasikoButtonSize.medium,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}
