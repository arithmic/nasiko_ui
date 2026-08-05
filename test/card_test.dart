import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

void main() {
  setUpAll(() {
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(1200, 900)),
      designSize: const Size(1200, 900),
      splitScreenMode: false,
      minTextAdapt: true,
    );
  });

  Widget wrap(Widget child) => MaterialApp(
    theme: NasikoTheme.lightTheme,
    home: Scaffold(body: Center(child: SizedBox(width: 360, child: child))),
  );

  testWidgets('tag labels keep their given case', (tester) async {
    await tester.pumpWidget(
      wrap(
        const NasikoCard(
          title: 'calendar-agent',
          description: 'Manages Google Calendar events using MCP tools.',
          tags: [NasikoCardTag('Calendar'), NasikoCardTag('Google')],
        ),
      ),
    );

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('CALENDAR'), findsNothing);
  });

  testWidgets('tags beyond the fitting width collapse into a +N chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const NasikoCard(
          title: 'calendar-agent',
          maxVisibleTags: 4,
          tags: [
            NasikoCardTag('Calendar'),
            NasikoCardTag('Google'),
            NasikoCardTag('Scheduling'),
            NasikoCardTag('Availability'),
            NasikoCardTag('Meetings'),
          ],
        ),
      ),
    );

    expect(find.text('Calendar'), findsOneWidget);
    // Five long chips cannot fit 360px, so at least one is collapsed.
    expect(find.textContaining(RegExp(r'^\+\d+$')), findsOneWidget);
  });

  testWidgets('tag chips are outlined rounded-rects, not filled pills', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const NasikoCard(
          title: 'calendar-agent',
          tags: [NasikoCardTag('Repository review')],
        ),
      ),
    );

    final chip = tester.widget<NasikoChip>(find.byType(NasikoChip));
    expect(chip.shape, NasikoChipShape.rectangle);
    expect(chip.variant, NasikoChipVariant.base);
  });
}
