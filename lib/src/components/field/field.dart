// lib/src/components/field/field.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Presentation wrapper that gives any form control a consistent label,
/// description, and error treatment.
///
/// Layout: label row (with an optional required marker) above the control,
/// and a helper line below it showing either the [description] or — when
/// present — the [errorText], which replaces the description with a
/// cross-fade. The error line enters with a fade + slight slide-down and the
/// reserved space grows/collapses smoothly (reduced-motion aware).
///
/// ```dart
/// NasikoField(
///   label: 'Workspace name',
///   isRequired: true,
///   description: 'Shown to everyone in your org.',
///   errorText: state.hasError ? 'Name is already taken.' : null,
///   child: NasikoInputField(...),
/// )
/// ```
class NasikoField extends StatelessWidget {
  /// Creates a labelled field wrapper around [child].
  const NasikoField({
    super.key,
    required this.child,
    this.label,
    this.isRequired = false,
    this.description,
    this.errorText,
    this.enabled = true,
  });

  /// The form control being presented (input, dropdown, checkbox row, …).
  final Widget child;

  /// Optional label shown above the control.
  final String? label;

  /// Appends a foregroundError `*` to the label when true.
  final bool isRequired;

  /// Optional supporting copy under the control. Hidden while [errorText]
  /// is showing (the error replaces it).
  final String? description;

  /// Validation message under the control; `null` collapses the space.
  final String? errorText;

  /// When false, the label and description render dimmed. The [child] itself
  /// is expected to handle its own disabled state.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final motion = context.motion;

    final labelColor =
        enabled ? colors.foregroundPrimary : colors.foregroundDisabled;
    final requiredColor =
        enabled ? colors.foregroundError : colors.foregroundDisabled;
    final descriptionColor =
        enabled ? colors.foregroundSecondary : colors.foregroundDisabled;

    // Helper line: error wins over description; SizedBox.shrink collapses
    // the space entirely. Keys drive the AnimatedSwitcher cross-fade.
    Widget helper;
    if (errorText != null) {
      helper = Semantics(
        liveRegion: true,
        child: Padding(
          key: const ValueKey('nasiko-field-error'),
          padding: EdgeInsets.only(top: spacing.s4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlert02,
                size: iconSizes.xs,
                color: colors.foregroundError,
              ),
              SizedBox(width: spacing.s4),
              Expanded(
                child: Text(
                  errorText!,
                  style: typography.bodyTertiary.copyWith(
                    color: colors.foregroundError,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (description != null) {
      helper = Padding(
        key: const ValueKey('nasiko-field-description'),
        padding: EdgeInsets.only(top: spacing.s4),
        child: Text(
          description!,
          style: typography.bodyTertiary.copyWith(color: descriptionColor),
        ),
      );
    } else {
      helper = const SizedBox.shrink(key: ValueKey('nasiko-field-none'));
    }

    final helperDuration = motion.resolve(context, motion.fast);
    final slideDistance = spacing.s4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text.rich(
            TextSpan(
              text: label,
              style: typography.bodySecondary.copyWith(color: labelColor),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: typography.bodySecondary.copyWith(
                      color: requiredColor,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: spacing.s4),
        ],
        child,
        // AnimatedSize grows/collapses the reserved space; AnimatedSwitcher
        // cross-fades description <-> error, with a slight slide-down so the
        // incoming line settles into place.
        AnimatedSize(
          duration: helperDuration,
          curve: motion.move,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: helperDuration,
            switchInCurve: motion.enter,
            switchOutCurve: motion.exit,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: AnimatedBuilder(
                  animation: animation,
                  child: child,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -slideDistance * (1 - animation.value)),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: helper,
          ),
        ),
      ],
    );
  }
}

/// Thin [FormField] integration for [NasikoField].
///
/// Wires a [FormField]'s validation state into the Nasiko field presentation:
/// the builder supplies just the control, and its output is wrapped in a
/// [NasikoField] that renders [label], [isRequired], [description], and the
/// live `state.errorText`.
///
/// ```dart
/// NasikoFormField<String>(
///   label: 'Email',
///   isRequired: true,
///   description: 'We only use this for sign-in.',
///   initialValue: '',
///   validator: (value) =>
///       (value == null || !value.contains('@')) ? 'Enter a valid email.' : null,
///   autovalidateMode: AutovalidateMode.onUserInteraction,
///   builder: (state) => NasikoInputField(
///     onChanged: state.didChange,
///   ),
/// )
/// ```
class NasikoFormField<T> extends FormField<T> {
  /// Creates a Nasiko-presented form field.
  ///
  /// [builder] returns the raw control for the current [FormFieldState];
  /// call `state.didChange(value)` from the control to update the field.
  NasikoFormField({
    super.key,
    required Widget Function(FormFieldState<T> state) builder,
    super.validator,
    super.initialValue,
    super.autovalidateMode,
    String? label,
    bool isRequired = false,
    String? description,
  }) : super(
          builder: (state) => NasikoField(
            label: label,
            isRequired: isRequired,
            description: description,
            errorText: state.errorText,
            child: builder(state),
          ),
        );
}
