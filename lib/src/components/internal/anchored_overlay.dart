// lib/src/components/internal/anchored_overlay.dart

import 'package:flutter/widgets.dart';

import 'overlay_reveal.dart';

// Positioning strategy: sealed anchor model (auto / manual / global),
// anchor-rect tracking on scroll + window resize, and OverlayPortal
// foundation. Measured positioning avoids the common two-pass "render
// invisibly, measure, re-position" approach: the child's measured size
// arrives inside [NasikoAnchoredPositionDelegate.getPositionForChild]
// (single layout pass — no invisible first frame), where flip-on-overflow
// and screen-edge clamping are computed exactly.

/// Distance (logical px) the entrance reveal slides from, matching the
/// existing popover/menu reveal offsets.
const double _kRevealDistance = 4.0;

/// The edge of the anchor an auto-positioned overlay prefers to attach to.
enum NasikoAnchorSide { top, bottom, left, right }

extension on NasikoAnchorSide {
  NasikoAnchorSide get opposite => switch (this) {
        NasikoAnchorSide.top => NasikoAnchorSide.bottom,
        NasikoAnchorSide.bottom => NasikoAnchorSide.top,
        NasikoAnchorSide.left => NasikoAnchorSide.right,
        NasikoAnchorSide.right => NasikoAnchorSide.left,
      };

  bool get isVertical =>
      this == NasikoAnchorSide.top || this == NasikoAnchorSide.bottom;
}

/// Cross-axis alignment of an auto-positioned overlay against its anchor.
///
/// For vertical sides (top/bottom) this is horizontal alignment; for
/// horizontal sides (left/right) it is vertical alignment. Alignments are
/// physical (start = left / top) to match the existing popover contract;
/// RTL-aware resolution is a possible later refinement.
enum NasikoAnchorAlignment { start, center, end }

/// How a [NasikoAnchoredOverlay] positions its overlay.
///
/// Sealed so the engine can exhaustively switch on the three strategies.
sealed class NasikoAnchorBase {
  const NasikoAnchorBase();
}

/// Measured auto-positioning: preferred [side] + [alignment], flip to the
/// opposite side when the overlay doesn't fit, and clamp the final position
/// to the overlay bounds inset by [screenPadding].
@immutable
class NasikoAutoAnchor extends NasikoAnchorBase {
  const NasikoAutoAnchor({
    this.side = NasikoAnchorSide.bottom,
    this.alignment = NasikoAnchorAlignment.start,
    this.gap = 0.0,
    this.offset = Offset.zero,
    this.screenPadding = 8.0,
  });

  /// Preferred side of the anchor to open on.
  final NasikoAnchorSide side;

  /// Cross-axis alignment against the anchor's edges.
  final NasikoAnchorAlignment alignment;

  /// Main-axis distance between the anchor edge and the overlay. Flips with
  /// the resolved side. Pass a spacing token (e.g. `context.spacing.s4`).
  final double gap;

  /// Extra offset applied after side/alignment resolution, before clamping.
  final Offset offset;

  /// Minimum distance kept between the overlay and every screen edge.
  final double screenPadding;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NasikoAutoAnchor &&
        other.side == side &&
        other.alignment == alignment &&
        other.gap == gap &&
        other.offset == offset &&
        other.screenPadding == screenPadding;
  }

  @override
  int get hashCode =>
      Object.hash(side, alignment, gap, offset, screenPadding);
}

/// Pure follower positioning via [CompositedTransformFollower]: the overlay's
/// [followerAnchor] point is pinned to the anchor's [targetAnchor] point plus
/// [offset]. No measurement, no flip, no clamping — paint-time accurate even
/// while the anchor moves.
@immutable
class NasikoManualAnchor extends NasikoAnchorBase {
  const NasikoManualAnchor({
    this.targetAnchor = Alignment.bottomLeft,
    this.followerAnchor = Alignment.topLeft,
    this.offset = Offset.zero,
  });

  /// Point on the anchor the overlay attaches to.
  final AlignmentGeometry targetAnchor;

  /// Point on the overlay pinned to [targetAnchor].
  final AlignmentGeometry followerAnchor;

