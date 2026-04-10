import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

/// An action that appears in the trailing popup menu of a [SectionItem].
class SectionItemAction {
  const SectionItemAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  /// Label shown in the popup menu row.
  final String label;

  /// Icon shown in the popup menu row.
  final HugeIconsType? icon;

  /// Called when this action is selected.
  final VoidCallback onTap;

  /// When true the label and icon are rendered in the error/destructive colour.
  final bool isDestructive;
}

/// A model representing a single section item.
class SectionItem {
  const SectionItem({
    required this.label,
    this.id,
    this.icon,
    this.onTap,
    this.menuActions,
    this.maxLines,
  });

  /// The display label for this item.
  final String label;

  /// Optional stable identifier used for ID-based selection via
  /// [Section.selectedChildId]. Falls back to [label] when absent.
  final String? id;

  /// Optional leading icon for this item.
  final HugeIconsType? icon;

  /// Callback when the item row is tapped.
  final VoidCallback? onTap;

  /// When non-empty a three-dot icon appears on hover / selection and opens a
  /// popup menu containing these actions.
  final List<SectionItemAction>? menuActions;

  /// Maximum lines for the label text.
  final int? maxLines;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section widget
// ─────────────────────────────────────────────────────────────────────────────

/// A navigation section component for sidebars.
///
/// Supports two modes:
/// 1. **Simple** – tapping navigates; shows selected state via [isSelected].
/// 2. **Expandable** – tapping toggles inline children; selected child is
///    tracked via [selectedChild] (label) or [selectedChildId] (id).
///
/// Expandable sections also support [isLoading] and [emptyMessage] so callers
/// never need to build their own expandable wrappers.
class Section extends StatefulWidget {
  const Section({
    super.key,
    required this.label,
    required this.icon,
    this.maxLines,
    this.children,
    this.selectedChild,
    this.selectedChildId,
    this.isSelected = false,
    this.onTap,
    this.onChildTap,
    this.backgroundColor,
    this.expandedBgColor,
    this.isDisabled = false,
    this.isLoading = false,
    this.emptyMessage,
  });

  /// The display label for this section.
  final String label;

  /// Maximum lines for the section label.
  final int? maxLines;

  /// Leading icon for this section.
  final HugeIconsType? icon;

  /// Optional list of child items (makes this section expandable).
  final List<SectionItem>? children;

  /// The label of the currently selected child item (label-based matching).
  /// Ignored when [selectedChildId] is provided.
  final String? selectedChild;

  /// The id of the currently selected child item (id-based matching).
  /// Takes precedence over [selectedChild].
  final String? selectedChildId;

  /// Whether this section is currently selected (non-expandable sections only).
  final bool isSelected;

  /// Callback when section header is tapped (non-expandable sections only).
  final VoidCallback? onTap;

  /// Callback when a child item is tapped; receives the child's [SectionItem.id]
  /// if set, otherwise its [SectionItem.label].
  final ValueChanged<String>? onChildTap;

  /// Background colour for the collapsed expandable container.
  final Color? backgroundColor;

  /// Background colour when the expandable container is expanded.
  final Color? expandedBgColor;

  /// Whether this section is disabled.
  final bool isDisabled;

  /// When true an expandable section shows a loading indicator instead of
  /// children. The section remains expandable even if [children] is empty.
  final bool isLoading;

  /// Message shown inside an expanded section when [children] is empty and
  /// [isLoading] is false. The section remains expandable when this is set.
  final String? emptyMessage;

  /// A section is expandable when it has children, is loading, or has an
  /// empty-state message to show.
  bool get isExpandable =>
      children != null &&
      (children!.isNotEmpty || isLoading || emptyMessage != null);

  @override
  State<Section> createState() => _SectionState();
}

class _SectionState extends State<Section> {
  bool _isExpanded = false;
  bool _isHovered = false;

  bool get _canInteract => !widget.isDisabled;

  @override
  void initState() {
    super.initState();
    _isExpanded = _hasSelectedChild();
  }

