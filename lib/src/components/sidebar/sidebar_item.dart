import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A navigation item shown in the sidebar rail.
class NasikoSidebarItem {
  const NasikoSidebarItem({
    required this.id,
    required this.label,
    required this.icon,
    this.sections,
    this.isDisabled = false,
  });

  final String id;
  final String label;
  final HugeIconsType icon;

  /// Content sections displayed in the panel when this item is selected.
  /// When null or empty, the panel is hidden for this item.
  final List<NasikoSidebarSection>? sections;

  /// When true, the item is rendered in a muted, non-interactive style.
  final bool isDisabled;

  bool get hasPanel => sections != null && sections!.isNotEmpty;
}

/// A section within the sidebar panel (e.g., "Agent Sources", "Your Registries").
class NasikoSidebarSection {
  const NasikoSidebarSection({
    required this.title,
    required this.icon,
    this.children,
    this.isCollapsible = true,
    this.isLoading = false,
    this.emptyMessage,
    this.trailingIcon,
    this.onTrailingIconTap,
    this.selectedChildId,
    this.onChildTap,
  });

  final String title;
  final HugeIconsType? icon;
  final List<SectionItem>? children;
  final bool isCollapsible;
  final bool isLoading;
  final String? emptyMessage;

  /// Trailing action icon on the section header (e.g., the "+" in "Your Registries").
  final HugeIconsType? trailingIcon;
  final VoidCallback? onTrailingIconTap;

  final String? selectedChildId;
  final ValueChanged<String>? onChildTap;
}

/// A footer item at the bottom of the sidebar rail (e.g., Settings, Help).
class NasikoSidebarFooterItem {
  const NasikoSidebarFooterItem({
    required this.id,
    required this.icon,
    required this.label,
    this.onTap,
    this.isDisabled = false,
  });

  final String id;
  final HugeIconsType icon;
  final String label;
  final VoidCallback? onTap;

  /// When true, the item is rendered in a muted, non-interactive style.
  final bool isDisabled;
}
