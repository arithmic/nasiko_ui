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
            // Key by stable id so per-section expand state isn't reused by
            // list position across screen changes (a collapsed section's state
            // leaking onto a non-collapsible one hides its children).
            key: ValueKey(section.id),
            label: section.title.toUpperCase(),
            icon: section.icon,
            isCollapsible: section.isCollapsible,
            isLoading: section.isLoading,
            emptyMessage: section.emptyMessage,
            children:
                section.children.isNotEmpty ||
                    section.isLoading ||
                    section.emptyMessage != null
                ? section.children
                      .map(
                        (item) => SectionItem(
                          id: item.id,
                          label: item.label,
                          subtitle: item.subtitle,
                          onTap: item.onTap,
                          menuActions: item.menuActions,
                          maxLines: item.maxLines,
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
