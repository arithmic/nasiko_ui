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
    return Container(
      width: width,
      color: Colors.white,
      child: ListView(
        children: sections.map((section) {
          return _Section(section: section);
        }).toList(),
      ),
    );
  }
}

class _Section extends StatefulWidget {
  const _Section({required this.section});
  final NasikoNavigationSection section;

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.all(spacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.section.isCollapsible
                ? () => setState(() => isExpanded = !isExpanded)
                : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.section.title.toUpperCase(),
                    style: typography.bodyTertiaryBold,
                  ),
                ),
                if (widget.section.isCollapsible)
                  Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),

          if (isExpanded) ...[
            SizedBox(height: spacing.s8),
            ...widget.section.children.map((item) {
              return NasikoNavigationListItem(item: item);
            }),
          ],
        ],
      ),
    );
  }
}
