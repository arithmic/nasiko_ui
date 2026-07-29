import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

@immutable
class NasikoButtonLayout {
  const NasikoButtonLayout({
    required this.padding,
    required this.minHeight,
    required this.iconSize,
    this.iconSpacing = 0,
  });

  final EdgeInsets padding;
  final double minHeight;
  final double iconSize;
  final double iconSpacing;
}

NasikoButtonLayout standardButtonLayout(
  BuildContext context,
  NasikoButtonSize size,
) {
  final spacing = context.spacing;
  final iconSizes = context.iconSize;

  return switch (size) {
    NasikoButtonSize.large => NasikoButtonLayout(
      padding: EdgeInsets.symmetric(
        vertical: spacing.s8,
        horizontal: spacing.s16,
      ),
      minHeight: spacing.s36,
      iconSize: iconSizes.s,
      iconSpacing: spacing.s8,
    ),
    NasikoButtonSize.medium => NasikoButtonLayout(
      padding: EdgeInsets.symmetric(
        vertical: spacing.s8,
        horizontal: spacing.s12,
      ),
      minHeight: spacing.s32,
      iconSize: iconSizes.xs,
      iconSpacing: spacing.s8,
    ),
    NasikoButtonSize.small => NasikoButtonLayout(
      padding: EdgeInsets.symmetric(
        vertical: spacing.s8,
        horizontal: spacing.s8,
      ),
      minHeight: spacing.s28,
      iconSize: iconSizes.xxs,
      iconSpacing: spacing.s4,
    ),
  };
}

NasikoButtonLayout quietButtonLayout(
  BuildContext context,
  NasikoButtonSize size,
) {
  final spacing = context.spacing;
  final iconSizes = context.iconSize;

  return switch (size) {
    NasikoButtonSize.large => NasikoButtonLayout(
      padding: EdgeInsets.symmetric(
        vertical: spacing.s8,
        horizontal: spacing.s12,
      ),
      minHeight: spacing.s36,
      iconSize: iconSizes.s,
      iconSpacing: spacing.s8,
    ),
    NasikoButtonSize.medium => NasikoButtonLayout(
      padding: EdgeInsets.symmetric(
        vertical: spacing.s8,
        horizontal: spacing.s8,
      ),
      minHeight: spacing.s32,
      iconSize: iconSizes.xs,
      iconSpacing: spacing.s8,
    ),
    NasikoButtonSize.small => NasikoButtonLayout(
      padding: EdgeInsets.symmetric(
        vertical: spacing.s8,
        horizontal: spacing.s8,
      ),
      minHeight: spacing.s28,
      iconSize: iconSizes.xxs,
      iconSpacing: spacing.s4,
    ),
  };
}

NasikoButtonLayout textButtonLayout(BuildContext context) {
  final spacing = context.spacing;
  final iconSizes = context.iconSize;

  return NasikoButtonLayout(
    padding: EdgeInsets.symmetric(
      vertical: spacing.s8,
      horizontal: spacing.s12,
    ),
    minHeight: spacing.s36,
    iconSize: iconSizes.s,
    iconSpacing: spacing.s8,
  );
}

NasikoButtonLayout linkButtonLayout(BuildContext context) {
  final spacing = context.spacing;
  final iconSizes = context.iconSize;

  return NasikoButtonLayout(
    padding: EdgeInsets.all(spacing.s12),
    minHeight: spacing.s36,
    iconSize: iconSizes.s,
    iconSpacing: spacing.s8,
  );
}

NasikoButtonLayout iconButtonLayout(
  BuildContext context,
  NasikoButtonSize size,
) {
  final spacing = context.spacing;
  final iconSizes = context.iconSize;

  return switch (size) {
    NasikoButtonSize.large => NasikoButtonLayout(
      padding: EdgeInsets.all(spacing.s8),
      minHeight: spacing.s36,
      iconSize: iconSizes.s,
    ),
    NasikoButtonSize.medium => NasikoButtonLayout(
      padding: EdgeInsets.all(spacing.s8),
      minHeight: spacing.s32,
      iconSize: iconSizes.xs,
    ),
    NasikoButtonSize.small => NasikoButtonLayout(
      padding: EdgeInsets.all(spacing.s8),
      minHeight: spacing.s28,
      iconSize: iconSizes.xxs,
    ),
  };
}
