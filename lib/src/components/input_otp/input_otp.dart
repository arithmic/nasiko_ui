// lib/src/components/input_otp/input_otp.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

// Slot model: N boxed slots optionally split into groups with a dash
// separator, pasted / multi-character input distributes across the slots,
// backspace steps the active slot backwards, and a caret marks the active
// empty slot.
//
// Implementation note: an alternative design wires one TextField PER SLOT
// and shuttles focus between them (e.g. with a zero-width-space sentinel).
// We instead drive all slots from a single hidden input — one invisible
// TextField overlays the slots and owns the text, focus, keyboard, and
// paste handling — which gives the same observable behavior with far less
// focus choreography.

/// A one-time-passcode input rendered as individual character slots.
///
/// One invisible text field spans the whole control: tapping anywhere
/// focuses it, typing fills slots left to right, backspace clears the last
/// character (stepping the active slot back), and pasting (keyboard
/// shortcut, or the OS one-time-code autofill via [AutofillHints.oneTimeCode])
/// distributes the characters across the slots.
/// Interactive selection is disabled so the code can
/// never be partially selected; input is filtered to digits by default
/// ([alphanumeric] widens it) and hard-capped at [length].
///
/// The caret cannot be moved into earlier slots: the single-field model
/// keeps editing at the end, so Arrow Left/Right slot hopping is
/// intentionally not supported (backspace already walks back).
///
/// The active slot's border animates at `motion.fast`; a caret blinks in the
/// active empty slot (static under reduced motion). Error state ([hasError])
/// swaps the borders to borderError; there is deliberately no shake
/// animation.
///
/// ```dart
/// NasikoInputOtp(
///   length: 6,
///   groups: const [3, 3],
///   onCompleted: (code) => submit(code),
/// )
/// ```
class NasikoInputOtp extends StatefulWidget {
  /// Creates an OTP input with [length] slots.
  const NasikoInputOtp({
    super.key,
    this.length = 6,
    this.groups,
    this.alphanumeric = false,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.hasError = false,
    this.onChanged,
    this.onCompleted,
    this.semanticLabel = 'One-time code',
  }) : assert(length > 0, 'length must be > 0');

  /// Total number of character slots. Defaults to 6.
  final int length;

  /// Optional grouping, e.g. `[3, 3]` renders two groups of three slots
  /// separated by a dash. Must sum to [length]. Null renders one group.
  final List<int>? groups;

  /// When true accepts letters and digits; digits only by default.
  final bool alphanumeric;

  /// External text controller; an internal one is managed when null.
  final TextEditingController? controller;

  /// External focus node; an internal one is managed when null.
  final FocusNode? focusNode;

  /// Whether the input should focus itself on mount.
  final bool autofocus;

  /// Whether the input is interactive.
  final bool enabled;

  /// Renders all slot borders in the error color.
  final bool hasError;

  /// Called with the current (possibly partial) code on every change.
  final ValueChanged<String>? onChanged;

  /// Called once each time the code reaches [length] characters.
  final ValueChanged<String>? onCompleted;

  /// Label announced for the hidden text field.
  final String semanticLabel;

  @override
  State<NasikoInputOtp> createState() => _NasikoInputOtpState();
}

