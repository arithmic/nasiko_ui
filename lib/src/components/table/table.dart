// lib/src/components/table/nasiko_table.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A styled table component for displaying structured data.
///
/// Notes:
///  - This implementation uses a LayoutBuilder + ConstrainedBox to ensure the
///    inner Rows receive a finite horizontal constraint so `Expanded` works
///    correctly (prevents "unbounded width" render errors).
///  - If you provide a `bodyScrollController`, pass the same controller when
///    disposing (the caller owns the controller lifecycle).
class NasikoTable extends StatelessWidget {
  const NasikoTable({
    super.key,
    required this.columns,
    required this.data,
    this.bodyHeight,
    this.bodyScrollController,
  });

  /// Defines the structure and styling of the table columns.
  final List<NasikoTableColumn> columns;

  /// The data for the table body.
  /// Each inner list contains the widget for the cell,
  /// corresponding to the order in [columns].
  final List<List<Widget>> data;

  /// Optional height for the table body area (so the body can scroll vertically).
  /// If null, a default height of 400 is used.
  final double? bodyHeight;

  /// Optional ScrollController for the table body. If provided, use the same
  /// controller instance for both the Scrollbar and the SingleChildScrollView.
  final ScrollController? bodyScrollController;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundSurface, // Outer surface color
        borderRadius: BorderRadius.circular(radii.r8),
        border: Border.all(
          color: colors.borderPrimary, // Thick border around the entire table
          width: borderWidths.w2,
        ),
      ),
      // Allow for horizontal scrolling if content is wide
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Constrain the inner Column to at least the viewport width so child
            // Rows with Expanded children receive finite horizontal constraints.
            return ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  // Allow for vertical scrolling of the body with a fixed height.
                  SizedBox(
                    height: bodyHeight ?? 400,
                    child: Scrollbar(
                      controller: bodyScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: bodyScrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _buildBodyRows(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Header Builder ---

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final iconSizes = context.iconSize;

    return Container(
      // Darker background for the header row
      color: colors.backgroundGroup, // neutral/200 or similar
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s12,
            ),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  flex: col.flex,
                  child: Align(
                    alignment: col.alignment,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          col.title,
                          style: typography.bodyPrimaryBold.copyWith(
                            color: colors.foregroundPrimary,
                          ),
                        ),
                        if (col.isSortable)
                          Padding(
                            padding: EdgeInsets.only(left: spacing.s4),
                            child: Icon(
                              Icons
                                  .arrow_downward_rounded, // Example sorting icon
                              size: iconSizes.s,
                              color: colors.foregroundSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Divider between header and body
          NasikoDivider(axis: NasikoDividerAxis.horizontal),
        ],
      ),
    );
  }

  // --- Body Row Builder ---

  List<Widget> _buildBodyRows(BuildContext context) {
    return data.map((rowWidgets) {
      if (rowWidgets.length != columns.length) {
        throw FlutterError(
          'NasikoTable: Row data length (${rowWidgets.length}) must match column definition length (${columns.length}).',
        );
      }
      return _NasikoTableRow(columns: columns, rowWidgets: rowWidgets);
    }).toList();
  }
}

// --- Internal Widget for Hover Effect ---

class _NasikoTableRow extends StatefulWidget {
  const _NasikoTableRow({required this.columns, required this.rowWidgets});

  final List<NasikoTableColumn> columns;
  final List<Widget> rowWidgets;

  @override
  State<_NasikoTableRow> createState() => _NasikoTableRowState();
}

class _NasikoTableRowState extends State<_NasikoTableRow> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    // Apply hover background color
    final Color backgroundColor = _isHovering
        ? colors.backgroundSurfaceHover
        : Colors.transparent;

    return InkWell(
      onTap: () {
        /* Handle row click if needed */
      },
      onHover: (isHovering) {
        setState(() {
          _isHovering = isHovering;
        });
      },
      child: Container(
        color: backgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s12,
        ),
        child: Column(
          children: [
            Row(
              // Because the outer ConstrainedBox provides a finite width,
              // Expanded children below will behave correctly.
              mainAxisSize: MainAxisSize.max,
              children: List.generate(widget.columns.length, (i) {
                final column = widget.columns[i];
                final cellWidget = widget.rowWidgets[i];

                return Expanded(
                  flex: column.flex,
                  child: Align(alignment: column.alignment, child: cellWidget),
                );
              }),
            ),
            // Divider between body rows
            NasikoDivider(axis: NasikoDividerAxis.horizontal),
          ],
        ),
      ),
    );
  }
}
