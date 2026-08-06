// lib/src/components/resizable/resizable.dart

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

// Resize algorithm:
// - drag uses an ABSOLUTE delta from a layout snapshot taken at drag start
//   (recomputed from the snapshot on every pointer move), eliminating
//   floating-point drift and giving natural drag reversal;
// - the delta is capped to min(total shrinkable, total expandable), then
//   distributed by shrinking panels on the far side of the divider outward
//   from the pivot, growing the pivot panel, and cascading any overflow to
//   the remaining panels on the near side;
// - a layout is rejected unless it still sums to ~1.0;
// - double-tapping a divider resets the adjacent pair toward its defaults;
// - horizontal drags invert under RTL.
// Design notes: sizes are expressed as flex factors (normalized internally
// to fractions); the grip is hover/focus-revealed on our motion tokens;
// arrow keys resize a focused divider (keyboard resize is a first-class
// interaction here); no global mouse-cursor override while dragging past a
// panel's limit.

/// Configuration for one panel inside a [NasikoResizablePanelGroup].
///
/// Sizes are flex factors, like [Expanded.flex] but continuous: a panel's
/// share of the main axis is `flex / totalFlex`. [minFlex] / [maxFlex] are in
/// the same unit and are normalized against the group's total *default* flex,
/// so `NasikoResizablePanel(defaultFlex: 340, minFlex: 240, maxFlex: 480)`
/// next to `NasikoResizablePanel(defaultFlex: 660)` reads like pixel widths
/// of a 1000-unit layout.
@immutable
class NasikoResizablePanel {
  const NasikoResizablePanel({
    required this.child,
    this.defaultFlex = 1.0,
    this.minFlex,
    this.maxFlex,
  })  : assert(defaultFlex > 0, 'defaultFlex must be > 0'),
        assert(minFlex == null || minFlex >= 0, 'minFlex must be >= 0'),
        assert(
          minFlex == null || minFlex <= defaultFlex,
          'minFlex must be <= defaultFlex',
        ),
        assert(
          maxFlex == null || maxFlex >= defaultFlex,
          'maxFlex must be >= defaultFlex',
        );

  /// The panel's content. Clipped while smaller than its intrinsic size.
  final Widget child;

  /// Initial share of the main axis, relative to the other panels' flexes.
  final double defaultFlex;

  /// Smallest share the panel can be dragged to (same unit as [defaultFlex]).
  final double? minFlex;

  /// Largest share the panel can be dragged to (same unit as [defaultFlex]).
  final double? maxFlex;
}

/// A row or column of panels separated by draggable dividers.
///
/// - Dragging a divider resizes the two adjacent panels; when a neighbor
///   hits its min/max the remainder cascades to the next panel on that side
///   (redistribution algorithm, see file header).
/// - Divider affordance: a hairline that brightens on hover plus a grip pill
///   revealed on hover/focus/drag (animated at `motion.hover`); the cursor
///   becomes a resize cursor over the divider.
/// - Double-tapping a divider resets the adjacent pair toward its default
///   sizes ([resetOnDoubleTap]).
/// - Keyboard: dividers are focusable; Left/Right (horizontal) or Up/Down
///   (vertical) arrows move the focused divider by 2% of the group per press.
/// - [onLayoutChanged] reports the normalized panel fractions (sum ≈ 1.0)
///   after every applied change, enabling layout persistence.
///
/// Changing the panel *count or flex configuration* resets the layout to the
/// new defaults — a deterministic reset was chosen over leftover-space
/// heuristics (e.g. spreading freed space across added panels).
///
/// Replacing the app's `CollapsibleSplitPane`
/// (`web/lib/widgets/collapsible_split_pane.dart`) later:
/// `listPane` maps to `NasikoResizablePanel(defaultFlex: 340, minFlex: 240,
/// maxFlex: 480, child: listPane)` and `detailPane` to a flexible
/// `NasikoResizablePanel(defaultFlex: 660)` (its `listWidth: 340` becomes the
/// default flex of a ~1000-unit layout). Its animated collapse-to-strip
/// (`isExpandedNotifier` + `collapsedChild`) is orthogonal to drag-resizing
/// and would layer on as a future `collapsedExtent` API rather than being
/// emulated with `minFlex: 0`.
class NasikoResizablePanelGroup extends StatefulWidget {
  const NasikoResizablePanelGroup({
    super.key,
    required this.panels,
    this.axis = Axis.horizontal,
    this.onLayoutChanged,
    this.resetOnDoubleTap = true,
  }) : assert(panels.length > 0, 'panels must not be empty');

