import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

class NasikoPopupMenuItemData {
  const NasikoPopupMenuItemData({
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  final String label;
  final HugeIconsType icon;
  final bool isDestructive;
}

class NasikoPopupMenu extends StatelessWidget {
  const NasikoPopupMenu({
    super.key,
    required this.child,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.width,
    this.maxHeight = 220.0,
    this.enabled = true,
    this.offset,
  });

  final Widget child;
  final List<NasikoPopupMenuItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  final double? width;
  final double maxHeight;
  final bool enabled;

  /// Optional offset from anchor bottom-left.
  /// If null -> defaults to spacing.s4 below.
  final Offset? offset;

  Future<void> _openMenu(BuildContext context) async {
    if (!enabled) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final spacing = context.spacing;

    final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final size = renderBox.size;

    final dx = offset?.dx ?? 0;
    final dy = offset?.dy ?? spacing.s4;

    final menuWidth = width ?? size.width;

    final selected = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + dx,
        position.dy + size.height + dy,
        overlay.size.width - position.dx - size.width,
        overlay.size.height - position.dy - size.height,
      ),
      elevation: 0,
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      items: [
        PopupMenuItem<int>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _NasikoPopupMenuSurface(
            items: items,
            selectedIndex: selectedIndex,
            width: menuWidth,
            maxHeight: maxHeight,
            onItemSelected: (index) {
              Navigator.of(context).pop(index);
            },
          ),
        ),
      ],
    );

    if (selected != null) {
      onItemSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _openMenu(context),
      child: child,
    );
  }
}

class _NasikoPopupMenuSurface extends StatefulWidget {
  const _NasikoPopupMenuSurface({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.width,
    required this.maxHeight,
  });

  final List<NasikoPopupMenuItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final double width;
  final double maxHeight;

  @override
  State<_NasikoPopupMenuSurface> createState() =>
      _NasikoPopupMenuSurfaceState();
}

class _NasikoPopupMenuSurfaceState extends State<_NasikoPopupMenuSurface> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    const double scrollbarThickness = 6.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.width,
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        decoration: BoxDecoration(
          color: colors.backgroundGroup,
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
        child: Padding(
          padding: EdgeInsets.all(spacing.s12),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.separated(
              padding: EdgeInsets.only(right: spacing.s8 + scrollbarThickness),
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: widget.items.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: spacing.s8),
              itemBuilder: (context, index) {
                final item = widget.items[index];

                return _NasikoMenuItem(
                  label: item.label,
                  icon: item.icon,
                  isSelected: widget.selectedIndex == index,
                  isDestructive: item.isDestructive,
                  onTap: () => widget.onItemSelected(index),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NasikoMenuItem extends StatefulWidget {
  const _NasikoMenuItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDestructive,
  });

  final String label;
  final HugeIconsType icon;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  State<_NasikoMenuItem> createState() => _NasikoMenuItemState();
}

class _NasikoMenuItemState extends State<_NasikoMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final typography = context.typography;
    final spacing = context.spacing;

    Color backgroundColor;

    if (widget.isSelected) {
      backgroundColor = colors.backgroundSecondaryBrand;
    } else if (_isHovered) {
      backgroundColor = colors.backgroundSecondaryBrandHover;
    } else {
      backgroundColor = Colors.transparent;
    }

    final foregroundColor = widget.isDestructive
        ? colors.foregroundError
        : (widget.isSelected
              ? colors.foregroundPrimary
              : colors.foregroundSecondary);

    final textStyle =
        (widget.isSelected
                ? typography.bodyPrimaryBold
                : typography.bodyPrimary)
            .copyWith(color: foregroundColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radii.r16),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(radii.r16),
          splashColor: colors.backgroundBrandSubtle.withValues(alpha: 0.5),
          highlightColor: colors.backgroundBrandSubtle.withValues(alpha: 0.5),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s16,
            ),
            child: Row(
              children: [
                HugeIcon(icon: widget.icon, size: 28, color: foregroundColor),
                SizedBox(width: spacing.s16),
                Expanded(child: Text(widget.label, style: textStyle)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
