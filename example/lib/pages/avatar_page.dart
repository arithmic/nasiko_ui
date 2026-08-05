import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Avatar',
      description:
          'Image, initials, or icon avatars in three sizes and two shapes. '
          '(The network-image variant is omitted so the gallery stays fully '
          'offline; pass imageUrl in real usage.)',
      children: [
        GallerySection(
          title: 'Sizes — initials',
          child: ExampleWrap(
            children: const [
              LabeledExample(
                label: 'large',
                child: NasikoAvatar(size: NasikoAvatarSize.large, text: 'SN'),
              ),
              LabeledExample(
                label: 'medium',
                child: NasikoAvatar(size: NasikoAvatarSize.medium, text: 'SN'),
              ),
              LabeledExample(
                label: 'small',
                child: NasikoAvatar(size: NasikoAvatarSize.small, text: 'SN'),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Shapes',
          child: ExampleWrap(
            children: const [
              LabeledExample(
                label: 'circle (default)',
                child: NasikoAvatar(text: 'AB'),
              ),
              LabeledExample(
                label: 'square',
                child: NasikoAvatar(
                  shape: NasikoAvatarShape.square,
                  text: 'AB',
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Icon fallback',
          description: 'Shown when both imageUrl and text are null.',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'icon, circle',
                child: NasikoAvatar(icon: kIconUser),
              ),
              LabeledExample(
                label: 'icon, square, large',
                child: NasikoAvatar(
                  icon: kIconUser,
                  shape: NasikoAvatarShape.square,
                  size: NasikoAvatarSize.large,
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Custom colors',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'brand tokens',
                child: NasikoAvatar(
                  text: 'NK',
                  backgroundColor: context.colors.backgroundBrand,
                  foregroundColor: context.colors.foregroundOnAction,
                ),
              ),
              LabeledExample(
                label: 'feedback tokens',
                child: NasikoAvatar(
                  text: 'ER',
                  backgroundColor: context.colors.backgroundError,
                  foregroundColor: context.colors.foregroundError,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
