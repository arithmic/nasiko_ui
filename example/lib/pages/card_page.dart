import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  List<NasikoCardTag> get _tags => [
        NasikoCardTag('4 tools', icon: kIconCoins),
        NasikoCardTag('connected', icon: kIconTick),
        const NasikoCardTag('gpt-4o'),
        const NasikoCardTag('extra'),
      ];

  @override
  Widget build(BuildContext context) {
    const width = 380.0;
    return GalleryPage(
      title: 'Card',
      description:
          'Agent-style cards: variants control the left accent and body '
          'layout. Tags overflow into a "+N" chip after maxVisibleTags.',
      children: [
        GallerySection(
          title: 'Normal',
          child: SizedBox(
            width: width,
            child: NasikoCard(
              title: 'Invoice parser',
              version: 'v1.2.0',
              subtitle: 'Finance workspace',
              leadingIcon: kIconFile,
              description:
                  'Extracts totals, due dates, and vendors from uploaded '
                  'invoices, then files them.',
              author: 'By Nasiko Labs',
              tags: _tags,
              menuActions: [
                NasikoPopupMenuItemData(label: 'Duplicate', icon: kIconAdd),
                NasikoPopupMenuItemData(
                  label: 'Delete',
                  icon: kIconDelete,
                  isDestructive: true,
                ),
              ],
              onMenuActionSelected: (_) {},
              onTap: () {},
            ),
          ),
        ),
        GallerySection(
          title: 'Setting up',
          child: SizedBox(
            width: width,
            child: NasikoCard(
              title: 'Support triager',
              variant: NasikoCardVariant.settingUp,
              settingUpTitle: 'Deploying…',
              settingUpBody: 'Provisioning tools and memory.',
              tags: _tags.take(2).toList(),
            ),
          ),
        ),
        GallerySection(
          title: 'Active',
          child: SizedBox(
            width: width,
            child: NasikoCard(
              title: 'Sales researcher',
              version: 'v2.0.1',
              variant: NasikoCardVariant.active,
              description: 'Live and healthy — green accent.',
              tags: _tags.take(2).toList(),
              onTap: () {},
            ),
          ),
        ),
        GallerySection(
          title: 'Error',
          child: SizedBox(
            width: width,
            child: NasikoCard(
              title: 'Data syncer',
              variant: NasikoCardVariant.error,
              errorTitle: 'Failed to start',
              errorBody: 'The upstream credential was rejected.',
              errorDetails:
                  'HTTP 401 from https://api.example.com/v1/token — check '
                  'the OAuth client secret in workspace settings.',
              onRetry: () {},
              onDelete: () {},
            ),
          ),
        ),
        GallerySection(
          title: 'Selected & disabled',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                child: NasikoCard(
                  title: 'Selected card',
                  description: 'Persistent selected elevation.',
                  selected: true,
                  onTap: () {},
                ),
              ),
              SizedBox(width: context.spacing.s16),
              const SizedBox(
                width: width,
                child: NasikoCard(
                  title: 'Disabled card',
                  description: 'Muted style; interactions suppressed.',
                  disabled: true,
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Custom trailing widget',
          child: SizedBox(
            width: width,
            child: NasikoCard(
              title: 'Marketplace agent',
              description: 'trailingWidget replaces the three-dot menu.',
              trailingWidget: SecondaryButton(
                label: 'Connect',
                size: NasikoButtonSize.small,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}
