import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/components/section/section.dart';

class NasikoNavigationSection {
  const NasikoNavigationSection({
    required this.id,
    required this.title,
    this.icon,
    this.children = const [],
    this.isCollapsible = true,
    this.selectedChildId,
    this.onChildTap,
    this.isLoading = false,
    this.emptyMessage,
  });

  final String id;
  final String title;
  final List<List<dynamic>>? icon;
  final List<NasikoNavigationItem> children;
  final bool isCollapsible;
  final String? selectedChildId;
  final ValueChanged<String>? onChildTap;

  /// When true the section shows a loading indicator instead of children.
  final bool isLoading;

  /// Message shown when [children] is empty and [isLoading] is false.
  final String? emptyMessage;
}

class NasikoNavigationItem {
  const NasikoNavigationItem({
    required this.id,
    required this.label,
    this.subtitle,
    this.onTap,
    this.menuActions,
    this.maxLines,
  });

  final String id;
  final String label;
  final String? subtitle;
  final void Function()? onTap;
  final List<SectionItemAction>? menuActions;
  final int? maxLines;
}
