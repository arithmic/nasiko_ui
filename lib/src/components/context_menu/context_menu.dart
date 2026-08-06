// lib/src/components/context_menu/context_menu.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../../tokens/colors/_color_palette.dart' show sand900;
import '../internal/anchored_overlay.dart';

// Trigger detection and positioning:
// - secondary-tap (right-click) opens at the pointer's global position;
//   on Windows the menu opens on secondary-tap **up** instead of down,
//   matching the platform convention;
// - on web, the browser's native context menu is disabled around the
//   secondary tap and re-enabled afterwards (BrowserContextMenu);
// - long-press opens the menu on Android/iOS by default.
// Positioning goes through [NasikoGlobalAnchor], which reuses the shared
// flip-on-overflow + screen-edge clamping pipeline at the pointer point.
//
// Submenus are deliberately NOT supported: reliable nested submenus require
// grouped-hover machinery (trigger and submenu surfaces tracked as one
// hover region) that this component intentionally avoids. It ships flat
// menus (items + dividers); nest actions behind a dedicated item that opens
// a follow-up surface instead.

// ── Visual constants ─────────────────────────────────────────────────────
// Mirrored from NasikoPopupMenu (menu/menu.dart) so both menus render
// identically. Copied (not imported) because those helpers are private to
// menu.dart — keep the two in sync when the menu design changes.

/// Surface color: inverse (dark) card in light mode — a design decision, not
/// a theme bug. Light mode pins the `sand900` palette value; dark mode uses
/// the elevated surface so the menu reads one step lighter than the page.
Color _menuSurfaceColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? sand900
      : context.colors.backgroundSurface;
}

/// Foreground for non-destructive items, matched to [_menuSurfaceColor].
Color _menuItemForegroundColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? context.colors.foregroundConstantWhite
      : context.colors.foregroundPrimary;
}

/// Hover/focus highlight for items, matched to [_menuSurfaceColor].
Color _menuItemHighlightColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? context.colors.foregroundSecondary
      : context.colors.backgroundSurfaceHover;
}

// ── Entries ──────────────────────────────────────────────────────────────

/// An entry in a [NasikoContextMenu]: either a selectable
/// [NasikoContextMenuItem] or a [NasikoContextMenuDivider].
sealed class NasikoContextMenuEntry {
  const NasikoContextMenuEntry();
}

/// A selectable context-menu action.
class NasikoContextMenuItem extends NasikoContextMenuEntry {
  const NasikoContextMenuItem({
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.enabled = true,
    this.onSelected,
  });

  /// Single-line label.
  final String label;

  /// Optional leading icon.
  final HugeIconsType? icon;

  /// Renders the item in the error foreground for destructive actions.
  final bool isDestructive;

  /// Disabled items render dimmed, are skipped by keyboard traversal, and
  /// cannot be activated.
  final bool enabled;

  /// Called after the menu closes when the item is activated.
  final VoidCallback? onSelected;
}

/// A thin horizontal rule separating groups of items.
class NasikoContextMenuDivider extends NasikoContextMenuEntry {
  const NasikoContextMenuDivider();
}

// ── Region widget ────────────────────────────────────────────────────────

