// lib/src/components/command/command.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A single executable entry in the command palette.
///
/// ```dart
/// NasikoCommandItem(
///   label: 'New invoice',
///   icon: HugeIcons.strokeRoundedFile02,
///   keywords: ['create', 'billing'],
///   shortcut: ['⌘', 'N'],
///   onSelected: () => context.go('/invoices/new'),
/// )
/// ```
class NasikoCommandItem {
  /// Creates a command palette item.
  const NasikoCommandItem({
    required this.label,
    required this.onSelected,
    this.icon,
    this.keywords = const [],
    this.shortcut,
  });

  /// Primary text shown for the item; also what the query is matched against.
  final String label;

  /// Runs when the item is chosen. Invoked AFTER the palette dialog has been
  /// popped (scheduled on the next frame), so it may safely navigate.
  final VoidCallback onSelected;

  /// Optional leading icon.
  final HugeIconsType? icon;

  /// Extra search terms that match with substring score (never shown).
  final List<String> keywords;

  /// Optional shortcut hint rendered with [NasikoKbd] as display glyphs,
  /// e.g. `['⌘', 'K']`. Purely visual — the palette does not register it.
  final List<String>? shortcut;
}

/// A labelled group of [NasikoCommandItem]s in the command palette.
///
/// Groups whose items are all filtered out by the query are hidden entirely.
class NasikoCommandGroup {
  /// Creates a command palette group.
  const NasikoCommandGroup({required this.label, required this.items});

  /// Section heading shown above the group's items.
  final String label;

  /// The commands in this group, in preferred display order.
  final List<NasikoCommandItem> items;
}

/// Shows the Nasiko command palette as a top-aligned dialog.
///
/// Presents a search input over grouped, filterable commands:
/// - Filtering is live and case-insensitive (label prefix > word-boundary
///   prefix > substring/keyword).
/// - ArrowUp/ArrowDown move the highlight across all visible items (wrapping),
///   Enter runs the highlighted command, Escape closes.
/// - The selected item's `onSelected` runs after the dialog has been popped,
///   so it can navigate freely.
///
/// ```dart
/// await showNasikoCommandPalette(
///   context: context,
///   groups: [
///     NasikoCommandGroup(label: 'Navigation', items: [...]),
///     NasikoCommandGroup(label: 'Actions', items: [...]),
///   ],
/// );
/// ```
Future<void> showNasikoCommandPalette({
  required BuildContext context,
  required List<NasikoCommandGroup> groups,
  String placeholder = 'Type a command or search…',
}) {
  final motion = context.motion;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: motion.resolve(context, motion.base),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: motion.enter,
        reverseCurve: motion.exit,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          // Scale from the top so the surface appears to settle downward,
          // matching its top-center placement.
          alignment: Alignment.topCenter,
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _NasikoCommandPalette(groups: groups, placeholder: placeholder);
    },
  );
}

/// One group that survived filtering, with its (scored, sorted) items.
class _VisibleGroup {
  const _VisibleGroup({required this.label, required this.items});

  final String label;
  final List<NasikoCommandItem> items;
}

/// The palette surface: search input on top, grouped results below.
class _NasikoCommandPalette extends StatefulWidget {
  const _NasikoCommandPalette({
    required this.groups,
    required this.placeholder,
  });

  final List<NasikoCommandGroup> groups;
  final String placeholder;

  @override
  State<_NasikoCommandPalette> createState() => _NasikoCommandPaletteState();
}