  /// Extra translation applied after anchoring.
  final Offset offset;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NasikoManualAnchor &&
        other.targetAnchor == targetAnchor &&
        other.followerAnchor == followerAnchor &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(targetAnchor, followerAnchor, offset);
}

/// Absolute positioning at [position], expressed in the overlay's coordinate
/// space (a zero-size anchor). Enables right-click / long-press context
/// menus: pass the pointer's position, and the overlay opens on [side] of it
/// with the same flip + clamp treatment as [NasikoAutoAnchor].
@immutable
class NasikoGlobalAnchor extends NasikoAnchorBase {
  const NasikoGlobalAnchor(
    this.position, {
    this.side = NasikoAnchorSide.bottom,
    this.alignment = NasikoAnchorAlignment.start,
    this.screenPadding = 8.0,
  });

  /// The point (overlay coordinates) the overlay opens from.
  final Offset position;

  /// Preferred side of [position] to open on.
  final NasikoAnchorSide side;

  /// Cross-axis alignment against [position].
  final NasikoAnchorAlignment alignment;

  /// Minimum distance kept between the overlay and every screen edge.
  final double screenPadding;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NasikoGlobalAnchor &&
        other.position == position &&
        other.side == side &&
        other.alignment == alignment &&
        other.screenPadding == screenPadding;
  }

  @override
  int get hashCode => Object.hash(position, side, alignment, screenPadding);
}

/// Builds the overlay surface. [side] is the side the overlay resolved to
/// (post-flip for auto/global anchors) — useful for arrows or side-dependent
/// styling. Dismissal (tap-outside, Escape, focus) stays with the caller.
typedef NasikoAnchoredOverlayBuilder = Widget Function(
  BuildContext context,
  NasikoAnchorSide side,
);

/// Internal anchored-overlay engine shared by floating surfaces (popover
/// today; menu/select in a later wave).
///
/// Renders [overlayBuilder] through an [OverlayPortal] attached to [child],
/// positioned by [anchor]. Visibility is declarative via [visible]; show/hide
/// is synced post-frame so callers may flip it during build.
///
/// Auto/global anchors get measured flip-on-overflow + screen-edge clamping
/// via [NasikoAnchoredPositionDelegate]; the anchor rect is re-measured on
/// scroll (nearest [ScrollNotificationObserver]) and on window resize.
///
/// Entrance animates with [NasikoOverlayReveal] sliding away from the
/// resolved side (motion tokens, reduced-motion aware); removal is instant,
/// matching the package's motion personality. Set [animateEntrance] to false
/// to opt out.
///
/// Not exported from the package barrel — internal use only.
class NasikoAnchoredOverlay extends StatefulWidget {
  const NasikoAnchoredOverlay({
    super.key,
    required this.visible,
    required this.anchor,
    required this.overlayBuilder,
    required this.child,
    this.animateEntrance = true,
  });

  /// Whether the overlay is shown. Synced to the portal post-frame.
  final bool visible;

  /// Positioning strategy.
  final NasikoAnchorBase anchor;

  /// Builds the overlay surface (see [NasikoAnchoredOverlayBuilder]).
  final NasikoAnchoredOverlayBuilder overlayBuilder;

  /// The anchor widget the overlay attaches to.
  final Widget child;

  /// Wrap the surface in the shared entrance reveal.
  final bool animateEntrance;

  @override
  State<NasikoAnchoredOverlay> createState() => _NasikoAnchoredOverlayState();
}

