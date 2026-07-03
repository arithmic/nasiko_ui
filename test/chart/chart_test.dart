import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';
import 'package:nasiko_ui/src/components/chart/chart_tooltip_overlay.dart';

void main() {
  setUpAll(() {
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(390, 844)),
      designSize: const Size(390, 844),
      splitScreenMode: false,
      minTextAdapt: true,
    );
  });

  /// Pumps [child] inside the Nasiko light theme with bounded constraints
  /// (fl_chart requires a bounded box).
  Future<void> pumpInTheme(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NasikoTheme.lightTheme,
        home: Scaffold(
          body: Center(child: SizedBox(width: 360, child: child)),
        ),
      ),
    );
  }

  group('NasikoChartState palette', () {
    test('chartSeriesColor wraps modulo the palette length', () {
      final n = lightColors.chartSeries.length;
      expect(lightColors.chartSeriesColor(0), equals(lightColors.chartSeries1));
      expect(
        lightColors.chartSeriesColor(n),
        equals(lightColors.chartSeriesColor(0)),
      );
      expect(
        lightColors.chartSeriesColor(n + 1),
        equals(lightColors.chartSeriesColor(1)),
      );
    });

    test('series palette has seven distinct colours', () {
      expect(lightColors.chartSeries.toSet().length, equals(7));
    });
  });

  group('NasikoChartFrame', () {
    Widget frame(NasikoChartState state, {VoidCallback? onRetry}) =>
        NasikoChartFrame(
          state: state,
          height: 120,
          onRetry: onRetry,
          builder: (_) => const Text('CHART_BODY'),
        );

    testWidgets('loaded renders the builder output', (tester) async {
      await pumpInTheme(tester, frame(NasikoChartState.loaded));
      expect(find.text('CHART_BODY'), findsOneWidget);
    });

    testWidgets('loading renders a spinner', (tester) async {
      await pumpInTheme(tester, frame(NasikoChartState.loading));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('CHART_BODY'), findsNothing);
    });

    testWidgets('error renders a Retry button that fires onRetry', (
      tester,
    ) async {
      var tapped = false;
      await pumpInTheme(
        tester,
        frame(NasikoChartState.error, onRetry: () => tapped = true),
      );
      expect(find.text("Couldn't load chart"), findsOneWidget);
      expect(find.widgetWithText(TertiaryButton, 'Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });

    testWidgets('empty renders the empty label', (tester) async {
      await pumpInTheme(tester, frame(NasikoChartState.empty));
      expect(find.text('Not enough data to chart yet'), findsOneWidget);
    });
  });

  group('NasikoChartLegend', () {
    testWidgets('renders one row per item with percent labels', (
      tester,
    ) async {
      await pumpInTheme(
        tester,
        const NasikoChartLegend(
          items: [
            NasikoChartLegendItem(
              label: 'Alpha',
              color: Color(0xFF111111),
              percentLabel: '60%',
            ),
            NasikoChartLegendItem(
              label: 'Beta',
              color: Color(0xFF222222),
              percentLabel: '40%',
            ),
          ],
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
    });
  });

  group('ChartTooltipOverlay', () {
    testWidgets('inserts and removes the tooltip overlay on demand', (
      tester,
    ) async {
      await pumpInTheme(tester, const _OverlayHarness());
      expect(find.byType(NasikoChartTooltip), findsNothing);

      await tester.tap(find.byType(_OverlayHarness));
      await tester.pump();
      expect(find.byType(NasikoChartTooltip), findsOneWidget);
      expect(find.text('Harness title'), findsOneWidget);

      final state = tester.state<_OverlayHarnessState>(
        find.byType(_OverlayHarness),
      );
      state.hideChartTooltip();
      await tester.pump();
      expect(find.byType(NasikoChartTooltip), findsNothing);
    });

    testWidgets('updates content in place on a repeated show', (tester) async {
      await pumpInTheme(tester, const _OverlayHarness());
      final state = tester.state<_OverlayHarnessState>(
        find.byType(_OverlayHarness),
      );

      state.show();
      await tester.pump();
      expect(find.text('Harness title'), findsOneWidget);

      state.showChartTooltip(
        anchor: const Offset(20, 20),
        title: 'Updated title',
        rows: const [
          NasikoChartTooltipRow(color: Color(0xFF8C6B05), value: '\$10'),
        ],
      );
      await tester.pump();

      // Still exactly one overlay (updated in place, not a new entry).
      expect(find.byType(NasikoChartTooltip), findsOneWidget);
      expect(find.text('Updated title'), findsOneWidget);
      expect(find.text('Harness title'), findsNothing);
    });
  });

  group('NasikoChartTooltip', () {
    testWidgets('renders a row with no label as dot + value only', (
      tester,
    ) async {
      await pumpInTheme(
        tester,
        const NasikoChartTooltip(
          title: 'Mar 10',
          rows: [
            NasikoChartTooltipRow(color: Color(0xFF8C6B05), value: '\$1.2k'),
          ],
        ),
      );
      expect(find.text('Mar 10'), findsOneWidget);
      expect(find.text('\$1.2k'), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a row with a label, divider, and value', (
      tester,
    ) async {
      await pumpInTheme(
        tester,
        const NasikoChartTooltip(
          title: 'Mar 10',
          rows: [
            NasikoChartTooltipRow(
              color: Color(0xFF8C6B05),
              label: 'Revenue',
              value: '\$1.2k',
            ),
          ],
        ),
      );
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('\$1.2k'), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });

  group('Chart smoke tests', () {
    final lineSeries = [
      const NasikoChartSeries(
        name: 'A',
        points: [
          NasikoChartPoint(x: 0, y: 1),
          NasikoChartPoint(x: 1, y: 3),
          NasikoChartPoint(x: 2, y: 2),
        ],
      ),
      const NasikoChartSeries(
        name: 'B',
        points: [
          NasikoChartPoint(x: 0, y: 2),
          NasikoChartPoint(x: 1, y: 1),
          NasikoChartPoint(x: 2, y: 4),
        ],
      ),
    ];

    testWidgets('NasikoLineChart pumps without error', (tester) async {
      await pumpInTheme(tester, NasikoLineChart(series: lineSeries));
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoLineChart responds to hover without error', (
      tester,
    ) async {
      await pumpInTheme(tester, NasikoLineChart(series: lineSeries));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(NasikoLineChart)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoAreaChart pumps without error', (tester) async {
      await pumpInTheme(
        tester,
        const NasikoAreaChart(
          points: [
            NasikoChartPoint(x: 0, y: 10),
            NasikoChartPoint(x: 1, y: 20),
            NasikoChartPoint(x: 2, y: 15),
            NasikoChartPoint(x: 3, y: 30),
          ],
          threshold: 25,
          thresholdLabel: '\$25',
          projectionFromIndex: 2,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoAreaChart responds to hover without error', (
      tester,
    ) async {
      await pumpInTheme(
        tester,
        const NasikoAreaChart(
          points: [
            NasikoChartPoint(x: 0, y: 10),
            NasikoChartPoint(x: 1, y: 20),
            NasikoChartPoint(x: 2, y: 15),
            NasikoChartPoint(x: 3, y: 30),
          ],
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(NasikoAreaChart)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoDonutChart pumps without error', (tester) async {
      await pumpInTheme(
        tester,
        const NasikoDonutChart(
          segments: [
            NasikoDonutSegment(label: 'x', value: 3),
            NasikoDonutSegment(label: 'y', value: 1),
          ],
          centerLabel: '\$4',
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoDonutChart responds to hover without error', (
      tester,
    ) async {
      await pumpInTheme(
        tester,
        const NasikoDonutChart(
          segments: [
            NasikoDonutSegment(label: 'x', value: 3),
            NasikoDonutSegment(label: 'y', value: 1),
          ],
          centerLabel: '\$4',
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(NasikoDonutChart)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('long legend labels ellipsize instead of overflowing',
        (tester) async {
      await pumpInTheme(
        tester,
        const NasikoDonutChart(
          segments: [
            // A long agent id like the ones the FinOps dashboard shows.
            NasikoDonutSegment(
              label: '726ad9f6-49e1-4702-8eaf-8457d42c0000-really-long-id',
              value: 3,
            ),
            NasikoDonutSegment(label: 'Translator Agent', value: 1),
          ],
          centerLabel: r'$4',
        ),
      );
      // Before the fix the un-truncated label pushed the legend row past its
      // (Flexible-bounded) width and threw a RenderFlex overflow.
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoBarChart pumps without error', (tester) async {
      await pumpInTheme(
        tester,
        const NasikoBarChart(
          data: [
            NasikoBarDatum(label: 'a', value: 4),
            NasikoBarDatum(label: 'b', value: 2),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoStackedBarChart pumps without error', (tester) async {
      await pumpInTheme(
        tester,
        const NasikoStackedBarChart(
          data: [
            NasikoStackedDatum(
              label: 'a',
              segments: [
                NasikoStackedSegment(name: 's1', value: 3),
                NasikoStackedSegment(name: 's2', value: 2),
              ],
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoStackedBarChart responds to hover without error', (
      tester,
    ) async {
      await pumpInTheme(
        tester,
        const NasikoStackedBarChart(
          data: [
            NasikoStackedDatum(
              label: 'a',
              segments: [
                NasikoStackedSegment(name: 's1', value: 3),
                NasikoStackedSegment(name: 's2', value: 2),
              ],
            ),
          ],
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(NasikoStackedBarChart)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoSegmentBar pumps without error', (tester) async {
      await pumpInTheme(
        tester,
        const NasikoSegmentBar(
          rows: [
            NasikoSegmentDatum(label: 'Budget used', percent: 0.72),
          ],
        ),
      );
      expect(find.text('72%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NasikoStatChartCard pumps with a chart child', (tester) async {
      await pumpInTheme(
        tester,
        NasikoStatChartCard(
          title: 'Total spend',
          value: '\$94,127',
          delta: const NasikoTrendDelta(
            label: '9%',
            direction: NasikoTrendDirection.up,
          ),
          onExpand: () {},
          onOverflow: () {},
          child: NasikoLineChart(series: lineSeries, height: 120),
        ),
      );
      expect(find.text('Total spend'), findsOneWidget);
      expect(find.text('\$94,127'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

class _OverlayHarness extends StatefulWidget {
  const _OverlayHarness();

  @override
  State<_OverlayHarness> createState() => _OverlayHarnessState();
}

class _OverlayHarnessState extends State<_OverlayHarness>
    with ChartTooltipOverlay {
  void show() => showChartTooltip(
    anchor: const Offset(10, 10),
    title: 'Harness title',
    rows: const [
      NasikoChartTooltipRow(color: Color(0xFF8C6B05), value: '\$9'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return composeTooltipTarget(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: show,
        child: const SizedBox(width: 100, height: 100),
      ),
    );
  }
}
