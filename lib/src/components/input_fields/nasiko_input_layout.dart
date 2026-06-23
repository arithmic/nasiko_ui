import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Size-driven geometry for [NasikoInput], bound to Nasiko tokens.
///
/// Mirrors the Figma `input/{md,sm}/layout/*` + shared `control/*` tokens.
/// The input is fixed-height, so there is no vertical padding token.
@immutable
class NasikoInputLayout {
  const NasikoInputLayout({
    required this.height,
    required this.horizontalPadding,
    required this.contentGap,
    required this.iconSize,
    required this.bodyRadius,
    required this.focusRadius,
    required this.labelGap,
    required this.hintGap,
  });

  /// Fixed box height (36 default / 28 compact).
  final double height;

  /// Inner horizontal padding of the input-box (12 / 8).
  final double horizontalPadding;

  /// Gap between icon and text (8 / 6).
  final double contentGap;

  /// Leading/trailing icon size (16 / 12).
  final double iconSize;

  /// Radius of the visible input-box (8 / 6).
  final double bodyRadius;

  /// Radius of the outset focus ring (10 / 8).
  final double focusRadius;

  /// Gap between label-row and input-box (8, both sizes).
  final double labelGap;

  /// Gap between input-box and hint-row (4, both sizes).
  final double hintGap;
}

/// Returns the size-driven layout for [NasikoInput].
NasikoInputLayout inputLayout(BuildContext context, NasikoInputSize size) {
  final spacing = context.spacing;
  final radii = context.radius;
  final icons = context.iconSize;

  return switch (size) {
    NasikoInputSize.medium => NasikoInputLayout(
        // NOTE: Flutter has no `control/height/*` token group; heights bind to
        // spacing tiers (s36/s28), same parity gap accepted by the Button port.
        height: spacing.s36, // 36
        horizontalPadding: spacing.s12, // 12
        contentGap: spacing.s8, // 8
        iconSize: icons.sm, // 16
        bodyRadius: radii.r8, // 8
        focusRadius: radii.r10, // 10
        labelGap: spacing.s8, // 8
        hintGap: spacing.s4, // 4
      ),
    NasikoInputSize.small => NasikoInputLayout(
        height: spacing.s28, // 28
        horizontalPadding: spacing.s8, // 8
        contentGap: spacing.s6, // 6
        iconSize: icons.xs, // 12
        bodyRadius: radii.r6, // 6
        focusRadius: radii.r8, // 8
        labelGap: spacing.s8, // 8
        hintGap: spacing.s4, // 4
      ),
  };
}
