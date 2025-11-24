// lib/src/components/accordion/nasiko_accordion.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A data class for a single item in a [NasikoAccordion].
class NasikoAccordionItem {
  const NasikoAccordionItem({required this.title, required this.content});

  /// The title text displayed in the header.
  final String title;

  /// The widget to display when the item is expanded.
  final Widget content;
}

/// An accordion component that displays a list of expandable items.
///
/// It can be configured to allow only one item to be open at a time
/// (standard accordion) or multiple items.
class NasikoAccordion extends StatefulWidget {
  const NasikoAccordion({
    super.key,
    required this.items,
    this.allowMultipleOpen = false,
    this.initialOpenIndex = 0,
    this.initialOpenIndices,
  });

  /// The list of [NasikoAccordionItem] to display.
  final List<NasikoAccordionItem> items;

  /// If `true`, multiple items can be expanded at once.
  /// If `false` (default), expanding one item will close any other open item.
  final bool allowMultipleOpen;

  /// For single-open mode, the index of the item that should be
  /// open when the widget is first built.
  final int? initialOpenIndex;

  /// For multi-open mode, the set of indices that should be
  /// open when the widget is first built.
  final Set<int>? initialOpenIndices;

  @override
  State<NasikoAccordion> createState() => _NasikoAccordionState();
}

class _NasikoAccordionState extends State<NasikoAccordion> {
  // For single-open mode
  int? _selectedIndex;

  // For multi-open mode
  late Set<int> _openIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.allowMultipleOpen ? null : widget.initialOpenIndex;
    _openIndices = widget.allowMultipleOpen
        ? Set<int>.from(
            widget.initialOpenIndices ?? {},
          ) // Creates a mutable copy
        : {};
  }

  void _onItemTapped(int index) {
    setState(() {
      if (widget.allowMultipleOpen) {
        // Toggle logic for multi-open
        if (_openIndices.contains(index)) {
          _openIndices.remove(index);
        } else {
          _openIndices.add(index);
        }
      } else {
        // Toggle logic for single-open
        if (_selectedIndex == index) {
          _selectedIndex = null; // Close if tapped again
        } else {
          _selectedIndex = index; // Open new one
        }
      }
    });
  }

  bool _isExpanded(int index) {
    if (widget.allowMultipleOpen) {
      return _openIndices.contains(index);
    }
    return _selectedIndex == index;
  }

  @override
  Widget build(BuildContext context) {
    // We use a Column here, not a ListView, because accordions are
    // typically not virtualized and we want them to size to their content.
    return Column(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          _NasikoAccordionItemWidget(
            title: widget.items[i].title,
            content: widget.items[i].content,
            isExpanded: _isExpanded(i),
            onTap: () => _onItemTapped(i),
          ),
      ],
    );
  }
}

/// The internal stateless widget that renders a single item.
class _NasikoAccordionItemWidget extends StatelessWidget {
  const _NasikoAccordionItemWidget({
    required this.title,
    required this.content,
    required this.isExpanded,
    required this.onTap,
  });

  final String title;
  final Widget content;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final borderWidths = context.borderWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. The clickable header
        InkWell(
          onTap: onTap,
          splashColor: colors.backgroundBrandSubtle.withOpacity(0.5),
          highlightColor: colors.backgroundBrandSubtle.withOpacity(0.5),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.s16),
            child: Row(
              children: [
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: typography.bodyPrimaryBold.copyWith(
                      color: colors.foregroundPrimary,
                    ),
                  ),
                ),
                // Icon
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: colors.foregroundSecondary,
                  size: iconSizes.m, // 24px
                ),
              ],
            ),
          ),
        ),

        // 2. The expandable content area
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: double.infinity,
            child: isExpanded
                ? Padding(
                    // Add padding to content
                    padding: EdgeInsets.only(
                      bottom: spacing.s16,
                      right: spacing.s24, // Keep content from hitting icon
                    ),
                    child: DefaultTextStyle(
                      style: typography.bodySecondary.copyWith(
                        color: colors.foregroundSecondary,
                      ),
                      child: content,
                    ),
                  )
                : const SizedBox(height: 0),
          ),
        ),

        // 3. The divider
        Divider(
          color: colors.borderPrimary,
          height: borderWidths.w1,
          thickness: borderWidths.w1,
        ),
      ],
    );
  }
}
