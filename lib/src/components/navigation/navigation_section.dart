import 'package:flutter/material.dart';

class NasikoNavigationSection {
  const NasikoNavigationSection({
    required this.id,
    required this.title,
    this.icon,
    this.children = const [],
    this.isCollapsible = true,
    this.selectedChildId,
    this.onChildTap,
  });

  final String id;
  final String title;
  final List<List<dynamic>>? icon;
  final List<NasikoNavigationItem> children;
  final bool isCollapsible;
  final String? selectedChildId;
  final ValueChanged<String>? onChildTap;
}

class NasikoNavigationItem {
  const NasikoNavigationItem({
    required this.id,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  final String id;
  final String label;
  final String? subtitle;
  final void Function()? onTap;
}
