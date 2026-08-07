// lib/src/components/slider/slider.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../internal/interaction_states.dart';

// Interaction model: track tap jumps the thumb, dragging anywhere on the
// control scrubs the value, arrow keys step the value (Shift for a 10x
// larger step, key repeats included), divisions snap, and the thumb grows
// a focus ring when keyboard-focused. Visuals, tokens, and motion follow
// the Nasiko design system.

/// Signature for formatting a slider value into a human-readable string,
/// used by the floating value label and assistive technologies.
typedef NasikoSliderLabelFormatter = String Function(double value);

/// A horizontal slider for selecting a value from a continuous range or a
/// fixed number of divisions.
///
/// Controlled component: [value] is owned by the caller and updated through
/// [onChanged]. Passing `null` for [onChanged] disables the slider (same
/// convention as [NasikoSwitch] and [NasikoCheckbox]).
///
/// Interaction:
/// * Tap anywhere on the track to jump the thumb there.
/// * Drag anywhere on the control to scrub; the thumb follows the pointer.
/// * Arrow Left/Down decrease, Arrow Right/Up increase. The step is
///   `range / divisions` when [divisions] is set, otherwise 1% of the range.
///   Holding Shift multiplies the step by 10. Key repeats are honored.
/// * When [divisions] is set the value snaps to the nearest division and
///   tick marks are drawn on the track.
///
/// Visuals: borderPrimary resting track, backgroundBrand active fill
/// (backgroundBrandHover while hovered/dragged), backgroundBase thumb with a
/// borderSecondary outline, and a button-style borderSecondary focus ring.
/// Color changes animate at `motion.hover`; tap/keyboard thumb travel
/// animates at `motion.fast` (reduced-motion aware); pointer drags track the
/// finger with no lag.
///
/// ```dart
/// NasikoSlider(
///   value: volume,
///   min: 0,
///   max: 100,
///   divisions: 10,
///   labelFormatter: (v) => v.round().toString(),
///   onChanged: (v) => setState(() => volume = v),
/// )
/// ```
class NasikoSlider extends StatefulWidget {
  /// Creates a Nasiko slider.
  const NasikoSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.onChangeStart,
    this.onChangeEnd,
    this.labelFormatter,
    this.semanticFormatter,
    this.focusNode,
    this.autofocus = false,
  })  : assert(min <= max, 'min must be <= max'),
        assert(divisions == null || divisions > 0,
            'divisions must be null or > 0');

  /// The current value. Clamped into `[min, max]` for display.
  final double value;

  /// Called with the new value while the user interacts. `null` disables
  /// the slider.
  final ValueChanged<double>? onChanged;

  /// Lower bound of the range. Defaults to 0.0.
  final double min;

  /// Upper bound of the range. Defaults to 1.0.
  final double max;

  /// Number of discrete divisions. When non-null the value snaps to the
  /// nearest division and tick marks are shown; when null the slider is
  /// continuous.
  final int? divisions;

  /// Called with the current value when a drag gesture begins.
  final ValueChanged<double>? onChangeStart;

  /// Called with the final value when a drag gesture ends.
  final ValueChanged<double>? onChangeEnd;

  /// When provided, a tooltip-style value label floats above the thumb while
  /// the slider is hovered or dragged. When null, no label is shown.
  final NasikoSliderLabelFormatter? labelFormatter;

  /// Formats the value announced to assistive technologies. Falls back to
  /// [labelFormatter], then to a compact numeric default.
  final NasikoSliderLabelFormatter? semanticFormatter;

  /// External focus node; an internal one is managed when null.
  final FocusNode? focusNode;

  /// Whether the slider should focus itself on mount.
  final bool autofocus;

  @override
  State<NasikoSlider> createState() => _NasikoSliderState();
}

/// Intent for a keyboard-driven slider step. [direction] is -1 or 1;
/// [big] applies the 10x Shift multiplier.
class _SliderStepIntent extends Intent {
  const _SliderStepIntent(this.direction, this.big);

  final int direction;
  final bool big;
}

