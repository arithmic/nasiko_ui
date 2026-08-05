// lib/src/components/data_table/data_table.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'pagination.dart';

export 'pagination.dart';

/// Signature for [NasikoDataTable.onSortChanged].
///
/// [columnIndex] is the newly sorted column, or `null` when the third click
/// on a header clears the sort. [ascending] is the requested direction.
typedef NasikoDataTableSortCallback = void Function(
  int? columnIndex,
  bool ascending,
);

/// Signature for [NasikoDataTable.rowKey]: maps a row to the stable identity
/// used for selection.
typedef NasikoDataTableRowKey<T> = Object Function(T row);

/// Describes one column of a [NasikoDataTable].
class NasikoDataColumn<T> {
  const NasikoDataColumn({
    required this.label,
    required this.cellBuilder,
    this.sortable = false,
    this.comparator,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
  })  : assert(flex > 0, 'flex must be greater than zero.'),
        assert(width == null || width > 0, 'width must be greater than zero.');

  /// Header label for the column.
  final String label;

  /// Builds the cell widget for a given row.
  final Widget Function(BuildContext context, T row) cellBuilder;

  /// Whether the header is clickable to sort by this column.
  final bool sortable;

  /// Orders two rows for client-side sorting. Required for [sortable]
  /// columns when the table sorts internally (no
  /// [NasikoDataTable.onSortChanged]); ignored when the parent owns sorting.
  final int Function(T a, T b)? comparator;

  /// Flex factor for the column when [width] is `null`. Defaults to 1.
  final int flex;

  /// Fixed width for the column; overrides [flex] when set.
  final double? width;

  /// Alignment of the header label and cell content within the column.
  final Alignment alignment;
}

/// A composable, styled data table for Nasiko UI.
///
/// Visually identical to [NasikoTable] (same header treatment, dividers,
/// radii) but built around typed rows with per-column
/// [NasikoDataColumn.cellBuilder]s, and with optional sorting, selection,
/// and pagination — each usable in a controlled or internal mode:
///
/// * **Sorting** — controlled when [onSortChanged] is provided: the table
///   only reports `(columnIndex, ascending)` and renders [rows] as given.
///   Otherwise it sorts client-side with [NasikoDataColumn.comparator],
///   seeded from [sortColumnIndex]/[sortAscending]. Header clicks cycle
///   ascending → descending → cleared.
/// * **Selection** — enabled with [selectable]. Row identity comes from
///   [rowKey] (defaults to the row object itself). Controlled when
///   [selected] is provided; every change is reported through
///   [onSelectionChanged]. The header checkbox selects/clears the current
///   page and shows a dash (mixed) state when the page is partially
///   selected.
/// * **Pagination** — enabled with [pageSize]. The page is controlled when
///   [onPageChanged] is provided (the table then renders [page] and only
///   emits the requested index); otherwise it pages internally. For
///   server-side pagination pass pre-sliced [rows] plus [totalRows]: the
///   table skips slicing and uses [totalRows] for the summary and page
///   count.
///
/// While [isLoading], the body renders [skeletonRowCount] shimmering
/// placeholder rows; with no rows (and not loading) it renders [emptyState]
/// or a default [NasikoEmpty]. Page and sort changes cross-fade the body at
/// `context.motion.fast` (reduced-motion aware).
class NasikoDataTable<T> extends StatefulWidget {
  const NasikoDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.rowKey,
    this.isLoading = false,
    this.skeletonRowCount = 6,
    this.emptyState,
    this.onRowTap,
    this.selectable = false,
    this.selected,
    this.onSelectionChanged,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSortChanged,
    this.pageSize,
    this.page,
    this.onPageChanged,
    this.totalRows,
  })  : assert(
          skeletonRowCount > 0,
          'skeletonRowCount must be greater than zero.',
        ),
        assert(
          pageSize == null || pageSize > 0,
          'pageSize must be greater than zero when provided.',
        ),
        assert(page == null || page >= 0, 'page must not be negative.'),
        assert(
          totalRows == null || totalRows >= 0,
          'totalRows must not be negative.',
        ),
        assert(
          totalRows == null || pageSize != null,
          'totalRows is only meaningful when pageSize is set.',
        );

  /// Column definitions, in display order.
  final List<NasikoDataColumn<T>> columns;

  /// The rows to display. When sorting/pagination run internally this is
  /// the full data set; in controlled/server-side modes it is the already
  /// ordered (and, with [totalRows], already sliced) visible set.
  final List<T> rows;

  /// Maps a row to a stable identity for selection. Defaults to the row
  /// object itself (via `==`/`hashCode`).
  final NasikoDataTableRowKey<T>? rowKey;

  /// Whether to show shimmering skeleton rows instead of the body.
  final bool isLoading;

  /// Number of skeleton rows rendered while [isLoading]. Defaults to 6.
  final int skeletonRowCount;

  /// Widget shown when there are no rows and the table is not loading.
  /// Defaults to `NasikoEmpty(title: 'No data')`.
  final Widget? emptyState;

  /// Called when a row is tapped (or activated with Enter). Makes rows
  /// clickable and focusable.
  final void Function(T row)? onRowTap;

  /// Whether to show the leading checkbox column.
  final bool selectable;

  /// Controlled selection: the set of [rowKey] values currently selected.
  /// When `null`, selection state is kept internally.
  final Set<Object>? selected;

  /// Called with the full next selection whenever it changes.
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// The sorted column. In controlled sorting ([onSortChanged] non-null)
  /// this drives the header chevron; otherwise it seeds the internal sort.
  final int? sortColumnIndex;

  /// Sort direction for [sortColumnIndex]. Defaults to true (ascending).
  final bool sortAscending;

  /// When provided, sorting is controlled: header clicks emit
  /// `(columnIndex, ascending)` (index `null` clears the sort) and the
  /// table does not reorder [rows] itself.
  final NasikoDataTableSortCallback? onSortChanged;

  /// Rows per page. When set, the table slices [rows] client-side (unless
  /// [totalRows] is provided) and shows the pagination footer.
  final int? pageSize;

  /// The current zero-based page in controlled pagination
  /// ([onPageChanged] non-null); also seeds the internal page.
  final int? page;

  /// When provided, pagination is controlled: the table emits the requested
  /// zero-based page index instead of paging internally.
  final ValueChanged<int>? onPageChanged;

  /// Total row count for server-side pagination. When set, [rows] are
  /// treated as the pre-sliced current page: the table does not slice and
  /// uses this value for the range summary and page count.
  final int? totalRows;

  @override
  State<NasikoDataTable<T>> createState() => _NasikoDataTableState<T>();
}

