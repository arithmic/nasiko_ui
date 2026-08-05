// lib/src/components/table/nasiko_table.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Defines the structure and behavior of a single column in [NasikoTable].
class NasikoTableColumn {
  const NasikoTableColumn({
    required this.title,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.isSortable = false,
  });

  final String title;
  final int flex;
  final Alignment alignment;
  final bool isSortable;
}

/// A styled table component for displaying structured data.
class NasikoTable extends StatefulWidget {
  const NasikoTable({
    super.key,
    required this.columns,
    required this.data,
    this.bodyHeight,
    this.bodyScrollController,
  });

  final List<NasikoTableColumn> columns;
  final List<List<Widget>> data;
  final double? bodyHeight;
  final ScrollController? bodyScrollController;

  @override
  State<NasikoTable> createState() => _NasikoTableState();
}

class _NasikoTableState extends State<NasikoTable> {
  late final ScrollController _verticalController;
  late final bool _verticalControllerOwned;

  @override
  void initState() {
    super.initState();

    // Vertical scroll controller
    if (widget.bodyScrollController != null) {
      _verticalController = widget.bodyScrollController!;
      _verticalControllerOwned = false;
    } else {
      _verticalController = ScrollController();
      _verticalControllerOwned = true;
    }
  }

  @override
  void didUpdateWidget(covariant NasikoTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bodyScrollController != widget.bodyScrollController) {
      if (_verticalControllerOwned) {
        _verticalController.dispose();
      }
      if (widget.bodyScrollController != null) {
        setState(() {
          _verticalController = widget.bodyScrollController!;
          _verticalControllerOwned = false;
        });
      } else {
        setState(() {
          _verticalController = ScrollController();
          _verticalControllerOwned = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_verticalControllerOwned) {
      _verticalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundBase,
        borderRadius: BorderRadius.circular(radii.r8),
        border: Border.all(
          color: colors.borderPrimary,
          width: borderWidths.w1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radii.r8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Body with vertical scroll. No gutter here — rows own their
            // horizontal padding so hover and dividers reach the table edges;
            // the scrollbar thumb overlays the trailing gutter.
            SizedBox(
              height: widget.bodyHeight ?? 400,
              child: Scrollbar(
                controller: _verticalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _verticalController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildBodyRows(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final iconSizes = context.iconSize;

    return Container(
      color: colors.backgroundGroup,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s12,
            ),
            child: Row(
              children: widget.columns.map((col) {
                return Expanded(
                  flex: col.flex,
                  child: Align(
                    alignment: col.alignment,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          col.title,
                          style: typography.bodySecondaryBold.copyWith(
                            color: colors.foregroundPrimary,
                          ),
                        ),
                        if (col.isSortable)
                          Padding(
                            padding: EdgeInsets.only(left: spacing.s4),
                            child: Icon(
                              Icons.arrow_downward_rounded,
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
          const NasikoDivider(axis: NasikoDividerAxis.horizontal),
        ],
      ),
    );
  }

  List<Widget> _buildBodyRows(BuildContext context) {
    return List.generate(widget.data.length, (i) {
      final rowWidgets = widget.data[i];
      if (rowWidgets.length != widget.columns.length) {
        throw FlutterError(
          'NasikoTable: Row data length (${rowWidgets.length}) must match column definition length (${widget.columns.length}).',
        );
      }
      return _NasikoTableRow(
        columns: widget.columns,
        rowWidgets: rowWidgets,
        // The table's own border closes the last row; a divider there too
        // would read as a doubled bottom edge.
        showDivider: i < widget.data.length - 1,
      );
    });
  }
}

/// One body row: cells laid out across the column flexes plus a trailing
/// divider. Rows have no hover tint — the table is read, not clicked.
class _NasikoTableRow extends StatelessWidget {
  const _NasikoTableRow({
    required this.columns,
    required this.rowWidgets,
    required this.showDivider,
  });

  final List<NasikoTableColumn> columns;
  final List<Widget> rowWidgets;

  /// Whether to close the row with a divider. False for the last row, whose
  /// edge is already drawn by the table's border.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s16,
            vertical: spacing.s8,
          ),
          child: Row(
            children: List.generate(columns.length, (i) {
              final column = columns[i];
              final cellWidget = rowWidgets[i];

              return Expanded(
                flex: column.flex,
                child: Align(
                  alignment: column.alignment,
                  child: cellWidget,
                ),
              );
            }),
          ),
        ),
        if (showDivider)
          const NasikoDivider(axis: NasikoDividerAxis.horizontal),
      ],
    );
  }
}

// ============================================================================
// TABLE CELL COMPONENTS
// ============================================================================

/// A simple text cell for the table
class NasikoTableTextCell extends StatelessWidget {
  const NasikoTableTextCell(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: context.typography.bodyPrimary);
  }
}

/// A cell with an info icon and "Copy" text
class NasikoTableCopyCell extends StatelessWidget {
  const NasikoTableCopyCell({super.key, this.onCopy});

  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedInformationCircle,
          size: context.iconSize.s,
          color: context.colors.foregroundSecondary,
        ),
        SizedBox(width: context.spacing.s8),
        Text(
          'Copy',
          style: context.typography.bodySecondary.copyWith(
            color: context.colors.foregroundSecondary,
          ),
        ),
      ],
    );
  }
}