/// Shows a context menu when [child] is right-clicked (secondary tap) or —
/// on Android/iOS by default — long-pressed.
///
/// The menu opens at the pointer position via [NasikoGlobalAnchor]: it
/// prefers opening below-right of the pointer and flips/clamps against the
/// screen edges when it doesn't fit. The surface and item visuals are
/// identical to [NasikoPopupMenu].
///
/// Keyboard: the menu opens focused; ArrowUp/ArrowDown/Home/End rove across
/// enabled items (wrapping), Enter/Space activates, and Escape closes the
/// menu and restores focus to wherever it lived before opening. Tapping
/// outside also closes it.
///
/// ```dart
/// NasikoContextMenu(
///   items: [
///     NasikoContextMenuItem(label: 'Rename', onSelected: _rename),
///     const NasikoContextMenuDivider(),
///     NasikoContextMenuItem(
///       label: 'Delete',
///       isDestructive: true,
///       onSelected: _delete,
///     ),
///   ],
///   child: const FileTile(),
/// )
/// ```
class NasikoContextMenu extends StatefulWidget {
  const NasikoContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.enabled = true,
    this.width = 220.0,
    this.maxHeight = 320.0,
    this.longPressEnabled,
  });

  /// The region that reacts to secondary tap / long press.
  final Widget child;

  /// Menu entries, in display order.
  final List<NasikoContextMenuEntry> items;

  /// When false the menu never opens (and closes if currently open).
  final bool enabled;

  /// Fixed menu surface width.
  final double width;

  /// Maximum surface height; the item list scrolls beyond it.
  final double maxHeight;

  /// Whether long-press opens the menu. Defaults to true on Android/iOS
  /// only, where long-press is the platform's context-menu gesture.
  final bool? longPressEnabled;

  @override
  State<NasikoContextMenu> createState() => _NasikoContextMenuState();
}

class _NasikoContextMenuState extends State<NasikoContextMenu> {
  bool _visible = false;

  /// Pointer position in overlay coordinates the menu opens at.
  Offset _position = Offset.zero;

  /// Global pointer position captured at long-press start.
  Offset? _longPressPosition;

  /// Focus owner before the menu opened; restored on close.
  FocusNode? _previousFocus;

  /// Owns keyboard focus while the menu is open. Owned here (not by the
  /// surface) so it survives in-place repositioning and so [_showAt] can
  /// tell whether focus currently lives inside the menu.
  final FocusScopeNode _menuScopeNode =
      FocusScopeNode(debugLabel: 'NasikoContextMenu');

  /// Whether the browser context menu was already disabled by someone else
  /// — if so, never toggle it.
  final bool _browserMenuAlreadyDisabled =
      kIsWeb && !BrowserContextMenu.enabled;

