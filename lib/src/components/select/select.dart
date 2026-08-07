// lib/src/components/select/select.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A single option displayed by [NasikoSelect] (and the package combobox).
///
/// [T] is the domain value the option carries — an enum, an id, a model —
/// while [label] is what the user sees (and what typeahead matches against).
class NasikoSelectItem<T> {
  const NasikoSelectItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  /// The value reported through `onChanged` / `onSelected` when this option
  /// is picked.
  final T value;

  /// Display text for the option. Also drives [NasikoSelect]'s typeahead:
  /// pressing a letter jumps to the next option whose label starts with it.
  final String label;

  /// Optional leading icon. Only the Hugeicons library is used,
  /// e.g. `HugeIcons.strokeRoundedUser`.
  final HugeIconsType? icon;

  /// When false the option renders greyed out and can be neither focused
  /// nor selected.
  final bool enabled;
}

/// A single-value select for the Nasiko Design System.
///
/// Renders a field-styled trigger (48px, `backgroundSurface` fill,
/// `borderPrimary` hairline, rotating chevron) that opens a
/// [NasikoPopover]-anchored option menu sized to the trigger's width.
/// The selected option shows a check mark and bold label.
///
/// Keyboard: the trigger is focusable; Enter/Space/ArrowDown open the menu.
/// Inside the menu ArrowUp/ArrowDown/Home/End move focus across enabled
/// options (wrapping), Enter/Space select, Escape closes and restores focus
/// to the trigger, and letter keys jump to the next option whose label
/// starts with the typed character.
///
/// ```dart
/// NasikoSelect<String>(
///   value: _provider,
///   placeholder: 'Choose a provider',
///   items: const [
///     NasikoSelectItem(value: 'anthropic', label: 'Anthropic'),
///     NasikoSelectItem(value: 'openai', label: 'OpenAI'),
///   ],
///   onChanged: (v) => setState(() => _provider = v),
/// )
/// ```
class NasikoSelect<T> extends StatefulWidget {
  const NasikoSelect({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.placeholder = 'Select…',
    this.enabled = true,
    this.width,
    this.maxMenuHeight = 280,
  });

  /// The options to choose from. An empty list greys the field out, exactly
  /// like [enabled] being false — nothing to pick means nothing to open.
  final List<NasikoSelectItem<T>> items;

  /// Called with the picked option's value. The widget is controlled: it
  /// never stores the selection itself, the parent must update [value].
  final ValueChanged<T> onChanged;

  /// The currently selected value, or null to show [placeholder]. Matched
  /// against [NasikoSelectItem.value] with `==`.
  final T? value;

  /// Text shown in the trigger while [value] is null (or not in [items]).
  final String placeholder;

  /// When false the field renders greyed out and the menu never opens.
  final bool enabled;

  /// Fixed width for the trigger and the menu. When null the trigger sizes
  /// to its parent's constraints and the menu matches the trigger's
  /// rendered width.
  final double? width;

  /// Maximum menu height before the option list scrolls.
  final double maxMenuHeight;

  @override
  State<NasikoSelect<T>> createState() => _NasikoSelectState<T>();
}

class _NasikoSelectState<T> extends State<NasikoSelect<T>> {
  final NasikoPopoverController _popover = NasikoPopoverController();
  final FocusNode _triggerFocus = FocusNode(debugLabel: 'NasikoSelect');

  bool _isOpen = false;
  bool _isHovered = false;
  bool _isFocused = false;

  /// Menu width resolved when opening: `widget.width` or the trigger's
  /// rendered width.
  double? _menuWidth;

