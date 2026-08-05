// test/goldens/buttons_golden_test.dart
//
// One golden frame per button variant-kind, in light AND dark. Each frame is
// a grid of every size (large / medium / small) plus a disabled example, so
// a single PNG documents the full state matrix of that variant.
//
// Generate baselines with: flutter test --update-goldens test/goldens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  void noop() {}

  // Label buttons: take a NasikoButtonSize.
  final sizedLabelVariants =
      <String, Widget Function(NasikoButtonSize size, VoidCallback? onTap)>{
    'primary': (size, onTap) =>
        PrimaryButton(label: 'Primary', size: size, onPressed: onTap),
    'secondary': (size, onTap) =>
        SecondaryButton(label: 'Secondary', size: size, onPressed: onTap),
    'tertiary': (size, onTap) =>
        TertiaryButton(label: 'Tertiary', size: size, onPressed: onTap),
    'destructive': (size, onTap) =>
        DestructiveButton(label: 'Destructive', size: size, onPressed: onTap),
    'destructive_secondary': (size, onTap) => DestructiveSecondaryButton(
          label: 'Destructive secondary',
          size: size,
          onPressed: onTap,
        ),
    'destructive_text': (size, onTap) => DestructiveTextButton(
          label: 'Destructive text',
          size: size,
          onPressed: onTap,
        ),
  };

  // Icon buttons: take a NasikoButtonSize and a HugeIcons icon.
  final sizedIconVariants =
      <String, Widget Function(NasikoButtonSize size, VoidCallback? onTap)>{
    'primary_icon': (size, onTap) => PrimaryIconButton(
          icon: HugeIcons.strokeRoundedSearch01,
          size: size,
          onPressed: onTap,
        ),
    'secondary_icon': (size, onTap) => SecondaryIconButton(
          icon: HugeIcons.strokeRoundedSearch01,
          size: size,
          onPressed: onTap,
        ),
    'tertiary_icon': (size, onTap) => TertiaryIconButton(
          icon: HugeIcons.strokeRoundedSearch01,
          size: size,
          onPressed: onTap,
        ),
    'destructive_icon': (size, onTap) => DestructiveIconButton(
          icon: HugeIcons.strokeRoundedCancel01,
          size: size,
          onPressed: onTap,
        ),
  };

  // Text-only buttons: no size parameter — enabled + disabled per frame.
  final unsizedTextVariants =
      <String, Widget Function(VoidCallback? onTap)>{
    'primary_text': (onTap) =>
        PrimaryTextButton(label: 'Primary text', onPressed: onTap),
    'secondary_text': (onTap) =>
        SecondaryTextButton(label: 'Secondary text', onPressed: onTap),
    'link': (onTap) => LinkButton(label: 'Link button', onPressed: onTap),
  };

  Widget sizedGrid(
    Widget Function(NasikoButtonSize size, VoidCallback? onTap) build,
  ) {
    return goldenFrame(
      Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          build(NasikoButtonSize.large, noop),
          build(NasikoButtonSize.medium, noop),
          build(NasikoButtonSize.small, noop),
          // Disabled example (large).
          build(NasikoButtonSize.large, null),
        ],
      ),
    );
  }

  Widget unsizedGrid(Widget Function(VoidCallback? onTap) build) {
    return goldenFrame(
      Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          build(noop),
          build(null),
        ],
      ),
    );
  }

  for (final mode in kGoldenThemeModes) {
    final suffix = brightnessSuffix(mode);

    for (final entry in sizedLabelVariants.entries) {
      testWidgets('button ${entry.key} – $suffix', (tester) async {
        await pumpNasiko(tester, sizedGrid(entry.value), brightness: mode);
        await tester.pumpAndSettle();
        await expectGolden(tester, 'buttons_${entry.key}_$suffix');
      });
    }

    for (final entry in sizedIconVariants.entries) {
      testWidgets('button ${entry.key} – $suffix', (tester) async {
        await pumpNasiko(tester, sizedGrid(entry.value), brightness: mode);
        await tester.pumpAndSettle();
        await expectGolden(tester, 'buttons_${entry.key}_$suffix');
      });
    }

    for (final entry in unsizedTextVariants.entries) {
      testWidgets('button ${entry.key} – $suffix', (tester) async {
        await pumpNasiko(tester, unsizedGrid(entry.value), brightness: mode);
        await tester.pumpAndSettle();
        await expectGolden(tester, 'buttons_${entry.key}_$suffix');
      });
    }
  }
}
