// lib/src/components/menu/nasiko_menu.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A single item for use within the [NasikoMenu].
///
/// This is an internal-facing widget.
class _NasikoMenuItem extends StatelessWidget {
  const _NasikoMenuItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final typography = context.typography;
    final spacing = context.spacing;
    final borderWidths = context.borderWidth;

    // Determine the styles based on the selection state
    final Color backgroundColor = isSelected
        ? colors.backgroundSecondaryBrand
        : Colors.transparent;

    final Color textColor = isSelected
        ? colors.foregroundPrimary
        : colors.foregroundSecondary;

    final Border border = isSelected
        ? Border.all(color: colors.borderSecondary, width: borderWidths.w1)
        : Border.all(color: Colors.transparent, width: borderWidths.w1);

    // Use AnimatedContainer to smoothly transition between states
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        borderRadius: BorderRadius.circular(radii.r8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radii.r8),
        splashColor: colors.backgroundBrandSubtle.withOpacity(0.5),
        highlightColor: colors.backgroundBrandSubtle.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.all(spacing.s12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: typography.bodySecondary.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A scrollable menu component for navigation or selection.
///
/// Displays a title and a list of items, highlighting the
/// currently selected item.
class NasikoMenu extends StatefulWidget {
  const NasikoMenu({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.titleIcon,
    this.height = 300.0,
  });

  /// The title displayed above the menu.
  final String title;

  /// The icon displayed next to the title.
  final IconData? titleIcon;

  /// The list of string labels for the menu items.
  final List<String> items;

  /// The index of the currently selected item.
  final int selectedIndex;

  /// Callback for when a new item is tapped.
  final ValueChanged<int> onItemSelected;

  /// The fixed height of the scrollable menu area.
  final double height;

  @override
  State<NasikoMenu> createState() => _NasikoMenuState();
}

class _NasikoMenuState extends State<NasikoMenu> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Menu Title
        Padding(
          padding: EdgeInsets.only(left: spacing.s4, bottom: spacing.s8),
          child: Row(
            children: [
              if (widget.titleIcon != null) ...[
                Icon(
                  widget.titleIcon,
                  color: colors.foregroundPrimary,
                  size: iconSizes.s, // 20px
                ),
                SizedBox(width: spacing.s8),
              ],
              Text(
                widget.title,
                style: typography.bodyPrimaryBold.copyWith(
                  color: colors.foregroundPrimary,
                ),
              ),
            ],
          ),
        ),

        // 2. Menu Container
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.backgroundGroup,
            borderRadius: BorderRadius.circular(radii.r12),
          ),
          child: Padding(
            padding: EdgeInsets.all(spacing.s8),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.separated(
                controller: _scrollController,
                itemCount: widget.items.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: spacing.s4),
                itemBuilder: (context, index) {
                  return _NasikoMenuItem(
                    label: widget.items[index],
                    isSelected: widget.selectedIndex == index,
                    onTap: () => widget.onItemSelected(index),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
