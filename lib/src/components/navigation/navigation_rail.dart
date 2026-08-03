import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../buttons/button_layout.dart';

class NasikoNavigationRail extends StatelessWidget {
  const NasikoNavigationRail({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
    this.isExpanded = false,
    this.widthCollapsed,
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

  /// Width of the rail when collapsed. Defaults to the large icon button
  /// size, matching the collapsed [_RailItem]s.
  final double? widthCollapsed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final motion = context.motion;
    final largeIconLayout = iconButtonLayout(context, NasikoButtonSize.large);

    final width = isExpanded
        ? widthExpanded
        : (widthCollapsed ?? largeIconLayout.minHeight);

    return AnimatedContainer(
      // Matches the consumer-side sidebar rail resize (250ms easeInOutCubic).
      duration: motion.resolve(context, motion.panel),
      curve: motion.move,
      width: width,
      padding: EdgeInsets.only(bottom: spacing.s8),
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
    final borderWidths = context.borderWidth;
    final typography = context.typography;
    final motion = context.motion;
    final isDisabled = widget.item.isDisabled;
    final layout = iconButtonLayout(context, NasikoButtonSize.large);

    final bgColor = widget.isSelected
        ? colors.backgroundSecondaryBrand
        : Colors.transparent;

    final border = !isDisabled && _hovered
        ? colors.borderSecondary
        : colors.borderPrimary;

    final content = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.item.isDisabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.item.isDisabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: motion.hover,
          curve: motion.enter,
          margin: EdgeInsets.symmetric(vertical: spacing.s4),
          // Container adds the border's own width as extra padding on top of
          // this (even for the default inside-aligned stroke), so subtract it
          // here to keep the total inset at layout.padding.
          padding: EdgeInsets.all(layout.padding.left - borderWidths.w1),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(radii.r8),
            border: Border.all(color: border, width: borderWidths.w1),
          ),
          child: Row(
            children: [
              HugeIcon(
                strokeWidth: widget.isExpanded || isDisabled ? 1.5 : 1.8,
                icon: widget.item.icon,
                size: layout.iconSize,
                color: isDisabled
                    ? colors.foregroundDisabled
                    : widget.isSelected
                    ? colors.foregroundPrimary
                    : colors.foregroundIconPrimary,
              ),
              if (widget.isExpanded) ...[
                SizedBox(width: spacing.s8),
                Expanded(
                  // Fade the label in as the rail expands — opacity only, no
                  // slide, so the text never fights the width animation.
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: motion.resolve(context, motion.fast),
                    curve: motion.enter,
                    child: Text(
                      widget.item.label,
                      style:
                          (widget.isSelected
                                  ? typography.buttonSecondary
                                  : typography.bodySecondary)
                              .copyWith(
                                fontWeight: widget.isSelected
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                color: isDisabled
                                    ? colors.foregroundDisabled
                                    : colors.foregroundPrimary,
                              ),
                    ),
                    builder: (context, opacity, child) =>
                        Opacity(opacity: opacity, child: child),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (widget.isExpanded) return content;
    return Tooltip(message: widget.item.label, child: content);
  }
}
