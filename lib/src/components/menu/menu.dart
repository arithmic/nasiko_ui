// lib/src/components/menu/nasiko_menu.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Menu item data model (icon + label).
class NasikoPopupMenuItemData {
  const NasikoPopupMenuItemData({
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;

  /// Optional styling for destructive actions (Logout, Delete, etc.)
  final bool isDestructive;
}

/// A single public widget:
/// - Wraps any child
/// - Shows Nasiko popup menu on tap
/// - Handles overlay + outside tap close
/// - Supports icon + text items
class NasikoPopupMenu extends StatefulWidget {
  const NasikoPopupMenu({
    super.key,
    required this.child,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.width,
    this.maxHeight = 220.0,
    this.enabled = true,
    this.offset,
    this.barrierColor,
    this.closeOnScroll = true,
    this.closeOnEscape = true,
  });

  final Widget child;
  final List<NasikoPopupMenuItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  final double? width;
  final double maxHeight;
  final Offset? offset;

  final bool enabled;
  final Color? barrierColor;

  /// Close menu when any scroll happens in the page.
  final bool closeOnScroll;

  /// Close menu when ESC key is pressed (web/desktop).
  final bool closeOnEscape;

  @override
  State<NasikoPopupMenu> createState() => _NasikoPopupMenuState();
}

class _NasikoPopupMenuState extends State<NasikoPopupMenu> {
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _barrierEntry;
  OverlayEntry? _menuEntry;

  bool get _isOpen => _menuEntry != null;

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  void _closeMenu() {
    _menuEntry?.remove();
    _menuEntry = null;

    _barrierEntry?.remove();
    _barrierEntry = null;
  }

  void _toggleMenu() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final overlayState = Overlay.of(context);

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final spacing = context.spacing;

    final dx = widget.offset?.dx ?? 0;
    final dy = widget.offset?.dy ?? spacing.s4;

    final menuWidth = widget.width ?? size.width;

    // Barrier entry: outside tap + optional scroll close + ESC close
    _barrierEntry = OverlayEntry(
      builder: (context) {
        Widget barrier = Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _closeMenu,
            child: ColoredBox(color: widget.barrierColor ?? Colors.transparent),
          ),
        );

        // Close on scroll anywhere in the page
        if (widget.closeOnScroll) {
          barrier = NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Close on any scroll update/user scroll
              if (notification is ScrollUpdateNotification ||
                  notification is UserScrollNotification) {
                _closeMenu();
              }
              return false;
            },
            child: barrier,
          );
        }

        // Close on ESC (desktop/web)
        if (widget.closeOnEscape) {
          barrier = Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                _closeMenu();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: barrier,
          );
        }

        return barrier;
      },
    );

    // Menu entry: positioned relative to anchor
    _menuEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(dx, size.height + dy),
                child: Material(
                  color: Colors.transparent,
                  child: _NasikoPopupMenuSurface(
                    items: widget.items,
                    selectedIndex: widget.selectedIndex,
                    width: menuWidth,
                    maxHeight: widget.maxHeight,
                    onItemSelected: (index) {
                      _closeMenu();

                      // Safe for navigation (logout / pushReplacement / etc.)
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        widget.onItemSelected(index);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlayState.insert(_barrierEntry!);
    overlayState.insert(_menuEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _toggleMenu,
        child: widget.child,
      ),
    );
  }
}

/// Internal surface widget (scrollable menu container).
class _NasikoPopupMenuSurface extends StatefulWidget {
  const _NasikoPopupMenuSurface({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.width,
    required this.maxHeight,
  });

  final List<NasikoPopupMenuItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final double width;
  final double maxHeight;

  @override
  State<_NasikoPopupMenuSurface> createState() =>
      _NasikoPopupMenuSurfaceState();
}

class _NasikoPopupMenuSurfaceState extends State<_NasikoPopupMenuSurface> {
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

    const double scrollbarThickness = 6.0;

    return Container(
      width: widget.width,
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: colors.backgroundGroup,
        borderRadius: BorderRadius.circular(radii.r8),
        border: Border.all(color: colors.borderPrimary, width: borderWidths.w1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, spacing.s4h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: spacing.s8w,
          top: spacing.s8h,
          bottom: spacing.s8h,
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: ListView.separated(
            padding: EdgeInsets.only(right: spacing.s8w + scrollbarThickness),
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: widget.items.length,
            separatorBuilder: (context, index) => SizedBox(height: spacing.s4h),
            itemBuilder: (context, index) {
              final item = widget.items[index];

              return _NasikoMenuItem(
                label: item.label,
                icon: item.icon,
                isSelected: widget.selectedIndex == index,
                isDestructive: item.isDestructive,
                onTap: () => widget.onItemSelected(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Internal menu row widget (icon left, text next).
class _NasikoMenuItem extends StatefulWidget {
  const _NasikoMenuItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDestructive,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  State<_NasikoMenuItem> createState() => _NasikoMenuItemState();
}

class _NasikoMenuItemState extends State<_NasikoMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final typography = context.typography;
    final spacing = context.spacing;
    final borderWidths = context.borderWidth;

    Color backgroundColor;
    Color borderColor;

    if (widget.isSelected) {
      backgroundColor = colors.backgroundSecondaryBrand;
      borderColor = colors.borderSecondary;
    } else if (_isHovered) {
      backgroundColor = colors.backgroundSecondaryBrandHover;
      borderColor = Colors.transparent;
    } else {
      backgroundColor = Colors.transparent;
      borderColor = Colors.transparent;
    }

    final foregroundColor = widget.isDestructive
        ? colors.foregroundError
        : colors.foregroundSecondary;

    final textStyle = widget.isSelected
        ? typography.bodySecondaryBold
        : typography.bodySecondary.copyWith(color: foregroundColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: borderWidths.w1),
          borderRadius: BorderRadius.circular(radii.r8),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(radii.r8),
          splashColor: colors.backgroundBrandSubtle.withValues(alpha: 0.5),
          highlightColor: colors.backgroundBrandSubtle.withValues(alpha: 0.5),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s12w,
              vertical: spacing.s8h,
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: spacing.s16w, color: foregroundColor),
                SizedBox(width: spacing.s8w),
                Expanded(child: Text(widget.label, style: textStyle)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
