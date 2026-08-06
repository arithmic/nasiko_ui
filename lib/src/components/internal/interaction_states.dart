// lib/src/components/internal/interaction_states.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

// Cohesive interaction-state tracking:
// hovered, pressed, focused, and disabled are observed by one widget and
// handed to the builder as a single immutable snapshot, instead of each
// component wiring its own MouseRegion + Listener + focus plumbing.

/// Immutable snapshot of a widget's interaction states.
@immutable
class NasikoInteractionState {
  const NasikoInteractionState({
    this.isHovered = false,
    this.isPressed = false,
    this.isFocused = false,
    this.isDisabled = false,
  });

  /// A pointer is hovering the widget.
  final bool isHovered;

  /// A pointer is down on the widget.
  final bool isPressed;

  /// The widget holds keyboard focus with a visible focus highlight.
  final bool isFocused;

  /// The widget is non-interactive.
  final bool isDisabled;

  /// Standard highlight condition: hovered or keyboard-focused (and
  /// interactive) — matches the menu-item hover/focus treatment.
  bool get isHighlighted => !isDisabled && (isHovered || isFocused);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NasikoInteractionState &&
        other.isHovered == isHovered &&
        other.isPressed == isPressed &&
        other.isFocused == isFocused &&
        other.isDisabled == isDisabled;
  }

  @override
  int get hashCode => Object.hash(isHovered, isPressed, isFocused, isDisabled);

  @override
  String toString() => 'NasikoInteractionState('
      'hovered: $isHovered, pressed: $isPressed, '
      'focused: $isFocused, disabled: $isDisabled)';
}

/// Builds the visual for the current [state]. [child] is the optional
/// state-independent subtree passed to [NasikoInteractionStates.child].
typedef NasikoInteractionStateBuilder = Widget Function(
  BuildContext context,
  NasikoInteractionState state,
  Widget? child,
);

/// Internal base widget for interactive components: tracks hovered, pressed,
/// focused, and disabled together and exposes them to [builder].
///
/// One [FocusableActionDetector] provides hover + focus highlight tracking,
/// mouse cursor, and Enter/Space keyboard activation; a translucent
/// [Listener] tracks the pressed state (same approach as [ButtonPressScale],
/// so wrapped gesture handling is untouched); a [GestureDetector] fires
/// [onPressed] on tap.
///
/// With [pressScale] enabled the built visual scales to 0.98 while pressed
/// using `context.motion.pressed` / `context.motion.enter` — identical
/// semantics to `ButtonPressScale`, minus the extra Listener (this widget
/// already owns the pressed state). Reduced-motion aware.
///
/// Intended as the standard base for future interactive components (menu
/// items, select options, chips...). Not exported from the package barrel —
/// internal use only.
class NasikoInteractionStates extends StatefulWidget {
  const NasikoInteractionStates({
    super.key,
    required this.builder,
    this.child,
    this.enabled = true,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.enableKeyboardActivation = true,
    this.pressScale = false,
    this.cursor,
    this.behavior = HitTestBehavior.opaque,
    this.onHoverChange,
    this.onFocusChange,
    this.onPressChange,
  });

  /// Builds the visual for the current interaction state.
  final NasikoInteractionStateBuilder builder;

  /// Optional state-independent subtree forwarded to [builder].
  final Widget? child;

  /// Whether the widget is interactive. When false the state reports
  /// `isDisabled: true` and hover/press/focus tracking is suspended.
  final bool enabled;

  /// Invoked on tap and (when [enableKeyboardActivation]) on Enter/Space.
  final VoidCallback? onPressed;

  /// External focus node; an internal one is managed when null.
  final FocusNode? focusNode;

  /// Whether to autofocus on mount.
  final bool autofocus;

  /// Activate [onPressed] via Enter, numpad Enter, and Space while focused.
  final bool enableKeyboardActivation;

  /// Apply the shared press-scale micro-feedback around the built visual.
  final bool pressScale;

  /// Mouse cursor while hovered. Defaults to click when interactive
  /// ([enabled] and [onPressed] non-null), deferring otherwise.
  final MouseCursor? cursor;

  /// Hit-test behavior of the tap detector.
  final HitTestBehavior behavior;

  /// Notified when the hovered state changes.
  final ValueChanged<bool>? onHoverChange;

  /// Notified when the focus highlight changes.
  final ValueChanged<bool>? onFocusChange;

  /// Notified when the pressed state changes.
  final ValueChanged<bool>? onPressChange;

  @override
  State<NasikoInteractionStates> createState() =>
      _NasikoInteractionStatesState();
}

class _NasikoInteractionStatesState extends State<NasikoInteractionStates> {
  static const double _pressedScale = 0.98;

  static const Map<ShortcutActivator, Intent> _activationShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _interactive => widget.enabled && widget.onPressed != null;

  @override
  void didUpdateWidget(covariant NasikoInteractionStates oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A press must not survive disabling mid-gesture.
    if (!widget.enabled && _pressed) {
      _pressed = false;
      widget.onPressChange?.call(false);
    }
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    widget.onHoverChange?.call(value);
  }

  void _setPressed(bool value) {
    if (!widget.enabled && value) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
    widget.onPressChange?.call(value);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
    widget.onFocusChange?.call(value);
  }

  void _activate() {
    if (!_interactive) return;
    widget.onPressed!.call();
  }

  @override
  Widget build(BuildContext context) {
    final state = NasikoInteractionState(
      isHovered: _hovered,
      isPressed: _pressed,
      isFocused: _focused,
      isDisabled: !widget.enabled,
    );

    Widget content = widget.builder(context, state, widget.child);

    if (widget.pressScale) {
      // Same values and reduced-motion behavior as ButtonPressScale.
      final motion = context.motion;
      final reduceMotion = NasikoMotionTheme.reduceMotion(context);
      final scale =
          _pressed && widget.enabled && !reduceMotion ? _pressedScale : 1.0;
      content = AnimatedScale(
        scale: scale,
        duration: motion.resolve(context, motion.pressed),
        curve: motion.enter,
        child: content,
      );
    }

    return FocusableActionDetector(
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: widget.cursor ??
          (_interactive ? SystemMouseCursors.click : MouseCursor.defer),
      onShowHoverHighlight: _setHovered,
      onShowFocusHighlight: _setFocused,
      shortcuts: widget.enableKeyboardActivation && widget.onPressed != null
          ? _activationShortcuts
          : const <ShortcutActivator, Intent>{},
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            _activate();
            return null;
          },
        ),
      },
      child: Listener(
        // Translucent: pressed tracking only observes; it never competes
        // with the tap detector below or any wrapped gesture handling.
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: GestureDetector(
          behavior: widget.behavior,
          onTap: _interactive ? _activate : null,
          child: content,
        ),
      ),
    );
  }
}
