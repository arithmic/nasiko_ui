// lib/src/components/chip/chip_group.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A horizontal scrollable group of chips.
///
/// Use this to display multiple chips in a row with consistent spacing.
/// The group will automatically scroll horizontally if the chips overflow.
class NasikoChipGroup extends StatelessWidget {
  const NasikoChipGroup({
    super.key,
    required this.children,
    this.spacing,
    this.scrollable = true,
  });

  /// The list of chip widgets to display.
  final List<Widget> children;

  /// The spacing between chips.
  /// Defaults to the design system's s8 spacing token.
  final double? spacing;

  /// Whether the chip group should scroll horizontally.
  /// Defaults to `true`.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final spacingValue = spacing ?? context.spacing.s8;

    final content = Wrap(
      spacing: spacingValue,
      runSpacing: spacingValue,
      children: children,
    );

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1) SizedBox(width: spacingValue),
            ],
          ],
        ),
      );
    }

    return content;
  }
}