  /// Panel configurations, in main-axis order.
  final List<NasikoResizablePanel> panels;

  /// Main axis of the group.
  final Axis axis;

  /// Called with the normalized fractions (one per panel, summing to ~1.0)
  /// after every applied resize, reset, or keyboard step.
  final ValueChanged<List<double>>? onLayoutChanged;

  /// Whether double-tapping a divider resets the two adjacent panels toward
  /// their default sizes.
  final bool resetOnDoubleTap;

  @override
  State<NasikoResizablePanelGroup> createState() =>
      _NasikoResizablePanelGroupState();
}

class _NasikoResizablePanelGroupState extends State<NasikoResizablePanelGroup> {
  /// Fraction step applied per arrow-key press on a focused divider.
  static const double _keyboardStep = 0.02;

  /// Current panel fractions; always sums to ~1.0.
  late List<double> _fractions;

  late List<double> _defaultFractions;
  late List<double> _minFractions;
  late List<double> _maxFractions;

  /// Snapshot of [_fractions] at drag start (absolute-delta approach).
  List<double>? _dragInitialLayout;

  /// Main-axis global pointer position at drag start.
  double? _dragStartPosition;

  /// Main-axis extent available to panels (constraints minus dividers),
  /// captured during layout for pixel→fraction conversion.
  double _availableExtent = 0.0;

  bool get _isHorizontal => widget.axis == Axis.horizontal;

  @override
  void initState() {
    super.initState();
    _normalizeFromPanels();
  }