class _NasikoAnchoredOverlayState extends State<NasikoAnchoredOverlay> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();

  /// Anchor rect in overlay coordinates; measured for auto anchors only.
  Rect? _anchorRect;

  /// Side the position delegate actually placed the overlay on. Null until
  /// first layout; used to orient the entrance reveal and inform the builder.
  NasikoAnchorSide? _resolvedSide;

  // Re-measure the anchor rect while an ancestor scrolls (via a
  // ScrollNotificationObserver subscription).
  ScrollNotificationObserverState? _scrollObserver;
  bool _rectUpdateScheduled = false;

  bool get _needsAnchorRect => widget.anchor is NasikoAutoAnchor;

  @override
  void initState() {
    super.initState();
    _syncVisibility();
  }

  @override
  void didUpdateWidget(covariant NasikoAnchoredOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final visibilityChanged = widget.visible != oldWidget.visible;
    final anchorChanged = widget.anchor != oldWidget.anchor;
    if (visibilityChanged || (widget.visible && anchorChanged)) {
      if (anchorChanged) _resolvedSide = null;
      _syncVisibility();
    }
    _syncScrollObserver();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncScrollObserver();
    // MediaQuery size is a dependency of build() while visible, so window
    // resizes land here: re-measure the anchor against the new overlay size.
    if (widget.visible && _needsAnchorRect) _scheduleAnchorRectUpdate();
  }

  @override
  void dispose() {
    _unsubscribeScrollObserver();
    super.dispose();
  }

  // ── Visibility ────────────────────────────────────────────────────────

  /// Syncs the portal with [NasikoAnchoredOverlay.visible] post-frame, since
  /// [OverlayPortalController.show]/[OverlayPortalController.hide] must not
  /// run during build.
  void _syncVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.visible) {
        if (_needsAnchorRect) _updateAnchorRect();
        if (!_portal.isShowing) _portal.show();
      } else {
        if (_portal.isShowing) _portal.hide();
        _anchorRect = null;
        _resolvedSide = null;
      }
      _syncScrollObserver();
    });
  }

  // ── Anchor tracking ───────────────────────────────────────────────────

  void _syncScrollObserver() {
    final shouldListen = widget.visible && _needsAnchorRect;
    if (!shouldListen) {
      _unsubscribeScrollObserver();
      return;
    }
    final observer = ScrollNotificationObserver.maybeOf(context);
    if (identical(observer, _scrollObserver)) return;
    _unsubscribeScrollObserver();
    _scrollObserver = observer;
    _scrollObserver?.addListener(_handleScrollNotification);
  }

  void _unsubscribeScrollObserver() {
    _scrollObserver?.removeListener(_handleScrollNotification);
    _scrollObserver = null;
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (!widget.visible || !_needsAnchorRect) return;
    // Depth-0 updates only: track the closest scrollable, not nested ones.
    if (notification is ScrollUpdateNotification &&
        defaultScrollNotificationPredicate(notification)) {
      _scheduleAnchorRectUpdate();
    }
  }

  void _scheduleAnchorRectUpdate() {
    if (_rectUpdateScheduled) return;
    _rectUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rectUpdateScheduled = false;
      if (mounted && widget.visible && _needsAnchorRect) _updateAnchorRect();
    });
  }

  /// Measures the anchor's rect in the overlay's coordinate space (not
  /// screen space — they differ when the Overlay itself is offset, common on
  /// Flutter web).
  void _updateAnchorRect() {
    final box = context.findRenderObject();
    final overlayState = Overlay.of(context, debugRequiredFor: widget);
    final overlayBox = overlayState.context.findRenderObject();

    final ready = box is RenderBox &&
        box.attached &&
        box.hasSize &&
        overlayBox is RenderBox &&
        overlayBox.attached &&
        overlayBox.hasSize;
    if (!ready) {
      // First layout hasn't happened yet (e.g. visible at mount) — retry.
      _scheduleAnchorRectUpdate();
      return;
    }

    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final rect = topLeft & box.size;
    if (rect != _anchorRect) {
      setState(() => _anchorRect = rect);
    }
  }

  // ── Side resolution / reveal ──────────────────────────────────────────

  /// Called by the delegate during layout; defers the rebuild so the reveal
  /// direction updates on the next frame without mutating state mid-layout.
  void _handleSideResolved(NasikoAnchorSide side) {
    if (_resolvedSide == side) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.visible || _resolvedSide == side) return;
      setState(() => _resolvedSide = side);
    });
  }

  /// Entrance slides away from the anchor: e.g. an overlay below its anchor
  /// starts [_kRevealDistance] px up (near the anchor) and settles downward.
  Offset _slideFromFor(NasikoAnchorSide side) => switch (side) {
        NasikoAnchorSide.bottom => const Offset(0, -_kRevealDistance),
        NasikoAnchorSide.top => const Offset(0, _kRevealDistance),
        NasikoAnchorSide.right => const Offset(-_kRevealDistance, 0),
        NasikoAnchorSide.left => const Offset(_kRevealDistance, 0),
      };

  Widget _buildSurface(BuildContext context, NasikoAnchorSide side) {
    final surface = widget.overlayBuilder(context, side);
    if (!widget.animateEntrance) return surface;
    return NasikoOverlayReveal(
      slideFrom: _slideFromFor(side),
      child: surface,
    );
  }

  // ── Overlay child per anchor strategy ─────────────────────────────────

  Widget _buildAuto(BuildContext context, NasikoAutoAnchor anchor) {
    final rect = _anchorRect;
    // Rect not measured yet (first frame when visible at mount) — render
    // nothing; _updateAnchorRect retries and rebuilds.
    if (rect == null) return const SizedBox.shrink();

    final side = _resolvedSide ?? anchor.side;
    return CustomSingleChildLayout(
      delegate: NasikoAnchoredPositionDelegate(
        anchorRect: rect,
        preferredSide: anchor.side,
        alignment: anchor.alignment,
        gap: anchor.gap,
        offset: anchor.offset,
        screenPadding: anchor.screenPadding,
        onSideResolved: _handleSideResolved,
      ),
      child: _buildSurface(context, side),
    );
  }

  Widget _buildManual(BuildContext context, NasikoManualAnchor anchor) {
    final textDirection = Directionality.maybeOf(context);
    final target = anchor.targetAnchor.resolve(textDirection);
    final follower = anchor.followerAnchor.resolve(textDirection);
    final side = _sideForManual(target, follower);
    return CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      targetAnchor: target,
      followerAnchor: follower,
      offset: anchor.offset,
      // Align keeps placement correct whether the overlay lays the follower
      // out tight (full-size) or loose (shrink-wrapped).
      child: Align(
        alignment: follower,
        child: _buildSurface(context, side),
      ),
    );
  }

  /// Derives the dominant opening direction of a manual anchor pair so the
  /// reveal can slide away from the anchor.
  NasikoAnchorSide _sideForManual(Alignment target, Alignment follower) {
    if (target.y > follower.y) return NasikoAnchorSide.bottom;
    if (target.y < follower.y) return NasikoAnchorSide.top;
    if (target.x > follower.x) return NasikoAnchorSide.right;
    if (target.x < follower.x) return NasikoAnchorSide.left;
    return NasikoAnchorSide.bottom;
  }

  Widget _buildGlobal(BuildContext context, NasikoGlobalAnchor anchor) {
    final side = _resolvedSide ?? anchor.side;
    return CustomSingleChildLayout(
      delegate: NasikoAnchoredPositionDelegate(
        // A zero-size anchor rect at the global point reuses the full
        // side/flip/clamp pipeline.
        anchorRect: anchor.position & Size.zero,
        preferredSide: anchor.side,
        alignment: anchor.alignment,
        gap: 0.0,
        offset: Offset.zero,
        screenPadding: anchor.screenPadding,
        onSideResolved: _handleSideResolved,
      ),
      child: _buildSurface(context, side),
    );
  }

  Widget _buildOverlayChild(BuildContext context) {
    return switch (widget.anchor) {
      final NasikoAutoAnchor anchor => _buildAuto(context, anchor),
      final NasikoManualAnchor anchor => _buildManual(context, anchor),
      final NasikoGlobalAnchor anchor => _buildGlobal(context, anchor),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Register a MediaQuery dependency while auto-positioned and visible so
    // window resizes trigger didChangeDependencies → anchor re-measure.
    if (widget.visible && _needsAnchorRect) {
      MediaQuery.maybeSizeOf(context);
    }
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlayChild,
        child: widget.child,
      ),
    );
  }
}

