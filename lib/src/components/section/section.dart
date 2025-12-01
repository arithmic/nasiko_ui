// section_list_fixed.dart
import 'package:flutter/material.dart';

/// Improved SectionItem and SectionList matching the provided design.
/// Uses optional design tokens via BuildContext extensions if available; falls back to Theme.
class SectionItem<T> {
  const SectionItem({
    required this.value,
    required this.label,
    this.icon,
    this.isCaption = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool isCaption;
}

/// Inline, accordion-style section list with precise styling to match screenshots.
class SectionListFixed<T> extends StatefulWidget {
  const SectionListFixed({
    super.key,
    this.leadingIcon,
    required this.hint,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.initiallyExpanded = false,
    this.indent = 24.0,
  });

  final IconData? leadingIcon;
  final String hint;
  final List<SectionItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onChanged;
  final bool initiallyExpanded;
  final double indent;

  @override
  State<SectionListFixed<T>> createState() => _SectionListFixedState<T>();
}

class _SectionListFixedState<T> extends State<SectionListFixed<T>>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _controller;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (_expanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  TextStyle _headerStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge!.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle _itemStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleMedium!;
  }

  @override
  Widget build(BuildContext context) {
    // token fallbacks: attempt to use the tokens if available on context; otherwise fall back.
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = 12.0;

    // header row
    final header = InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        child: Row(
          children: [
            if (widget.leadingIcon != null) ...[
              Icon(widget.leadingIcon, size: 22, color: Color(0xFF495063)),
              SizedBox(width: 12),
            ],
            Expanded(child: Text(widget.hint, style: _headerStyle(context))),
            Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );

    final children = widget.items
        .map((item) {
          if (item.isCaption) {
            return Padding(
              padding: EdgeInsets.only(left: widget.indent, top: 8, bottom: 4),
              child: Text(
                item.label,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: Color(0xFF7E8691),
                ),
              ),
            );
          }

          final isSelected = item.value == widget.selectedValue;
          if (isSelected) {
            // pill style
            return Padding(
              padding: EdgeInsets.only(
                left: widget.indent,
                right: 12,
                top: 6,
                bottom: 6,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF7E9C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFB8871E)),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                child: Text(
                  item.label,
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: Color(0xFF2E3440),
                  ),
                ),
              ),
            );
          } else {
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.only(left: widget.indent, right: 12),
              leading: item.icon != null
                  ? Icon(item.icon, size: 18, color: Color(0xFF495063))
                  : null,
              title: Text(item.label, style: _itemStyle(context)),
              onTap: () => widget.onChanged(item.value),
              minLeadingWidth: 0,
              horizontalTitleGap: 8,
            );
          }
        })
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        ClipRect(
          child: AnimatedBuilder(
            animation: _controller.view,
            builder: (context, child) => Align(
              alignment: Alignment.topCenter,
              heightFactor: _heightFactor.value,
              child: child,
            ),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}
