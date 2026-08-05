// test/behavior/field_test.dart
//
// Behavior tests for NasikoField and NasikoFormField: label + required
// marker + description rendering, the errorText lifecycle (error replaces
// the description with a fade/slide entrance and collapses back when
// cleared), and Form.validate() integration.
//
// The helper-line swap animates at motion.fast (150 ms) through an
// AnimatedSwitcher inside an AnimatedSize, both one-shot. These tests use
// BOUNDED explicit pumps (2 × 160 ms) to walk through the entrance so the
// outgoing child is fully removed before asserting — matching the suite's
// determinism rules even though pumpAndSettle would also be safe here.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  /// Walks through the helper line's 150 ms entrance/exit + size change.
  Future<void> pumpHelperSwap(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump(const Duration(milliseconds: 160));
  }

  group('NasikoField rendering', () {
    testWidgets('renders label, required marker, and description',
        (tester) async {
      await pumpNasiko(
        tester,
        const SizedBox(
          width: 360,
          child: NasikoField(
            label: 'Workspace name',
            isRequired: true,
            description: 'Shown to everyone in your org.',
            child: SizedBox(width: 360, height: 40),
          ),
        ),
      );

      // The label and its required marker render as one rich text.
      expect(find.text('Workspace name *'), findsOneWidget);
      expect(find.text('Shown to everyone in your org.'), findsOneWidget);
    });

    testWidgets('omits the required marker when isRequired is false',
        (tester) async {
      await pumpNasiko(
        tester,
        const SizedBox(
          width: 360,
          child: NasikoField(
            label: 'Workspace name',
            child: SizedBox(width: 360, height: 40),
          ),
        ),
      );

      expect(find.text('Workspace name'), findsOneWidget);
      expect(find.text('Workspace name *'), findsNothing);
    });
  });

  group('NasikoField errorText lifecycle', () {
    testWidgets('setting errorText replaces the description; clearing it '
        'restores the description', (tester) async {
      String? error;
      late StateSetter setFieldState;
      const description = 'Shown to everyone in your org.';

      await pumpNasiko(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setFieldState = setState;
            return SizedBox(
              width: 360,
              child: NasikoField(
                label: 'Workspace name',
                description: description,
                errorText: error,
                child: const SizedBox(width: 360, height: 40),
              ),
            );
          },
        ),
      );

      expect(find.text(description), findsOneWidget);

      // Error appears: fades/slides in through the bounded entrance and
      // fully replaces the description.
      setFieldState(() => error = 'Name is already taken.');
      await pumpHelperSwap(tester);
      expect(find.text('Name is already taken.'), findsOneWidget);
      expect(find.text(description), findsNothing,
          reason: 'the error replaces the description while present');

      // Error clears: the description cross-fades back.
      setFieldState(() => error = null);
      await pumpHelperSwap(tester);
      expect(find.text('Name is already taken.'), findsNothing);
      expect(find.text(description), findsOneWidget);
    });
  });

  group('NasikoFormField + Form integration', () {
    testWidgets('Form.validate() drives the Nasiko error presentation',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      const description = 'We only use this for sign-in.';

      await pumpNasiko(
        tester,
        Form(
          key: formKey,
          child: SizedBox(
            width: 360,
            child: NasikoFormField<String>(
              label: 'Email',
              isRequired: true,
              description: description,
              initialValue: '',
              validator: (value) => (value == null || !value.contains('@'))
                  ? 'Enter a valid email.'
                  : null,
              builder: (state) => NasikoInputField(
                hintText: 'you@nasiko.com',
                onChanged: state.didChange,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Email *'), findsOneWidget);
      expect(find.text(description), findsOneWidget);

      // Invalid: validate() fails and the error line replaces the
      // description.
      expect(formKey.currentState!.validate(), isFalse);
      await pumpHelperSwap(tester);
      expect(find.text('Enter a valid email.'), findsOneWidget);
      expect(find.text(description), findsNothing);

      // The control feeds the FormField through state.didChange; a valid
      // value makes validate() pass and clears the error.
      await tester.enterText(find.byType(TextFormField), 'satya@nasiko.com');
      expect(formKey.currentState!.validate(), isTrue);
      await pumpHelperSwap(tester);
      expect(find.text('Enter a valid email.'), findsNothing);
      expect(find.text(description), findsOneWidget);
    });
  });
}