  @override
  void didUpdateWidget(Section oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasSelectedChild() && !_isExpanded) {
      setState(() => _isExpanded = true);
    }
  }

  bool _hasSelectedChild() {
    if (!widget.isExpandable) return false;
    final children = widget.children;
    if (children == null || children.isEmpty) return false;

    if (widget.selectedChildId != null) {
      return children.any((c) => (c.id ?? c.label) == widget.selectedChildId);
    }
    if (widget.selectedChild != null) {
      return children.any((c) => c.label == widget.selectedChild);
    }
    return false;
  }

  bool _isChildSelected(SectionItem child) {
    if (widget.selectedChildId != null) {
      return (child.id ?? child.label) == widget.selectedChildId;
    }
    return child.label == widget.selectedChild;
  }

  void _toggleExpanded() {
    if (!_canInteract) return;
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

    if (widget.isExpandable) {
      final bool hasSelectedChild = _hasSelectedChild();

      return Container(
        decoration: BoxDecoration(
          color: hasSelectedChild && !_isExpanded
              ? colors.backgroundSecondaryBrand
              : _isExpanded
              ? (widget.expandedBgColor ?? colors.backgroundBase)
              : (widget.backgroundColor ?? colors.backgroundBase),
          borderRadius: BorderRadius.circular(radii.r12),
          border: Border.all(
            color: hasSelectedChild && !_isExpanded
                ? colors.borderSecondary
                : (_isExpanded ? colors.borderPrimary : Colors.transparent),
            width: borderWidths.w1,
          ),
        ),
        padding: EdgeInsets.all(spacing.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────
            GestureDetector(
              onTap: _canInteract ? _toggleExpanded : null,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  children: [
                    HugeIcon(
                      icon: widget.icon!,
                      size: iconSizes.s,
                      color: widget.isDisabled
                          ? colors.foregroundDisabled
                          : hasSelectedChild
                          ? colors.foregroundPrimary
                          : colors.foregroundIconTertiary,
                    ),
                    SizedBox(width: spacing.s8),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing.s4),
                        child: Text(
                          widget.label,
                          maxLines: widget.maxLines,
                          style: typography.bodySecondaryBold.copyWith(
                            color: widget.isDisabled
                                ? colors.foregroundDisabled
                                : colors.foregroundPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.s8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: iconSizes.s,
                        color: widget.isDisabled
                            ? colors.foregroundDisabled
                            : colors.foregroundIconPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expanded content ──────────────────────────────────────────
            if (_isExpanded) ...[
              SizedBox(height: spacing.s8),
              if (widget.isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s12,
                    vertical: spacing.s8,
                  ),
                  child: Text(
                    'Loading...',
                    style: typography.bodySecondary.copyWith(
                      color: colors.foregroundSecondary,
                    ),
                  ),
                )
              else if (widget.children == null || widget.children!.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s12,
                    vertical: spacing.s8,
                  ),
                  child: Text(
                    widget.emptyMessage ?? '',
                    style: typography.bodySecondary.copyWith(
                      color: colors.foregroundSecondary,
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.children!.map((child) {
                    return _SectionChildItem(
                      item: child,
                      isSelected: _isChildSelected(child),
                      onTap: () {
                        child.onTap?.call();
                        widget.onChildTap?.call(child.id ?? child.label);
                      },
                      isDisabled: widget.isDisabled,
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      );
    }

    // ── Non-expandable section ─────────────────────────────────────────────
    final bool showSelectedState = widget.isSelected;

    Color backgroundColor;
    Color borderColor;
    if (showSelectedState) {
      backgroundColor = colors.backgroundSecondaryBrand;
      borderColor = colors.foregroundBrand;
    } else if (_isHovered && _canInteract) {
      backgroundColor = Colors.transparent;
      borderColor = colors.borderSecondary;
    } else {
      backgroundColor = Colors.transparent;
      borderColor = Colors.transparent;
    }

    return MouseRegion(
      cursor: _canInteract
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: _canInteract ? (_) => setState(() => _isHovered = true) : null,
      onExit: _canInteract ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: _canInteract ? _toggleExpanded : null,
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
              HugeIcon(
                icon: widget.icon!,
                size: iconSizes.s,
                color: widget.isDisabled
                    ? colors.foregroundDisabled
                    : showSelectedState
                    ? colors.foregroundPrimary
                    : colors.foregroundIconTertiary,
              ),
              SizedBox(width: spacing.s8),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: widget.maxLines,
                  style: typography.bodySecondaryBold.copyWith(
                    color: widget.isDisabled
                        ? colors.foregroundDisabled
                        : colors.foregroundPrimary,
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

// ─────────────────────────────────────────────────────────────────────────────
// Internal child item widget
// ─────────────────────────────────────────────────────────────────────────────

class _SectionChildItem extends StatefulWidget {
  const _SectionChildItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.isDisabled,
  });

  final SectionItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  State<_SectionChildItem> createState() => _SectionChildItemState();
}

class _SectionChildItemState extends State<_SectionChildItem> {
  bool _isHovered = false;

  /// Guards against the row's onTap firing when the user clicks the popup menu
  /// trigger, since pointer-down on the menu button precedes the tap event.
  bool _isMenuPointerDown = false;

  bool get _canInteract => !widget.isDisabled;
  bool get _hasMenu =>
      widget.item.menuActions != null && widget.item.menuActions!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;
    final borderWidths = context.borderWidth;

    Color backgroundColor;
    Color borderColor;
    if (widget.isDisabled) {
      backgroundColor = colors.backgroundSurface;
      borderColor = colors.borderDisabled;
    } else if (widget.isSelected) {
      backgroundColor = colors.backgroundSecondaryBrand;
      borderColor = Colors.transparent;
    } else if (_isHovered) {
      backgroundColor = Colors.transparent;
      borderColor = colors.borderSecondary;
    } else {
      backgroundColor = Colors.transparent;
      borderColor = Colors.transparent;
    }

    final showTrailing =
        _hasMenu && (_isHovered || widget.isSelected) && _canInteract;

    return MouseRegion(
      cursor: _canInteract
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: _canInteract ? (_) => setState(() => _isHovered = true) : null,
      onExit: _canInteract ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _canInteract
            ? () {
                if (_isMenuPointerDown) return;
                widget.onTap();
              }
            : null,
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.label,
                  maxLines: widget.item.maxLines,
                  overflow: widget.item.maxLines != null
                      ? TextOverflow.ellipsis
                      : null,
                  style: widget.isSelected
                      ? typography.bodySecondaryBold.copyWith(
                          color: widget.isDisabled
                              ? colors.foregroundDisabled
                              : colors.foregroundPrimary,
                        )
                      : typography.bodySecondary.copyWith(
                          color: widget.isDisabled
                              ? colors.foregroundDisabled
                              : colors.foregroundSecondary,
                        ),
                ),
              ),
              if (showTrailing)
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _isMenuPointerDown = true,
                  onPointerUp: (_) => _isMenuPointerDown = false,
                  onPointerCancel: (_) => _isMenuPointerDown = false,
                  child: _MenuButton(actions: widget.item.menuActions!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trailing popup menu button
// ─────────────────────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.actions});

  final List<SectionItemAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    return PopupMenuButton<int>(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 130),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radii.r8),
      ),
      color: colors.backgroundBase,
      elevation: 4,
      position: PopupMenuPosition.under,
      onSelected: (index) => actions[index].onTap(),
      itemBuilder: (_) => [
        for (int i = 0; i < actions.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                HugeIcon(
                  icon: actions[i].icon!,
                  color: actions[i].isDestructive
                      ? colors.foregroundError
                      : colors.foregroundPrimary,
                ),
                SizedBox(width: spacing.s8),
                Text(
                  actions[i].label,
                  style: typography.bodySecondary.copyWith(
                    color: actions[i].isDestructive
                        ? colors.foregroundError
                        : colors.foregroundPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: EdgeInsets.only(left: spacing.s4),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedMoreHorizontal,
          size: iconSizes.s,
          color: colors.foregroundSecondary,
        ),
      ),
    );
  }
}
