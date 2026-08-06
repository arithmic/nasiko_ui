// lib/src/components/toggle/toggle_group.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

// Interaction model: single mode behaves like an optional radio set
// (tapping the selected item clears it), multiple mode toggles items
// independently, and Arrow Left/Right move focus between items with
// wrap-around while Home/End jump to the first/last item. Visuals, tokens,
// and motion follow the Nasiko design system.

/// Selection behavior of a [NasikoToggleGroup].
enum NasikoToggleGroupMode {
  /// At most one item is on at a time; pressing the active item turns it
  /// off (selection becomes null).
  single,

  /// Any number of items may be on simultaneously.
  multiple,
}

/// One entry of a [NasikoToggleGroup].
///
/// At least one of [label] and [icon] must be provided.
@immutable
class NasikoToggleGroupItem<T> {
  /// Creates a toggle-group item identified by [value].
  const NasikoToggleGroupItem({
    required this.value,
    this.label,
    this.icon,
    this.enabled = true,
    this.semanticLabel,
  }) : assert(
         label != null || icon != null,
         'Provide a label, an icon, or both.',
       );

  /// The unique value this item represents.
  final T value;

  /// Optional text label.
  final String? label;

  /// Optional leading icon.
  final HugeIconsType? icon;

  /// Whether this individual item is interactive (the group's own enabled
  /// state also applies).
  final bool enabled;

  /// Announced to assistive technologies; falls back to [label].
  final String? semanticLabel;
}

/// Intent for arrow-key focus movement inside a [NasikoToggleGroup].
class _ToggleGroupFocusIntent extends Intent {
  const _ToggleGroupFocusIntent(this.kind);

  final _ToggleGroupFocusKind kind;
}

enum _ToggleGroupFocusKind { previous, next, first, last }

/// A horizontal set of [NasikoToggle]s with single or multiple selection.
///
/// Controlled component: selection state is owned by the caller. Use
/// [NasikoToggleGroup.single] with a nullable [value] / [onChanged], or
/// [NasikoToggleGroup.multiple] with a [values] set / [onValuesChanged].
///
/// Keyboard:
/// Arrow Left/Right move focus across enabled items with wrap-around,
/// Home/End jump to the first/last enabled item, and Enter/Space activate
/// the focused item (handled by each [NasikoToggle]).
///
/// Design rule: buttons in a group must share one size, so the group takes a
/// single [size] and applies it to every item — items cannot vary.
///
/// ```dart
/// NasikoToggleGroup<TextAlign>.single(
///   value: alignment,
///   onChanged: (v) => setState(() => alignment = v),
///   items: const [
///     NasikoToggleGroupItem(value: TextAlign.left, label: 'Left'),
///     NasikoToggleGroupItem(value: TextAlign.center, label: 'Center'),
///     NasikoToggleGroupItem(value: TextAlign.right, label: 'Right'),
///   ],
/// )
/// ```
class NasikoToggleGroup<T> extends StatefulWidget {
  /// Creates a group where at most one item is on; pressing the active item
  /// clears the selection (reported as null).
  const NasikoToggleGroup.single({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.size = NasikoButtonSize.large,
    this.enabled = true,
  }) : mode = NasikoToggleGroupMode.single,
       values = null,
       onValuesChanged = null;

  /// Creates a group where any number of items may be on.
  const NasikoToggleGroup.multiple({
    super.key,
    required this.items,
    required this.values,
    required this.onValuesChanged,
    this.size = NasikoButtonSize.large,
    this.enabled = true,
  }) : mode = NasikoToggleGroupMode.multiple,
       value = null,
       onChanged = null;

  /// The selection behavior of this group.
  final NasikoToggleGroupMode mode;

  /// The items to render, in order.
  final List<NasikoToggleGroupItem<T>> items;

  /// Single mode: the currently selected value, or null for none.
  final T? value;

  /// Single mode: called with the new selection (null when the active item
  /// was pressed again). A null callback disables the group.
  final ValueChanged<T?>? onChanged;

  /// Multiple mode: the set of currently selected values.
  final Set<T>? values;

  /// Multiple mode: called with the updated set after a toggle. A null
  /// callback disables the group.
  final ValueChanged<Set<T>>? onValuesChanged;

  /// The one [NasikoButtonSize] applied to every item. Grouped buttons must
  /// never mix sizes (design rule) — hence a group-level knob only.
  final NasikoButtonSize size;