  bool get _longPressEnabled =>
      widget.longPressEnabled ??
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void didUpdateWidget(covariant NasikoContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _visible) _hide(restoreFocus: false);
  }

  @override
  void dispose() {
    _menuScopeNode.dispose();
    super.dispose();
  }

  void _showAt(Offset globalPosition) {
    if (!widget.enabled || widget.items.isEmpty || !mounted) return;

    // Convert the pointer's global position into the overlay's coordinate
    // space — they differ when the Overlay itself is offset (Flutter web).
    final overlayBox = Overlay.of(context).context.findRenderObject();
    final position = overlayBox is RenderBox
        ? overlayBox.globalToLocal(globalPosition)
        : globalPosition;

    // Capture the previous focus owner unless focus already lives inside
    // the menu (right-click reposition while open) — the menu's own nodes
    // must never be a restore target.
    if (_previousFocus == null && !_menuScopeNode.hasFocus) {
      _previousFocus = FocusManager.instance.primaryFocus;
    }
    setState(() {
      _position = position;
      _visible = true;
    });
  }

  void _hide({bool restoreFocus = true}) {
    if (!_visible) return;
    setState(() => _visible = false);

    final previous = _previousFocus;
    _previousFocus = null;
    if (restoreFocus && previous != null && previous.canRequestFocus) {
      previous.requestFocus();
    }
  }

  // Windows opens context menus on button release; everywhere else on
  // press. On web the browser menu is suppressed for the duration of the
  // gesture.
  Future<void> _handleSecondaryTapDown(TapDownDetails details) async {
    if (kIsWeb && !_browserMenuAlreadyDisabled) {
      await BrowserContextMenu.disableContextMenu();
    }
    if (defaultTargetPlatform != TargetPlatform.windows) {
      _showAt(details.globalPosition);
    }
  }

  Future<void> _handleSecondaryTapUp(TapUpDetails details) async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      _showAt(details.globalPosition);
      // Let the re-enable below land after the current pointer event, so
      // the native menu can't sneak in.
      await Future<void>.delayed(Duration.zero);
    }
    if (kIsWeb && !_browserMenuAlreadyDisabled) {
      await BrowserContextMenu.enableContextMenu();
    }
  }

  /// A canceled secondary tap (e.g. right-press then drag) already ran
  /// [_handleSecondaryTapDown]: restore the browser menu so it isn't left
  /// disabled for the rest of the session.
  Future<void> _handleSecondaryTapCancel() async {
    if (kIsWeb && !_browserMenuAlreadyDisabled) {
      await BrowserContextMenu.enableContextMenu();
    }
  }

  void _handleItemSelected(NasikoContextMenuItem item) {
    _hide();
    item.onSelected?.call();
  }

  Widget _buildOverlay(BuildContext context, NasikoAnchorSide side) {
    return TapRegion(
      onTapOutside: (_) => _hide(restoreFocus: false),
      child: _NasikoContextMenuSurface(
        items: widget.items,
        width: widget.width,
        maxHeight: widget.maxHeight,
        scopeNode: _menuScopeNode,
        onDismiss: _hide,
        onItemSelected: _handleItemSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NasikoAnchoredOverlay(
      visible: _visible,
      anchor: NasikoGlobalAnchor(
        _position,
        side: NasikoAnchorSide.bottom,
        alignment: NasikoAnchorAlignment.start,
        screenPadding: context.spacing.s8,
      ),
      overlayBuilder: _buildOverlay,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: _handleSecondaryTapDown,
        onSecondaryTapUp: _handleSecondaryTapUp,
        onSecondaryTapCancel: _handleSecondaryTapCancel,
        onLongPressStart: _longPressEnabled
            ? (details) => _longPressPosition = details.globalPosition
            : null,
        onLongPress: _longPressEnabled
            ? () {
                final position = _longPressPosition;
                _longPressPosition = null;
                if (position != null) _showAt(position);
              }
            : null,
        child: widget.child,
      ),
    );
  }
}

// ── Menu surface ─────────────────────────────────────────────────────────
// Focus roving, scroll handling, and the card treatment are mirrored from
// NasikoPopupMenu's private surface so the two menus stay pixel-identical.

/// Keyboard focus movement inside the menu.
enum _MenuFocusKind { next, previous, first, last }

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

class _NasikoContextMenuSurface extends StatefulWidget {
  const _NasikoContextMenuSurface({
    required this.items,
    required this.onItemSelected,
    required this.onDismiss,
    required this.width,
    required this.maxHeight,
    required this.scopeNode,
  });

  final List<NasikoContextMenuEntry> items;
  final ValueChanged<NasikoContextMenuItem> onItemSelected;

  /// Owned by the region state; focused on open, reused across repositions.
  final FocusScopeNode scopeNode;

  /// Closes the menu without selecting (Escape).
  final VoidCallback onDismiss;

  final double width;
  final double maxHeight;

  @override
  State<_NasikoContextMenuSurface> createState() =>
      _NasikoContextMenuSurfaceState();
}

class _NasikoContextMenuSurfaceState extends State<_NasikoContextMenuSurface> {
  late final ScrollController _scrollController;
  bool _isScrollable = false;

  /// One node per entry (dividers/disabled items simply never attach theirs).
  List<FocusNode> _itemFocusNodes = const <FocusNode>[];

