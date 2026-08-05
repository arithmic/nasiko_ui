// test/behavior/data_table_test.dart
//
// Behavior tests for NasikoDataTable: the internal sort cycle
// (asc → desc → clear), controlled sorting that never reorders locally,
// row/header selection with the indeterminate dash state, client-side
// pagination slicing with the 'X–Y of Z' summary, server-side pagination
// (totalRows: no slicing), the loading skeleton, and the empty state.
//
// NOTE ON PUMPS: the loading skeleton hosts a repeating shimmer — those
// tests use FIXED pumps only (never pumpAndSettle, it would time out).
// Everywhere else the body cross-fade (motion.fast) is a one-shot
// AnimatedSwitcher, so pumpAndSettle is safe.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

class _Agent {
  const _Agent(this.name, this.status, this.age);
  final String name;
  final String status;
  final int age;
}

void main() {
  // Deliberately NOT in name order, so the unsorted baseline is distinct
  // from both the ascending and descending orders.
  const agents = [
    _Agent('Dan', 'Error', 52),
    _Agent('Alice', 'Active', 34),
    _Agent('Cara', 'Active', 29),
    _Agent('Bella', 'Paused', 41),
  ];

  List<NasikoDataColumn<_Agent>> columns({bool withComparator = true}) => [
        NasikoDataColumn<_Agent>(
          label: 'Name',
          sortable: true,
          comparator:
              withComparator ? (a, b) => a.name.compareTo(b.name) : null,
          cellBuilder: (context, row) => Text(row.name),
        ),
        NasikoDataColumn<_Agent>(
          label: 'Status',
          cellBuilder: (context, row) => Text(row.status),
        ),
        NasikoDataColumn<_Agent>(
          label: 'Age',
          cellBuilder: (context, row) => Text('${row.age}'),
        ),
      ];

  /// Vertical position of a cell text — used to assert visual row order.
  double dyOf(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  /// Asserts the given cell texts appear top-to-bottom in [expected] order.
  void expectRowOrder(WidgetTester tester, List<String> expected) {
    for (var i = 0; i < expected.length - 1; i++) {
      expect(
        dyOf(tester, expected[i]),
        lessThan(dyOf(tester, expected[i + 1])),
        reason: '${expected[i]} should be rendered above ${expected[i + 1]}',
      );
    }
  }

  /// The checkbox inside the body row whose name cell shows [name].
  Finder rowCheckbox(String name) => find.descendant(
        of: find.widgetWithText(Row, name).first,
        matching: find.byType(NasikoCheckbox),
      );

  group('NasikoDataTable internal sorting', () {
    testWidgets('header tap cycles ascending → descending → cleared',
        (tester) async {
      await pumpNasiko(
        tester,
        SizedBox(
          width: 620,
          child: NasikoDataTable<_Agent>(columns: columns(), rows: agents),
        ),
      );
      await tester.pumpAndSettle();

      // Unsorted: rows render in the order they were given.
      expectRowOrder(tester, ['Dan', 'Alice', 'Cara', 'Bella']);

      // 1st tap: ascending by name.
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expectRowOrder(tester, ['Alice', 'Bella', 'Cara', 'Dan']);

      // 2nd tap: descending.
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expectRowOrder(tester, ['Dan', 'Cara', 'Bella', 'Alice']);

      // 3rd tap: sort cleared — back to the given order.
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expectRowOrder(tester, ['Dan', 'Alice', 'Cara', 'Bella']);
    });
  });

  group('NasikoDataTable controlled sorting', () {
    testWidgets('emits (index, ascending) and never reorders rows locally',
        (tester) async {
      final events = <(int?, bool)>[];
      int? sortColumn;
      var sortAscending = true;

      await pumpNasiko(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 620,
            child: NasikoDataTable<_Agent>(
              // No comparator: the parent owns ordering in controlled mode.
              columns: columns(withComparator: false),
              rows: agents,
              sortColumnIndex: sortColumn,
              sortAscending: sortAscending,
              onSortChanged: (index, ascending) {
                events.add((index, ascending));
                setState(() {
                  sortColumn = index;
                  sortAscending = ascending;
                });
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expect(events, [(0, true)]);
      // The table itself must not reorder — the parent didn't.
      expectRowOrder(tester, ['Dan', 'Alice', 'Cara', 'Bella']);

      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expect(events, [(0, true), (0, false)]);
      expectRowOrder(tester, ['Dan', 'Alice', 'Cara', 'Bella']);

      // Third tap on the same header clears the sort: index is null.
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expect(events, [(0, true), (0, false), (null, true)]);
      expectRowOrder(tester, ['Dan', 'Alice', 'Cara', 'Bella']);
    });
  });

  group('NasikoDataTable selection', () {
    Future<void> pumpSelectable(
      WidgetTester tester, {
      required void Function(Set<Object>) onSelectionChanged,
      Set<Object>? selected,
    }) async {
      await pumpNasiko(
        tester,
        SizedBox(
          width: 620,
          child: NasikoDataTable<_Agent>(
            columns: columns(),
            rows: agents,
            selectable: true,
            rowKey: (row) => row.name,
            selected: selected,
            onSelectionChanged: onSelectionChanged,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('row checkbox toggles and reports the full selection set',
        (tester) async {
      Set<Object>? last;
      await pumpSelectable(tester, onSelectionChanged: (s) => last = s);

      // Header + 4 row checkboxes.
      expect(find.byType(NasikoCheckbox), findsNWidgets(5));

      await tester.tap(rowCheckbox('Dan'));
      await tester.pumpAndSettle();
      expect(last, {'Dan'});

      await tester.tap(rowCheckbox('Alice'));
      await tester.pumpAndSettle();
      expect(last, {'Dan', 'Alice'});

      // Toggling off removes only that key.
      await tester.tap(rowCheckbox('Dan'));
      await tester.pumpAndSettle();
      expect(last, {'Alice'});
    });

    testWidgets(
        'header checkbox selects the page; partial selection shows the '
        'indeterminate dash which completes the page', (tester) async {
      Set<Object>? last;
      await pumpSelectable(tester, onSelectionChanged: (s) => last = s);

      // Remember where the header checkbox sits — when the page becomes
      // partially selected it is swapped for a (private) dash widget at the
      // same position.
      final headerCheckboxCenter =
          tester.getCenter(find.byType(NasikoCheckbox).first);

      // Select-all on page.
      await tester.tapAt(headerCheckboxCenter);
      await tester.pumpAndSettle();
      expect(last, {'Dan', 'Alice', 'Cara', 'Bella'});

      // Deselect one row: the page is now partial, so the header checkbox
      // is replaced by the indeterminate dash (one fewer NasikoCheckbox).
      await tester.tap(rowCheckbox('Cara'));
      await tester.pumpAndSettle();
      expect(last, {'Dan', 'Alice', 'Bella'});
      expect(
        find.byType(NasikoCheckbox),
        findsNWidgets(4),
        reason: 'header swaps to the indeterminate dash when partial',
      );

      // Activating the dash completes the page.
      await tester.tapAt(headerCheckboxCenter);
      await tester.pumpAndSettle();
      expect(last, {'Dan', 'Alice', 'Cara', 'Bella'});
      expect(find.byType(NasikoCheckbox), findsNWidgets(5),
          reason: 'fully selected page restores the real header checkbox');

      // Tapping the (checked) header checkbox clears the page.
      await tester.tapAt(headerCheckboxCenter);
      await tester.pumpAndSettle();
      expect(last, isEmpty);
    });

    testWidgets('controlled selection reports changes without applying them',
        (tester) async {
      Set<Object>? last;
      await pumpSelectable(
        tester,
        selected: const {'Dan'},
        onSelectionChanged: (s) => last = s,
      );

      await tester.tap(rowCheckbox('Alice'));
      await tester.pumpAndSettle();

      // The parent was told the next set, but since `selected` never
      // changed, the header must still reflect a single-row (partial)
      // selection — proving no internal state was applied.
      expect(last, {'Dan', 'Alice'});
      expect(find.byType(NasikoCheckbox), findsNWidgets(4),
          reason: 'still partial: controlled table kept selected == {Dan}');
    });
  });

  group('NasikoDataTable pagination (client-side)', () {
    // Ages are kept three-digit so the rendered age cells can never collide
    // with the single-digit pagination number buttons ('1', '2', '3').
    const items = [
      _Agent('Item 1', 'Active', 101),
      _Agent('Item 2', 'Active', 102),
      _Agent('Item 3', 'Active', 103),
      _Agent('Item 4', 'Active', 104),
      _Agent('Item 5', 'Active', 105),
      _Agent('Item 6', 'Active', 106),
      _Agent('Item 7', 'Active', 107),
      _Agent('Item 8', 'Active', 108),
    ];

    Future<void> pumpPaged(WidgetTester tester) async {
      await pumpNasiko(
        tester,
        SizedBox(
          width: 620,
          child: NasikoDataTable<_Agent>(
            columns: columns(),
            rows: items,
            pageSize: 3,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('slices rows per page and renders the range summary',
        (tester) async {
      await pumpPaged(tester);

      expect(find.text('1–3 of 8'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.text('Item 4'), findsNothing);

      // Previous chevron is disabled on the first page.
      final prev = tester
          .widget<TertiaryIconButton>(find.byType(TertiaryIconButton).first);
      expect(prev.onPressed, isNull);
    });

    testWidgets('numbered page button jumps to that page', (tester) async {
      await pumpPaged(tester);

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      expect(find.text('4–6 of 8'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
      expect(find.text('Item 6'), findsOneWidget);
      expect(find.text('Item 1'), findsNothing);
      expect(find.text('Item 7'), findsNothing);
    });

    testWidgets('next chevron advances; last page shows a short range',
        (tester) async {
      await pumpPaged(tester);

      // Next chevron is the LAST TertiaryIconButton in the footer.
      final next = find.byType(TertiaryIconButton).last;
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('4–6 of 8'), findsOneWidget);

      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('7–8 of 8'), findsOneWidget);
      expect(find.text('Item 7'), findsOneWidget);
      expect(find.text('Item 8'), findsOneWidget);
      expect(find.text('Item 6'), findsNothing);

      // Now the next chevron is disabled.
      expect(
        tester.widget<TertiaryIconButton>(next).onPressed,
        isNull,
      );
    });
  });

  group('NasikoDataTable pagination (server-side, totalRows)', () {
    testWidgets('does not slice pre-sliced rows and sums with totalRows',
        (tester) async {
      // Three-digit ages again, so age cells can't collide with the
      // pagination number buttons ('1'..'4').
      const serverPage = [
        _Agent('Srv 7', 'Active', 107),
        _Agent('Srv 8', 'Active', 108),
        _Agent('Srv 9', 'Active', 109),
      ];
      final requestedPages = <int>[];

      await pumpNasiko(
        tester,
        SizedBox(
          width: 620,
          child: NasikoDataTable<_Agent>(
            columns: columns(),
            rows: serverPage,
            pageSize: 3,
            totalRows: 10,
            page: 2,
            onPageChanged: requestedPages.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // All 3 given rows render even though page == 2 (no local slicing),
      // and the summary is computed from totalRows.
      expect(find.text('Srv 7'), findsOneWidget);
      expect(find.text('Srv 9'), findsOneWidget);
      expect(find.text('7–9 of 10'), findsOneWidget);

      // pageCount = ceil(10 / 3) = 4.
      expect(find.text('4'), findsOneWidget);

      // Controlled: page taps only emit the requested index; the rendered
      // rows are unchanged until the parent supplies a new slice.
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();
      expect(requestedPages, [3]);
      expect(find.text('Srv 7'), findsOneWidget);

      await tester.tap(find.byType(TertiaryIconButton).last);
      await tester.pumpAndSettle();
      expect(requestedPages, [3, 3]);
    });
  });

  group('NasikoDataTable loading skeleton', () {
    testWidgets('isLoading renders shimmer rows and hides the footer',
        (tester) async {
      await pumpNasiko(
        tester,
        SizedBox(
          width: 620,
          child: NasikoDataTable<_Agent>(
            columns: columns(),
            rows: agents,
            isLoading: true,
            skeletonRowCount: 5,
            pageSize: 3,
          ),
        ),
      );
      // FIXED pumps only from here: the skeleton shimmer repeats forever,
      // so pumpAndSettle would time out. Never settle a visible skeleton.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(NasikoSkeletonScope), findsOneWidget);
      // 5 skeleton rows × 3 columns of placeholder blocks.
      expect(find.byType(NasikoSkeletonBlock), findsNWidgets(15));
      // Real cell content and the pagination footer are suppressed.
      expect(find.text('Dan'), findsNothing);
      expect(find.byType(NasikoPagination), findsNothing);
      expect(find.text('No data'), findsNothing);
    });
  });

  group('NasikoDataTable empty state', () {
    testWidgets('no rows and not loading renders the default empty state',
        (tester) async {
      await pumpNasiko(
        tester,
        SizedBox(
          width: 620,
          child: NasikoDataTable<_Agent>(
            columns: columns(),
            rows: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No data'), findsOneWidget);
      expect(find.byType(NasikoSkeletonScope), findsNothing);
    });

    testWidgets('a custom emptyState widget replaces the default',
        (tester) async {
      await pumpNasiko(
        tester,
        SizedBox(
          width: 620,
          child: NasikoDataTable<_Agent>(
            columns: columns(),
            rows: const [],
            emptyState: const NasikoEmpty(title: 'No agents yet'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No agents yet'), findsOneWidget);
      expect(find.text('No data'), findsNothing);
    });
  });
}