  /// Enter/Space/ArrowDown on the focused trigger open the menu.
  static const Map<ShortcutActivator, Intent> _triggerShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown): ActivateIntent(),
  };

  bool get _interactive => widget.enabled && widget.items.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _popover.addListener(_handlePopoverChanged);
  }

  @override
  void didUpdateWidget(covariant NasikoSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Close if the field became non-interactive while open. Deferred: this
    // runs during build and the popover's OverlayPortal must not hide then.
    if (!_interactive && _popover.isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_interactive) _popover.hide();
      });
    }
  }

  @override
  void dispose() {
    _popover.removeListener(_handlePopoverChanged);
    _popover.dispose();
    _triggerFocus.dispose();
    super.dispose();
  }

  void _handlePopoverChanged() {
    if (!mounted || _isOpen == _popover.isShowing) return;
    setState(() => _isOpen = _popover.isShowing);
  }

  void _openMenu() {
    if (!_interactive || _popover.isShowing) return;
    // Focus the trigger first so the popover captures it as the focus to
    // restore on Escape.
    _triggerFocus.requestFocus();
    final renderBox = context.findRenderObject() as RenderBox?;
    setState(() {
      _menuWidth = widget.width ??
          ((renderBox != null && renderBox.hasSize)
              ? renderBox.size.width
              : null);
    });
    _popover.show();
  }

  void _toggleMenu() => _popover.isShowing ? _popover.hide() : _openMenu();

  void _handleSelect(NasikoSelectItem<T> item) {
    _popover.hide();
    // Selection closes without going through the popover's Escape path, so
    // restore focus to the trigger ourselves.
    _triggerFocus.requestFocus();
    widget.onChanged(item.value);
  }

  void _setHovered(bool value) {
    if (value != _isHovered) setState(() => _isHovered = value);
  }

  NasikoSelectItem<T>? get _selectedItem {
    for (final item in widget.items) {
      if (item.value == widget.value) return item;
    }
    return null;
  }

  int? get _selectedIndex {
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].value == widget.value) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;
    final motion = context.motion;

    final interactive = _interactive;
    final selected = _selectedItem;
    final displayText = selected?.label ?? widget.placeholder;

    final borderColor = !interactive
        ? colors.borderDisabled
        : _isFocused
            ? colors.borderFocus
            : _isHovered
                ? colors.borderHover
                // Functional-border tier: the trigger's border is its
                // affordance, like an input field's.
                : colors.borderInput;

    final fillColor = !interactive
        ? colors.backgroundDisabled
        : _isHovered
            ? colors.backgroundSurfaceHover
            : colors.backgroundSurface;

    final textColor = !interactive
        ? colors.foregroundDisabled
        : selected == null
            ? colors.foregroundSecondary
            : colors.foregroundPrimary;

    final field = AnimatedContainer(
      // Decorative hover/focus fade — raw token per the motion convention.
      duration: motion.hover,
      curve: motion.enter,
      height: spacing.s48h,
      padding: EdgeInsets.symmetric(horizontal: spacing.s12w),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(radii.r8),
        border: Border.all(color: borderColor, width: borderWidths.w1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayText,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: typography.bodySecondary.copyWith(color: textColor),
            ),
          ),
          SizedBox(width: spacing.s8),
          AnimatedRotation(
            turns: _isOpen ? 0.5 : 0.0,
            // Structural (the chevron moves) — disabled under reduced motion.
            duration: motion.resolve(context, motion.fast),
            curve: motion.move,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              size: iconSizes.xs,
              color: interactive
                  ? colors.foregroundSecondary
                  : colors.foregroundDisabled,
            ),
          ),
        ],
      ),
    );

    final trigger = Semantics(
      container: true,
      button: true,
      enabled: interactive,
      expanded: interactive ? _isOpen : null,
      label: displayText,
      child: MouseRegion(
        cursor:
            interactive ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: FocusableActionDetector(
          focusNode: _triggerFocus,
          enabled: interactive,
          onShowFocusHighlight: (value) => setState(() => _isFocused = value),
          shortcuts: _triggerShortcuts,
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _openMenu();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: interactive ? _toggleMenu : null,
            // The Semantics wrapper above already announces the value.
            child: ExcludeSemantics(child: field),
          ),
        ),
      ),
    );

    final result = NasikoPopover(
      controller: _popover,
      width: _menuWidth,
      popoverBuilder: (context) => _NasikoSelectMenu<T>(
        items: widget.items,
        selectedIndex: _selectedIndex,
        maxHeight: widget.maxMenuHeight,
        onSelect: _handleSelect,
      ),
      child: trigger,
    );

    if (widget.width == null) return result;
    return SizedBox(width: widget.width, child: result);
  }
}

