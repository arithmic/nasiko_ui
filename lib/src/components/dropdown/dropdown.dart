import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A model representing a single dropdown item.
class NasikoDropdownItem<T> {
  const NasikoDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.shortcut,
  });

  /// The value associated with this item.
  final T value;

  /// The display label for this item.
  final String label;

  /// Optional leading icon for this item.
  final IconData? icon;

  /// Optional keyboard shortcut text (e.g., "⌘⇧B").
  final String? shortcut;
}

/// A dropdown select component with expandable menu.
///
/// Displays a trigger button that opens a scrollable list of options.
/// Supports optional leading icons, keyboard shortcuts, and selection state.
class NasikoDropdown<T> extends StatefulWidget {
  const NasikoDropdown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.leadingIcon,
    this.hint = 'Select an option',
    this.maxHeight = 300.0,
    this.enabled = true,
  });

  /// The list of dropdown items to display.
  final List<NasikoDropdownItem<T>> items;

  /// The currently selected value.
  final T? selectedValue;

  /// Callback when selection changes.
  final ValueChanged<T> onChanged;

  /// Optional leading icon for the trigger button.
  final IconData? leadingIcon;

  /// Hint text when no item is selected.
  final String hint;

  /// Maximum height of the dropdown menu.
  final double maxHeight;

  /// Whether the dropdown is enabled.
  final bool enabled;

  @override
  State<NasikoDropdown<T>> createState() => _NasikoDropdownState<T>();
}

class _NasikoDropdownState<T> extends State<NasikoDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _closeDropdown() {
    _animationController.reverse().then((_) {
      _removeOverlay();
      setState(() => _isOpen = false);
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectItem(NasikoDropdownItem<T> item) {
    widget.onChanged(item.value);
    _closeDropdown();
  }

  NasikoDropdownItem<T>? get _selectedItem {
    if (widget.selectedValue == null) return null;
    try {
      return widget.items.firstWhere(
        (item) => item.value == widget.selectedValue,
      );
    } catch (_) {
      return null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        final colors = this.context.colors;
        final spacing = this.context.spacing;
        final radii = this.context.radius;
        final borderWidths = this.context.borderWidth;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeDropdown,
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + spacing.s4),
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when tapping menu
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: SizeTransition(
                      sizeFactor: _expandAnimation,
                      axisAlignment: -1,
                      child: Material(
                        elevation: 0,
                        color: Colors.transparent,
                        child: Container(
                          width: size.width,
                          constraints: BoxConstraints(
                            maxHeight: widget.maxHeight,
                          ),
                          decoration: BoxDecoration(
                            color: colors.backgroundGroup,
                            borderRadius: BorderRadius.circular(radii.r12),
                            border: Border.all(
                              color: colors.borderPrimary,
                              width: borderWidths.w1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(radii.r12),
                            child: Scrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              child: ListView.builder(
                                controller: _scrollController,
                                shrinkWrap: true,
                                padding: EdgeInsets.all(spacing.s8),
                                itemCount: widget.items.length,
                                itemBuilder: (context, index) {
                                  final item = widget.items[index];
                                  final isSelected =
                                      item.value == widget.selectedValue;

                                  return _DropdownMenuItem<T>(
                                    item: item,
                                    isSelected: isSelected,
                                    onTap: () => _selectItem(item),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final borderWidths = context.borderWidth;

    final selectedItem = _selectedItem;
    final displayLabel = selectedItem?.label ?? widget.hint;

    final effectiveOpacity = widget.enabled ? 1.0 : 0.5;
    final borderColor = _isOpen ? colors.borderSecondary : colors.borderPrimary;
    final backgroundColor = _isOpen
        ? colors.backgroundGroup
        : colors.backgroundSurface;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Opacity(
        opacity: effectiveOpacity,
        child: GestureDetector(
          onTap: _toggleDropdown,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s12,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radii.r12),
              border: Border.all(color: borderColor, width: borderWidths.w1),
            ),
            child: Row(
              children: [
                // Leading icon
                if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: iconSizes.s,
                    color: colors.foregroundIconPrimary,
                  ),
                  SizedBox(width: spacing.s8),
                ],

                // Label
                Expanded(
                  child: Text(
                    displayLabel,
                    style: typography.bodyPrimaryBold.copyWith(
                      color: colors.foregroundPrimary,
                    ),
                  ),
                ),

                // Keyboard shortcut badge (if selected item has one)
                if (selectedItem?.shortcut != null) ...[
                  SizedBox(width: spacing.s8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.s8,
                      vertical: spacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.backgroundSurface,
                      borderRadius: BorderRadius.circular(radii.r4),
                    ),
                    child: Text(
                      selectedItem!.shortcut!,
                      style: typography.bodyTertiary.copyWith(
                        color: colors.foregroundSecondary,
                      ),
                    ),
                  ),
                ],

                SizedBox(width: spacing.s8),

                // Chevron icon
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: iconSizes.s,
                    color: colors.foregroundIconPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal dropdown menu item widget.
class _DropdownMenuItem<T> extends StatefulWidget {
  const _DropdownMenuItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NasikoDropdownItem<T> item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_DropdownMenuItem<T>> createState() => _DropdownMenuItemState<T>();
}

class _DropdownMenuItemState<T> extends State<_DropdownMenuItem<T>> {
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
      backgroundColor = colors.backgroundSurfaceHover;
      borderColor = Colors.transparent;
    } else {
      backgroundColor = Colors.transparent;
      borderColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(bottom: spacing.s4),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s12,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radii.r8),
            border: Border.all(color: borderColor, width: borderWidths.w1),
          ),
          child: Text(
            widget.item.label,
            style: typography.bodySecondaryBold.copyWith(
              color: widget.isSelected
                  ? colors.foregroundPrimary
                  : colors.foregroundSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
