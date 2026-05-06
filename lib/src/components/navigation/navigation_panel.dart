import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

class NasikoNavigationPanel extends StatelessWidget {
  const NasikoNavigationPanel({
    super.key,
    required this.sections,
    this.width = 200,
  });

  final List<NasikoNavigationSection> sections;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ListView(
        children: sections.map((section) {
          return Section(
            label: section.title,
            icon: null,
            children: section.children.map((item) {
              return SectionItem(
                id: item.id,
                label: item.label,
                onTap: item.onTap,
              );
            }).toList(),
            isInitiallyExpanded: true,
            isCollapsible: section.isCollapsible,
          );
        }).toList(),
      ),
    );
  }
}
