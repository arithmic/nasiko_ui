// lib/src/components/select/combobox.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../internal/overlay_reveal.dart';

/// A controlled async autocomplete for the Nasiko Design System.
///
/// The PARENT owns the query and the item list: this widget renders a text
/// field (visuals from `NasikoTextBox`), debounces typing by [debounce]
/// before calling [onQueryChanged], and shows an anchored popover with
/// [items] while the field is focused and the query is non-empty (or while
/// [isLoading]). The typical wiring is a repository search:
///
/// ```dart
/// NasikoCombobox<SearchUser>(
///   items: [for (final u in _results) NasikoSelectItem(value: u, label: u.name)],
///   isLoading: _isSearching,
///   onQueryChanged: _runSearch,
///   onSelected: (item) => setState(() => _selected = item.value),
/// )
/// ```
///
/// Keyboard: ArrowDown/ArrowUp move a visual highlight over enabled options
/// (focus never leaves the text field), Enter selects the highlighted
/// option, Escape closes the popover and — when it is already closed —
/// clears the field. Selecting fills the field with the option's label and
/// closes the popover; [selectedLabel] lets the parent reset or prefill the
/// field text afterwards.
///
/// Built directly on [OverlayPortal]/[CompositedTransformFollower] (with
/// `NasikoPopover`'s flip and outside-tap dismiss logic) because the popover
/// component moves focus into its surface, which would steal the caret from
/// the text field.
class NasikoCombobox<T> extends StatefulWidget {
  const NasikoCombobox({
    super.key,
    required this.items,
    required this.onQueryChanged,
    required this.onSelected,
    this.selectedLabel,
    this.placeholder = 'Search…',
    this.isLoading = false,
    this.enabled = true,
    this.emptyLabel = 'No results',
    this.debounce = const Duration(milliseconds: 250),
    this.maxMenuHeight = 280,
  });

  /// The options currently offered — owned and updated by the parent in
  /// response to [onQueryChanged]. Disabled items are skipped by the
  /// keyboard highlight and cannot be tapped.
  final List<NasikoSelectItem<T>> items;

  /// Called with the raw field text once typing has settled for [debounce].
  /// Also called with `''` when Escape clears the field.
  final ValueChanged<String> onQueryChanged;

  /// Called with the picked option. The widget fills the field with the
  /// option's label and closes the popover before invoking this.
  final ValueChanged<NasikoSelectItem<T>> onSelected;

  /// When this changes the field text is replaced with it (null clears the
  /// field). Lets the parent reset or prefill the input — e.g. clearing it
  /// after a pill-style selection, or restoring a saved value.
  final String? selectedLabel;

  /// Hint shown while the field is empty.
  final String placeholder;

  /// While true the popover shows a spinner row (appended below any stale
  /// [items] still on screen).
  final bool isLoading;

  /// When false the field renders greyed out and cannot be focused.
  final bool enabled;

  /// Row shown when [items] is empty and [isLoading] is false.
  final String emptyLabel;

  /// How long typing must settle before [onQueryChanged] fires.
  final Duration debounce;

  /// Maximum popover height before the option list scrolls.
  final double maxMenuHeight;

  @override
  State<NasikoCombobox<T>> createState() => _NasikoComboboxState<T>();
}

