import 'package:flutter/material.dart';

class NasikoNavigationRailItem {
  const NasikoNavigationRailItem({
    required this.id,
    required this.icon,
    required this.label,
    this.isDisabled = false,
  });

  final String id;
  final IconData icon;
  final String label;
  final bool isDisabled;
}
