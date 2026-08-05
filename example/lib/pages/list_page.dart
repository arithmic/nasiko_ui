import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  int _selected = 0;
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'List',
      description:
          'NasikoList of NasikoListItems: selection, hierarchy with '
          'expand/collapse, status dots, trailing badges, and disabled rows.',
      children: [
        GallerySection(
          title: 'Selectable list',
          child: SizedBox(
            width: 360,
            child: NasikoList(
              children: [
                for (final (i, title) in ['Overview', 'Runs', 'Settings']
                    .indexed)
                  NasikoListItem(
                    title: title,
                    isSelected: _selected == i,
                    onTap: () => setState(() => _selected = i),
                  ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'Hierarchy & trailing content',
          child: SizedBox(
            width: 360,
            child: NasikoList(
              children: [
                NasikoListItem(
                  title: 'Pipeline run',
                  subtitle: 'Finished 2m ago',
                  leadingIcon: kIconFile,
                  hasChildren: true,
                  isExpanded: _expanded,
                  showStatusDot: true,
                  badgeLabel: '1.85s',
                  onTap: () => setState(() => _expanded = !_expanded),
                  onToggleExpand: () =>
                      setState(() => _expanded = !_expanded),
                ),
                if (_expanded) ...[
                  NasikoListItem(
                    title: 'Fetch invoices',
                    indentLevel: 1,
                    badgeLabel: '0.42s',
                    badgeIcon: kIconTick,
                    onTap: () {},
                  ),
                  NasikoListItem(
                    title: 'Parse totals',
                    indentLevel: 1,
                    badgeLabel: '1.10s',
                    onTap: () {},
                  ),
                  NasikoListItem(
                    title: 'Write results',
                    indentLevel: 2,
                    onTap: () {},
                  ),
                ],
                const NasikoListItem(
                  title: 'Disabled item',
                  isDisabled: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