  /// Master switch; when false every item renders disabled.
  final bool enabled;

  @override
  State<NasikoToggleGroup<T>> createState() => _NasikoToggleGroupState<T>();
}

class _NasikoToggleGroupState<T> extends State<NasikoToggleGroup<T>> {
  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): _ToggleGroupFocusIntent(
          _ToggleGroupFocusKind.previous,
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight): _ToggleGroupFocusIntent(
          _ToggleGroupFocusKind.next,
        ),
        SingleActivator(LogicalKeyboardKey.home): _ToggleGroupFocusIntent(
          _ToggleGroupFocusKind.first,
        ),
        SingleActivator(LogicalKeyboardKey.end): _ToggleGroupFocusIntent(
          _ToggleGroupFocusKind.last,
        ),
      };

  final List<FocusNode> _nodes = <FocusNode>[];

  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(covariant NasikoToggleGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _syncNodes();
    }
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncNodes() {
    while (_nodes.length > widget.items.length) {
      _nodes.removeLast().dispose();
    }
    while (_nodes.length < widget.items.length) {
      _nodes.add(FocusNode(debugLabel: 'NasikoToggleGroup[${_nodes.length}]'));
    }
  }

  bool get _groupEnabled =>
      widget.enabled &&
      (widget.mode == NasikoToggleGroupMode.single
          ? widget.onChanged != null
          : widget.onValuesChanged != null);

  bool _itemEnabled(int index) => _groupEnabled && widget.items[index].enabled;

  bool _isSelected(NasikoToggleGroupItem<T> item) =>
      widget.mode == NasikoToggleGroupMode.single
      ? widget.value == item.value
      : (widget.values ?? const <Never>{}).contains(item.value);

  void _activate(NasikoToggleGroupItem<T> item) {
    switch (widget.mode) {
      case NasikoToggleGroupMode.single:
        // Pressing the active item deselects it (Radix single-mode default).
        widget.onChanged?.call(widget.value == item.value ? null : item.value);
      case NasikoToggleGroupMode.multiple:
        final next = Set<T>.of(widget.values ?? const <Never>{});
        if (!next.remove(item.value)) {
          next.add(item.value);
        }
        widget.onValuesChanged?.call(next);
    }
  }

  /// Moves focus per [kind] across enabled items, wrapping at the ends
  /// (Radix roving-focus loop behavior).
  void _moveFocus(_ToggleGroupFocusKind kind) {
    if (_nodes.isEmpty) return;
    final enabledIndexes = <int>[
      for (var i = 0; i < widget.items.length; i++)
        if (_itemEnabled(i)) i,
    ];
    if (enabledIndexes.isEmpty) return;

    final current = _nodes.indexWhere((node) => node.hasFocus);
    final int target;
    switch (kind) {
      case _ToggleGroupFocusKind.first:
        target = enabledIndexes.first;
      case _ToggleGroupFocusKind.last:
        target = enabledIndexes.last;
      case _ToggleGroupFocusKind.previous:
      case _ToggleGroupFocusKind.next:
        final position = enabledIndexes.indexOf(current);
        if (position == -1) {
          target = enabledIndexes.first;
        } else {
          final delta = kind == _ToggleGroupFocusKind.next ? 1 : -1;
          target =
              enabledIndexes[(position + delta + enabledIndexes.length) %
                  enabledIndexes.length];
        }
    }
    _nodes[target].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Semantics(
      container: true,
      child: FocusTraversalGroup(
        child: Shortcuts(
          shortcuts: _shortcuts,
          child: Actions(
            actions: <Type, Action<Intent>>{
              _ToggleGroupFocusIntent: CallbackAction<_ToggleGroupFocusIntent>(
                onInvoke: (intent) {
                  _moveFocus(intent.kind);
                  return null;
                },
              ),
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.items.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing.s4),
                  Semantics(
                    inMutuallyExclusiveGroup:
                        widget.mode == NasikoToggleGroupMode.single,
                    child: NasikoToggle(
                      value: _isSelected(widget.items[i]),
                      onChanged: _itemEnabled(i)
                          ? (_) => _activate(widget.items[i])
                          : null,
                      label: widget.items[i].label,
                      icon: widget.items[i].icon,
                      semanticLabel: widget.items[i].semanticLabel,
                      size: widget.size,
                      focusNode: _nodes[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
