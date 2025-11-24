// lib/src/components/breadcrumb/nasiko_breadcrumb.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A data class for a single item in a [NasikoBreadcrumb].
class NasikoBreadcrumbItem {
  const NasikoBreadcrumbItem({required this.label, this.onTap});

  /// The text label for the breadcrumb item.
  final String label;

  /// The callback to execute when the item is tapped.
  /// If `null`, the item is considered "current" or "disabled"
  /// and will not be interactive.
  final VoidCallback? onTap;
}

/// A breadcrumb component for displaying navigation hierarchy.
class NasikoBreadcrumb extends StatelessWidget {
  const NasikoBreadcrumb({super.key, required this.items, this.leadingIcon});

  /// The list of [NasikoBreadcrumbItem] to display.
  final List<NasikoBreadcrumbItem> items;

  /// An optional icon to display at the very beginning of the breadcrumbs.
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    // final typography = context.typography;
    final iconSizes = context.iconSize;

    // Build the list of widgets
    final List<Widget> children = [];

    // 1. Add the leading icon if it exists
    if (leadingIcon != null) {
      children.add(
        Icon(
          leadingIcon,
          size: iconSizes.s, // 20px
          color: colors.foregroundPrimary, // neutral/700
        ),
      );
    }

    // 2. Add the items and separators
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final bool isLastItem = i == items.length - 1;

      // Add a separator before every item except the first
      // (or if there's no leading icon)
      if (i > 0 || leadingIcon != null) {
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.s4),
            child: Icon(
              Icons.chevron_right,
              size: iconSizes.xs, // 16px
              color: colors.foregroundSecondary, // neutral/500
            ),
          ),
        );
      }

      // Add the breadcrumb item itself
      children.add(
        _BreadcrumbItem(
          label: item.label,
          onTap: isLastItem
              ? null
              : item.onTap, // The last item is never tappable
        ),
      );
    }

    // 3. Return a Wrap to handle layout
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// An internal widget for a single breadcrumb item.
class _BreadcrumbItem extends StatelessWidget {
  const _BreadcrumbItem({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final bool isTappable = onTap != null;

    final text = Text(
      label,
      style: typography.bodySecondary.copyWith(
        color: isTappable
            ? colors
                  .foregroundPrimary // neutral/700
            : colors.foregroundSecondary, // neutral/500 for the last item
        fontWeight: isTappable ? FontWeight.w400 : FontWeight.w600,
      ),
    );

    if (!isTappable) {
      return text;
    }

    // Wrap with InkWell to make it tappable
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radius.r4),
      splashColor: context.colors.backgroundBrandSubtle.withOpacity(0.5),
      highlightColor: context.colors.backgroundBrandSubtle.withOpacity(0.5),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.s4,
          vertical: context.spacing.s2,
        ),
        child: text,
      ),
    );
  }
}
