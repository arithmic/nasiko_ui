import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// The regressions this pins: row content used to sit inside a padded body
/// wrapper, so row dividers stopped short of the table's edges; and the last
/// row drew a divider flush against the container border, reading as a
/// doubled bottom edge.
void main() {
  setUpAll(() {
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(1200, 900)),
      designSize: const Size(1200, 900),
      splitScreenMode: false,
      minTextAdapt: true,
    );
  });

  const tableWidth = 600.0;

  Future<void> pumpTable(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: NasikoTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: tableWidth,
            child: NasikoDataTable<String>(
              columns: [
                NasikoDataColumn<String>(
                  label: 'Name',
                  cellBuilder: (context, row) => Text(row),
                ),
              ],
              rows: const ['alpha', 'beta'],
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('dividers are full-bleed and the last row has none',
      (tester) async {
    await pumpTable(tester);

    // Header divider + a separator between the two rows. The last row is
    // closed by the table's border, not a divider.
    final dividers = find.byType(NasikoDivider);
    expect(dividers, findsNWidgets(2));

    // 1px border on each side is the only inset allowed.
    for (var i = 0; i < 2; i++) {
      expect(
        tester.getSize(dividers.at(i)).width,
        tableWidth - 2,
        reason: 'divider $i must be full-bleed, not inset by a body gutter',
      );
    }

    // The last row's bottom edge must sit on the container's inner edge, with
    // no divider or leftover gutter between them.
    final tableBottom = tester.getRect(find.byType(NasikoDataTable<String>)).bottom;
    final lastRowBottom = tester
        .getRect(
          find
              .ancestor(
                of: find.text('beta'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        )
        .bottom;
    expect(tableBottom - lastRowBottom, 1.0);
  });

  testWidgets('hovering a row does not tint it', (tester) async {
    await pumpTable(tester);

    final row = find.ancestor(
      of: find.text('alpha'),
      matching: find.byType(AnimatedContainer),
    );

    // AnimatedContainer folds `color` into the decoration of the Container
    // it builds, so read the resolved fill from there.
    Color? rowFill() {
      final container = tester.widget<Container>(
        find.descendant(of: row, matching: find.byType(Container)).first,
      );
      return (container.decoration as BoxDecoration?)?.color;
    }

    expect(rowFill(), Colors.transparent);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('alpha')));
    await tester.pumpAndSettle();

    expect(
      rowFill(),
      Colors.transparent,
      reason: 'rows must stay untinted on hover',
    );
    expect(tester.getSize(row).width, tableWidth - 2);
  });
}
