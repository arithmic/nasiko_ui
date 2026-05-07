import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

class NasikoPopupMenuItemData {
  const NasikoPopupMenuItemData({
    required this.label,
    this.icon,
    this.isDestructive = false,
  });

  final String label;
  final HugeIconsType? icon;
  final bool isDestructive;
}

class NasikoPopupMenu extends StatefulWidget {
  const NasikoPopupMenu({
    super.key,
    required this.child,
    required this.items,
    required this.onItemSelected,
    this.width,
    this.maxHeight = 220.0,
    this.enabled = true,
    this.offset,
  });

  final Widget child;
  final List<NasikoPopupMenuItemData> items;
  final ValueChanged<int> onItemSelected;

  final double? width;
  final double maxHeight;
  final bool enabled;

  /// Optional offset from anchor bottom-left.
  /// If null -> defaults to spacing.s4 below.
  final Offset? offset;

  @override
  State<NasikoPopupMenu> createState() => _NasikoPopupMenuState();
}

class _NasikoPopupMenuState extends State<NasikoPopupMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  double? _resolvedMenuWidth;
  double _resolvedYOffset = 0;
  double _anchorHeight = 0;

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeMenu();
      return;
    }

    _openMenu();
  }

  void _openMenu() {
    if (!widget.enabled) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final spacing = context.spacing;
    final size = renderBox.size;
    final overlay = Overlay.of(context);

    _resolvedMenuWidth = widget.width ?? size.width;
    _resolvedYOffset = widget.offset?.dy ?? spacing.s4;
    _anchorHeight = size.height;

    final globalPosition = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    // Vertical: open upward if there isn't enough space below.
    final spaceBelow =
        screenSize.height - (globalPosition.dy + _anchorHeight);
    final openUpward = spaceBelow < widget.maxHeight + _resolvedYOffset;
    final yOffset = openUpward
        ? -_resolvedYOffset
        : _anchorHeight + _resolvedYOffset;

    // Horizontal: clamp so the menu never overflows the right (or left) edge.
    double xOffset = widget.offset?.dx ?? 0;
    final menuRight = globalPosition.dx + xOffset + _resolvedMenuWidth!;
    if (menuRight > screenSize.width) {
      xOffset -= menuRight - screenSize.width;
    }
    if (globalPosition.dx + xOffset < 0) {
      xOffset = -globalPosition.dx;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeMenu,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(xOffset, yOffset),
              child: Material(
                color: Colors.transparent,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: FractionalTranslation(
                    translation: openUpward
                        ? const Offset(0, -1)
                        : Offset.zero,
                    child: _NasikoPopupMenuSurface(
                      items: widget.items,
                      width: _resolvedMenuWidth!,
                      maxHeight: widget.maxHeight,
                      onItemSelected: (index) {
                        _removeMenu();
                        widget.onItemSelected(index);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void didUpdateWidget(covariant NasikoPopupMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled && _overlayEntry != null) {
      _removeMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        // ← add this
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _toggleMenu,
          child: AbsorbPointer(child: widget.child),
        ),
      ),
    );
  }
}

class _NasikoPopupMenuSurface extends StatefulWidget {
  const _NasikoPopupMenuSurface({
    required this.items,
    required this.onItemSelected,
    required this.width,
    required this.maxHeight,
  });

  final List<NasikoPopupMenuItemData> items;
  final ValueChanged<int> onItemSelected;
  final double width;
  final double maxHeight;

  @override
  State<_NasikoPopupMenuSurface> createState() =>
      _NasikoPopupMenuSurfaceState();
}

class _NasikoPopupMenuSurfaceState extends State<_NasikoPopupMenuSurface> {
  late final ScrollController _scrollController;
  bool _isScrollable = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollability();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NasikoPopupMenuSurface oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.length != widget.items.length ||
        oldWidget.maxHeight != widget.maxHeight ||
        oldWidget.width != widget.width) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollability();
      });
    }
  }

  void _updateScrollability() {
    if (!_scrollController.hasClients || !mounted) {
      return;
    }

    final isScrollable = _scrollController.position.maxScrollExtent > 0;
    if (isScrollable != _isScrollable) {
      setState(() {
        _isScrollable = isScrollable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;

    const double scrollbarThickness = 4.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.width,
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        decoration: BoxDecoration(
          color: const Color(0xFF242628),
          borderRadius: BorderRadius.circular(radii.r16),
          border: Border.all(color: colors.borderPrimary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: spacing.s16,
              offset: Offset(0, spacing.s4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.s12),
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (notification) {
              final isScrollable = notification.metrics.maxScrollExtent > 0;
              if (isScrollable != _isScrollable) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _isScrollable = isScrollable;
                    });
                  }
                });
              }
              return false;
            },
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.separated(
                padding: EdgeInsets.only(
                  right: _isScrollable ? spacing.s4 + scrollbarThickness : 0,
                ),
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: widget.items.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: spacing.s4),
                itemBuilder: (context, index) {
                  final item = widget.items[index];

                  return _NasikoMenuItem(
                    label: item.label,
                    icon: item.icon,
                    isDestructive: item.isDestructive,
                    onTap: () => widget.onItemSelected(index),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NasikoMenuItem extends StatefulWidget {
  const _NasikoMenuItem({
    required this.label,
    required this.onTap,
    required this.isDestructive,
    this.icon,
  });

  final String label;
  final HugeIconsType? icon;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  State<_NasikoMenuItem> createState() => _NasikoMenuItemState();
}

class _NasikoMenuItemState extends State<_NasikoMenuItem> {
  bool _isHovered = false;
  bool _isFocused = false;

  void _setHovered(bool value) {
    if (value != _isHovered) {
      setState(() => _isHovered = value);
    }
  }

  void _setFocused(bool value) {
    if (value != _isFocused) {
      setState(() => _isFocused = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final typography = context.typography;
    final spacing = context.spacing;
    final isHighlighted = _isHovered || _isFocused;

    final foregroundColor = widget.isDestructive
        ? colors.foregroundError
        : const Color(0xFFFFFFFF);

    final textStyle = typography.bodySecondary.copyWith(color: foregroundColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: FocusableActionDetector(
        onShowFocusHighlight: _setFocused,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFF6D737A)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(radii.r8),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s12,
                vertical: spacing.s8,
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    HugeIcon(
                      icon: widget.icon!,
                      size: 20,
                      color: foregroundColor,
                    ),
                    SizedBox(width: spacing.s8),
                  ],
                  Expanded(
                    child: Text(
                      widget.label,
                      style: textStyle,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
