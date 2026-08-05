import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller =
      TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.typography.bodySecondary.copyWith(
      color: context.colors.foregroundSecondary,
    );
    return GalleryPage(
      title: 'Tabs',
      description:
          'NasikoTabBar with a TabController. Disabled tabs revert taps to '
          'the previous selection.',
      children: [
        GallerySection(
          title: 'With TabBarView',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NasikoTabBar(
                controller: _controller,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  NasikoTabItem(label: 'Overview'),
                  NasikoTabItem(label: 'Runs'),
                  NasikoTabItem(label: 'Settings'),
                ],
              ),
              SizedBox(
                height: 120,
                child: TabBarView(
                  controller: _controller,
                  children: [
                    for (final text in [
                      'Overview content.',
                      'Runs content.',
                      'Settings content.',
                    ])
                      Padding(
                        padding: EdgeInsets.all(context.spacing.s16),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(text, style: bodyStyle),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'With a disabled tab',
          child: DefaultTabController(
            length: 3,
            child: Builder(
              builder: (context) => NasikoTabBar(
                controller: DefaultTabController.of(context),
                tabAlignment: TabAlignment.start,
                tabs: const [
                  NasikoTabItem(label: 'General'),
                  NasikoTabItem(label: 'Members'),
                  NasikoTabItem(label: 'Billing (locked)', enabled: false),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