/// Keyboard focus movement inside the select menu.
enum _SelectFocusKind { next, previous, first, last }

/// Intent for Up/Down/Home/End focus movement across options.
class _SelectFocusIntent extends Intent {
  const _SelectFocusIntent._(this.kind);

  static const _SelectFocusIntent next =
      _SelectFocusIntent._(_SelectFocusKind.next);
  static const _SelectFocusIntent previous =
      _SelectFocusIntent._(_SelectFocusKind.previous);
  static const _SelectFocusIntent first =
      _SelectFocusIntent._(_SelectFocusKind.first);
  static const _SelectFocusIntent last =
      _SelectFocusIntent._(_SelectFocusKind.last);

  final _SelectFocusKind kind;
}

/// The option list rendered inside the popover surface.
///
/// Owns one roving [FocusNode] per option, handles Arrow/Home/End movement
/// (skipping disabled options, wrapping at the ends) plus single-character
/// typeahead. Escape is handled by the enclosing [NasikoPopover].
class _NasikoSelectMenu<T> extends StatefulWidget {
  const _NasikoSelectMenu({
    required this.items,
    required this.selectedIndex,
    required this.maxHeight,
    required this.onSelect,
  });

  final List<NasikoSelectItem<T>> items;
  final int? selectedIndex;
  final double maxHeight;
  final ValueChanged<NasikoSelectItem<T>> onSelect;

  @override
  State<_NasikoSelectMenu<T>> createState() => _NasikoSelectMenuState<T>();
}

class _NasikoSelectMenuState<T> extends State<_NasikoSelectMenu<T>> {
  final ScrollController _scrollController = ScrollController();

  /// One node per option, in item order; drives arrow/Home/End navigation.
  List<FocusNode> _itemFocusNodes = const <FocusNode>[];

