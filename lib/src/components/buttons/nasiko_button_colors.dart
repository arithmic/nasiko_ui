import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// The resolved colors for one button state.
@immutable
class NasikoButtonColors {
  const NasikoButtonColors({
    required this.fill,
    required this.foreground,
    this.border,
    this.focusRing,
  });

  final Color fill;
  final Color foreground;

  /// Body border color, or null when the type/state draws no border.
  final Color? border;

  /// Focus-ring color, set only in the focused state.
  final Color? focusRing;
}

/// One interaction state for a button. Mirrors the Figma status axis
/// (default · hovered · active · focused · disabled). `active` is the pressed
/// state.
enum NasikoButtonState { defaultState, hovered, active, focused, disabled }

/// Collapses a Material [WidgetState] set into a single [NasikoButtonState],
/// in priority order: disabled > focused > active(pressed) > hovered > default.
NasikoButtonState buttonStateFrom(Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) return NasikoButtonState.disabled;
  if (states.contains(WidgetState.focused)) return NasikoButtonState.focused;
  if (states.contains(WidgetState.pressed)) return NasikoButtonState.active;
  if (states.contains(WidgetState.hovered)) return NasikoButtonState.hovered;
  return NasikoButtonState.defaultState;
}

/// Resolves fill / foreground / border / focus-ring for a button given its
/// type, tone, and interaction state. Uses semantic tokens so it adapts across
/// light/dark.
///
/// `tone == destructive` is only honored for primary and secondary; it is
/// ignored for tertiary, ghost, and link.
NasikoButtonColors resolveButtonColors(
  NasikoColorTheme colors,
  NasikoButtonType type,
  NasikoButtonTone tone,
  NasikoButtonState state,
) {
  // Shared disabled treatment across every type/tone.
  if (state == NasikoButtonState.disabled) {
    return NasikoButtonColors(
      fill: colors.backgroundDisabled,
      foreground: colors.foregroundDisabled,
      border: _typeHasBorder(type) ? colors.borderDisabled : null,
    );
  }

  final focused = state == NasikoButtonState.focused;
  final focusRing = focused ? colors.borderSecondary : null;

  final destructive = tone == NasikoButtonTone.destructive &&
      (type == NasikoButtonType.primary ||
          type == NasikoButtonType.secondary);

  switch (type) {
    case NasikoButtonType.primary:
      if (destructive) {
        // white text; fill ramps error -> red700 -> red900.
        final fill = switch (state) {
          NasikoButtonState.hovered => colors.backgroundErrorHover,
          NasikoButtonState.active => colors.backgroundErrorActive,
          _ => colors.foregroundError, // default + focused
        };
        return NasikoButtonColors(
          fill: fill,
          foreground: colors.foregroundConstantWhite,
          border: colors.borderError,
          focusRing: focusRing,
        );
      }
      // Charcoal; fill ramps black-secondary -> black -> neutral/700.
      final fill = switch (state) {
        NasikoButtonState.hovered => colors.foregroundConstantBlack,
        NasikoButtonState.active => colors.backgroundNeutralActive,
        _ => colors.foregroundConstantBlackSecondary, // default + focused
      };
      final border = state == NasikoButtonState.hovered ||
              state == NasikoButtonState.active
          ? colors.borderHover
          : colors.borderPrimary;
      return NasikoButtonColors(
        fill: fill,
        foreground: colors.foregroundConstantWhite,
        border: border,
        focusRing: focusRing,
      );

    case NasikoButtonType.secondary:
      if (destructive) {
        // Outlined: base fill, red border; hover fills error, active light err.
        final fill = switch (state) {
          NasikoButtonState.hovered => colors.foregroundError,
          NasikoButtonState.active => colors.backgroundError,
          _ => colors.backgroundBase, // default + focused
        };
        final fg = state == NasikoButtonState.hovered
            ? colors.foregroundConstantWhite
            : colors.foregroundError;
        return NasikoButtonColors(
          fill: fill,
          foreground: fg,
          border: colors.borderErrorStrong,
          focusRing: focusRing,
        );
      }
      // Gold: secondary-brand -> secondary-brand-hover -> primary-brand.
      final fill = switch (state) {
        NasikoButtonState.hovered => colors.backgroundSecondaryBrandHover,
        NasikoButtonState.active => colors.backgroundBrand,
        _ => colors.backgroundSecondaryBrand, // default + focused
      };
      final border = state == NasikoButtonState.hovered ||
              state == NasikoButtonState.active
          ? colors.borderSecondary
          : colors.borderPrimary;
      return NasikoButtonColors(
        fill: fill,
        foreground: colors.foregroundPrimary,
        border: border,
        focusRing: focusRing,
      );

    case NasikoButtonType.tertiary:
      // base -> group -> surface.
      final fill = switch (state) {
        NasikoButtonState.hovered => colors.backgroundGroup,
        NasikoButtonState.active => colors.backgroundSurface,
        _ => colors.backgroundBase, // default + focused
      };
      final border = state == NasikoButtonState.hovered
          ? colors.borderSecondary
          : colors.borderPrimary;
      return NasikoButtonColors(
        fill: fill,
        foreground: colors.foregroundPrimary,
        border: border,
        focusRing: focusRing,
      );

    case NasikoButtonType.ghost:
      // transparent -> group -> surface; border only on active.
      final fill = switch (state) {
        NasikoButtonState.hovered => colors.backgroundGroup,
        NasikoButtonState.active => colors.backgroundSurface,
        _ => Colors.transparent, // default + focused
      };
      final border =
          state == NasikoButtonState.active ? colors.borderPrimary : null;
      return NasikoButtonColors(
        fill: fill,
        foreground: colors.foregroundPrimary,
        border: border,
        focusRing: focusRing,
      );

    case NasikoButtonType.link:
      // Neutral underlined text link: dark by default, darkening toward the
      // brand hover color on hover/focus.
      final fg = switch (state) {
        NasikoButtonState.hovered ||
        NasikoButtonState.focused =>
          colors.foregroundBrandHover,
        _ => colors.foregroundPrimary,
      };
      return NasikoButtonColors(
        fill: Colors.transparent,
        foreground: fg,
        focusRing: focusRing,
      );
  }
}

/// Whether a type draws a body border in its resting/disabled state (used to
/// decide if the disabled border token applies).
bool _typeHasBorder(NasikoButtonType type) =>
    type == NasikoButtonType.primary ||
    type == NasikoButtonType.secondary ||
    type == NasikoButtonType.tertiary;
