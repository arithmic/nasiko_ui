import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// The node holding keyboard focus before the menu opened; restored when
  /// the menu closes so focus returns to the trigger's context.
  FocusNode? _previousFocus;

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
    // Capture the currently focused node so it can be restored on close.
    _previousFocus = FocusManager.instance.primaryFocus;

    final surface = _NasikoPopupMenuSurface(
      items: widget.items,
      width: menuWidth,
      maxHeight: widget.maxHeight,
      onDismiss: _removeMenu,
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
    if (_overlayEntry == null) return;
    _overlayEntry!.remove();
    _overlayEntry = null;

    // Restore keyboard focus to wherever it lived before the menu opened
    // (typically the trigger), matching platform menu conventions.
    final previousFocus = _previousFocus;
    _previousFocus = null;
    if (previousFocus != null && previousFocus.canRequestFocus) {
      previousFocus.requestFocus();
    }
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

/// Keyboard focus movement inside the popup menu.
enum _MenuFocusKind { next, previous, first, last }

/// Intent for Up/Down/Home/End focus movement across menu items.
class _MenuFocusIntent extends Intent {
  const _MenuFocusIntent._(this.kind);

  static const _MenuFocusIntent next = _MenuFocusIntent._(_MenuFocusKind.next);
  static const _MenuFocusIntent previous =
      _MenuFocusIntent._(_MenuFocusKind.previous);
  static const _MenuFocusIntent first =
      _MenuFocusIntent._(_MenuFocusKind.first);
  static const _MenuFocusIntent last = _MenuFocusIntent._(_MenuFocusKind.last);

  final _MenuFocusKind kind;
}

class _NasikoPopupMenuSurface extends StatefulWidget {
  const _NasikoPopupMenuSurface({
    required this.items,
    required this.onItemSelected,
    required this.onDismiss,
    required this.width,
    required this.maxHeight,
  });

  final List<NasikoPopupMenuItemData> items;
  final ValueChanged<int> onItemSelected;

  /// Closes the menu without selecting (Escape).
  final VoidCallback onDismiss;

  final double width;
  final double maxHeight;

  @override
  State<_NasikoPopupMenuSurface> createState() =>
      _NasikoPopupMenuSurfaceState();
}

class _NasikoPopupMenuSurfaceState extends State<_NasikoPopupMenuSurface> {
  late final ScrollController _scrollController;
  bool _isScrollable = false;

  /// Owns keyboard focus while the menu is open. Focused explicitly (not just
  /// via `autofocus`) because `autofocus` yields when another node in the
  /// enclosing scope already has primary focus — e.g. a focused text field
  /// on the page behind the menu.
  final FocusScopeNode _menuScopeNode =
      FocusScopeNode(debugLabel: 'NasikoPopupMenu');

  /// One node per item, in item order; drives arrow/Home/End navigation.
  List<FocusNode> _itemFocusNodes = const <FocusNode>[];

  static const Map<ShortcutActivator, Intent> _menuShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown): _MenuFocusIntent.next,
    SingleActivator(LogicalKeyboardKey.arrowUp): _MenuFocusIntent.previous,
    SingleActivator(LogicalKeyboardKey.home): _MenuFocusIntent.first,
    SingleActivator(LogicalKeyboardKey.end): _MenuFocusIntent.last,
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _itemFocusNodes = _generateFocusNodes(0, widget.items.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollability();
      if (mounted) {
        _menuScopeNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final node in _itemFocusNodes) {
      node.dispose();
    }
    _menuScopeNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NasikoPopupMenuSurface oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.length != widget.items.length) {
      _syncFocusNodes();
    }

    if (oldWidget.items.length != widget.items.length ||
        oldWidget.maxHeight != widget.maxHeight ||
        oldWidget.width != widget.width) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollability();
      });
    }
  }

  List<FocusNode> _generateFocusNodes(int startIndex, int count) {
    return List<FocusNode>.generate(
      count,
      (index) => FocusNode(
        debugLabel: 'NasikoPopupMenu item ${startIndex + index}',
      ),
    );
  }

  void _syncFocusNodes() {
    final target = widget.items.length;
    final current = _itemFocusNodes.length;
    if (current == target) return;

    final nodes = List<FocusNode>.of(_itemFocusNodes);
    if (current < target) {
      nodes.addAll(_generateFocusNodes(current, target - current));
    } else {
      final removed = nodes.sublist(target);
      nodes.removeRange(target, current);
      // Defer disposal until the ListView has rebuilt without these nodes.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final node in removed) {
          node.dispose();
        }
      });
    }
    _itemFocusNodes = nodes;
  }

  void _handleFocusIntent(_MenuFocusIntent intent) {
    if (_itemFocusNodes.isEmpty) return;
    final lastIndex = _itemFocusNodes.length - 1;
    final current = _itemFocusNodes.indexWhere((node) => node.hasFocus);

    final target = switch (intent.kind) {
      // No item focused yet: Down enters at the first item, Up at the last.
      _MenuFocusKind.next =>
        current < 0 || current == lastIndex ? 0 : current + 1,
      _MenuFocusKind.previous =>
        current <= 0 ? lastIndex : current - 1,
      _MenuFocusKind.first => 0,
      _MenuFocusKind.last => lastIndex,
    };
    _focusItem(target);
  }

  void _focusItem(int index) {
    final node = _itemFocusNodes[index];
    if (node.context != null) {
      node.requestFocus();
      return;
    }

    // The ListView builds items lazily, so a far-away item may not have a
    // Focus widget attached yet. Jump the scroll position near the target,
    // then focus it once it has been built.
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      final fraction = _itemFocusNodes.length <= 1
          ? 0.0
          : index / (_itemFocusNodes.length - 1);
      _scrollController.jumpTo(position.maxScrollExtent * fraction);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && node.context != null) {
        node.requestFocus();
      }
    });
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
    const double scrollbarThickness = 4.0;

    return Shortcuts(
      shortcuts: _menuShortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (DismissIntent intent) {
              widget.onDismiss();
              return null;
            },
          ),
          _MenuFocusIntent: CallbackAction<_MenuFocusIntent>(
            onInvoke: (_MenuFocusIntent intent) {
              _handleFocusIntent(intent);
              return null;
            },
          ),
        },
        child: FocusScope(
          node: _menuScopeNode,
          autofocus: true,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            child: _buildSurface(context, scrollbarThickness),
          ),
        ),
      ),
    );
  }

  Widget _buildSurface(BuildContext context, double scrollbarThickness) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;

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
                    focusNode: _itemFocusNodes[index],
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
    required this.focusNode,
    this.icon,
  });

  final String label;
  final HugeIconsType? icon;
  final bool isDestructive;
  final VoidCallback onTap;

  /// Owned by the surface; used for arrow-key traversal across items.
  final FocusNode focusNode;

  @override
  State<_NasikoMenuItem> createState() => _NasikoMenuItemState();
}

class _NasikoMenuItemState extends State<_NasikoMenuItem> {
  bool _isHovered = false;
  bool _isFocused = false;

  static const Map<ShortcutActivator, Intent> _activationShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

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

  void _handleFocusChange(bool focused) {
    if (focused) {
      // Keep keyboard-focused items visible inside the scrollable menu.
      Scrollable.ensureVisible(context, alignment: 0.5);
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

    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: FocusableActionDetector(
            focusNode: widget.focusNode,
            onShowFocusHighlight: _setFocused,
            onFocusChange: _handleFocusChange,
            shortcuts: _activationShortcuts,
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (ActivateIntent intent) {
                  widget.onTap();
                  return null;
                },
              ),
            },
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
        ),
      ),
    );
  }
}
