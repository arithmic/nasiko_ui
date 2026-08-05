import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _lastPicked = 'none';

  List<NasikoPopupMenuItemData> get _items => [
        NasikoPopupMenuItemData(label: 'Duplicate', icon: kIconAdd),
        NasikoPopupMenuItemData(label: 'Rename', icon: kIconFile),
        NasikoPopupMenuItemData(label: 'Share', icon: kIconSend),
        NasikoPopupMenuItemData(
          label: 'Delete',
          icon: kIconDelete,
          isDestructive: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Menu',
      description:
          'NasikoPopupMenu — inverse (dark) surface in light mode by design. '
          'Arrow keys move focus, Enter selects, Escape closes.',
      children: [
        GallerySection(
          title: 'Anchored to a button',
          child: Row(
            children: [
              NasikoPopupMenu(
                items: _items,
                onItemSelected: (index) =>
                    setState(() => _lastPicked = _items[index].label),
                // The menu wrapper absorbs the tap; the callback only keeps
                // the button in its enabled visual state.
                child: SecondaryButton(
                  label: 'Open menu',
                  size: NasikoButtonSize.medium,
                  onPressed: () {},
                ),
              ),
              SizedBox(width: context.spacing.s16),
              Text(
                'Last picked: $_lastPicked',
                style: context.typography.bodySecondary.copyWith(
                  color: context.colors.foregroundSecondary,
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Fixed width + disabled anchor',
          child: Row(
            children: [
              NasikoPopupMenu(
                items: _items,
                width: 240,
                onItemSelected: (index) =>
                    setState(() => _lastPicked = _items[index].label),
                child: SecondaryIconButton(
                  icon: kIconMore,
                  size: NasikoButtonSize.medium,
                  onPressed: () {},
                ),
              ),
              SizedBox(width: context.spacing.s16),
              NasikoPopupMenu(
                items: _items,
                enabled: false,
                onItemSelected: (_) {},
                child: const SecondaryButton(
                  label: 'Menu disabled',
                  size: NasikoButtonSize.medium,
                  onPressed: null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