class _NasikoDataTableState<T> extends State<NasikoDataTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int _page = 0;
  Set<Object> _selected = <Object>{};

  bool get _sortControlled => widget.onSortChanged != null;
  bool get _pageControlled => widget.onPageChanged != null;

  @override
  void initState() {
    super.initState();
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending;
    _page = widget.page ?? 0;
    _selected = <Object>{...?widget.selected};
  }

  Object _keyOf(T row) => widget.rowKey?.call(row) ?? row as Object;

  // --- State transitions -----------------------------------------------

  void _handleSort(int index) {
    final int? current =
        _sortControlled ? widget.sortColumnIndex : _sortColumnIndex;
    final bool ascending =
        _sortControlled ? widget.sortAscending : _sortAscending;

    // Cycle: unsorted -> ascending -> descending -> cleared.
    final int? nextIndex;
    final bool nextAscending;
    if (current != index) {
      nextIndex = index;
      nextAscending = true;
    } else if (ascending) {
      nextIndex = index;
      nextAscending = false;
    } else {
      nextIndex = null;
      nextAscending = true;
    }

    if (_sortControlled) {
      widget.onSortChanged!(nextIndex, nextAscending);
    } else {
      setState(() {
        _sortColumnIndex = nextIndex;
        _sortAscending = nextAscending;
        // Reordering invalidates the current slice.
        if (!_pageControlled) _page = 0;
      });
    }
  }

  void _handlePageChanged(int nextPage) {
    if (_pageControlled) {
      widget.onPageChanged!(nextPage);
    } else {
      setState(() => _page = nextPage);
    }
  }

  void _setSelection(Set<Object> next) {
    if (widget.selected == null) {
      setState(() => _selected = next);
    }
    widget.onSelectionChanged?.call(next);
  }

  void _toggleRow(Object key, Set<Object> selected) {
    final next = <Object>{...selected};
    if (!next.remove(key)) next.add(key);
    _setSelection(next);
  }

  // --- Build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (widget.onSortChanged == null) {
        for (var i = 0; i < widget.columns.length; i++) {
          final col = widget.columns[i];
          if (col.sortable && col.comparator == null) {
            throw FlutterError(
              'NasikoDataTable: column $i ("${col.label}") is sortable but '
              'has no comparator. Provide NasikoDataColumn.comparator, or '
              'pass onSortChanged to sort externally.',
            );
          }
        }
      }
      return true;
    }());

    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final motion = context.motion;

    // --- Sorting ---
    final int? sortIndex =
        _sortControlled ? widget.sortColumnIndex : _sortColumnIndex;
    final bool sortAscending =
        _sortControlled ? widget.sortAscending : _sortAscending;

    List<T> ordered = widget.rows;
    if (!_sortControlled &&
        sortIndex != null &&
        sortIndex >= 0 &&
        sortIndex < widget.columns.length) {
      final comparator = widget.columns[sortIndex].comparator;
      if (comparator != null) {
        ordered = <T>[...widget.rows]
          ..sort(sortAscending ? comparator : (a, b) => comparator(b, a));
      }
    }

    // --- Pagination ---
    final int? pageSize = widget.pageSize;
    final int total = widget.totalRows ?? widget.rows.length;
    final int pageCount = pageSize == null
        ? 1
        : math.max(1, (total + pageSize - 1) ~/ pageSize);
    final int rawPage = _pageControlled ? (widget.page ?? 0) : _page;
    final int currentPage = math.min(math.max(rawPage, 0), pageCount - 1);

    List<T> visible = ordered;
    if (pageSize != null && widget.totalRows == null) {
      final int startIndex = currentPage * pageSize;
      visible = startIndex >= ordered.length
          ? <T>[]
          : ordered.sublist(
              startIndex,
              math.min(ordered.length, startIndex + pageSize),
            );
    }

    // --- Selection ---
    final Set<Object> selected = widget.selected ?? _selected;
    final List<Object> visibleKeys = widget.selectable
        ? <Object>[for (final row in visible) _keyOf(row)]
        : const <Object>[];

    // --- Body ---
    final Widget body;
    final Key bodyKey;
    final bool bodyIsEmptyState = !widget.isLoading && visible.isEmpty;
    if (widget.isLoading) {
      body = _buildSkeleton(context);
      bodyKey = const ValueKey<String>('nasiko-data-table-loading');
    } else if (bodyIsEmptyState) {
      body = _buildEmpty(context);
      bodyKey = const ValueKey<String>('nasiko-data-table-empty');
    } else {
      body = _buildRows(context, visible, selected);
      bodyKey = ValueKey<String>(
        'nasiko-data-table-rows-$currentPage-$sortIndex-$sortAscending',
      );
    }

    final bool showFooter = pageSize != null && !widget.isLoading && total > 0;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(context, sortIndex, sortAscending, selected,
                visibleKeys),

            // Body: page/sort changes cross-fade the row block.
            AnimatedSwitcher(
              duration: motion.resolve(context, motion.fast),
              switchInCurve: motion.enter,
              switchOutCurve: motion.exit,
              layoutBuilder: (currentChild, previousChildren) => Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              child: KeyedSubtree(key: bodyKey, child: body),
            ),

            // Footer
            if (showFooter) ...[
              // No body block closes itself with a divider any more, so the
              // footer draws its own separator.
              const NasikoDivider(axis: NasikoDividerAxis.horizontal),
              _buildFooter(
                context,
                currentPage,
                pageCount,
                pageSize,
                total,
                visible.length,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Header -----------------------------------------------------------

  Widget _buildHeader(
    BuildContext context,
    int? sortIndex,
    bool sortAscending,
    Set<Object> selected,
    List<Object> visibleKeys,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Container(
      color: colors.backgroundGroup,
      // Ink effects (sortable header hover/splash, header checkbox splash)
      // paint on the nearest Material; without this transparent layer they
      // would render below the opaque header/table fills and never show
      // (same pattern as NasikoCard).
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s16,
                vertical: spacing.s12,
              ),
              child: Row(
                children: [
                  if (widget.selectable)
                    SizedBox(
                      width: spacing.s36,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildHeaderCheckbox(selected, visibleKeys),
                      ),
                    ),
                  for (var i = 0; i < widget.columns.length; i++)
                    _buildHeaderCell(context, i, sortIndex, sortAscending),
                ],
              ),
            ),
            const NasikoDivider(axis: NasikoDividerAxis.horizontal),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    BuildContext context,
    int index,
    int? sortIndex,
    bool sortAscending,
  ) {
    final col = widget.columns[index];
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radii = context.radius;
    final iconSizes = context.iconSize;
    final motion = context.motion;

    final Widget label = Text(
      col.label,
      style: typography.bodySecondaryBold.copyWith(
        color: colors.foregroundPrimary,
      ),
    );

    Widget content = label;
    if (col.sortable) {
      final bool isSorted = sortIndex == index;

      content = InkWell(
        onTap: () => _handleSort(index),
        borderRadius: BorderRadius.circular(radii.r4),
        splashColor: colors.backgroundBrandSubtle,
        highlightColor: colors.backgroundBrandSubtle,
        hoverColor: colors.backgroundSurfaceHover,
        focusColor: colors.backgroundSurfaceHover,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            label,
            Padding(
              padding: EdgeInsets.only(left: spacing.s4),
              // Hidden until sorted; points down for descending and rotates
              // half a turn (up) for ascending.
              child: AnimatedOpacity(
                opacity: isSorted ? 1.0 : 0.0,
                duration: motion.fast,
                curve: motion.enter,
                child: AnimatedRotation(
                  turns: isSorted && sortAscending ? 0.5 : 0.0,
                  duration: motion.resolve(context, motion.fast),
                  curve: motion.move,
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: iconSizes.s,
                    color: colors.foregroundSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _layoutCell(col, content);
  }

  Widget _buildHeaderCheckbox(Set<Object> selected, List<Object> visibleKeys) {
    final bool hasRows = visibleKeys.isNotEmpty;
    final int selectedOnPage = visibleKeys.where(selected.contains).length;
    final bool allSelected = hasRows && selectedOnPage == visibleKeys.length;
    final bool someSelected = selectedOnPage > 0 && !allSelected;

    // NasikoCheckbox has no tristate; the partial state renders a custom
    // dash box with the same styling. Tapping it completes the page.
    if (someSelected) {
      return _IndeterminateHeaderCheckbox(
        onPressed: () => _setSelection(<Object>{...selected, ...visibleKeys}),
      );
    }

    return NasikoCheckbox(
      isChecked: allSelected,
      onChanged: !hasRows
          ? null
          : (_) {
              if (allSelected) {
                _setSelection(<Object>{...selected}..removeAll(visibleKeys));
              } else {
                _setSelection(<Object>{...selected, ...visibleKeys});
              }
            },
    );
  }

  // --- Body -------------------------------------------------------------

  /// Lays a cell out the way [NasikoTable] does: aligned within an
  /// [Expanded] flex slot, or a fixed-width box when [NasikoDataColumn.width]
  /// is set.
  Widget _layoutCell(NasikoDataColumn<T> col, Widget child) {
    final Widget aligned = Align(alignment: col.alignment, child: child);
    final double? width = col.width;
    if (width != null) return SizedBox(width: width, child: aligned);
    return Expanded(flex: col.flex, child: aligned);
  }

  /// Rows are laid out edge to edge: each row owns its horizontal padding so
  /// the trailing divider spans the table's full width (matching
  /// [NasikoTable]).
  Widget _buildRows(BuildContext context, List<T> visible,
      Set<Object> selected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visible.length; i++)
          _buildRow(
            context,
            visible[i],
            selected,
            // The container's own border closes the last row; a divider there
            // too would read as a doubled bottom edge.
            showDivider: i < visible.length - 1,
          ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    T row,
    Set<Object> selected, {
    required bool showDivider,
  }) {
    final spacing = context.spacing;

    final Widget cells = Row(
      children: [
        if (widget.selectable)
          SizedBox(
            width: spacing.s36,
            child: Align(
              alignment: Alignment.centerLeft,
              child: NasikoCheckbox(
                isChecked: selected.contains(_keyOf(row)),
                onChanged: (_) => _toggleRow(_keyOf(row), selected),
              ),
            ),
          ),
        for (final col in widget.columns)
          _layoutCell(col, col.cellBuilder(context, row)),
      ],
    );

    return _NasikoDataTableRow(
      onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(row),
      showDivider: showDivider,
      child: cells,
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final spacing = context.spacing;
    final iconSizes = context.iconSize;
    final radii = context.radius;

    Widget cellBlock(NasikoDataColumn<T> col) {
      final Widget block = Padding(
        padding: EdgeInsets.only(right: spacing.s16),
        child: NasikoSkeletonBlock(height: spacing.s12),
      );
      final double? width = col.width;
      if (width != null) return SizedBox(width: width, child: block);
      return Expanded(flex: col.flex, child: block);
    }

    Widget skeletonRow({required bool showDivider}) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s8,
            ),
            child: Row(
              children: [
                if (widget.selectable)
                  SizedBox(
                    width: spacing.s36,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: NasikoSkeletonBlock(
                        width: iconSizes.m,
                        height: iconSizes.m,
                        radius: BorderRadius.circular(radii.r6),
                      ),
                    ),
                  ),
                for (final col in widget.columns) cellBlock(col),
              ],
            ),
          ),
          if (showDivider)
            const NasikoDivider(axis: NasikoDividerAxis.horizontal),
        ],
      );
    }

    // NasikoSkeletonScope excludes semantics; announce loading here.
    return Semantics(
      label: 'Loading',
      child: NasikoSkeletonScope(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.skeletonRowCount; i++)
              skeletonRow(showDivider: i < widget.skeletonRowCount - 1),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s16,
        vertical: spacing.s32,
      ),
      child: widget.emptyState ?? const NasikoEmpty(title: 'No data'),
    );
  }

  // --- Footer -----------------------------------------------------------

  Widget _buildFooter(
    BuildContext context,
    int page,
    int pageCount,
    int pageSize,
    int total,
    int visibleCount,
  ) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final int first = page * pageSize + 1;
    final int last = math.min(total, page * pageSize + visibleCount);
    final String summary =
        visibleCount == 0 ? '0–0 of $total' : '$first–$last of $total';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s16,
        vertical: spacing.s12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              summary,
              style: typography.bodyTertiary.copyWith(
                color: colors.foregroundSecondary,
              ),
            ),
          ),
          NasikoPagination(
            page: page,
            pageCount: pageCount,
            onPageChanged: _handlePageChanged,
          ),
        ],
      ),
    );
  }
}

