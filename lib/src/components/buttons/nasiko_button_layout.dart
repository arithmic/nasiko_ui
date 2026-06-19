import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Layout values for the DESIGN-2 button restructure, by [NasikoButtonSize].
///
/// Heights, gaps, paddings, radii, and icon size are all size-driven (not
/// type-driven), matching the Figma `button/{default,just-icon}/layout/*`
/// tokens. Bound to existing Nasiko tokens where the value exists.
@immutable
class NasikoButtonLayoutV2 {
  const NasikoButtonLayoutV2({
    required this.height,
    required this.contentGap,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.bodyRadius,
    required this.focusRadius,
    required this.iconSize,
  });

  final double height;
  final double contentGap;
  final double verticalPadding;
  final double horizontalPadding;
  final double bodyRadius;
  final double focusRadius;
  final double iconSize;

  EdgeInsets get padding => EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      );
}

/// Returns the size-driven layout for the new button components.
NasikoButtonLayoutV2 buttonLayoutV2(
  BuildContext context,
  NasikoButtonSize size,
) {
  final spacing = context.spacing;
  final radii = context.radius;
  final icons = context.iconSize;

  return switch (size) {
    NasikoButtonSize.small => NasikoButtonLayoutV2(
        height: spacing.s28, // 28
        contentGap: spacing.s6, // 6
        verticalPadding: spacing.s5, // 5
        horizontalPadding: spacing.s12, // 12
        bodyRadius: radii.r6, // 6
        focusRadius: radii.r8, // 8
        iconSize: icons.xs, // 12
      ),
    NasikoButtonSize.medium => NasikoButtonLayoutV2(
        // TODO: add an `s32` spacing token; using a literal until then.
        height: 32,
        contentGap: spacing.s6, // 6
        verticalPadding: spacing.s7, // 7
        horizontalPadding: spacing.s12, // 12
        bodyRadius: radii.r8, // 8
        focusRadius: radii.r10, // 10
        iconSize: icons.sm, // 16
      ),
    NasikoButtonSize.large => NasikoButtonLayoutV2(
        height: spacing.s36, // 36
        contentGap: spacing.s8, // 8
        verticalPadding: spacing.s7, // 7
        horizontalPadding: spacing.s16, // 16
        bodyRadius: radii.r8, // 8
        focusRadius: radii.r10, // 10
        iconSize: icons.md, // 20
      ),
  };
}