  static const Map<ShortcutActivator, Intent> _menuShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowDown): _SelectFocusIntent.next,
    SingleActivator(LogicalKeyboardKey.arrowUp): _SelectFocusIntent.previous,
    SingleActivator(LogicalKeyboardKey.home): _SelectFocusIntent.first,
    SingleActivator(LogicalKeyboardKey.end): _SelectFocusIntent.last,
  };

  @override
  void initState() {
    super.initState();
    _itemFocusNodes = _generateFocusNodes(0, widget.items.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Initial focus: the selected option, else the first enabled one.
      final selected = widget.selectedIndex;
      final target = (selected != null &&
              selected >= 0 &&
              selected < widget.items.length &&
              widget.items[selected].enabled)
          ? selected
          : _firstEnabled();
      if (target != null) _focusItem(target);
    });
  }

  @override
  void didUpdateWidget(covariant _NasikoSelectMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _syncFocusNodes();
    }
  }

  @override
  void dispose() {
    for (final node in _itemFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  List<FocusNode> _generateFocusNodes(int startIndex, int count) {
    return List<FocusNode>.generate(
      count,
      (index) => FocusNode(debugLabel: 'NasikoSelect item ${startIndex + index}'),
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

  int get _focusedIndex =>
      _itemFocusNodes.indexWhere((node) => node.hasFocus);

  int? _firstEnabled() {
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].enabled) return i;
    }
    return null;
  }

  int? _lastEnabled() {
    for (var i = widget.items.length - 1; i >= 0; i--) {
      if (widget.items[i].enabled) return i;
    }
    return null;
  }

  /// Next enabled index from [from] in [step] direction, wrapping. Returns
  /// null when no other option is enabled.
  int? _nextEnabled(int from, int step) {
    final count = widget.items.length;
    for (var i = 1; i <= count; i++) {
      final index = ((from + step * i) % count + count) % count;
      if (widget.items[index].enabled) return index;
    }
    return null;
  }

  void _handleFocusIntent(_SelectFocusIntent intent) {
    if (widget.items.isEmpty) return;
    final current = _focusedIndex;

    final target = switch (intent.kind) {
      // No option focused yet: Down enters at the first, Up at the last.
      _SelectFocusKind.next =>
        current < 0 ? _firstEnabled() : _nextEnabled(current, 1),
      _SelectFocusKind.previous =>
        current < 0 ? _lastEnabled() : _nextEnabled(current, -1),
      _SelectFocusKind.first => _firstEnabled(),
      _SelectFocusKind.last => _lastEnabled(),
    };
    if (target != null) _focusItem(target);
  }

  void _focusItem(int index) {
    final node = _itemFocusNodes[index];
    if (node.context != null) {
      node.requestFocus();
      return;
    }

    // The ListView builds items lazily, so a far-away option may not have a
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

  /// Typeahead: a printable character jumps to the next enabled option whose
  /// label starts with it (case-insensitive), scanning forward from the
  /// focused option and wrapping. Space is left to the activation shortcuts.
  KeyEventResult _handleTypeahead(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final character = event.character;
    if (character == null || character.trim().isEmpty) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed) {
      return KeyEventResult.ignored;
    }

    final query = character.toLowerCase();
    final current = _focusedIndex;
    final count = widget.items.length;
    for (var i = 1; i <= count; i++) {
      final index = (current + i) % count;
      final item = widget.items[index];
      if (item.enabled && item.label.toLowerCase().startsWith(query)) {
        _focusItem(index);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Shortcuts(
      shortcuts: _menuShortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SelectFocusIntent: CallbackAction<_SelectFocusIntent>(
            onInvoke: (intent) {
              _handleFocusIntent(intent);
              return null;
            },
          ),
        },
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _handleTypeahead,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              child: ListView.separated(
                controller: _scrollController,
                shrinkWrap: true,
                padding: EdgeInsets.all(spacing.s8),
                itemCount: widget.items.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: spacing.s2),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return _NasikoSelectOption(
                    label: item.label,
                    icon: item.icon,
                    enabled: item.enabled,
                    selected: index == widget.selectedIndex,
                    focusNode: _itemFocusNodes[index],
                    onTap: () => widget.onSelect(item),
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

/// One row in the select menu: hover/focus highlight, optional leading icon,
/// check mark + bold label when selected, greyout when disabled.
class _NasikoSelectOption extends StatefulWidget {
  const _NasikoSelectOption({
    required this.label,
    required this.enabled,
    required this.selected,
    required this.focusNode,
    required this.onTap,
    this.icon,
  });

  final String label;
  final HugeIconsType? icon;
  final bool enabled;
  final bool selected;

  /// Owned by the menu surface; used for arrow-key traversal across options.
  final FocusNode focusNode;
  final VoidCallback onTap;

  @override
  State<_NasikoSelectOption> createState() => _NasikoSelectOptionState();
}

class _NasikoSelectOptionState extends State<_NasikoSelectOption> {
  bool _isHovered = false;
  bool _isFocused = false;

  static const Map<ShortcutActivator, Intent> _activationShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  void _setHovered(bool value) {
    if (value != _isHovered) setState(() => _isHovered = value);
  }

  void _handleFocusChange(bool focused) {
    if (focused) {
      // Keep keyboard-focused options visible inside the scrollable menu.
      Scrollable.ensureVisible(context, alignment: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final iconSizes = context.iconSize;
    final motion = context.motion;

    final isHighlighted = widget.enabled && (_isHovered || _isFocused);
    final foregroundColor =
        widget.enabled ? colors.foregroundPrimary : colors.foregroundDisabled;
    final textStyle =
        (widget.selected ? typography.bodySecondaryBold : typography.bodySecondary)
            .copyWith(color: foregroundColor);

    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: widget.enabled,
        selected: widget.selected,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: FocusableActionDetector(
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            onShowFocusHighlight: (value) => setState(() => _isFocused = value),
            onFocusChange: _handleFocusChange,
            shortcuts: _activationShortcuts,
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onTap();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.enabled ? widget.onTap : null,
              child: AnimatedContainer(
                duration: motion.hover,
                curve: motion.enter,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.s12,
                  vertical: spacing.s8,
                ),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? colors.backgroundSurfaceHover
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(radii.r8),
                ),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      HugeIcon(
                        icon: widget.icon!,
                        size: iconSizes.s,
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
                    if (widget.selected) ...[
                      SizedBox(width: spacing.s8),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedTick02,
                        size: iconSizes.xs,
                        color: foregroundColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