/// A cell item component showing various UI elements
class NasikoTableCellItem extends StatelessWidget {
  const NasikoTableCellItem({
    super.key,
    this.showButton = false,
    this.showIcons = false,
    this.showTags = false,
    this.showCheckbox = false,
    this.showRadio = false,
    this.showAvatar = false,
    this.showSwitch = false,
    this.showStatus = false,
  });

  final bool showButton;
  final bool showIcons;
  final bool showTags;
  final bool showCheckbox;
  final bool showRadio;
  final bool showAvatar;
  final bool showSwitch;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text labels
        Row(
          children: [
            Text('Copy', style: context.typography.bodyPrimary),
            SizedBox(width: spacing.s16),
            Text('Copy', style: context.typography.bodyPrimary),
          ],
        ),

        if (showButton) ...[
          SizedBox(height: spacing.s12),
          Row(
            children: [
              Text(
                'Button',
                style: context.typography.bodyPrimary.copyWith(
                  color: colors.foregroundBrand,
                ),
              ),
              SizedBox(width: spacing.s8),
              Icon(
                Icons.info_outline,
                size: context.iconSize.xs,
                color: colors.foregroundBrand,
              ),
            ],
          ),
        ],

        if (showIcons) ...[
          SizedBox(height: spacing.s12),
          Row(
            children: [
              // _buildIconButton(context, Icons.content_copy),
              SizedBox(width: spacing.s8),
              // _buildIconButton(context, Icons.content_copy),
              SizedBox(width: spacing.s8),
              // _buildIconButton(context, Icons.content_copy),
              SizedBox(width: spacing.s8),
              // _buildIconButton(context, Icons.content_copy),
            ],
          ),
        ],

        if (showTags) ...[
          SizedBox(height: spacing.s12),
          Wrap(
            spacing: spacing.s8,
            runSpacing: spacing.s8,
            children: [
              // _buildTag(context, 'Tag'),
              // _buildTag(context, 'Tag'),
              // _buildTag(context, 'Tag'),
            ],
          ),
        ],

        if (showCheckbox) ...[
          SizedBox(height: spacing.s12),
          NasikoCheckboxTile(
            label: 'Airplane Mode',
            icon: Icons.airplanemode_active,
            isChecked: true,
            onChanged: (value) {},
          ),
        ],

        if (showRadio) ...[
          SizedBox(height: spacing.s12),
          Row(
            children: [
              Container(
                width: spacing.s20,
                height: spacing.s20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.backgroundBrand,
                  border: Border.all(
                    color: colors.borderSecondary,
                    width: context.borderWidth.w2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: spacing.s8,
                    height: spacing.s8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.foregroundPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing.s12),
              Icon(
                Icons.airplanemode_active,
                size: context.iconSize.s,
                color: colors.foregroundPrimary,
              ),
              SizedBox(width: spacing.s8),
              Text('Airplane Mode', style: context.typography.bodyPrimary),
            ],
          ),
        ],

        if (showAvatar) ...[
          SizedBox(height: spacing.s12),
          Row(
            children: [
              const NasikoAvatar(
                size: NasikoAvatarSize.small,
                icon: HugeIcons.strokeRoundedRelieved01,
              ),
              SizedBox(width: spacing.s8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Label', style: context.typography.bodyPrimary),
                  SizedBox(height: spacing.s4),
                  Text(
                    'anskjames2001@gmail.com',
                    style: context.typography.caption.copyWith(
                      color: colors.foregroundSecondary,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],

        if (showSwitch) ...[
          SizedBox(height: spacing.s12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: context.iconSize.s,
                color: colors.foregroundSecondary,
              ),
              SizedBox(width: spacing.s12),
              NasikoSwitch(value: true, onChanged: (value) {}),
              SizedBox(width: spacing.s12),
              Text('Airplane Mode', style: context.typography.bodyPrimary),
              SizedBox(width: spacing.s12),
              Icon(
                Icons.info_outline,
                size: context.iconSize.s,
                color: colors.foregroundSecondary,
              ),
            ],
          ),
        ],

        if (showStatus) ...[
          SizedBox(height: spacing.s12),
          Row(
            children: [
              Container(
                width: spacing.s8,
                height: spacing.s8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.foregroundSuccess,
                ),
              ),
              SizedBox(width: spacing.s8),
              Text('Copy', style: context.typography.bodyPrimary),
            ],
          ),
        ],
      ],
    );
  }
}
