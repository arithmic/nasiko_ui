import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// The single resolved visual state of a [NasikoSearch], in precedence order.
///
/// Resolution precedence (highest first): disabled, loading, focus, hover,
/// normal.
enum NasikoSearchVisualState {
  normal,
  hover,
  focus,
  disabled,
  loading,
}

/// Per-state colors for a [NasikoSearch].
@immutable
class NasikoSearchColors {
  const NasikoSearchColors({
    required this.fill,
    required this.border,
    required this.text,
    this.ring,
  });

  /// Search-box fill.
  final Color fill;

  /// Search-box border color.
  final Color border;

  /// Value text color.
  final Color text;

  /// Outset focus-ring color, or null when no ring is drawn.
  final Color? ring;
}

/// Resolves the semantic colors for [state] from the active Nasiko theme.
NasikoSearchColors resolveSearchColors(
  BuildContext context,
  NasikoSearchVisualState state,
) {
  final c = context.colors;

  return switch (state) {
    NasikoSearchVisualState.normal => NasikoSearchColors(
        fill: c.backgroundBase,
        border: c.borderPrimary,
        text: c.foregroundPrimary,
      ),
    NasikoSearchVisualState.hover => NasikoSearchColors(
        fill: c.backgroundBase,
        border: c.borderSecondary, // gold
        text: c.foregroundPrimary,
      ),
    NasikoSearchVisualState.focus => NasikoSearchColors(
        fill: c.backgroundBase,
        border: c.borderPrimary,
        text: c.foregroundPrimary,
        ring: c.borderSecondary, // gold ring
      ),
    NasikoSearchVisualState.disabled => NasikoSearchColors(
        fill: c.backgroundDisabled,
        border: c.borderDisabled,
        text: c.foregroundDisabled,
      ),
    NasikoSearchVisualState.loading => NasikoSearchColors(
        fill: c.backgroundBase,
        border: c.borderPrimary,
        text: c.foregroundPrimary,
      ),
  };
}
