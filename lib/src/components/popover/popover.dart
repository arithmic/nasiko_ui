import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../internal/overlay_reveal.dart';

/// Horizontal alignment of the popover surface relative to its anchor.
enum NasikoPopoverAlignment { start, center, end }

/// Minimum space (logical px) required below the anchor before the popover
/// flips above it. A heuristic — the surface sizes to its intrinsic content,
/// so its height isn't known before layout.
const double _kMinSpaceBelow = 240.0;

/// Controls the visibility of a [NasikoPopover].
///
/// Create one per popover, keep it in state, and call [show], [hide], or
/// [toggle] from the anchor's interaction handlers:
///
/// ```dart
/// final _controller = NasikoPopoverController();
///
/// NasikoPopover(
///   controller: _controller,
///   popoverBuilder: (context) => const FilterOptions(),
///   child: SecondaryButton(
///     label: 'Filters',
///     onPressed: _controller.toggle,
///   ),
/// )
/// ```
class NasikoPopoverController extends ChangeNotifier {
  bool _isShowing = false;

  /// Whether the popover is currently visible.
  bool get isShowing => _isShowing;

  /// Shows the popover. No-op when already visible.
  void show() {
    if (_isShowing) return;
    _isShowing = true;
    notifyListeners();
  }

  /// Hides the popover. No-op when already hidden.
  void hide() {
    if (!_isShowing) return;
    _isShowing = false;
    notifyListeners();
  }

  /// Shows the popover when hidden, hides it when visible.
  void toggle() => _isShowing ? hide() : show();
}

/// An anchored, non-modal overlay surface attached to [child].
///
/// The popover opens below the anchor with a small gap and flips above it
/// when there isn't enough space below (mirroring [NasikoPopupMenu]).
/// Visibility is driven entirely by [controller]; the surface is rendered
/// through an [OverlayPortal], so it follows the anchor while open and needs
/// no manual overlay lifecycle.
///
/// Dismissal: tapping outside (when [dismissOnOutsideTap]) or pressing
/// Escape hides the popover; Escape also restores focus to where it was
/// before opening. Entrance animates via the shared overlay reveal and is
/// reduced-motion aware; removal is instant, matching the package's motion
/// personality.
class NasikoPopover extends StatefulWidget {
  const NasikoPopover({
    super.key,
    required this.controller,
    required this.child,
    required this.popoverBuilder,
    this.alignment = NasikoPopoverAlignment.start,
    this.offset = Offset.zero,
    this.width,
    this.dismissOnOutsideTap = true,
  });

  /// Drives the popover's visibility.
  final NasikoPopoverController controller;

  /// The anchor the popover attaches to.
  final Widget child;

  /// Builds the popover's content, laid inside the card surface.
  final WidgetBuilder popoverBuilder;

  /// Horizontal alignment of the surface against the anchor's edge.
  final NasikoPopoverAlignment alignment;

  /// Extra offset applied on top of the computed anchored position.
  final Offset offset;

  /// Fixed surface width. When null the surface sizes to its content.
  final double? width;

  /// Whether tapping outside the anchor and surface hides the popover.
  final bool dismissOnOutsideTap;

  @override
  State<NasikoPopover> createState() => _NasikoPopoverState();
}

class _NasikoPopoverState extends State<NasikoPopover> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  final FocusScopeNode _popoverScope =
      FocusScopeNode(debugLabel: 'NasikoPopover');

  /// Focus owner before the popover opened — restored on Escape.
  FocusNode? _previousFocus;
  bool _openAbove = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    if (widget.controller.isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleControllerChanged();
      });
    }
  }

  @override
  void didUpdateWidget(covariant NasikoPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      // Defer the sync: didUpdateWidget runs during build, and
      // OverlayPortalController.show()/hide() must not be called then.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleControllerChanged();
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _popoverScope.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted || widget.controller.isShowing == _portal.isShowing) return;
    if (widget.controller.isShowing) {
      _previousFocus = FocusManager.instance.primaryFocus;
      setState(() => _openAbove = _shouldOpenAbove());
      _portal.show();
    } else {
      _portal.hide();
    }
  }

  /// Whether to flip above the anchor. Mirrors the popup menu's openUpward
  /// logic, measured in the overlay's coordinate space.
  bool _shouldOpenAbove() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return false;

    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final anchor = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);

    final spaceBelow =
        overlayBox.size.height - (anchor.dy + renderBox.size.height);
    final spaceAbove = anchor.dy;
    return spaceBelow < _kMinSpaceBelow && spaceAbove > spaceBelow;
  }

  void _dismissAndRestoreFocus() {
    final hadFocus = _popoverScope.hasFocus;
    widget.controller.hide();
    if (hadFocus) _previousFocus?.requestFocus();
    _previousFocus = null;
  }

  /// Anchor points on the target (anchor) and follower (surface).
  ///
  /// The same alignment is reused for the inner [Align] so placement stays
  /// correct whether the overlay lays the follower out tight (full-size) or
  /// loose (shrink-wrapped).
  (Alignment target, Alignment follower) get _anchors {
    switch (widget.alignment) {
      case NasikoPopoverAlignment.start:
        return _openAbove
            ? (Alignment.topLeft, Alignment.bottomLeft)
            : (Alignment.bottomLeft, Alignment.topLeft);
      case NasikoPopoverAlignment.center:
        return _openAbove
            ? (Alignment.topCenter, Alignment.bottomCenter)
            : (Alignment.bottomCenter, Alignment.topCenter);
      case NasikoPopoverAlignment.end:
        return _openAbove
            ? (Alignment.topRight, Alignment.bottomRight)
            : (Alignment.bottomRight, Alignment.topRight);
    }
  }

  Widget _buildSurface(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    return Container(
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
        child: widget.popoverBuilder(context),
      ),
    );
  }

  Widget _buildOverlayChild(BuildContext context) {
    final gap = context.spacing.s4;
    final (targetAnchor, followerAnchor) = _anchors;

    return CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      offset: widget.offset + Offset(0, _openAbove ? -gap : gap),
      child: Align(
        alignment: followerAnchor,
        child: TapRegion(
          groupId: this,
          onTapOutside:
              widget.dismissOnOutsideTap ? (_) => widget.controller.hide() : null,
          child: FocusScope(
            node: _popoverScope,
            child: Shortcuts(
              shortcuts: const {
                SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
              },
              child: Actions(
                actions: {
                  DismissIntent: CallbackAction<DismissIntent>(
                    onInvoke: (_) {
                      _dismissAndRestoreFocus();
                      return null;
                    },
                  ),
                },
                child: Focus(
                  autofocus: true,
                  // Entrance only — removal stays instant, matching the
                  // subtle & fast motion personality.
                  child: NasikoOverlayReveal(
                    slideFrom: Offset(0, _openAbove ? 4 : -4),
                    child: _buildSurface(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlayChild,
      child: CompositedTransformTarget(
        link: _link,
        // Same tap group as the surface so taps on the anchor never count
        // as "outside" — lets toggle buttons work without a hide/show race.
        child: TapRegion(groupId: this, child: widget.child),
      ),
    );
  }
}
