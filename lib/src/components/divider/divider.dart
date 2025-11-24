// lib/src/components/divider/nasiko_divider.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// Defines the orientation of the divider.
enum NasikoDividerAxis {
  horizontal,
  vertical,
}

/// A horizontal or vertical line to separate content,
/// styled by the Nasiko Design System.
class NasikoDivider extends StatelessWidget {
  const NasikoDivider({
    super.key,
    this.axis = NasikoDividerAxis.horizontal,
  });

  /// The orientation of the divider.
  /// Defaults to [NasikoDividerAxis.horizontal].
  final NasikoDividerAxis axis;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderWidths = context.borderWidth;

    final Color dividerColor = colors.borderPrimary; // neutral/300
    final double dividerThickness = borderWidths.w1; // 1px

    if (axis == NasikoDividerAxis.horizontal) {
      return Divider(
        color: dividerColor,
        thickness: dividerThickness,
        // Setting height to thickness ensures the widget itself
        // takes up no extra vertical space.
        height: dividerThickness,
      );
    } else {
      return VerticalDivider(
        color: dividerColor,
        thickness: dividerThickness,
        // Setting width to thickness ensures the widget itself
        // takes up no extra horizontal space.
        width: dividerThickness,
      );
    }
  }
}