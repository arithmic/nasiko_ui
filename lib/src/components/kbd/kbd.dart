// lib/src/components/kbd/kbd.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Renders a keyboard shortcut as a row of key caps.
///
/// Each entry in [keys] becomes one cap — pass display glyphs, not key
/// names: `['⌘', 'K']`, `['Ctrl', 'Shift', 'P']`.
///
/// ```dart
/// NasikoKbd(keys: ['⌘', 'K'])
/// ```
/// Non-interactive; purely a visual hint (e.g. in menus, tooltips, and
/// command palettes).
class NasikoKbd extends StatelessWidget {
  const NasikoKbd({super.key, required this.keys});

  /// The key cap glyphs, in press order.
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) SizedBox(width: spacing.s4w),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s4w,
              vertical: spacing.s2h,
            ),
            decoration: BoxDecoration(
              color: colors.backgroundSurface,
              borderRadius: BorderRadius.circular(context.radius.r4),
              border: Border.all(
                color: colors.borderPrimary,
                width: context.borderWidth.w1,
              ),
            ),
            child: Text(
              keys[i],
              style: context.typography.code.copyWith(
                color: colors.foregroundSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
