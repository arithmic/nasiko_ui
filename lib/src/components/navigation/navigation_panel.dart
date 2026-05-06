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
    final spacing = context.spacing;

    return SizedBox(
      width: width,
      child: ListView.separated(
        padding: EdgeInsets.all(spacing.s12),
        itemCount: sections.length,
        separatorBuilder: (_, __) => SizedBox(height: spacing.s8),
        itemBuilder: (_, i) {
          final section = sections[i];
          return Section(
            label: section.title.toUpperCase(),
            icon: section.icon,
            children: section.children.isNotEmpty
                ? section.children
                      .map(
                        (item) => SectionItem(
                          id: item.id,
                          label: item.label,
                          subtitle: item.subtitle,
                          onTap: item.onTap,
                        ),
                      )
                      .toList()
                : null,
            selectedChildId: section.selectedChildId,
            onChildTap: section.onChildTap,
          );
        },
      ),
    );
  }
}
