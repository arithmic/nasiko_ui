import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

class NasikoNavigationRail extends StatelessWidget {
  const NasikoNavigationRail({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
    this.isExpanded = false,
    this.widthCollapsed = 36,
    this.widthExpanded = 170,
    this.footerItems,
    this.footer,
  });

  final List<NasikoNavigationRailItem> items;
  final List<NasikoNavigationRailItem>? footerItems;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final Widget? footer;
  final bool isExpanded;
  final double widthExpanded;
  final double widthCollapsed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final width = isExpanded ? widthExpanded : widthCollapsed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      padding: EdgeInsets.symmetric(vertical: spacing.s8),
      child: Column(
        children: [
          ...items.map((item) {
            final isSelected = item.id == selectedId;

            return _RailItem(
              item: item,
              isSelected: isSelected,
              isExpanded: isExpanded,
              onTap: () => onSelect(item.id),
            );
          }),

          const Spacer(),

          if (footerItems != null)
            ...footerItems!.map((item) {
              final isSelected = item.id == selectedId;

              return _RailItem(
                item: item,
                isSelected: isSelected,
                isExpanded: isExpanded,
                onTap: () => onSelect(item.id),
              );
            }),

          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _RailItem extends StatefulWidget {
  const _RailItem({
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  final NasikoNavigationRailItem item;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final iconSizes = context.iconSize;
    final borderWidths = context.borderWidth;
    final typography = context.typography;

    final bgColor = widget.isSelected
        ? colors.backgroundBase
        : Colors.transparent;

    final border = (_hovered || widget.isSelected)
        ? colors.borderSecondary
        : Colors.transparent;

    final content = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.item.isDisabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.item.isDisabled ? null : widget.onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: spacing.s4),
          padding: EdgeInsets.all(spacing.s8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(radii.r8),
            border: Border.all(color: border, width: borderWidths.w1),
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: widget.item.icon,
                size: iconSizes.s,
                color: colors.foregroundIconPrimary,
              ),
              if (widget.isExpanded) ...[
                SizedBox(width: spacing.s8),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: widget.isSelected
                        ? typography.buttonSecondary.copyWith(
                            color: colors.backgroundError,
                          )
                        : typography.bodySecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Tooltip(message: widget.item.label, child: content);
  }
}
