import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

class NasikoNavigationListItem extends StatefulWidget {
  const NasikoNavigationListItem({super.key, required this.item});

  final NasikoNavigationItem item;

  @override
  State<NasikoNavigationListItem> createState() =>
      _NasikoNavigationListItemState();
}

class _NasikoNavigationListItemState extends State<NasikoNavigationListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final radii = context.radius;
    final colors = context.colors;
    final motion = context.motion;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: motion.hover,
          curve: motion.enter,
          margin: EdgeInsets.only(bottom: spacing.s4),
          padding: EdgeInsets.all(spacing.s8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radii.r8),
            border: Border.all(
              color: _hovered ? colors.borderSecondary : Colors.transparent,
            ),
          ),
          child: Text(widget.item.label),
        ),
      ),
    );
  }
}
