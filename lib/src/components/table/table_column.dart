// lib/src/components/table/nasiko_table_column.dart

import 'package:flutter/material.dart';

/// Defines the structure and behavior of a single column in [NasikoTable].
class NasikoTableColumn {
  const NasikoTableColumn({
    required this.title,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.isSortable = false,
  });

  /// The text displayed in the column header.
  final String title;

  /// The flex factor for [Expanded] within the row.
  final int flex;

  /// The alignment of content within the cell.
  final Alignment alignment;

  /// If true, a sort icon will be displayed next to the title.
  final bool isSortable;
}
