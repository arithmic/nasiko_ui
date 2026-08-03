import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../internal/overlay_reveal.dart';

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
  OverlayEntry? _overlayEntry;

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
    final anchorSize = renderBox.size;

    // Convert anchor position into the overlay's coordinate space rather than
    // screen space. Positioned() inside the overlay uses overlay-local coords,
    // which can differ from screen coords when the overlay is inside a
    // Navigator/Scaffold with an offset (common in Flutter web).
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox;
    final anchor = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final overlaySize = overlayBox.size;

    final gap = widget.offset?.dy ?? spacing.s4;
    final menuWidth = widget.width ?? anchorSize.width;

    // ── Vertical ──────────────────────────────────────────────────────────────
    // Open below by default; flip upward when there isn't enough space below.
    final spaceBelow = overlaySize.height - (anchor.dy + anchorSize.height);
    final openUpward = spaceBelow < widget.maxHeight + gap;

    double? top, bottom;
    if (openUpward) {
      // Menu bottom aligns with anchor bottom — grows upward.
      bottom = overlaySize.height - (anchor.dy + anchorSize.height);
    } else {
      // Menu top aligns with anchor top — grows downward (industry standard).
      top = anchor.dy;
    }

    // ── Horizontal ────────────────────────────────────────────────────────────
    // Right-align menu's right edge to anchor's right edge so it opens to the
    // LEFT — natural for trailing "⋮" buttons.
    // Flip to left-align only if that would clip the left edge.
    final anchorRight = anchor.dx + anchorSize.width;
    final overflowsLeft = anchorRight - menuWidth < 0;

    double? left, right;
    if (overflowsLeft) {
      left = 0;
    } else {
      right = overlaySize.width - anchorRight;
    }

    final themeData = Theme.of(context).copyWith(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
    final surface = _NasikoPopupMenuSurface(
      items: widget.items,
      width: menuWidth,
      maxHeight: widget.maxHeight,
      onItemSelected: (index) {
        _removeMenu();
        widget.onItemSelected(index);
      },
    );

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeMenu,
              child: const SizedBox.expand(),
            ),
            Positioned(
              top: top,
              bottom: bottom,
              left: left,
              right: right,
              // Entrance only — removal via OverlayEntry.remove() stays
              // instant, matching the subtle & fast motion personality.
              child: NasikoOverlayReveal(
                // Slide in the direction the menu opens.
                slideFrom: Offset(0, openUpward ? 4 : -4),
                child: Material(
                  color: Colors.transparent,
                  child: Theme(data: themeData, child: surface),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _toggleMenu,
        child: AbsorbPointer(child: widget.child),
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
          child: AnimatedContainer(
            duration: context.motion.hover,
            curve: context.motion.enter,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? colors.foregroundSecondary
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
