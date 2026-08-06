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
      // Scrollable when the viewport is shorter than the item stack (short
      // laptop windows, docked devtools). ConstrainedBox + IntrinsicHeight
      // preserve the Spacer-driven footer pinning whenever there IS room.
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : 0,
              ),
              child: IntrinsicHeight(
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
              ),
            ),
          );
        },
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
  final OverlayPortalController _tooltipController = OverlayPortalController();

  Widget _buildTooltipOverlay(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;

    final renderBox = this.context.findRenderObject() as RenderBox;
    final target = (renderBox.localToGlobal(Offset.zero) & renderBox.size).centerRight;

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomSingleChildLayout(
          // Right-center: anchored to the item's right edge, vertically
          // centered — matches a collapsed icon-only rail (no room below).
          delegate: _RailTooltipPositionDelegate(target: target),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s12,
                vertical: spacing.s8,
              ),
              decoration: BoxDecoration(
                color: colors.foregroundConstantBlack,
                borderRadius: BorderRadius.circular(radii.r8),
              ),
              child: Text(
                widget.item.label,
                style: typography.bodyPrimary.copyWith(
                  color: colors.foregroundConstantWhite,
                  fontStyle: FontStyle.normal,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
      onEnter: (_) {
        setState(() => _hovered = true);
        if (!widget.isExpanded) _tooltipController.show();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _tooltipController.hide();
      },
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
    return OverlayPortal(
      controller: _tooltipController,
      overlayChildBuilder: _buildTooltipOverlay,
      child: content,
    );
  }
}

/// Positions a tooltip's right-center at [target] in global coordinates —
/// mirrors the framework's own `_TooltipPositionDelegate` (which anchors
/// below/above), swapped to anchor at the item's right edge instead.
class _RailTooltipPositionDelegate extends SingleChildLayoutDelegate {
  _RailTooltipPositionDelegate({required this.target});

  final Offset target;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    const gap = 8.0;
    const margin = 8.0;
    final x = (target.dx + gap).clamp(
      margin,
      (size.width - childSize.width - margin).clamp(margin, size.width),
    );
    final y = (target.dy - childSize.height / 2).clamp(
      margin,
      (size.height - childSize.height - margin).clamp(margin, size.height),
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_RailTooltipPositionDelegate oldDelegate) =>
      target != oldDelegate.target;
}
