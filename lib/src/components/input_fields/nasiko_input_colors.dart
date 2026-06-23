import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// The single resolved visual state of a [NasikoInput], in precedence order.
///
/// Resolution precedence (highest first): disabled, readOnly, error, success,
/// focus, hover, normal.
enum NasikoInputVisualState {
  normal,
  hover,
  focus,
  disabled,
  error,
  success,
  readOnly,
}

/// Per-state colors for a [NasikoInput].
@immutable
class NasikoInputColors {
  const NasikoInputColors({
    required this.fill,
    required this.border,
    required this.text,
    required this.hint,
    this.ring,
  });

  /// Input-box fill.
  final Color fill;

  /// Input-box border color.
  final Color border;

  /// Value text color.
  final Color text;

  /// Hint text color.
  final Color hint;

  /// Outset focus-ring color, or null when no ring is drawn.
  final Color? ring;
}

/// Resolves the semantic colors for [state] from the active Nasiko theme.
NasikoInputColors resolveInputColors(
  BuildContext context,
  NasikoInputVisualState state,
) {
  final c = context.colors;

  return switch (state) {
    NasikoInputVisualState.normal => NasikoInputColors(
        fill: c.backgroundBase,
        border: c.borderPrimary,
        text: c.foregroundPrimary,
        hint: c.foregroundSecondary,
      ),
    NasikoInputVisualState.hover => NasikoInputColors(
        fill: c.backgroundBase,
        border: c.borderSecondary, // gold
        text: c.foregroundPrimary,
        hint: c.foregroundSecondary,
      ),
    NasikoInputVisualState.focus => NasikoInputColors(
        fill: c.backgroundBase,
        border: c.borderPrimary,
        text: c.foregroundPrimary,
        hint: c.foregroundSecondary,
        ring: c.borderSecondary, // gold ring
      ),
    NasikoInputVisualState.disabled => NasikoInputColors(
        fill: c.backgroundDisabled,
        border: c.borderDisabled,
        text: c.foregroundDisabled,
        hint: c.foregroundDisabled,
      ),
    // NOTE: Figma `border/default/error` is a light red (#fecaca); the Nasiko
    // semantic `borderError` may be stronger. We bind to the token (correct DS
    // behavior) rather than hard-coding the Figma hex.
    NasikoInputVisualState.error => NasikoInputColors(
        fill: c.backgroundBase,
        border: c.borderError,
        text: c.foregroundPrimary,
        hint: c.foregroundError,
      ),
    NasikoInputVisualState.success => NasikoInputColors(
        fill: c.backgroundBase,
        border: c.borderSuccess,
        text: c.foregroundPrimary,
        hint: c.foregroundSecondary,
      ),
    NasikoInputVisualState.readOnly => NasikoInputColors(
        fill: c.backgroundSurfaceSubtle,
        border: c.borderDisabled,
        text: c.foregroundPrimary,
        hint: c.foregroundSecondary,
      ),
  };
}
