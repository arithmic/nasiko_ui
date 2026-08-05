import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  String _selectedRail = 'inbox';
  bool _railExpanded = false;
  String _selectedChild = 'runs-today';

  List<NasikoNavigationRailItem> get _railItems => [
        NasikoNavigationRailItem(id: 'inbox', icon: kIconInbox, label: 'Inbox'),
        NasikoNavigationRailItem(
          id: 'agents',
          icon: kIconUser,
          label: 'Agents',
        ),
        NasikoNavigationRailItem(
          id: 'files',
          icon: kIconFile,
          label: 'Files',
        ),
        NasikoNavigationRailItem(
          id: 'disabled',
          icon: kIconAlert,
          label: 'Disabled',
          isDisabled: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GalleryPage(
      title: 'Navigation',
      description:
          'NasikoNavigationRail (collapsible icon rail), '
          'NasikoNavigationPanel (sectioned side panel), composed with '
          'NasikoNavigationLayout. Plus the standalone '
          'NasikoNavigationListItem row.',
      children: [
        GallerySection(
          title: 'Rail + panel in a layout',
          description: 'Toggle the switch to expand the rail with labels.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NasikoSwitch(
                    value: _railExpanded,
                    size: NasikoSwitchSize.small,
                    onChanged: (v) => setState(() => _railExpanded = v),
                  ),
                  SizedBox(width: context.spacing.s8),
                  Text(
                    'Expanded rail',
                    style: context.typography.bodySecondary.copyWith(
                      color: colors.foregroundSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.s12),
              Container(
                height: 380,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.borderPrimary,
                    width: context.borderWidth.w1,
                  ),
                  borderRadius: BorderRadius.circular(context.radius.r8),
                ),
                child: NasikoNavigationLayout(
                  rail: NasikoNavigationRail(
                    items: _railItems,
                    footerItems: [
                      NasikoNavigationRailItem(
                        id: 'settings',
                        icon: kIconMore,
                        label: 'Settings',
                      ),
                    ],
                    selectedId: _selectedRail,
                    isExpanded: _railExpanded,
                    onSelect: (id) => setState(() => _selectedRail = id),
                  ),
                  panel: NasikoNavigationPanel(
                    width: 220,
                    sections: [
                      NasikoNavigationSection(
                        id: 'runs',
                        title: 'Runs',
                        icon: kIconFile,
                        selectedChildId: _selectedChild,
                        onChildTap: (id) =>
                            setState(() => _selectedChild = id),
                        children: const [
                          NasikoNavigationItem(
                            id: 'runs-today',
                            label: 'Today',
                          ),
                          NasikoNavigationItem(
                            id: 'runs-week',
                            label: 'This week',
                          ),
                        ],
                      ),
                      const NasikoNavigationSection(
                        id: 'loading',
                        title: 'Loading section',
                        isLoading: true,
                      ),
                      const NasikoNavigationSection(
                        id: 'empty',
                        title: 'Empty section',
                        emptyMessage: 'No saved views',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Navigation list item',
          description: 'Hover to see the border highlight.',
          child: SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NasikoNavigationListItem(
                  item: NasikoNavigationItem(
                    id: 'item-1',
                    label: 'Getting started',
                    onTap: () {},
                  ),
                ),
                NasikoNavigationListItem(
                  item: NasikoNavigationItem(
                    id: 'item-2',
                    label: 'API reference',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