/// One body row: an optional tap/keyboard activation target and a trailing
/// divider. Rows deliberately have no hover tint (same as [NasikoTable]);
/// the only background treatment is the keyboard focus highlight, which
/// accessibility requires.
class _NasikoDataTableRow extends StatefulWidget {
  const _NasikoDataTableRow({
    required this.child,
    required this.showDivider,
    this.onTap,
  });

  final Widget child;

  /// Whether to close the row with a divider. False for the last row, whose
  /// edge is already drawn by the table's border or the footer divider.
  final bool showDivider;

  final VoidCallback? onTap;

  @override
  State<_NasikoDataTableRow> createState() => _NasikoDataTableRowState();
}

class _NasikoDataTableRowState extends State<_NasikoDataTableRow> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final motion = context.motion;

    Widget content = Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s16,
            vertical: spacing.s8,
          ),
          child: widget.child,
        ),
        if (widget.showDivider)
          const NasikoDivider(axis: NasikoDividerAxis.horizontal),
      ],
    );

    if (widget.onTap != null) {
      // The AnimatedContainer below paints the focus highlight, so the
      // InkWell contributes only the tap target, click cursor, focus node,
      // and Enter/Space activation.
      content = InkWell(
        onTap: widget.onTap,
        onFocusChange: (isFocused) => setState(() => _isFocused = isFocused),
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: content,
      );
    }

    return AnimatedContainer(
      duration: motion.hover,
      curve: motion.enter,
      color: _isFocused ? colors.backgroundSurfaceHover : Colors.transparent,
      child: content,
    );
  }
}