class _NasikoComboboxState<T> extends State<NasikoCombobox<T>> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'NasikoCombobox');
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  /// Index of the keyboard-highlighted option, -1 for none. Purely visual —
  /// keyboard focus stays on the text field.
  int _activeIndex = -1;

  bool _openAbove = false;
  bool _isFocused = false;

  /// Set when the popover was closed without leaving the field (Escape,
  /// selection, outside tap) so it doesn't immediately reopen; cleared on
  /// the next user edit or when focus leaves the field.
  bool _suppressed = false;

  /// Popover width, captured from the field's render box before showing.
  double? _menuWidth;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    final label = widget.selectedLabel;
    if (label != null) {
      _controller.text = label;
    }
  }

  @override
  void didUpdateWidget(covariant NasikoCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedLabel != oldWidget.selectedLabel) {
      // Programmatic text set: no onChanged, no debounce, no reopen.
      _debounce?.cancel();
      final text = widget.selectedLabel ?? '';
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      _activeIndex = -1;
      _suppressed = true;
    }

    if (_activeIndex >= widget.items.length) {
      _activeIndex = -1;
    }

    // Visibility depends on isLoading/items/enabled, all of which may have
    // just changed. Deferred: OverlayPortal must not show/hide during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncOverlay();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _shouldShow =>
      widget.enabled &&
      _isFocused &&
      !_suppressed &&
      (widget.isLoading || _controller.text.trim().isNotEmpty);

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (!_isFocused) {
        _suppressed = false;
        _activeIndex = -1;
      }
    });
    _syncOverlay();
  }

  void _syncOverlay() {
    if (!mounted) return;
    if (_shouldShow && !_portal.isShowing) {
      setState(() {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          _menuWidth = renderBox.size.width;
        }
        _openAbove = _computeOpenAbove();
      });
      _portal.show();
    } else if (!_shouldShow && _portal.isShowing) {
      _portal.hide();
    }
  }

  /// Whether to flip above the field — mirrors `NasikoPopover`'s heuristic,
  /// measured in the overlay's coordinate space, sized by [NasikoCombobox.maxMenuHeight].
  bool _computeOpenAbove() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return false;

    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final anchor = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);

    final spaceBelow =
        overlayBox.size.height - (anchor.dy + renderBox.size.height);
    final spaceAbove = anchor.dy;
    return spaceBelow < widget.maxMenuHeight && spaceAbove > spaceBelow;
  }

  void _handleTextChanged(String text) {
    _suppressed = false;
    setState(() => _activeIndex = -1);
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () {
      if (mounted) widget.onQueryChanged(text);
    });
    _syncOverlay();
  }

  void _handleOutsideTap() {
    if (!_portal.isShowing) return;
    setState(() {
      _suppressed = true;
      _activeIndex = -1;
    });
    _portal.hide();
  }

  void _select(NasikoSelectItem<T> item) {
    _debounce?.cancel();
    _controller.value = TextEditingValue(
      text: item.label,
      selection: TextSelection.collapsed(offset: item.label.length),
    );
    setState(() {
      _suppressed = true;
      _activeIndex = -1;
    });
    _syncOverlay();
    widget.onSelected(item);
  }

  void _clearField() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _activeIndex = -1);
    widget.onQueryChanged('');
    _syncOverlay();
  }

  /// Intercepts navigation keys before the text field's editing shortcuts.
  /// Anything not consumed here falls through to normal text editing.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) return _moveActive(1);
    if (key == LogicalKeyboardKey.arrowUp) return _moveActive(-1);

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_portal.isShowing &&
          _activeIndex >= 0 &&
          _activeIndex < widget.items.length) {
        final item = widget.items[_activeIndex];
        if (item.enabled) {
          _select(item);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.escape) {
      if (_portal.isShowing) {
        setState(() {
          _suppressed = true;
          _activeIndex = -1;
        });
        _portal.hide();
        return KeyEventResult.handled;
      }
      if (_controller.text.isNotEmpty) {
        _clearField();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  /// Moves the highlight over enabled options, wrapping at the ends.
  KeyEventResult _moveActive(int delta) {
    if (!_portal.isShowing || widget.items.isEmpty) {
      return KeyEventResult.ignored;
    }
    final count = widget.items.length;
    var index = _activeIndex;
    for (var i = 0; i < count; i++) {
      index = index < 0
          ? (delta > 0 ? 0 : count - 1)
          : ((index + delta) % count + count) % count;
      if (widget.items[index].enabled) {
        setState(() => _activeIndex = index);
        return KeyEventResult.handled;
      }
    }
    // No enabled option; swallow so the caret doesn't jump around.
    return KeyEventResult.handled;
  }

  Widget _buildSurface(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    return Container(
      width: _menuWidth,
      decoration: BoxDecoration(
        color: colors.backgroundBase,
        borderRadius: BorderRadius.circular(radii.r12),
        border: Border.all(color: colors.borderPrimary, width: borderWidths.w1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: spacing.s16,
            offset: Offset(0, spacing.s4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxMenuHeight),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(spacing.s8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildRows(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final borderWidths = context.borderWidth;

    final rows = <Widget>[];
    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      if (i > 0) rows.add(SizedBox(height: spacing.s2));
      rows.add(
        _NasikoComboboxOption(
          label: item.label,
          icon: item.icon,
          enabled: item.enabled,
          active: i == _activeIndex,
          onTap: item.enabled ? () => _select(item) : null,
        ),
      );
    }

    if (widget.isLoading) {
      if (rows.isNotEmpty) rows.add(SizedBox(height: spacing.s2));
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.s8),
          child: Center(
            child: NasikoSpinner(
              size: iconSizes.s,
              strokeWidth: borderWidths.w2,
            ),
          ),
        ),
      );
    } else if (widget.items.isEmpty) {
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s8,
          ),
          child: Text(
            widget.emptyLabel,
            style: typography.bodySecondary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildOverlayChild(BuildContext context) {
    final gap = context.spacing.s4;
    final targetAnchor = _openAbove ? Alignment.topLeft : Alignment.bottomLeft;
    final followerAnchor = _openAbove
        ? Alignment.bottomLeft
        : Alignment.topLeft;

    return CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      offset: Offset(0, _openAbove ? -gap : gap),
      child: Align(
        alignment: followerAnchor,
        child: TapRegion(
          groupId: this,
          onTapOutside: (_) => _handleOutsideTap(),
          // Entrance only — removal stays instant, matching the subtle &
          // fast motion personality (and NasikoPopover's behavior).
          child: NasikoOverlayReveal(
            slideFrom: Offset(0, _openAbove ? 4 : -4),
            child: _buildSurface(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final motion = context.motion;

    final enabled = widget.enabled;
    final borderColor = !enabled
        ? colors.borderDisabled
        : _isFocused
        ? colors.borderSecondary
        : colors.borderPrimary;

    final field = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!enabled) return;
        if (_focusNode.hasFocus) {
          // On web the engine can silently drop the text input connection
          // while the node stays focused; requestKeyboard reopens it
          // (same workaround as NasikoTextBox).
          _focusNode.context
              ?.findAncestorStateOfType<EditableTextState>()
              ?.requestKeyboard();
        } else {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      },
      child: AnimatedContainer(
        // Decorative focus fade — raw token per the motion convention.
        duration: motion.fast,
        curve: motion.enter,
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s12,
        ),
        decoration: BoxDecoration(
          color: enabled ? colors.backgroundBase : colors.backgroundDisabled,
          borderRadius: BorderRadius.circular(radii.r12),
          border: Border.all(color: borderColor, width: borderWidths.w1),
        ),
        child: Focus(
          onKeyEvent: _handleKey,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: enabled,
            maxLines: 1,
            onChanged: _handleTextChanged,
            // Keep focus in the field when Enter is pressed with nothing
            // highlighted — the default action would blur it.
            onEditingComplete: _noop,
            cursorColor: colors.borderSecondary,
            style: typography.bodySecondary.copyWith(
              color: enabled
                  ? colors.foregroundPrimary
                  : colors.foregroundDisabled,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: typography.bodySecondary.copyWith(
                color: enabled
                    ? colors.foregroundSecondary
                    : colors.foregroundDisabled,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlayChild,
      child: CompositedTransformTarget(
        link: _link,
        // Same tap group as the surface so taps on the field never count
        // as "outside" — mirrors NasikoPopover.
        child: TapRegion(groupId: this, child: field),
      ),
    );
  }

  static void _noop() {}
}

/// One row in the combobox popover: hover + keyboard-highlight visuals,
/// optional leading icon, greyout when disabled. Scrolls itself into view
/// when it becomes the keyboard-highlighted option.
class _NasikoComboboxOption extends StatefulWidget {
  const _NasikoComboboxOption({
    required this.label,
    required this.enabled,
    required this.active,
    required this.onTap,
    this.icon,
  });

  final String label;
  final HugeIconsType? icon;
  final bool enabled;

  /// Whether this row is the keyboard-highlighted one.
  final bool active;
  final VoidCallback? onTap;

  @override
  State<_NasikoComboboxOption> createState() => _NasikoComboboxOptionState();
}

class _NasikoComboboxOptionState extends State<_NasikoComboboxOption> {
  bool _isHovered = false;

  @override
  void didUpdateWidget(covariant _NasikoComboboxOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      // Keep the highlight visible inside the scrollable popover.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Scrollable.ensureVisible(context, alignment: 0.5);
      });
    }
  }

  void _setHovered(bool value) {
    if (value != _isHovered) setState(() => _isHovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final iconSizes = context.iconSize;
    final motion = context.motion;

    final isHighlighted = widget.enabled && (_isHovered || widget.active);
    final foregroundColor = widget.enabled
        ? colors.foregroundPrimary
        : colors.foregroundDisabled;

    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: widget.enabled,
        selected: widget.active,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
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
                      style: typography.bodySecondary.copyWith(
                        color: foregroundColor,
                      ),
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