/// Positions an anchored overlay within the full overlay bounds.
///
/// [getPositionForChild] receives the measured child size, so preferred-side
/// placement, flip-on-overflow, and clamping to padded screen bounds all
/// happen in a single layout pass. [getConstraintsForChild] also caps the
/// child to the padded bounds so oversized surfaces shrink instead of
/// overflowing the screen.
class NasikoAnchoredPositionDelegate extends SingleChildLayoutDelegate {
  NasikoAnchoredPositionDelegate({
    required this.anchorRect,
    required this.preferredSide,
    required this.alignment,
    required this.gap,
    required this.offset,
    required this.screenPadding,
    this.onSideResolved,
  });

  /// Anchor rect in the overlay's coordinate space.
  final Rect anchorRect;

  /// Side to attempt first; flipped when the child doesn't fit.
  final NasikoAnchorSide preferredSide;

  /// Cross-axis alignment against the anchor.
  final NasikoAnchorAlignment alignment;

  /// Main-axis distance between anchor edge and child.
  final double gap;

  /// Extra offset applied before clamping.
  final Offset offset;

  /// Minimum distance kept from every screen edge.
  final double screenPadding;

  /// Reports the side the child was actually placed on (called during
  /// layout — implementations must not mutate state synchronously).
  final ValueChanged<NasikoAnchorSide>? onSideResolved;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth - screenPadding * 2;
    final maxHeight = constraints.maxHeight - screenPadding * 2;
    return BoxConstraints(
      maxWidth: maxWidth > 0 ? maxWidth : 0,
      maxHeight: maxHeight > 0 ? maxHeight : 0,
    );
  }

  /// Free space available on [side] of the anchor, inside the padded bounds.
  double _spaceOn(NasikoAnchorSide side, Size size) => switch (side) {
        NasikoAnchorSide.top => anchorRect.top - gap - screenPadding,
        NasikoAnchorSide.bottom =>
          size.height - anchorRect.bottom - gap - screenPadding,
        NasikoAnchorSide.left => anchorRect.left - gap - screenPadding,
        NasikoAnchorSide.right =>
          size.width - anchorRect.right - gap - screenPadding,
      };

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Resolve the side: keep the preferred side unless the child overflows
    // it and the opposite side either fits or simply has more room.
    var side = preferredSide;
    final neededExtent =
        side.isVertical ? childSize.height : childSize.width;
    final preferredSpace = _spaceOn(side, size);
    if (preferredSpace < neededExtent) {
      final oppositeSpace = _spaceOn(side.opposite, size);
      if (oppositeSpace >= neededExtent || oppositeSpace > preferredSpace) {
        side = side.opposite;
      }
    }
    onSideResolved?.call(side);

    // Main axis: attach to the resolved side with the gap.
    double x;
    double y;
    switch (side) {
      case NasikoAnchorSide.bottom:
        y = anchorRect.bottom + gap;
        x = _crossAxis(anchorRect.left, anchorRect.right, childSize.width);
      case NasikoAnchorSide.top:
        y = anchorRect.top - gap - childSize.height;
        x = _crossAxis(anchorRect.left, anchorRect.right, childSize.width);
      case NasikoAnchorSide.right:
        x = anchorRect.right + gap;
        y = _crossAxis(anchorRect.top, anchorRect.bottom, childSize.height);
      case NasikoAnchorSide.left:
        x = anchorRect.left - gap - childSize.width;
        y = _crossAxis(anchorRect.top, anchorRect.bottom, childSize.height);
    }

    x += offset.dx;
    y += offset.dy;

    // Clamp to padded screen bounds (upper bound guarded so children wider
    // or taller than the padded area pin to the leading edge).
    final maxX = size.width - childSize.width - screenPadding;
    final maxY = size.height - childSize.height - screenPadding;
    x = _clampDouble(
        x, screenPadding, maxX < screenPadding ? screenPadding : maxX);
    y = _clampDouble(
        y, screenPadding, maxY < screenPadding ? screenPadding : maxY);

    return Offset(x, y);
  }

  /// double.clamp returns num; this keeps the math in doubles.
  static double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Cross-axis position between the anchor's [leading]/[trailing] edges.
  double _crossAxis(double leading, double trailing, double childExtent) =>
      switch (alignment) {
        NasikoAnchorAlignment.start => leading,
        NasikoAnchorAlignment.center =>
          leading + (trailing - leading - childExtent) / 2,
        NasikoAnchorAlignment.end => trailing - childExtent,
      };

  @override
  bool shouldRelayout(NasikoAnchoredPositionDelegate oldDelegate) {
    return anchorRect != oldDelegate.anchorRect ||
        preferredSide != oldDelegate.preferredSide ||
        alignment != oldDelegate.alignment ||
        gap != oldDelegate.gap ||
        offset != oldDelegate.offset ||
        screenPadding != oldDelegate.screenPadding;
  }
}