class _NasikoSliderState extends State<NasikoSlider> {
  // Arrow keys step in both axes; SingleActivator includes key repeats by
  // default, so holding an arrow key keeps stepping.
  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowLeft): _SliderStepIntent(-1, false),
    SingleActivator(LogicalKeyboardKey.arrowDown): _SliderStepIntent(-1, false),
    SingleActivator(LogicalKeyboardKey.arrowRight): _SliderStepIntent(1, false),
    SingleActivator(LogicalKeyboardKey.arrowUp): _SliderStepIntent(1, false),
    SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true):
        _SliderStepIntent(-1, true),
    SingleActivator(LogicalKeyboardKey.arrowDown, shift: true):
        _SliderStepIntent(-1, true),
    SingleActivator(LogicalKeyboardKey.arrowRight, shift: true):
        _SliderStepIntent(1, true),
    SingleActivator(LogicalKeyboardKey.arrowUp, shift: true):
        _SliderStepIntent(1, true),
  };

  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ??
      (_internalFocusNode ??= FocusNode(debugLabel: 'NasikoSlider'));

  /// True while a pointer drag is scrubbing the value; suppresses the
  /// thumb-travel animation so the thumb tracks the finger exactly.
  bool _dragging = false;

  bool get _enabled => widget.onChanged != null;

  double get _range => widget.max - widget.min;

  @override
  void didUpdateWidget(covariant NasikoSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// Clamps [raw] into range and snaps it to the nearest division.
  double _snap(double raw) {
    var v = raw.clamp(widget.min, widget.max).toDouble();
    final divisions = widget.divisions;
    if (divisions != null && _range > 0) {
      final step = _range / divisions;
      v = ((v - widget.min) / step).round() * step + widget.min;
      v = v.clamp(widget.min, widget.max).toDouble();
    }
    return v;
  }

  /// Notifies [NasikoSlider.onChanged] only when the snapped value actually
  /// changed, so no-op interactions don't rebuild the caller.
  void _commit(double raw) {
    final next = _snap(raw);
    if (next != widget.value) {
      widget.onChanged?.call(next);
    }
  }

  /// The keyboard/semantics step: `range / divisions` when divided, else 1%
  /// of the range; [big] applies the 10x Shift multiplier.
  double _stepSize({required bool big}) {
    final divisions = widget.divisions;
    var step = divisions != null ? _range / divisions : _range * 0.01;
    if (big) step *= 10;
    return step;
  }

  double _steppedValue(int direction, {required bool big}) =>
      _snap(widget.value + direction * _stepSize(big: big));

  void _applyStep(int direction, {required bool big}) {
    if (!_enabled) return;
    _commit(widget.value + direction * _stepSize(big: big));
  }

  /// Maps a local pointer x-position to a value. The thumb travels fully
  /// inside the control (it never overflows the edges), so the mapping is
  /// offset by half the thumb box for an exact finger match.
  double _valueFromDx(double dx, double width, double thumbBox) {
    final travel = width - thumbBox;
    if (travel <= 0 || _range <= 0) return widget.min;
    final fraction = ((dx - thumbBox / 2) / travel).clamp(0.0, 1.0).toDouble();
    return widget.min + fraction * _range;
  }

  String _format(double v) {
    final formatter = widget.semanticFormatter ?? widget.labelFormatter;
    if (formatter != null) return formatter(v);
    final rounded = double.parse(v.toStringAsFixed(2));
    if (rounded == rounded.roundToDouble()) return rounded.round().toString();
    return rounded.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;
    final motion = context.motion;

    final enabled = _enabled;

    // Geometry tokens: 8px track (spacing.s8), 20px thumb (iconSize.s)
    // inside a 28px box (spacing.s28) that permanently reserves the
    // focus-ring space, so focusing never resizes or repositions the thumb.
    final trackHeight = spacing.s8;
    final thumbSize = iconSizes.s;
    final thumbBox = spacing.s28;
    final controlHeight = thumbBox;

    final displayValue = widget.value.clamp(widget.min, widget.max).toDouble();
    final double fraction = _range > 0
        ? ((displayValue - widget.min) / _range).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Semantics(
      slider: true,
      enabled: enabled,
      value: _format(displayValue),
      increasedValue: _format(_steppedValue(1, big: false)),
      decreasedValue: _format(_steppedValue(-1, big: false)),
      onIncrease: enabled ? () => _applyStep(1, big: false) : null,
      onDecrease: enabled ? () => _applyStep(-1, big: false) : null,
      child: Shortcuts(
        shortcuts: _shortcuts,
        child: Actions(
          actions: <Type, Action<Intent>>{
            _SliderStepIntent: CallbackAction<_SliderStepIntent>(
              onInvoke: (intent) {
                _applyStep(intent.direction, big: intent.big);
                return null;
              },
            ),
          },
          child: NasikoInteractionStates(
            enabled: enabled,
            focusNode: _effectiveFocusNode,
            autofocus: widget.autofocus,
            enableKeyboardActivation: false,
            cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
            builder: (context, state, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  assert(
                    constraints.hasBoundedWidth,
                    'NasikoSlider requires a bounded width',
                  );
                  final width = constraints.maxWidth;
                  final travel = width - thumbBox;
                  final thumbLeft = travel > 0 ? fraction * travel : 0.0;
                  final fillWidth = thumbLeft + thumbBox / 2;

                  // Pointer drags must track the finger; tap/keyboard travel
                  // eases at motion.fast (structural -> reduced-motion aware).
                  final moveDuration = _dragging
                      ? Duration.zero
                      : motion.resolve(context, motion.fast);

                  final Color inactiveTrackColor =
                      enabled ? colors.borderPrimary : colors.backgroundDisabled;
                  final Color activeTrackColor = !enabled
                      ? colors.borderDisabled
                      : (state.isHovered || state.isPressed)
                          ? colors.backgroundBrandHover
                          : colors.backgroundBrand;
                  final Color thumbFillColor =
                      enabled ? colors.backgroundBase : colors.backgroundDisabled;
                  final Color thumbBorderColor = !enabled
                      ? colors.borderDisabled
                      : state.isHovered
                          ? colors.borderHover
                          : colors.borderSecondary;

                  final showLabel = enabled &&
                      widget.labelFormatter != null &&
                      (state.isHovered || state.isPressed || _dragging);

                  void handlePointerValue(double dx) {
                    _effectiveFocusNode.requestFocus();
                    _commit(_valueFromDx(dx, width, thumbBox));
                  }

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // Track tap jumps the thumb. Taps deliberately do not
                    // fire onChangeStart/onChangeEnd — those bracket drags.
                    onTapDown: enabled
                        ? (details) => handlePointerValue(details.localPosition.dx)
                        : null,
                    // Horizontal drag (not a pan) so vertical scrolling
                    // still works when embedded in scroll views.
                    onHorizontalDragStart: enabled
                        ? (details) {
                            setState(() => _dragging = true);
                            widget.onChangeStart?.call(widget.value);
                            handlePointerValue(details.localPosition.dx);
                          }
                        : null,
                    onHorizontalDragUpdate: enabled
                        ? (details) =>
                            handlePointerValue(details.localPosition.dx)
                        : null,
                    onHorizontalDragEnd: enabled
                        ? (details) {
                            setState(() => _dragging = false);
                            widget.onChangeEnd?.call(widget.value);
                          }
                        : null,
                    onHorizontalDragCancel: enabled
                        ? () {
                            setState(() => _dragging = false);
                            widget.onChangeEnd?.call(widget.value);
                          }
                        : null,
                    child: SizedBox(
                      width: width,
                      height: controlHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Resting track.
                          Positioned(
                            left: 0,
                            right: 0,
                            top: (controlHeight - trackHeight) / 2,
                            height: trackHeight,
                            child: AnimatedContainer(
                              duration: motion.hover,
                              curve: motion.enter,
                              decoration: BoxDecoration(
                                color: inactiveTrackColor,
                                borderRadius: BorderRadius.circular(radii.r40),
                              ),
                            ),
                          ),
                          // Active fill up to the thumb center. Outer layer
                          // animates width (structural), inner layer animates
                          // color (decorative, motion.hover).
                          Positioned(
                            left: 0,
                            top: (controlHeight - trackHeight) / 2,
                            height: trackHeight,
                            child: AnimatedContainer(
                              duration: moveDuration,
                              curve: motion.move,
                              width: fillWidth,
                              child: AnimatedContainer(
                                duration: motion.hover,
                                curve: motion.enter,
                                decoration: BoxDecoration(
                                  color: activeTrackColor,
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(radii.r40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Division tick marks: borderWidth.w2 x spacing.s4,
                          // backgroundBase so they read on both track colors.
                          if (widget.divisions != null && travel > 0)
                            for (var i = 0; i <= widget.divisions!; i++)
                              Positioned(
                                left: thumbBox / 2 +
                                    (i / widget.divisions!) * travel -
                                    borderWidths.w2 / 2,
                                top: (controlHeight - spacing.s4) / 2,
                                child: Container(
                                  width: borderWidths.w2,
                                  height: spacing.s4,
                                  decoration: BoxDecoration(
                                    color: colors.backgroundBase,
                                    borderRadius:
                                        BorderRadius.circular(radii.r40),
                                  ),
                                ),
                              ),
                          // Thumb with permanently reserved focus-ring space.
                          AnimatedPositioned(
                            duration: moveDuration,
                            curve: motion.move,
                            left: thumbLeft,
                            top: (controlHeight - thumbBox) / 2,
                            width: thumbBox,
                            height: thumbBox,
                            child: AnimatedContainer(
                              duration: motion.hover,
                              curve: motion.enter,
                              padding: EdgeInsets.all(spacing.s2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // Button-style focus ring: borderFocus w2.
                                border: Border.all(
                                  color: state.isFocused && enabled
                                      ? colors.borderFocus
                                      : Colors.transparent,
                                  width: borderWidths.w2,
                                ),
                              ),
                              child: AnimatedContainer(
                                duration: motion.hover,
                                curve: motion.enter,
                                width: thumbSize,
                                height: thumbSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: thumbFillColor,
                                  border: Border.all(
                                    color: thumbBorderColor,
                                    width: borderWidths.w2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Tooltip-style floating value label above the
                          // thumb, shown on hover/drag.
                          if (widget.labelFormatter != null)
                            AnimatedPositioned(
                              duration: moveDuration,
                              curve: motion.move,
                              left: thumbLeft + thumbBox / 2,
                              bottom: controlHeight + spacing.s4,
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  duration: motion.fast,
                                  curve: motion.enter,
                                  opacity: showLabel ? 1.0 : 0.0,
                                  child: FractionalTranslation(
                                    translation: const Offset(-0.5, 0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: spacing.s8,
                                        vertical: spacing.s4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.foregroundConstantBlack,
                                        borderRadius:
                                            BorderRadius.circular(radii.r6),
                                      ),
                                      child: Text(
                                        widget.labelFormatter!(displayValue),
                                        style: context.typography.bodyTertiary
                                            .copyWith(
                                          color:
                                              colors.foregroundConstantWhite,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
