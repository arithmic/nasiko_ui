import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Handle returned by [NasikoPopover.show]. Call [dismiss] to remove the
/// popover programmatically (e.g. from an external event).
class NasikoPopoverHandle {
  NasikoPopoverHandle._(this._entry);

  final OverlayEntry _entry;
  bool _dismissed = false;

  bool get isDismissed => _dismissed;

  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _entry.remove();
  }
}

/// Floating popover menu with a dark surface and icon + label rows.
///
/// Rendered via a rootOverlay [OverlayEntry] so it always paints above other
/// overlays (e.g. a sidebar's expanded-rail overlay). Outside taps dismiss.
///
/// Invoke imperatively from a tap callback:
///
/// ```dart
/// NasikoPopover.show(
///   context: context,
///   items: _userMenuItems,
///   onSelect: _handleUserMenuSelection,
///   left: 56,
///   bottom: 26,
/// );
/// ```
class NasikoPopover extends StatelessWidget {
  const NasikoPopover._({
    required this.items,
    required this.onSelect,
    required this.onDismiss,
    required this.width,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final List<NasikoPopupMenuItemData> items;
  final ValueChanged<int> onSelect;
  final VoidCallback onDismiss;
  final double width;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  /// Inserts the popover into the root overlay and returns a handle that can
  /// be used to dismiss it. The popover auto-dismisses when an item is
  /// selected or the user taps outside.
  ///
  /// Provide either [anchorContext] (to align the popover below a trigger
  /// widget) OR explicit [left]/[top]/[right]/[bottom] for absolute
  /// positioning against the root overlay.
  static NasikoPopoverHandle show({
    required BuildContext context,
    required List<NasikoPopupMenuItemData> items,
    required ValueChanged<int> onSelect,
    BuildContext? anchorContext,
    Offset anchorOffset = Offset.zero,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double width = 200,
  }) {
    final overlayState = Overlay.of(context, rootOverlay: true);

    double? resolvedLeft = left;
    double? resolvedTop = top;

    if (anchorContext != null) {
      final overlayBox =
          overlayState.context.findRenderObject() as RenderBox?;
      final anchorBox = anchorContext.findRenderObject() as RenderBox?;
      if (overlayBox != null && anchorBox != null) {
        final position = anchorBox.localToGlobal(
          Offset.zero,
          ancestor: overlayBox,
        );
        resolvedLeft = position.dx + anchorOffset.dx;
        resolvedTop = position.dy + anchorBox.size.height + anchorOffset.dy;
      }
    }

    late final OverlayEntry entry;
    late final NasikoPopoverHandle handle;

    entry = OverlayEntry(
      builder: (_) => NasikoPopover._(
        items: items,
        onSelect: (index) {
          handle.dismiss();
          onSelect(index);
        },
        onDismiss: () => handle.dismiss(),
        width: width,
        left: resolvedLeft,
        top: resolvedTop,
        right: right,
        bottom: bottom,
      ),
    );
    handle = NasikoPopoverHandle._(entry);
    overlayState.insert(entry);
    return handle;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              constraints: BoxConstraints(minWidth: width),
              decoration: BoxDecoration(
                color: colors.foregroundConstantBlack,
                borderRadius: BorderRadius.circular(radii.r8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < items.length; i++)
                    _NasikoPopoverItem(
                      data: items[i],
                      onTap: items[i].isDisabled ? null : () => onSelect(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NasikoPopoverItem extends StatefulWidget {
  const _NasikoPopoverItem({required this.data, required this.onTap});

  final NasikoPopupMenuItemData data;
  final VoidCallback? onTap;

  @override
  State<_NasikoPopoverItem> createState() => _NasikoPopoverItemState();
}

class _NasikoPopoverItemState extends State<_NasikoPopoverItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final radii = context.radius;

    final isDisabled = widget.data.isDisabled;

    final Color fgColor;
    if (isDisabled) {
      fgColor = colors.foregroundDisabled;
    } else {
      fgColor = colors.backgroundBase;
    }

    return MouseRegion(
      cursor: isDisabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: isDisabled ? null : (_) => setState(() => _isHovered = true),
      onExit: isDisabled ? null : (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            top: 6.0,
            bottom: 6.0,
          ),
          child: Container(
            padding: EdgeInsets.only(
              left: spacing.s8,
              right: spacing.s8,
              top: spacing.s8,
              bottom: spacing.s8,
            ),
            decoration: BoxDecoration(
              color: _isHovered && !isDisabled 
                  ? widget.data.isDestructive ? colors.backgroundError: const Color.fromRGBO(109, 115, 122, 1)
                  : colors.foregroundConstantBlack,
              borderRadius: BorderRadius.circular(radii.r8),
            ),
            child: Row(
              children: [
                if (widget.data.icon != null) ...[
                  HugeIcon(
                    icon: widget.data.icon!,
                    size: iconSizes.s,
                    color: fgColor,
                  ),
                  SizedBox(width: spacing.s8),
                ],
                Text(
                  widget.data.label,
                  style: typography.bodySecondary.copyWith(color: fgColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