  static const Map<ShortcutActivator, Intent> _menuShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown): _MenuFocusIntent.next,
    SingleActivator(LogicalKeyboardKey.arrowUp): _MenuFocusIntent.previous,
    SingleActivator(LogicalKeyboardKey.home): _MenuFocusIntent.first,
    SingleActivator(LogicalKeyboardKey.end): _MenuFocusIntent.last,
  };

  /// Entry indices participating in keyboard traversal.
  List<int> get _enabledIndices => <int>[
        for (var i = 0; i < widget.items.length; i++)
          if (widget.items[i] case NasikoContextMenuItem(enabled: true)) i,
      ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _itemFocusNodes = _generateFocusNodes(0, widget.items.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollability();
      if (mounted) {
        // Menu opens focused so arrow keys work immediately. Focused
        // explicitly (not via `autofocus`) because autofocus yields when
        // another node already holds primary focus.
        widget.scopeNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final node in _itemFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NasikoContextMenuSurface oldWidget) {
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
        debugLabel: 'NasikoContextMenu item ${startIndex + index}',
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
    final enabled = _enabledIndices;
    if (enabled.isEmpty) return;

    final current = _itemFocusNodes.indexWhere((node) => node.hasFocus);
    final currentPos = enabled.indexOf(current); // -1 when none focused.

    final target = switch (intent.kind) {
      // No item focused yet: Down enters at the first item, Up at the last.
      _MenuFocusKind.next => currentPos < 0 || currentPos == enabled.length - 1
          ? enabled.first
          : enabled[currentPos + 1],
      _MenuFocusKind.previous =>
        currentPos <= 0 ? enabled.last : enabled[currentPos - 1],
      _MenuFocusKind.first => enabled.first,
      _MenuFocusKind.last => enabled.last,
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
    // then focus it once built.
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
          node: widget.scopeNode,
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
          color: _menuSurfaceColor(context),
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
                  final entry = widget.items[index];
                  return switch (entry) {
                    NasikoContextMenuDivider() =>
                      const _NasikoContextMenuDividerTile(),
                    final NasikoContextMenuItem item => _NasikoContextMenuTile(
                        item: item,
                        focusNode: _itemFocusNodes[index],
                        onTap: () => widget.onItemSelected(item),
                      ),
                  };
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin rule between item groups, using the same hairline token as the
/// surface border so it reads on both the inverse and elevated surfaces.
class _NasikoContextMenuDividerTile extends StatelessWidget {
  const _NasikoContextMenuDividerTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.s4),
      child: Container(
        height: context.borderWidth.w1,
        color: context.colors.borderPrimary,
      ),
    );
  }
}

/// One selectable row — visuals identical to NasikoPopupMenu's item, with
/// added disabled handling.
class _NasikoContextMenuTile extends StatefulWidget {
  const _NasikoContextMenuTile({
    required this.item,
    required this.focusNode,
    required this.onTap,
  });

  final NasikoContextMenuItem item;

  /// Owned by the surface; used for arrow-key traversal across items.
  final FocusNode focusNode;

  final VoidCallback onTap;

  @override
  State<_NasikoContextMenuTile> createState() => _NasikoContextMenuTileState();
}

class _NasikoContextMenuTileState extends State<_NasikoContextMenuTile> {
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

    final item = widget.item;
    final enabled = item.enabled;
    final isHighlighted = enabled && (_isHovered || _isFocused);

    // Disabled foreground: alpha-modulated from the surface-matched token so
    // it dims correctly on both the inverse (light mode) and elevated (dark
    // mode) menu surfaces.
    final Color foregroundColor = !enabled
        ? _menuItemForegroundColor(context).withValues(alpha: 0.45)
        : item.isDestructive
            ? colors.foregroundError
            : _menuItemForegroundColor(context);

    final textStyle =
        typography.bodySecondary.copyWith(color: foregroundColor);

    Widget row = AnimatedContainer(
      duration: context.motion.hover,
      curve: context.motion.enter,
      decoration: BoxDecoration(
        color: isHighlighted
            ? _menuItemHighlightColor(context)
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
            if (item.icon != null) ...[
              HugeIcon(
                icon: item.icon!,
                size: 20,
                color: foregroundColor,
              ),
              SizedBox(width: spacing.s8),
            ],
            Expanded(
              child: Text(
                item.label,
                style: textStyle,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    if (enabled) {
      row = MouseRegion(
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
            child: row,
          ),
        ),
      );
    }

    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: enabled,
        child: row,
      ),
    );
  }
}
