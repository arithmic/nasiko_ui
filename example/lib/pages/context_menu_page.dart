import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class ContextMenuPage extends StatelessWidget {
  const ContextMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final typography = context.typography;

    return GalleryPage(
      title: 'Context Menu',
      description:
          'Right-click (secondary tap) opens the menu at the pointer; on '
          'Android/iOS a long-press opens it instead. Escape closes and '
          'restores focus; arrows rove across enabled items.',
      children: [
        GallerySection(
          title: 'Right-click area',
          description:
              'Includes a destructive item, dividers, and a disabled item.',
          child: NasikoContextMenu(
            items: [
              NasikoContextMenuItem(
                label: 'Open',
                icon: kIconFile,
                onSelected: () =>
                    NasikoToastService.showInfo(context, 'Open selected.'),
              ),
              NasikoContextMenuItem(
                label: 'Rename',
                onSelected: () =>
                    NasikoToastService.showInfo(context, 'Rename selected.'),
              ),
              const NasikoContextMenuDivider(),
              const NasikoContextMenuItem(
                label: 'Copy path (unavailable)',
                enabled: false,
              ),
              const NasikoContextMenuDivider(),
              NasikoContextMenuItem(
                label: 'Delete',
                icon: kIconDelete,
                isDestructive: true,
                onSelected: () =>
                    NasikoToastService.showError(context, 'Delete selected.'),
              ),
            ],
            child: Container(
              width: 420,
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.backgroundSurface,
                borderRadius: BorderRadius.circular(radii.r12),
                border: Border.all(
                  color: colors.borderPrimary,
                  width: borderWidths.w1,
                ),
              ),
              child: Text(
                'Right-click here (long-press on touch devices)',
                style: typography.bodySecondary.copyWith(
                  color: colors.foregroundSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