/// The header checkbox's "partially selected" state.
///
/// [NasikoCheckbox] has no tristate, so this mirrors its checked styling
/// (same box size, radius, brand fill, hover/focus treatment, and motion)
/// but paints a dash instead of a check. Activating it selects the rest of
/// the page.
class _IndeterminateHeaderCheckbox extends StatefulWidget {
  const _IndeterminateHeaderCheckbox({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_IndeterminateHeaderCheckbox> createState() =>
      _IndeterminateHeaderCheckboxState();
}

class _IndeterminateHeaderCheckboxState
    extends State<_IndeterminateHeaderCheckbox> {
  bool _isHovering = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;
    final spacing = context.spacing;
    final motion = context.motion;

    final Color fillColor =
        _isHovering ? colors.backgroundBrandHover : colors.backgroundBrand;
    final Border? border = _isFocused
        ? Border.all(
            color: colors.borderHover,
            width: borderWidths.w2,
            strokeAlign: BorderSide.strokeAlignOutside,
          )
        : null;

    return Semantics(
      mixed: true,
      child: FocusableActionDetector(
        onFocusChange: (isFocused) => setState(() => _isFocused = isFocused),
        onShowHoverHighlight: (isHovering) =>
            setState(() => _isHovering = isHovering),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(radii.r6),
          splashColor: colors.backgroundBrandSubtle,
          highlightColor: colors.backgroundBrandSubtle,
          child: AnimatedContainer(
            duration: motion.hover,
            curve: motion.enter,
            width: iconSizes.m,
            height: iconSizes.m,
            decoration: BoxDecoration(
              color: fillColor,
              border: border,
              borderRadius: BorderRadius.circular(radii.r6),
            ),
            child: Center(
              child: Container(
                width: spacing.s12,
                height: borderWidths.w2,
                decoration: BoxDecoration(
                  color: colors.foregroundOnAction,
                  borderRadius: BorderRadius.circular(borderWidths.w2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
