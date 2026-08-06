// test/behavior/hover_card_test.dart
//
// Behavior tests for NasikoHoverCard's hover-intent timers:
//   * opens after the 700ms open delay (699ms is not enough),
//   * closes 300ms after the pointer leaves both trigger and card,
//   * moving from the trigger ONTO the card cancels the pending close.
//
// Determinism: both delays are real Timers. Every test drives them with
// explicit pump durations and ends with the pointer away + a final >300ms
// pump so no timer is pending when the test finishes. The entrance reveal
// is a one-shot TweenAnimationBuilder; presence asserts use widget finders,
// which see the card regardless of its opacity.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  const trigger = 'hover trigger';
  const cardContent = 'card content';

  /// Far from both trigger and card on the 1400x900 surface.
  const awayPosition = Offset(1100, 700);

  Future<void> pumpHoverCard(WidgetTester tester) async {
    await pumpNasikoOverlayHost(
      tester,
      NasikoHoverCard(
        contentBuilder: (context) => const SizedBox(
          width: 200,
          height: 80,
          child: Center(child: Text(cardContent)),
        ),
        child: Container(
          width: 120,
          height: 40,
          alignment: Alignment.center,
          child: const Text(trigger),
        ),
      ),
    );
  }

  /// A hover pointer parked at [awayPosition].
  Future<TestGesture> createHoverPointer(WidgetTester tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: awayPosition);
    addTearDown(gesture.removePointer);
    await tester.pump();
    return gesture;
  }

  bool cardIsOpen(WidgetTester tester) =>
      find.text(cardContent).evaluate().isNotEmpty;

  /// Advances past a timer boundary. The overlay engine syncs its portal in
  /// a POST-frame callback, so visibility changes need one more frame after
  /// the frame in which the timer fired.
  Future<void> pumpPast(WidgetTester tester, Duration duration) async {
    await tester.pump(duration);
    await tester.pump();
  }

  testWidgets('opens after 700ms of hover; 699ms is not enough',
      (tester) async {
    await pumpHoverCard(tester);
    final pointer = await createHoverPointer(tester);

    await pointer.moveTo(tester.getCenter(find.text(trigger)));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 699));
    await tester.pump();
    expect(cardIsOpen(tester), isFalse,
        reason: 'the open delay has not elapsed yet');

    await pumpPast(tester, const Duration(milliseconds: 2));
    expect(cardIsOpen(tester), isTrue);

    // Flush: leave and run out the close grace before the test ends.
    await pointer.moveTo(awayPosition);
    await tester.pump();
    await pumpPast(tester, const Duration(milliseconds: 301));
    expect(cardIsOpen(tester), isFalse);
  });

  testWidgets('leaving before the open delay cancels the pending open',
      (tester) async {
    await pumpHoverCard(tester);
    final pointer = await createHoverPointer(tester);

    await pointer.moveTo(tester.getCenter(find.text(trigger)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await pointer.moveTo(awayPosition);
    await tester.pump();

    // Even well past the original 700ms mark, nothing opens.
    await pumpPast(tester, const Duration(milliseconds: 800));
    expect(cardIsOpen(tester), isFalse);
  });

  testWidgets('closes 300ms after the pointer leaves; 299ms keeps it open',
      (tester) async {
    await pumpHoverCard(tester);
    final pointer = await createHoverPointer(tester);

    await pointer.moveTo(tester.getCenter(find.text(trigger)));
    await tester.pump();
    await pumpPast(tester, const Duration(milliseconds: 701));
    expect(cardIsOpen(tester), isTrue);

    await pointer.moveTo(awayPosition);
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 299));
    await tester.pump();
    expect(cardIsOpen(tester), isTrue,
        reason: 'still inside the close grace period');

    await pumpPast(tester, const Duration(milliseconds: 2));
    expect(cardIsOpen(tester), isFalse);
  });

  testWidgets('moving from the trigger onto the card keeps it open',
      (tester) async {
    await pumpHoverCard(tester);
    final pointer = await createHoverPointer(tester);

    await pointer.moveTo(tester.getCenter(find.text(trigger)));
    await tester.pump();
    await pumpPast(tester, const Duration(milliseconds: 701));
    expect(cardIsOpen(tester), isTrue);

    // Jump straight onto the card: the exit-trigger + enter-card pair lands
    // in one event batch, cancelling the close grace timer.
    await pointer.moveTo(tester.getCenter(find.text(cardContent)));
    await tester.pump();

    // Well past the 300ms grace: still open while the card is hovered.
    await pumpPast(tester, const Duration(milliseconds: 600));
    expect(cardIsOpen(tester), isTrue);

    // Leaving the card starts the grace period; it closes after 300ms.
    await pointer.moveTo(awayPosition);
    await tester.pump();
    await pumpPast(tester, const Duration(milliseconds: 301));
    expect(cardIsOpen(tester), isFalse);
  });
}
