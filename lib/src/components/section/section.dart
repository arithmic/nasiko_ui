import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A model representing a single section item.
class SectionItem {
  const SectionItem({required this.label, this.icon, this.onTap});

  /// The display label for this item.
  final String label;

  /// Optional leading icon for this item.
  final IconData? icon;

  /// Callback when item is tapped (for non-expandable sections).
  final VoidCallback? onTap;
}

/// A navigation section component for sidebars.
///
/// Supports two types:
/// 1. Simple (non-expandable) - Clicking navigates to a page, shows selected state
/// 2. Expandable - Clicking toggles expand/collapse, shows children inline below
class Section extends StatefulWidget {
  const Section({
    super.key,
    required this.label,
    required this.icon,
    this.children,
    this.selectedChild,
    this.isSelected = false,
    this.onTap,
    this.onChildTap,
  });

  /// The display label for this section.
  final String label;

  /// Leading icon for this section.
  final IconData icon;

  /// Optional list of child items (makes this section expandable).
  final List<SectionItem>? children;

  /// The label of the currently selected child item.
  final String? selectedChild;

  /// Whether this section is currently selected (for non-expandable sections).
  final bool isSelected;

  /// Callback when section is tapped (for non-expandable sections).
  final VoidCallback? onTap;

  /// Callback when a child item is tapped.
  final ValueChanged<String>? onChildTap;

  bool get isExpandable => children != null && children!.isNotEmpty;

  @override
  State<Section> createState() => _SectionState();
}

class _SectionState extends State<Section> {
  bool _isExpanded = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = _hasSelectedChild();
  }

  @override
  void didUpdateWidget(Section oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-expand when a child becomes selected
    if (_hasSelectedChild() && !_isExpanded) {
      setState(() => _isExpanded = true);
    }
  }

  bool _hasSelectedChild() {
    if (!widget.isExpandable || widget.selectedChild == null) return false;
    return widget.children!.any((child) => child.label == widget.selectedChild);
  }

  void _toggleExpanded() {
    if (widget.isExpandable) {
      setState(() => _isExpanded = !_isExpanded);
    } else if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final borderWidths = context.borderWidth;

    // and this is NOT an expandable section
    final bool showSelectedState = widget.isSelected && !widget.isExpandable;

    Color backgroundColor;
    Color borderColor;

    if (showSelectedState) {
      backgroundColor = colors.backgroundSecondaryBrand;
      borderColor = colors.borderSecondary;
    } else if (!widget.isExpandable && _isHovered) {
      // Hover state for non-expandable sections
      backgroundColor = Colors.transparent;
      borderColor = colors.borderSecondary;
    } else {
      backgroundColor = Colors.transparent;
      borderColor = Colors.transparent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main section button
        MouseRegion(
          cursor: (widget.isExpandable || widget.onTap != null)
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: widget.isExpandable
              ? null
              : (_) => setState(() => _isHovered = true),
          onExit: widget.isExpandable
              ? null
              : (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _toggleExpanded,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s8,
                vertical: spacing.s12,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(radii.r8),
                border: Border.all(color: borderColor, width: borderWidths.w1),
              ),
              child: Row(
                children: [
                  // Leading icon
                  Icon(
                    widget.icon,
                    size: iconSizes.s,
                    color: colors.foregroundIconPrimary,
                  ),
                  SizedBox(width: spacing.s12),

                  // Label
                  Expanded(
                    child: Text(
                      widget.label,
                      style: typography.bodyPrimaryBold.copyWith(
                        color: colors.foregroundPrimary,
                      ),
                    ),
                  ),

                  // Chevron icon (only for expandable sections)
                  if (widget.isExpandable) ...[
                    SizedBox(width: spacing.s8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: iconSizes.s,
                        color: colors.foregroundIconPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Expanded children
        if (widget.isExpandable && _isExpanded) ...[
          SizedBox(height: spacing.s4),
          Padding(
            padding: EdgeInsets.only(left: spacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.children!.map((child) {
                return _SectionChildItem(
                  item: child,
                  isSelected: child.label == widget.selectedChild,
                  onTap: () {
                    if (widget.onChildTap != null) {
                      widget.onChildTap!(child.label);
                    }
                    if (child.onTap != null) {
                      child.onTap!();
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

/// Internal child item widget.
class _SectionChildItem extends StatefulWidget {
  const _SectionChildItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final SectionItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SectionChildItem> createState() => _SectionChildItemState();
}

class _SectionChildItemState extends State<_SectionChildItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;
    final borderWidths = context.borderWidth;

    Color backgroundColor;
    Color borderColor;

    if (widget.isSelected) {
      backgroundColor = colors.backgroundSecondaryBrand;
      borderColor = colors.borderSecondary;
    } else if (_isHovered) {
      backgroundColor = Colors.transparent;
      borderColor = colors.borderSecondary;
    } else {
      backgroundColor = Colors.transparent;
      borderColor = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(bottom: spacing.s4),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s8,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radii.r8),
            border: Border.all(color: borderColor, width: borderWidths.w1),
          ),
          child: Text(
            widget.item.label,
            style: widget.isSelected
                ? typography.bodySecondaryBold.copyWith(
                    color: colors.foregroundPrimary,
                  )
                : typography.bodySecondary.copyWith(
                    color: colors.foregroundSecondary,
                  ),
          ),
        ),
      ),
    );
  }
}