class _NasikoCommandPaletteState extends State<_NasikoCommandPalette> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _query = '';

  /// Index of the highlighted item within [_flatItems].
  int _activeIndex = 0;

  /// All visible items flattened across groups, rebuilt on every filter pass.
  List<NasikoCommandItem> _flatItems = const [];

  /// One key per flat index, used for scroll-into-view. Grown lazily and
  /// reused across rebuilds so keys stay stable per position.
  final List<GlobalKey> _itemKeys = [];

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  static bool _isWordCodeUnit(int c) =>
      (c >= 0x30 && c <= 0x39) || // 0-9
      (c >= 0x41 && c <= 0x5A) || // A-Z
      (c >= 0x61 && c <= 0x7A); // a-z

  /// Scores [item] against the lowercased [query].
  ///
  /// 3 = label prefix, 2 = word-boundary prefix inside the label,
  /// 1 = substring in label or any keyword, 0 = no match (hidden).
  /// An empty query scores every item 1 (show everything, original order).
  static int _score(NasikoCommandItem item, String query) {
    if (query.isEmpty) return 1;
    final label = item.label.toLowerCase();

    if (label.startsWith(query)) return 3;

    // Word-boundary prefix: the query starts a word inside the label
    // (preceded by any non-alphanumeric character).
    var index = label.indexOf(query);
    var foundInLabel = index >= 0;
    while (index > 0) {
      if (!_isWordCodeUnit(label.codeUnitAt(index - 1))) return 2;
      index = label.indexOf(query, index + 1);
    }
    if (foundInLabel) return 1;

    for (final keyword in item.keywords) {
      if (keyword.toLowerCase().contains(query)) return 1;
    }
    return 0;
  }

  /// Filters and sorts the groups for [_query]; also rebuilds [_flatItems]
  /// and keeps [_activeIndex] and [_itemKeys] consistent with the result.
  List<_VisibleGroup> _computeVisibleGroups() {
    final query = _query.trim().toLowerCase();
    final visible = <_VisibleGroup>[];
    final flat = <NasikoCommandItem>[];

    for (final group in widget.groups) {
      final scored = <(int score, int order, NasikoCommandItem item)>[];
      for (var i = 0; i < group.items.length; i++) {
        final score = _score(group.items[i], query);
        if (score > 0) scored.add((score, i, group.items[i]));
      }
      if (scored.isEmpty) continue;

      // Score descending, then original order — explicit tiebreak keeps the
      // sort stable regardless of List.sort's own (unstable) algorithm.
      scored.sort((a, b) {
        if (a.$1 != b.$1) return b.$1.compareTo(a.$1);
        return a.$2.compareTo(b.$2);
      });

      final items = [for (final entry in scored) entry.$3];
      visible.add(_VisibleGroup(label: group.label, items: items));
      flat.addAll(items);
    }

    _flatItems = flat;
    if (_activeIndex >= flat.length) _activeIndex = 0;
    while (_itemKeys.length < flat.length) {
      _itemKeys.add(GlobalKey());
    }
    return visible;
  }

  // ── Keyboard & selection ──────────────────────────────────────────────────

  void _moveActive(int delta) {
    if (_flatItems.isEmpty) return;
    setState(() {
      _activeIndex =
          (_activeIndex + delta + _flatItems.length) % _flatItems.length;
    });
    _scrollActiveIntoView();
  }

  void _scrollActiveIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _activeIndex >= _itemKeys.length) return;
      final itemContext = _itemKeys[_activeIndex].currentContext;
      if (itemContext == null) return;
      final motion = context.motion;
      Scrollable.ensureVisible(
        itemContext,
        alignment: 0.5,
        duration: motion.resolve(context, motion.fast),
        curve: motion.move,
      );
    });
  }

  /// Pops the palette, then runs [item]'s callback on the next frame so
  /// `onSelected` can navigate without fighting the closing dialog route.
  void _select(NasikoCommandItem item) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      item.onSelected();
    });
  }

  /// Intercepts navigation keys before the search field's editable text
  /// consumes them (same ancestor-Focus pattern as NasikoTextBox). Tab is
  /// deliberately left alone.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      _moveActive(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveActive(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      if (event is KeyDownEvent &&
          _flatItems.isNotEmpty &&
          _activeIndex < _flatItems.length) {
        _select(_flatItems[_activeIndex]);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      if (event is KeyDownEvent) Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleQueryChanged(String value) {
    setState(() {
      _query = value;
      _activeIndex = 0;
    });
    _scrollActiveIntoView();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final screen = MediaQuery.sizeOf(context);

    final visibleGroups = _computeVisibleGroups();

    final width = math.min(560.0, screen.width - spacing.s16 * 2);
    final topOffset = screen.height * 0.15;
    final maxHeight = math.max(0.0, screen.height * 0.85 - topOffset);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: topOffset),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: width,
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: colors.backgroundBase,
                borderRadius: BorderRadius.circular(radii.r16),
                border: Border.all(
                  color: colors.borderPrimary,
                  width: borderWidths.w1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: spacing.s16,
                    offset: Offset(0, spacing.s4),
                  ),
                ],
              ),
              // Clip so the highlight and scroll content respect the radius.
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchInput(context),
                  const NasikoDivider(axis: NasikoDividerAxis.horizontal),
                  Flexible(child: _buildResults(context, visibleGroups)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s16,
        vertical: spacing.s12,
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedSearch01,
            size: iconSizes.s,
            color: colors.foregroundIconPrimary,
          ),
          SizedBox(width: spacing.s8),
          Expanded(
            child: Semantics(
              label: 'Command palette search',
              container: true,
              child: Focus(
                onKeyEvent: _handleKeyEvent,
                child: TextField(
                  controller: _queryController,
                  autofocus: true,
                  onChanged: _handleQueryChanged,
                  style: typography.bodyPrimary.copyWith(
                    color: colors.foregroundPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: typography.bodyPrimary.copyWith(
                      color: colors.foregroundSecondary,
                    ),
                    // Borderless by design — the card supplies the frame and
                    // the divider below separates input from results.
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, List<_VisibleGroup> groups) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    if (groups.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s24,
        ),
        child: NasikoEmpty(
          title: 'No results',
          description: 'Nothing matches “${_query.trim()}”.',
        ),
      );
    }

    var flatIndex = 0;
    final children = <Widget>[];
    for (final group in groups) {
      children.add(
        Padding(
          padding: EdgeInsets.only(
            left: spacing.s12,
            right: spacing.s12,
            top: spacing.s8,
            bottom: spacing.s4,
          ),
          child: Text(
            group.label,
            style: typography.bodyTertiary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
        ),
      );
      for (final item in group.items) {
        final index = flatIndex;
        children.add(
          _CommandPaletteItem(
            key: _itemKeys[index],
            item: item,
            isActive: index == _activeIndex,
            onHover: () {
              if (_activeIndex != index) {
                setState(() => _activeIndex = index);
              }
            },
            onTap: () => _select(item),
          ),
        );
        flatIndex++;
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(spacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// One result row: icon + label + optional trailing shortcut caps.
///
/// The highlight follows the menu-item treatment — an AnimatedContainer at
/// `motion.hover` — driven by the palette's single active index (keyboard
/// and mouse share the same highlight).
class _CommandPaletteItem extends StatelessWidget {
  const _CommandPaletteItem({
    super.key,
    required this.item,
    required this.isActive,
    required this.onHover,
    required this.onTap,
  });

  final NasikoCommandItem item;
  final bool isActive;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final motion = context.motion;

    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => onHover(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AnimatedContainer(
              duration: motion.hover,
              curve: motion.enter,
              decoration: BoxDecoration(
                color: isActive
                    ? colors.backgroundSurfaceHover
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(radii.r8),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s12,
                vertical: spacing.s8,
              ),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    HugeIcon(
                      icon: item.icon!,
                      size: iconSizes.s,
                      color: colors.foregroundIconPrimary,
                    ),
                    SizedBox(width: spacing.s8),
                  ],
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: typography.bodySecondary.copyWith(
                        color: colors.foregroundPrimary,
                      ),
                    ),
                  ),
                  if (item.shortcut != null) ...[
                    SizedBox(width: spacing.s12),
                    NasikoKbd(keys: item.shortcut!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
