// lib/src/components/menu/nasiko_menu.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A single item for use within the [NasikoPopupMenu].
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
        splashColor: colors.backgroundBrandSubtle.withValues(alpha: 0.5),
        highlightColor: colors.backgroundBrandSubtle.withValues(alpha: 0.5),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: isSelected
                      ? typography.bodySecondaryBold
                      : typography.bodySecondary.copyWith(
                          color: colors.foregroundSecondary,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A popup menu component that displays a list of selectable items.
///
/// This widget creates a Material-style popup menu with a scrollable list
/// of items, highlighting the currently selected item.
class NasikoPopupMenu extends StatefulWidget {
  const NasikoPopupMenu({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.width = 200.0,
    this.maxHeight = 220.0,
  });

  /// The list of string labels for the menu items.
  final List<String> items;

  /// The index of the currently selected item.
  final int selectedIndex;

  /// Callback for when a new item is selected.
  final ValueChanged<int> onItemSelected;

  /// The width of the popup menu.
  final double width;

  /// The maximum height of the scrollable menu area.
  final double maxHeight;

  @override
  State<NasikoPopupMenu> createState() => _NasikoPopupMenuState();
}

class _NasikoPopupMenuState extends State<NasikoPopupMenu> {
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
    final borderWidths = context.borderWidth;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.width,
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        decoration: BoxDecoration(
          color: colors.backgroundGroup,
          borderRadius: BorderRadius.circular(radii.r8),
          border: Border.all(
            color: colors.borderPrimary,
            width: borderWidths.w1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.s8),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: widget.items.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: spacing.s4),
              itemBuilder: (context, index) {
                return _NasikoMenuItem(
                  label: widget.items[index],
                  isSelected: widget.selectedIndex == index,
                  onTap: () {
                    widget.onItemSelected(index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a popup menu at a specific position.
///
/// Returns the selected index when an item is tapped.
Future<int?> showNasikoPopupMenu({
  required BuildContext context,
  required RelativeRect position,
  required List<String> items,
  required int selectedIndex,
  double width = 200.0,
  double maxHeight = 220.0,
}) {
  return showMenu<int>(
    context: context,
    position: position,
    elevation: 0,
    color: Colors.transparent,
    shape: const RoundedRectangleBorder(),
    items: [
      PopupMenuItem<int>(
        enabled: false,
        padding: EdgeInsets.zero,
        child: NasikoPopupMenu(
          items: items,
          selectedIndex: selectedIndex,
          onItemSelected: (index) {
            Navigator.of(context).pop(index);
          },
          width: width,
          maxHeight: maxHeight,
        ),
      ),
    ],
  );
}
