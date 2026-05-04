import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'navigation_rail_item.dart';

class NasikoNavigationRail extends StatelessWidget {
  const NasikoNavigationRail({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
    this.isExpanded = false,
    this.widthCollapsed = 60,
    this.widthExpanded = 194,
  });

  final List<NasikoNavigationRailItem> items;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final bool isExpanded;

  final double widthCollapsed;
  final double widthExpanded;

  @override
  Widget build(BuildContext context) {
    final width = isExpanded ? widthExpanded : widthCollapsed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      child: Column(
        children: items.map((item) {
          final isSelected = item.id == selectedId;

          return GestureDetector(
            onTap: item.isDisabled ? null : () => onSelect(item.id),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey.shade200 : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  HugeIcon(icon: item.icon),
                  if (isExpanded) ...[
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.label)),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
