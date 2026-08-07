import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../internal/anchored_overlay.dart';

/// Horizontal alignment of the popover surface relative to its anchor.
enum NasikoPopoverAlignment { start, center, end }

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
/// when the surface doesn't fit below. Positioning runs on the shared
/// [NasikoAnchoredOverlay] engine: the flip uses the surface's measured size
/// (not a fixed heuristic), and the final position is clamped to the screen
/// bounds horizontally and vertically. Visibility is driven entirely by
/// [controller]; the surface is rendered through an overlay portal, so it
/// follows the anchor while open and needs no manual overlay lifecycle.
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
  final FocusScopeNode _popoverScope =
      FocusScopeNode(debugLabel: 'NasikoPopover');

  /// Focus owner before the popover opened — restored on Escape.
  FocusNode? _previousFocus;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    if (widget.controller.isShowing) {
      _previousFocus = FocusManager.instance.primaryFocus;
    }
  }

  @override
  void didUpdateWidget(covariant NasikoPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _popoverScope.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    if (widget.controller.isShowing) {
      _previousFocus = FocusManager.instance.primaryFocus;
    }
    // The anchored-overlay engine syncs show/hide from the rebuilt
    // `visible` value, so a rebuild is all that's needed here.
    setState(() {});
  }

  void _dismissAndRestoreFocus() {
    final hadFocus = _popoverScope.hasFocus;
    widget.controller.hide();
    if (hadFocus) _previousFocus?.requestFocus();
    _previousFocus = null;
  }

  NasikoAnchorAlignment get _anchorAlignment => switch (widget.alignment) {
        NasikoPopoverAlignment.start => NasikoAnchorAlignment.start,
        NasikoPopoverAlignment.center => NasikoAnchorAlignment.center,
        NasikoPopoverAlignment.end => NasikoAnchorAlignment.end,
      };

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
        boxShadow: context.elevation.overlay,
      ),
      child: Material(
        color: Colors.transparent,
        child: widget.popoverBuilder(context),
      ),
    );
  }

  /// Overlay content: the engine handles positioning and the entrance
  /// reveal; this layer owns dismissal (outside tap, Escape) and focus.
  Widget _buildOverlayContent(BuildContext context, NasikoAnchorSide side) {
    return TapRegion(
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
              child: _buildSurface(context),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return NasikoAnchoredOverlay(
      visible: widget.controller.isShowing,
      anchor: NasikoAutoAnchor(
        side: NasikoAnchorSide.bottom,
        alignment: _anchorAlignment,
        gap: spacing.s4,
        offset: widget.offset,
        screenPadding: spacing.s8,
      ),
      overlayBuilder: _buildOverlayContent,
      // Same tap group as the surface so taps on the anchor never count
      // as "outside" — lets toggle buttons work without a hide/show race.
      child: TapRegion(groupId: this, child: widget.child),
    );
  }
}
