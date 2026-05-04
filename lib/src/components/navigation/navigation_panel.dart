import 'package:flutter/material.dart';

import 'navigation_section.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.section.isCollapsible
              ? () => setState(() => isExpanded = !isExpanded)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(widget.section.title.toUpperCase()),
          ),
        ),
        if (isExpanded)
          ...widget.section.children.map((item) {
            return ListTile(title: Text(item.label), onTap: item.onTap);
          }),
      ],
    );
  }
}
