// lib/src/components/list/nasiko_list.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A container for displaying a vertical list of [NasikoListItem]s.
class NasikoList extends StatelessWidget {
  const NasikoList({super.key, required this.children});

  final List<NasikoListItem> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
