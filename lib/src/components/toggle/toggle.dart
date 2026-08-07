// lib/src/components/toggle/toggle.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../buttons/button_layout.dart';
import '../internal/interaction_states.dart';

// Interaction model: a two-state button — tap or Enter/Space flips the
// pressed state, hover and focus restyle the chrome, and the press-scale
// micro-feedback matches our buttons. Visuals, tokens, and motion follow
// the Nasiko design system.

/// A two-state (pressed / unpressed) button, e.g. a "Bold" control in a
/// formatting toolbar.
///
/// Controlled component: [value] is owned by the caller and flipped through
/// [onChanged]. Passing `null` for [onChanged] disables the toggle (same
/// convention as [NasikoSwitch] and [NasikoCheckbox]).
///
/// Visuals: rests like a tertiary button (backgroundBase fill, borderPrimary
/// outline); when on it fills backgroundSecondaryBrand with a
/// borderSecondary outline. Keyboard focus shows the button-style
/// borderSecondary w2 ring. State changes animate at `motion.fast` (the
/// shared button animation duration) and presses apply the standard
/// press-scale feedback.
///
/// At least one of [label] and [icon] must be provided.
///
/// ```dart
/// NasikoToggle(
///   icon: HugeIcons.strokeRoundedTextBold,
///   value: isBold,
///   onChanged: (v) => setState(() => isBold = v),
/// )
/// ```
///
/// For an exclusive or multi-select set of toggles, see [NasikoToggleGroup].
class NasikoToggle extends StatelessWidget {
  /// Creates a Nasiko toggle button.
  const NasikoToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.icon,
    this.size = NasikoButtonSize.large,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : assert(label != null || icon != null,
            'Provide a label, an icon, or both.');

  /// Whether the toggle is currently pressed (on).
  final bool value;

  /// Called with the flipped state when the toggle is activated. `null`
  /// disables the toggle.
  final ValueChanged<bool>? onChanged;

  /// Optional text label.
  final String? label;

  /// Optional leading icon.
  final HugeIconsType? icon;

  /// The visual size, using the shared button size scale. Toggles rendered
  /// as a group must all share the same size (design rule; [NasikoToggleGroup]
  /// enforces this).
  final NasikoButtonSize size;

  /// Announced to assistive technologies; falls back to [label].
  final String? semanticLabel;

  /// External focus node; an internal one is managed when null.
  final FocusNode? focusNode;

  /// Whether the toggle should focus itself on mount.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final typography = context.typography;
    final motion = context.motion;

    final enabled = onChanged != null;
    // Quiet (tertiary-like) metrics; text scale matches label buttons.
    final layout = quietButtonLayout(context, size);
    final baseTextStyle = switch (size) {
      NasikoButtonSize.large => typography.buttonPrimary,
      NasikoButtonSize.medium ||
      NasikoButtonSize.small =>
        typography.buttonSecondary,
    };

    return Semantics(
      button: true,
      enabled: enabled,
      selected: value,
      label: semanticLabel,
      child: NasikoInteractionStates(
        enabled: enabled,
        onPressed: enabled ? () => onChanged!(!value) : null,
        focusNode: focusNode,
        autofocus: autofocus,
        pressScale: true,
        builder: (context, state, _) {
          // State -> visual matrix, mirroring the tertiary button spec for
          // the off state and the secondary-brand fill for the on state.
          final Color background;
          final Color foreground;
          final BorderSide side;

          if (state.isDisabled) {
            background = colors.backgroundDisabled;
            foreground = colors.foregroundDisabled;
            side = BorderSide(
              color: colors.borderDisabled,
              width: borderWidths.w1,
            );
          } else if (value) {
            background = state.isHovered
                ? colors.backgroundSecondaryBrandHover
                : colors.backgroundSecondaryBrand;
            foreground = colors.foregroundPrimary;
            side = state.isFocused
                ? BorderSide(
                    color: colors.borderFocus,
                    width: borderWidths.w2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  )
                : BorderSide(
                    color: colors.borderSecondary,
                    width: borderWidths.w1,
                  );
          } else {
            background = colors.backgroundBase;
            foreground = state.isHovered
                ? colors.foregroundIconHover
                : colors.foregroundPrimary;
            side = state.isFocused
                ? BorderSide(
                    color: colors.borderFocus,
                    width: borderWidths.w2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  )
                : state.isHovered
                    ? BorderSide(
                        color: colors.borderSecondary,
                        width: borderWidths.w1,
                      )
                    : BorderSide(
                        color: colors.borderPrimary,
                        width: borderWidths.w1,
                      );
          }

          return AnimatedContainer(
            // motion.fast matches the shared button animationDuration.
            duration: motion.fast,
            curve: motion.enter,
            constraints: BoxConstraints(
              minHeight: layout.minHeight,
              minWidth: layout.minHeight,
            ),
            padding: layout.padding,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(radii.r8),
              border: Border.fromBorderSide(side),
            ),
            child: Align(
              alignment: Alignment.center,
              widthFactor: 1.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    HugeIcon(
                      icon: icon!,
                      size: layout.iconSize,
                      color: foreground,
                    ),
                    if (label != null) SizedBox(width: layout.iconSpacing),
                  ],
                  if (label != null)
                    Text(
                      label!,
                      style: baseTextStyle.copyWith(color: foreground),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