  @override
  void didUpdateWidget(covariant NasikoResizablePanelGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_panelConfigChanged(oldWidget.panels, widget.panels)) {
      _dragInitialLayout = null;
      _dragStartPosition = null;
      _normalizeFromPanels();
    }
  }

  bool _panelConfigChanged(
    List<NasikoResizablePanel> a,
    List<NasikoResizablePanel> b,
  ) {
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i].defaultFlex != b[i].defaultFlex ||
          a[i].minFlex != b[i].minFlex ||
          a[i].maxFlex != b[i].maxFlex) {
        return true;
      }
    }
    return false;
  }

  /// Converts flex factors into normalized fractions and min/max bounds.
  void _normalizeFromPanels() {
    final panels = widget.panels;
    final totalFlex =
        panels.fold<double>(0.0, (sum, p) => sum + p.defaultFlex);
    _defaultFractions = <double>[
      for (final p in panels) _asFixed(p.defaultFlex / totalFlex),
    ];
    _minFractions = <double>[
      for (final p in panels)
        _clampDouble(_asFixed((p.minFlex ?? 0.0) / totalFlex), 0.0, 1.0),
    ];
    _maxFractions = <double>[
      for (final p in panels)
        p.maxFlex == null
            ? 1.0
            : _clampDouble(_asFixed(p.maxFlex! / totalFlex), 0.0, 1.0),
    ];
    _fractions = List<double>.of(_defaultFractions);
  }

  // ── Resize math ────────────────────────────────────────────────────────

  /// Rounds to 6 fractional digits so repeated arithmetic stays drift-free
  /// and deterministic.
  static double _asFixed(double value) =>
      double.parse(value.toStringAsFixed(6));

  static double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Recomputes the whole layout from [initialLayout] for a total [delta]
  /// (fraction of the group, positive = towards the trailing edge) applied
  /// at the divider after panel [leadingPivot]. Invalid results (sum drifts
  /// from 1.0) are discarded, keeping the current layout.
  void _applyDelta({
    required double delta,
    required List<double> initialLayout,
    required int leadingPivot,
  }) {
    if (delta.abs() < 1e-9) {
      _setFractions(initialLayout);
      return;
    }

    final trailingPivot = leadingPivot + 1;
    final next = List<double>.of(initialLayout);

    if (delta > 0) {
      // Forward drag: shrink trailing panels, grow the leading side.

      // Phase 0: cap delta to min(totalShrinkable, totalExpandable).
      var totalShrinkable = 0.0;
      for (var i = trailingPivot; i < next.length; i++) {
        totalShrinkable += initialLayout[i] - _minFractions[i];
      }
      var totalExpandable =
          _maxFractions[leadingPivot] - initialLayout[leadingPivot];
      for (var i = leadingPivot - 1; i >= 0; i--) {
        totalExpandable += _maxFractions[i] - initialLayout[i];
      }
      final cappedDelta =
          math.min(delta, math.min(totalShrinkable, totalExpandable));

      // Phase 1: shrink trailing panels from the pivot outward.
      var applied = 0.0;
      for (var i = trailingPivot; i < next.length; i++) {
        final available = next[i] - _minFractions[i];
        if (available < 1e-9) continue;
        final shrink = _clampDouble(cappedDelta - applied, 0.0, available);
        next[i] = _asFixed(next[i] - shrink);
        applied = _asFixed(applied + shrink);
        if ((cappedDelta - applied).abs() < 1e-9) break;
      }

      // Phase 2: grow the leading pivot panel.
      final canGrow = _maxFractions[leadingPivot] - next[leadingPivot];
      final grow = _clampDouble(applied, 0.0, canGrow);
      next[leadingPivot] = _asFixed(next[leadingPivot] + grow);
      var overflow = _asFixed(applied - grow);

      // Phase 3: cascade overflow to the other leading panels.
      if (overflow > 1e-9) {
        for (var i = leadingPivot - 1; i >= 0; i--) {
          final canGrowI = _maxFractions[i] - next[i];
          final growI = _clampDouble(overflow, 0.0, canGrowI);
          next[i] = _asFixed(next[i] + growI);
          overflow = _asFixed(overflow - growI);
          if (overflow < 1e-9) break;
        }
      }
    } else {
      // Backward drag: shrink leading panels, grow the trailing side.
      final absDelta = -delta;

      // Phase 0: cap delta to min(totalShrinkable, totalExpandable).
      var totalShrinkable = 0.0;
      for (var i = leadingPivot; i >= 0; i--) {
        totalShrinkable += initialLayout[i] - _minFractions[i];
      }
      var totalExpandable =
          _maxFractions[trailingPivot] - initialLayout[trailingPivot];
      for (var i = trailingPivot + 1; i < next.length; i++) {
        totalExpandable += _maxFractions[i] - initialLayout[i];
      }
      final cappedDelta =
          math.min(absDelta, math.min(totalShrinkable, totalExpandable));

      // Phase 1: shrink leading panels from the pivot outward.
      var applied = 0.0;
      for (var i = leadingPivot; i >= 0; i--) {
        final available = next[i] - _minFractions[i];
        if (available < 1e-9) continue;
        final shrink = _clampDouble(cappedDelta - applied, 0.0, available);
        next[i] = _asFixed(next[i] - shrink);
        applied = _asFixed(applied + shrink);
        if ((cappedDelta - applied).abs() < 1e-9) break;
      }

      // Phase 2: grow the trailing pivot panel.
      final canGrow = _maxFractions[trailingPivot] - next[trailingPivot];
      final grow = _clampDouble(applied, 0.0, canGrow);
      next[trailingPivot] = _asFixed(next[trailingPivot] + grow);
      var overflow = _asFixed(applied - grow);

      // Phase 3: cascade overflow to the other trailing panels.
      if (overflow > 1e-9) {
        for (var i = trailingPivot + 1; i < next.length; i++) {
          final canGrowI = _maxFractions[i] - next[i];
          final growI = _clampDouble(overflow, 0.0, canGrowI);
          next[i] = _asFixed(next[i] + growI);
          overflow = _asFixed(overflow - growI);
          if (overflow < 1e-9) break;
        }
      }
    }

    // Validation: layout must still sum to ~1.0.
    final sum = next.fold<double>(0.0, (a, b) => a + b);
    if ((sum - 1.0).abs() > 0.01) return;

    _setFractions(next);
  }

  void _setFractions(List<double> next) {
    if (listEquals(next, _fractions)) return;
    setState(() => _fractions = List<double>.of(next));
    widget.onLayoutChanged?.call(List<double>.unmodifiable(_fractions));
  }

  // ── Divider callbacks ───────────────────────────────────────────────────

  double _mainAxisPosition(Offset globalPosition) =>
      _isHorizontal ? globalPosition.dx : globalPosition.dy;

  void _handleDragStart(int index, DragStartDetails details) {
    _dragInitialLayout = List<double>.of(_fractions);
    _dragStartPosition = _mainAxisPosition(details.globalPosition);
  }

  void _handleDragUpdate(int index, DragUpdateDetails details) {
    final initialLayout = _dragInitialLayout;
    final startPosition = _dragStartPosition;
    if (initialLayout == null || startPosition == null) return;
    if (_availableExtent <= 0) return;

    var pixelDelta =
        _asFixed(_mainAxisPosition(details.globalPosition) - startPosition);

    // Invert the delta for RTL horizontal dragging (ported behavior).
    final rtl = Directionality.of(context) == TextDirection.rtl;
    if (rtl && _isHorizontal) pixelDelta = -pixelDelta;

    _applyDelta(
      delta: _asFixed(pixelDelta / _availableExtent),
      initialLayout: initialLayout,
      leadingPivot: index,
    );
  }

  void _handleDragEnd(int index) {
    _dragInitialLayout = null;
    _dragStartPosition = null;
  }

  /// Arrow-key resize: one fixed fractional step through the same pipeline
  /// as dragging. [direction] is +1 towards the trailing edge.
  void _handleStep(int index, int direction) {
    _applyDelta(
      delta: _keyboardStep * direction,
      initialLayout: List<double>.of(_fractions),
      leadingPivot: index,
    );
  }

  /// Double-tap reset: returns the two panels adjacent to divider [index]
  /// toward their default sizes. The pair's combined share is whatever the
  /// rest of the layout leaves available — assigning raw defaults instead
  /// could break the sum-to-1.0 invariant with 3+ panels; this keeps it
  /// intact.
  void _handleReset(int index) {
    if (!widget.resetOnDoubleTap) return;
    final leading = index;
    final trailing = index + 1;

    var others = 0.0;
    for (var i = 0; i < _fractions.length; i++) {
      if (i != leading && i != trailing) others += _fractions[i];
    }
    final available = _asFixed(1.0 - others);
    final defaultsSum =
        _defaultFractions[leading] + _defaultFractions[trailing];
    if (available <= 0 || defaultsSum <= 0) return;

    // Split the available share in the defaults' proportion, then clamp.
    var a = _asFixed(available * _defaultFractions[leading] / defaultsSum);
    a = _clampDouble(
      a,
      _minFractions[leading],
      math.min(_maxFractions[leading], available),
    );
    final b = _asFixed(available - a);
    if (b < _minFractions[trailing] || b > _maxFractions[trailing]) return;

    final next = List<double>.of(_fractions);
    next[leading] = a;
    next[trailing] = b;
    _setFractions(next);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final dividerExtent = spacing.s8;
    final dividerCount = widget.panels.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalExtent =
            _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
        _availableExtent =
            math.max(0.0, totalExtent - dividerExtent * dividerCount);

        final children = <Widget>[];
        for (var i = 0; i < widget.panels.length; i++) {
          children.add(
            Expanded(
              // 1e6 scale keeps rounding error < one part per million; the
              // floor of 1 avoids Flex's zero-flex degenerate case.
              flex: math.max(1, (_fractions[i] * 1000000).round()),
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: widget.panels[i].child,
              ),
            ),
          );
          if (i < dividerCount) {
            final dividerIndex = i;
            children.add(
              _ResizableDivider(
                axis: widget.axis,
                hitExtent: dividerExtent,
                onDragStart: (details) =>
                    _handleDragStart(dividerIndex, details),
                onDragUpdate: (details) =>
                    _handleDragUpdate(dividerIndex, details),
                onDragEnd: () => _handleDragEnd(dividerIndex),
                onDoubleTap: () => _handleReset(dividerIndex),
                onStep: (direction) => _handleStep(dividerIndex, direction),
              ),
            );
          }
        }

        return Flex(
          direction: widget.axis,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}

