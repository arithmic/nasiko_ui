// section_list.dart
import 'package:flutter/material.dart';

/// Generic model representing a single section item.
class SectionItem<T> {
  const SectionItem({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Inline, non-floating expandable list used as a generic section.
/// Replaces previous floating "dropdown" semantics with inline expansion.
class SectionList<T> extends StatefulWidget {
  const SectionList({
    super.key,
    this.leadingIcon,
    required this.hint,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.initiallyExpanded = false,
    this.indent = 28.0,
    this.itemBuilder,
  });

  /// Optional leading icon shown on the header row.
  final IconData? leadingIcon;

  /// Header text for the section.
  final String hint;

  /// Items shown when expanded.
  final List<SectionItem<T>> items;

  /// Currently selected value (if any).
  final T? selectedValue;

  /// Called when a child is tapped.
  final ValueChanged<T> onChanged;

  /// Whether the section starts expanded.
  final bool initiallyExpanded;

  /// Left padding applied to the expanded items.
  final double indent;

  /// Optional custom item renderer. If null, a default ListTile-like row is used.
  final Widget Function(
    BuildContext context,
    SectionItem<T> item,
    bool isSelected,
  )?
  itemBuilder;

  @override
  State<SectionList<T>> createState() => _SectionListState<T>();
}

class _SectionListState<T> extends State<SectionList<T>>
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
      duration: const Duration(milliseconds: 180),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (_expanded) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant SectionList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // keep expansion if items were changed but expansion state stable
    if (_expanded) {
      // no-op; preserve open state unless parent changed intentionally
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final selected = widget.items.any((it) => it.value == widget.selectedValue);
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            if (widget.leadingIcon != null) ...[
              Icon(widget.leadingIcon, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                widget.hint,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.check_circle_rounded, size: 18),
              ),
            Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultItemBuilder(
    BuildContext context,
    SectionItem<T> item,
    bool isSelected,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: item.icon != null ? Icon(item.icon, size: 18) : null,
      title: Text(
        item.label,
        style: isSelected
            ? Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)
            : Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () => widget.onChanged(item.value),
      horizontalTitleGap: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        ClipRect(
          child: AnimatedBuilder(
            animation: _controller.view,
            builder: (context, child) {
              return Align(
                heightFactor: _heightFactor.value,
                alignment: Alignment.topCenter,
                child: child,
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: widget.indent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children
                    .map((item) {
                      final isSelected = item.value == widget.selectedValue;
                      if (widget.itemBuilder != null) {
                        return widget.itemBuilder!(context, item, isSelected);
                      }
                      return _defaultItemBuilder(context, item, isSelected);
                    })
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Backwards-compat typedefs (optional) — use these if other code still
/// references the old names. Remove when you fully migrate callers.
typedef NasikoDropdownItem<T> = SectionItem<T>;
typedef NasikoDropdown<T> = SectionList<T>;