class _NasikoInputOtpState extends State<NasikoInputOtp> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  String _lastReported = '';

  @override
  void initState() {
    super.initState();
    assert(
      widget.groups == null ||
          widget.groups!.fold<int>(0, (sum, g) => sum + g) == widget.length,
      'groups must sum to length',
    );
    _bindController(widget.controller);
    _bindFocusNode(widget.focusNode);
    _lastReported = _controller.text;
  }

  @override
  void didUpdateWidget(covariant NasikoInputOtp oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(
      widget.groups == null ||
          widget.groups!.fold<int>(0, (sum, g) => sum + g) == widget.length,
      'groups must sum to length',
    );
    if (oldWidget.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _unbindFocusNode();
      _bindFocusNode(widget.focusNode);
    }
  }

  @override
  void dispose() {
    _unbindFocusNode();
    _unbindController();
    super.dispose();
  }

  void _bindController(TextEditingController? controller) {
    _ownsController = controller == null;
    _controller = controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
  }

  void _unbindController() {
    _controller.removeListener(_handleTextChange);
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _bindFocusNode(FocusNode? focusNode) {
    _ownsFocusNode = focusNode == null;
    _focusNode = focusNode ?? FocusNode(debugLabel: 'NasikoInputOtp');
    _focusNode.addListener(_handleFocusChange);
  }

  void _unbindFocusNode() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleFocusChange() {
    if (!mounted) return;
    if (_focusNode.hasFocus) {
      _placeCaretAtEnd();
    }
    setState(() {});
  }

  /// Editing always happens at the end of the code — the slot metaphor has
  /// no mid-string caret (see class docs).
  void _placeCaretAtEnd() {
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
  }

  void _handleTextChange() {
    if (!mounted) return;
    final text = _controller.text;
    setState(() {});
    if (text == _lastReported) return;
    final wasComplete = _lastReported.length == widget.length;
    _lastReported = text;
    widget.onChanged?.call(text);
    if (!wasComplete && text.length == widget.length) {
      widget.onCompleted?.call(text);
    }
  }

  List<int> get _effectiveGroups => widget.groups ?? <int>[widget.length];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    final text = _controller.text;
    // The next slot to be filled; equals [length] when complete (then no
    // slot is highlighted — the completed state has no active slot).
    final activeIndex = text.length;
    final focused = _focusNode.hasFocus;

    // Build the slot row: groups separated by a dash divider (a
    // token-sized rounded bar).
    final children = <Widget>[];
    var slotIndex = 0;
    for (var g = 0; g < _effectiveGroups.length; g++) {
      if (g > 0) {
        children.add(SizedBox(width: spacing.s8));
        children.add(
          Container(
            width: spacing.s8,
            height: borderWidths.w2,
            decoration: BoxDecoration(
              color: colors.borderPrimary,
              borderRadius: BorderRadius.circular(radii.r40),
            ),
          ),
        );
        children.add(SizedBox(width: spacing.s8));
      }
      for (var s = 0; s < _effectiveGroups[g]; s++) {
        if (s > 0) children.add(SizedBox(width: spacing.s8));
        final index = slotIndex;
        children.add(
          _OtpSlot(
            character: index < text.length ? text[index] : '',
            index: index,
            length: widget.length,
            isActive: widget.enabled && focused && index == activeIndex,
            enabled: widget.enabled,
            hasError: widget.hasError,
          ),
        );
        slotIndex++;
      }
    }

    final slotsRow = Row(mainAxisSize: MainAxisSize.min, children: children);

    return Semantics(
      container: true,
      child: Stack(
        children: [
          slotsRow,
          // The single invisible text field: fills the control so any tap
          // focuses it; owns keyboard, IME, autofill, and paste.
          Positioned.fill(
            child: Semantics(
              label: widget.semanticLabel,
              child: Opacity(
                opacity: 0.0,
                // At opacity 0 an Opacity normally drops its child from the
                // semantics tree — keep the field reachable for assistive
                // tech (it owns the actual text input).
                alwaysIncludeSemantics: true,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: widget.alphanumeric
                      ? TextInputType.text
                      : TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    widget.alphanumeric
                        ? FilteringTextInputFormatter.allow(
                            RegExp('[a-zA-Z0-9]'))
                        : FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  onTap: _placeCaretAtEnd,
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                    height: 1,
                  ),
                  decoration:
                      const InputDecoration.collapsed(hintText: ''),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One rendered character slot.
class _OtpSlot extends StatelessWidget {
  const _OtpSlot({
    required this.character,
    required this.index,
    required this.length,
    required this.isActive,
    required this.enabled,
    required this.hasError,
  });

  final String character;
  final int index;
  final int length;
  final bool isActive;
  final bool enabled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final typography = context.typography;
    final motion = context.motion;

    // Border matrix: active slot gets the button-style w2 highlight
    // (borderSecondary, or borderError while erroring); resting slots use
    // the w1 input border. Each slot is a spacing.s36 square.
    final Color borderColor;
    final double borderWidth;
    if (!enabled) {
      borderColor = colors.borderDisabled;
      borderWidth = borderWidths.w1;
    } else if (isActive) {
      borderColor = hasError ? colors.borderError : colors.borderSecondary;
      borderWidth = borderWidths.w2;
    } else {
      borderColor = hasError ? colors.borderError : colors.borderPrimary;
      borderWidth = borderWidths.w1;
    }

    return Semantics(
      label: 'Character ${index + 1} of $length',
      value: character.isEmpty ? 'empty' : character,
      child: AnimatedContainer(
        // Active-slot border animates at motion.fast (color-only fade —
        // decorative, so the raw token is fine per the motion convention).
        duration: motion.fast,
        curve: motion.enter,
        width: spacing.s36,
        height: spacing.s36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? colors.backgroundBase : colors.backgroundDisabled,
          borderRadius: BorderRadius.circular(radii.r8),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: character.isNotEmpty
            ? Text(
                character,
                style: typography.code.copyWith(
                  color: enabled
                      ? colors.foregroundPrimary
                      : colors.foregroundDisabled,
                ),
              )
            : isActive
                ? const _OtpCaret()
                : const SizedBox.shrink(),
      ),
    );
  }
}

/// The blinking caret shown in the active empty slot.
///
/// Blink cadence is derived from motion tokens (motion.page out and back,
/// a 600ms cycle — the nearest-token approximation of a familiar ~1s text
/// caret blink). Under reduced motion the caret renders static.
class _OtpCaret extends StatefulWidget {
  const _OtpCaret();

  @override
  State<_OtpCaret> createState() => _OtpCaretState();
}

class _OtpCaretState extends State<_OtpCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    // Placeholder; the token duration is applied in didChangeDependencies.
    duration: const Duration(milliseconds: 300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = context.motion;
    _controller.duration = motion.page;
    if (NasikoMotionTheme.reduceMotion(context)) {
      _controller.stop();
      _controller.value = 1.0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;

    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: borderWidths.w2,
        height: iconSizes.xs,
        color: colors.foregroundPrimary,
      ),
    );
  }
}