/// Divider handle between two panels: hairline + hover/focus-revealed grip,
/// resize cursor, drag/double-tap gestures, and arrow-key resizing.
class _ResizableDivider extends StatefulWidget {
  const _ResizableDivider({
    required this.axis,
    required this.hitExtent,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDoubleTap,
    required this.onStep,
  });

  final Axis axis;
  final double hitExtent;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onDoubleTap;

  /// +1 = towards the trailing edge (right/down in LTR), -1 = leading.
  final ValueChanged<int> onStep;

  @override
  State<_ResizableDivider> createState() => _ResizableDividerState();
}

class _ResizableDividerState extends State<_ResizableDivider> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'NasikoResizableDivider');

  bool _hovered = false;
  bool _dragging = false;
  bool _focused = false;

  bool get _isHorizontal => widget.axis == Axis.horizontal;

  bool get _active => _hovered || _dragging || _focused;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (_isHorizontal) {
      // Arrows are physical; invert under RTL so the divider follows the key.
      final rtl = Directionality.of(context) == TextDirection.rtl;
      if (key == LogicalKeyboardKey.arrowLeft) {
        widget.onStep(rtl ? 1 : -1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        widget.onStep(rtl ? -1 : 1);
        return KeyEventResult.handled;
      }
    } else {
      if (key == LogicalKeyboardKey.arrowUp) {
        widget.onStep(-1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        widget.onStep(1);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _setDragging(bool value) {
    if (_dragging == value) return;
    setState(() => _dragging = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    final lineColor = _active ? colors.borderHover : colors.borderPrimary;

    // Hairline through the middle of the hit area.
    final line = Center(
      child: AnimatedContainer(
        // Decorative hover fade — raw token by convention.
        duration: motion.hover,
        curve: motion.enter,
        width: _isHorizontal ? borderWidths.w1 : double.infinity,
        height: _isHorizontal ? double.infinity : borderWidths.w1,
        color: lineColor,
      ),
    );

    // Grip pill, revealed while hovered/focused/dragging.
    final grip = Center(
      child: AnimatedOpacity(
        opacity: _active ? 1.0 : 0.0,
        duration: motion.hover,
        curve: motion.enter,
        child: Container(
          width: _isHorizontal ? spacing.s4 : spacing.s32,
          height: _isHorizontal ? spacing.s32 : spacing.s4,
          decoration: BoxDecoration(
            color: colors.borderHover,
            borderRadius: BorderRadius.circular(radii.r4),
          ),
        ),
      ),
    );

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      onFocusChange: (value) => setState(() => _focused = value),
      child: MouseRegion(
        cursor: _isHorizontal
            ? SystemMouseCursors.resizeLeftRight
            : SystemMouseCursors.resizeUpDown,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: widget.onDoubleTap,
          onHorizontalDragStart: _isHorizontal
              ? (details) {
                  _setDragging(true);
                  _focusNode.requestFocus();
                  widget.onDragStart(details);
                }
              : null,
          onHorizontalDragUpdate: _isHorizontal ? widget.onDragUpdate : null,
          onHorizontalDragEnd: _isHorizontal
              ? (_) {
                  _setDragging(false);
                  widget.onDragEnd();
                }
              : null,
          onHorizontalDragCancel: _isHorizontal
              ? () {
                  _setDragging(false);
                  widget.onDragEnd();
                }
              : null,
          onVerticalDragStart: !_isHorizontal
              ? (details) {
                  _setDragging(true);
                  _focusNode.requestFocus();
                  widget.onDragStart(details);
                }
              : null,
          onVerticalDragUpdate: !_isHorizontal ? widget.onDragUpdate : null,
          onVerticalDragEnd: !_isHorizontal
              ? (_) {
                  _setDragging(false);
                  widget.onDragEnd();
                }
              : null,
          onVerticalDragCancel: !_isHorizontal
              ? () {
                  _setDragging(false);
                  widget.onDragEnd();
                }
              : null,
          child: Semantics(
            label: 'Resize handle',
            child: SizedBox(
              width: _isHorizontal ? widget.hitExtent : null,
              height: _isHorizontal ? null : widget.hitExtent,
              child: Stack(
                children: [line, grip],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
