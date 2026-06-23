import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Size-driven geometry for [NasikoSearch], bound to Nasiko tokens.
///
/// Mirrors the Figma `search/{md,sm}/layout/*` + shared `control/*` tokens.
/// Search owns its own layout values (decoupled from Input's `input/*`), though
/// the resolved values match Input. Fixed-height, so no vertical padding token.
@immutable
class NasikoSearchLayout {
  const NasikoSearchLayout({
    required this.height,
    required this.horizontalPadding,
    required this.contentGap,
    required this.iconSize,
    required this.bodyRadius,
    required this.focusRadius,
  });

  /// Fixed box height (36 default / 28 compact).
  final double height;

  /// Inner horizontal padding of the search-box (12 / 8).
  final double horizontalPadding;

  /// Gap between icon and text (8 / 6).
  final double contentGap;

  /// Leading/trailing icon size (16 / 12).
  final double iconSize;

  /// Radius of the visible search-box (8 / 6).
  final double bodyRadius;

  /// Radius of the outset focus ring (10 / 8).
  final double focusRadius;
}

/// Returns the size-driven layout for [NasikoSearch].
NasikoSearchLayout searchLayout(BuildContext context, NasikoSearchSize size) {
  final spacing = context.spacing;
  final radii = context.radius;
  final icons = context.iconSize;

  return switch (size) {
    NasikoSearchSize.medium => NasikoSearchLayout(
        // NOTE: Flutter has no `control/height/*` token group; heights bind to
        // spacing tiers (s36/s28), same parity gap accepted by Input/Button.
        height: spacing.s36, // 36
        horizontalPadding: spacing.s12, // 12
        contentGap: spacing.s8, // 8
        iconSize: icons.sm, // 16
        bodyRadius: radii.r8, // 8
        focusRadius: radii.r10, // 10
      ),
    NasikoSearchSize.small => NasikoSearchLayout(
        height: spacing.s28, // 28
        horizontalPadding: spacing.s8, // 8
        contentGap: spacing.s6, // 6
        iconSize: icons.xs, // 12
        bodyRadius: radii.r6, // 6
        focusRadius: radii.r8, // 8
      ),
  };
}
