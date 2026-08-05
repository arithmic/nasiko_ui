// test/goldens/data_table_golden_test.dart
//
// Golden frames for NasikoDataTable: populated (with pagination footer),
// skeleton (loading), and empty — light and dark.
//
// SKELETON: the shimmer sweep repeats forever, so this frame NEVER uses
// pumpAndSettle (it would time out). It is captured on the first frame,
// where the shared shimmer controller is deterministically at t = 0.
//
// Generate baselines with: flutter test --update-goldens test/goldens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

class _Row {
  const _Row(this.name, this.status, this.age);
  final String name;
  final String status;
  final int age;
}

void main() {
  const rows = [
    _Row('Alice', 'Active', 34),
    _Row('Bella', 'Paused', 41),
    _Row('Cara', 'Active', 29),
    _Row('Dan', 'Error', 52),
  ];

  List<NasikoDataColumn<_Row>> columns() => [
        NasikoDataColumn<_Row>(
          label: 'Name',
          sortable: true,
          comparator: (a, b) => a.name.compareTo(b.name),
          cellBuilder: (context, row) => Text(row.name),
        ),
        NasikoDataColumn<_Row>(
          label: 'Status',
          cellBuilder: (context, row) => Text(row.status),
        ),
        NasikoDataColumn<_Row>(
          label: 'Age',
          cellBuilder: (context, row) => Text('${row.age}'),
        ),
      ];

  Widget table({
    List<_Row> data = rows,
    bool isLoading = false,
    int? pageSize,
  }) {
    return goldenFrame(
      SizedBox(
        width: 620,
        child: NasikoDataTable<_Row>(
          columns: columns(),
          rows: data,
          isLoading: isLoading,
          skeletonRowCount: 4,
          pageSize: pageSize,
        ),
      ),
    );
  }

  for (final mode in kGoldenThemeModes) {
    final suffix = brightnessSuffix(mode);

    testWidgets('data table populated – $suffix', (tester) async {
      await pumpNasiko(tester, table(pageSize: 3), brightness: mode);
      await tester.pumpAndSettle();
      await expectGolden(tester, 'data_table_populated_$suffix');
    });

    testWidgets('data table skeleton – $suffix', (tester) async {
      await pumpNasiko(tester, table(isLoading: true), brightness: mode);
      // ONE plain pump only: shimmer repeats forever — never settle here.
      await tester.pump();
      await expectGolden(tester, 'data_table_skeleton_$suffix');
    });

    testWidgets('data table empty – $suffix', (tester) async {
      await pumpNasiko(tester, table(data: const []), brightness: mode);
      // The empty state's entrance is one-shot; settling is safe.
      await tester.pumpAndSettle();
      await expectGolden(tester, 'data_table_empty_$suffix');
    });
  }
}
