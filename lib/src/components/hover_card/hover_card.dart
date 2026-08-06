// lib/src/components/hover_card/hover_card.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../internal/anchored_overlay.dart';

// Hover-intent handling: tooltip-style open/close delays, plus grouped
// hover regions — trigger and card behave as ONE hover area, so moving the
// pointer from the trigger onto the card keeps it open. Rather than a
// render-object registry, the linking is done with a MouseRegion on each
// side sharing state plus a close-grace timer that covers the pointer's
// travel across the gap.
//
// Delay defaults: openDelay 700ms / closeDelay 300ms — long enough to
// ignore incidental pointer passes, short enough to feel intentional.

/// Cross-axis alignment of the card against the trigger.
enum NasikoHoverCardAlignment { start, center, end }

/// Preferred side of the trigger the card opens on. Flips to the opposite
/// side automatically when the card doesn't fit.
enum NasikoHoverCardSide { top, bottom, left, right }

/// A non-modal card that opens after the pointer rests on [child] and closes
/// after it leaves both the trigger and the card — a rich, interactive
/// cousin of the tooltip (e.g. profile previews on an @mention).
///
/// Behavior:
/// - Opens [openDelay] (default 700ms) after the pointer enters the trigger;
///   leaving before the delay elapses cancels the open.
/// - Stays open while the pointer is over the trigger OR the card; the
///   [closeDelay] (default 300ms) grace period covers travel across the gap
///   between them and brief overshoots.
/// - Never steals focus: nothing here is focusable and no focus scope is
///   created, so text fields behind the card keep their caret. Because it is
///   hover-driven, the card is mouse-only — keep essential information
///   available through an accessible alternative (tap target, tooltip, or
///   inline text).
///
/// Positioning and the entrance reveal come from the shared
/// [NasikoAnchoredOverlay] engine (measured flip-on-overflow + screen-edge
/// clamping); removal is instant, matching the package's motion personality.
class NasikoHoverCard extends StatefulWidget {
  const NasikoHoverCard({
    super.key,
    required this.child,
    required this.contentBuilder,
    this.openDelay = const Duration(milliseconds: 700),
    this.closeDelay = const Duration(milliseconds: 300),
    this.side = NasikoHoverCardSide.bottom,
    this.alignment = NasikoHoverCardAlignment.center,
    this.width,
    this.padding,
    this.enabled = true,
  });

  /// The hover trigger.
  final Widget child;

  /// Builds the card's content, laid inside the card surface.
  final WidgetBuilder contentBuilder;

  /// Time the pointer must rest on the trigger before the card opens.
  final Duration openDelay;

  /// Grace period after the pointer leaves both trigger and card before the
  /// card closes.
  final Duration closeDelay;

  /// Preferred opening side (auto-flips on overflow).
  final NasikoHoverCardSide side;

  /// Cross-axis alignment against the trigger.
  final NasikoHoverCardAlignment alignment;

  /// Fixed card width. When null the card sizes to its content.
  final double? width;

  /// Content padding inside the card. Defaults to `spacing.s16` all around.
  final EdgeInsetsGeometry? padding;

  /// When false the card never opens (and closes if currently open).
  final bool enabled;

  @override
  State<NasikoHoverCard> createState() => _NasikoHoverCardState();
}

class _NasikoHoverCardState extends State<NasikoHoverCard> {
  bool _visible = false;
  bool _triggerHovered = false;
  bool _cardHovered = false;

  Timer? _openTimer;
  Timer? _closeTimer;

  @override
  void didUpdateWidget(covariant NasikoHoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) {
      _cancelTimers();
      if (_visible) setState(() => _visible = false);
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    _openTimer?.cancel();
    _openTimer = null;
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  bool get _anyHovered => _triggerHovered || _cardHovered;

  void _setTriggerHovered(bool value) {
    if (_triggerHovered == value) return;
    _triggerHovered = value;
    _handleHoverChanged();
  }

  void _setCardHovered(bool value) {
    if (_cardHovered == value) return;
    _cardHovered = value;
    _handleHoverChanged();
  }

  /// Central hover-intent controller: one open timer, one close-grace timer,
  /// both keyed off the combined trigger+card hover state (the two regions
  /// act as a single hover area).
  void _handleHoverChanged() {
    if (!widget.enabled) return;

    if (_anyHovered) {
      // Re-entered (trigger or card): abort any pending close.
      _closeTimer?.cancel();
      _closeTimer = null;
      if (!_visible && _openTimer == null) {
        _openTimer = Timer(widget.openDelay, () {
          _openTimer = null;
          if (mounted && widget.enabled && _anyHovered && !_visible) {
            setState(() => _visible = true);
          }
        });
      }
    } else {
      // Left both regions: abort a pending open, start the close grace.
      _openTimer?.cancel();
      _openTimer = null;
      if (_visible && _closeTimer == null) {
        _closeTimer = Timer(widget.closeDelay, () {
          _closeTimer = null;
          if (mounted && !_anyHovered && _visible) {
            setState(() => _visible = false);
          }
        });
      }
    }
  }

  NasikoAnchorSide get _anchorSide => switch (widget.side) {
        NasikoHoverCardSide.top => NasikoAnchorSide.top,
        NasikoHoverCardSide.bottom => NasikoAnchorSide.bottom,
        NasikoHoverCardSide.left => NasikoAnchorSide.left,
        NasikoHoverCardSide.right => NasikoAnchorSide.right,
      };

  NasikoAnchorAlignment get _anchorAlignment => switch (widget.alignment) {
        NasikoHoverCardAlignment.start => NasikoAnchorAlignment.start,
        NasikoHoverCardAlignment.center => NasikoAnchorAlignment.center,
        NasikoHoverCardAlignment.end => NasikoAnchorAlignment.end,
      };

  /// Card surface — same treatment as the popover card (base fill, r12,
  /// hairline border, soft shadow) so floating surfaces stay one family.
  Widget _buildCard(BuildContext context, NasikoAnchorSide side) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    return MouseRegion(
      onEnter: (_) => _setCardHovered(true),
      onExit: (_) => _setCardHovered(false),
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: colors.backgroundBase,
          borderRadius: BorderRadius.circular(radii.r12),
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
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: widget.padding ?? EdgeInsets.all(spacing.s16),
            child: widget.contentBuilder(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return NasikoAnchoredOverlay(
      visible: _visible,
      anchor: NasikoAutoAnchor(
        side: _anchorSide,
        alignment: _anchorAlignment,
        gap: spacing.s4,
        screenPadding: spacing.s8,
      ),
      overlayBuilder: _buildCard,
      child: MouseRegion(
        // Observe-only: never swallows the child's own hover/tap handling.
        opaque: false,
        onEnter: (_) => _setTriggerHovered(true),
        onExit: (_) => _setTriggerHovered(false),
        child: widget.child,
      ),
    );
  }
}
