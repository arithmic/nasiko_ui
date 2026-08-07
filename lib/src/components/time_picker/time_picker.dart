// lib/src/components/time_picker/time_picker.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

// Interaction model: OTP-like two-digit segments for hour/minute(/second)
// with digit entry that
// - appends the typed digit, restarting the entry on a third digit,
// - clamps the numeric value into the segment's [min, max] immediately, and
// - auto-advances focus to the next segment once two digits are entered.
// Design notes: segments are custom Focus widgets rather than TextFields
// (no cursor/IME machinery needed for two-digit numerics); Up/Down arrows
// increment/decrement with wrap-around and Left/Right move between
// segments; the AM/PM control is an inline toggle segment rather than a
// dropdown; and the completed value is clamped to optional
// [minTime]/[maxTime] bounds on top of the per-segment clamping. Seconds
// are opt-in (showSeconds).

/// Mode of a [NasikoTimePicker] / [NasikoTimeField].
enum NasikoTimePickerMode {
  /// 24-hour clock: hour segment accepts 0–23.
  h24,

  /// 12-hour clock with an AM/PM toggle: hour segment accepts 1–12.
  amPm,
}

/// An immutable time of day (hour 0–23, minute/second 0–59), independent of
/// any date. The AM/PM presentation is derived — the value is always 24-hour.
@immutable
class NasikoTimeOfDay {
  const NasikoTimeOfDay({
    required this.hour,
    required this.minute,
    this.second = 0,
  })  : assert(hour >= 0 && hour < 24, 'hour must be 0–23'),
        assert(minute >= 0 && minute < 60, 'minute must be 0–59'),
        assert(second >= 0 && second < 60, 'second must be 0–59');

  NasikoTimeOfDay.fromDateTime(DateTime time)
      : hour = time.hour,
        minute = time.minute,
        second = time.second;

  factory NasikoTimeOfDay.now() => NasikoTimeOfDay.fromDateTime(DateTime.now());

  /// Hour in 24-hour time, 0–23.
  final int hour;

  /// Minute, 0–59.
  final int minute;

  /// Second, 0–59.
  final int second;

  /// Whether the time falls in the post-meridiem half of the day.
  bool get isPm => hour >= 12;

  /// Seconds since midnight; the total order used for min/max clamping.
  int get inSeconds => hour * 3600 + minute * 60 + second;

  bool isBefore(NasikoTimeOfDay other) => inSeconds < other.inSeconds;

  bool isAfter(NasikoTimeOfDay other) => inSeconds > other.inSeconds;

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// `13:05` (or `13:05:09` with seconds).
  String format24({bool withSeconds = false}) => withSeconds
      ? '${_two(hour)}:${_two(minute)}:${_two(second)}'
      : '${_two(hour)}:${_two(minute)}';

  /// `1:05 PM` (or `1:05:09 PM` with seconds).
  String format12({bool withSeconds = false}) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final base = withSeconds
        ? '$displayHour:${_two(minute)}:${_two(second)}'
        : '$displayHour:${_two(minute)}';
    return '$base ${isPm ? 'PM' : 'AM'}';
  }

  NasikoTimeOfDay copyWith({int? hour, int? minute, int? second}) {
    return NasikoTimeOfDay(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NasikoTimeOfDay &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second;
  }

  @override
  int get hashCode => Object.hash(hour, minute, second);

  @override
  String toString() => 'NasikoTimeOfDay(${format24(withSeconds: true)})';
}

/// Inline time editor: `HH : MM` segments (plus optional seconds and an
/// AM/PM toggle in [NasikoTimePickerMode.amPm]) inside a single text-box
/// surface matching [NasikoDateField]'s visuals.
///
/// Keyboard, per segment:
/// - Digits type a two-digit value with immediate clamping to the segment
///   range and auto-advance to the next segment when filled (see file
///   header).
/// - ArrowUp/ArrowDown increment/decrement with wrap-around; from an empty
///   segment they land on the segment's minimum/maximum respectively.
/// - ArrowLeft/ArrowRight move between segments; Backspace/Delete clears.
/// - AM/PM segment: A/P set the period, ArrowUp/Down/Space/Enter toggle it.
///
/// [onChanged] fires whenever the segments form a complete time; the value
/// is first clamped to [minTime]/[maxTime] (all segments snap to the bound).
/// [value] is the source of truth — external changes overwrite the segments.
class NasikoTimePicker extends StatefulWidget {
  const NasikoTimePicker({
    super.key,
    this.value,
    required this.onChanged,
    this.mode = NasikoTimePickerMode.h24,
    this.minTime,
    this.maxTime,
    this.showSeconds = false,
    this.enabled = true,
    this.autofocus = false,
  });

  /// The current time, or null when nothing is selected yet.
  final NasikoTimeOfDay? value;

  /// Called with each complete (and clamped) time the user forms.
  final ValueChanged<NasikoTimeOfDay> onChanged;

  /// 24-hour or 12-hour+AM/PM presentation.
  final NasikoTimePickerMode mode;

  /// Earliest allowed time; completed values below it snap to it.
  final NasikoTimeOfDay? minTime;

  /// Latest allowed time; completed values above it snap to it.
  final NasikoTimeOfDay? maxTime;

  /// Whether a seconds segment is shown (off by default).
  final bool showSeconds;

  /// When false the picker renders disabled and ignores input.
  final bool enabled;

  /// Focus the hour segment once mounted (used by [NasikoTimeField]'s
  /// popover so typing works immediately).
  final bool autofocus;

  @override
  State<NasikoTimePicker> createState() => _NasikoTimePickerState();
}

class _NasikoTimePickerState extends State<NasikoTimePicker> {
  /// Hour is stored in 24-hour time regardless of [NasikoTimePickerMode].
  int? _hour;
  int? _minute;
  int? _second;

  /// AM/PM presentation state; meaningful in [NasikoTimePickerMode.amPm].
  /// Defaults to AM and survives the hour being cleared.
  bool _pm = false;

  /// Last value handed to [NasikoTimePicker.onChanged], to avoid repeats.
  NasikoTimeOfDay? _lastNotified;

  bool _focusWithin = false;

  final FocusNode _hourNode = FocusNode(debugLabel: 'NasikoTimePicker hour');
  final FocusNode _minuteNode =
      FocusNode(debugLabel: 'NasikoTimePicker minute');
  final FocusNode _secondNode =
      FocusNode(debugLabel: 'NasikoTimePicker second');
  final FocusNode _periodNode =
      FocusNode(debugLabel: 'NasikoTimePicker period');

  bool get _isAmPm => widget.mode == NasikoTimePickerMode.amPm;

  /// Segment nodes in traversal order for the current configuration.
  List<FocusNode> get _activeNodes => <FocusNode>[
        _hourNode,
        _minuteNode,
        if (widget.showSeconds) _secondNode,
        if (_isAmPm) _periodNode,
      ];

  @override
  void initState() {
    super.initState();
    _syncFromValue(widget.value);
    _lastNotified = widget.value;
    if (widget.autofocus) {
      // Explicit post-frame focus: `autofocus` would yield to any node that
      // already has primary focus (e.g. the popover's own focus wrapper).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.enabled) _hourNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant NasikoTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _currentTime) {
      setState(() {
        _syncFromValue(widget.value);
        _lastNotified = widget.value;
      });
    }
  }

  @override
  void dispose() {
    _hourNode.dispose();
    _minuteNode.dispose();
    _secondNode.dispose();
    _periodNode.dispose();
    super.dispose();
  }

  void _syncFromValue(NasikoTimeOfDay? value) {
    _hour = value?.hour;
    _minute = value?.minute;
    _second = value?.second;
    _pm = value?.isPm ?? false;
  }

  /// The complete time the segments currently form, or null while partial.
  NasikoTimeOfDay? get _currentTime {
    final hour = _hour;
    final minute = _minute;
    if (hour == null || minute == null) return null;
    if (widget.showSeconds && _second == null) return null;
    return NasikoTimeOfDay(hour: hour, minute: minute, second: _second ?? 0);
  }

  /// Hour as displayed: 0–23, or 1–12 in AM/PM mode.
  int? get _displayHour {
    final hour = _hour;
    if (hour == null) return null;
    if (!_isAmPm) return hour;
    final h12 = hour % 12;
    return h12 == 0 ? 12 : h12;
  }

  NasikoTimeOfDay _clampToBounds(NasikoTimeOfDay time) {
    final min = widget.minTime;
    final max = widget.maxTime;
    if (min != null && time.isBefore(min)) return min;
    if (max != null && time.isAfter(max)) return max;
    return time;
  }

  /// Fires [NasikoTimePicker.onChanged] when the segments form a complete
  /// time, snapping the whole value to [minTime]/[maxTime] first. Must run
  /// inside setState (it may rewrite segment fields when clamping).
  void _commit() {
    var time = _currentTime;
    if (time == null) return;
    final clamped = _clampToBounds(time);
    if (clamped != time) {
      time = clamped;
      _hour = time.hour;
      _minute = time.minute;
      if (widget.showSeconds) _second = time.second;
      _pm = time.isPm;
    }
    if (time != _lastNotified) {
      _lastNotified = time;
      widget.onChanged(time);
    }
  }

  // ── Segment mutations ───────────────────────────────────────────────────

  /// Converts a displayed 12-hour value (1–12) to 24-hour using [_pm].
  int _hour24FromDisplay(int display) => (display % 12) + (_pm ? 12 : 0);

  void _setHourInput(int value) {
    setState(() {
      _hour = _isAmPm ? _hour24FromDisplay(value) : value;
      _commit();
    });
  }

  void _stepHour(int direction) {
    setState(() {
      if (_isAmPm) {
        final current = _displayHour;
        final next = current == null
            ? (direction > 0 ? 1 : 12)
            : (current - 1 + direction) % 12 + 1;
        _hour = _hour24FromDisplay(next);
      } else {
        final current = _hour;
        _hour = current == null
            ? (direction > 0 ? 0 : 23)
            : (current + direction) % 24;
      }
      _commit();
    });
  }

  void _setMinuteInput(int value) {
    setState(() {
      _minute = value;
      _commit();
    });
  }

  void _stepMinute(int direction) {
    setState(() {
      final current = _minute;
      _minute = current == null
          ? (direction > 0 ? 0 : 59)
          : (current + direction) % 60;
      _commit();
    });
  }

  void _setSecondInput(int value) {
    setState(() {
      _second = value;
      _commit();
    });
  }

  void _stepSecond(int direction) {
    setState(() {
      final current = _second;
      _second = current == null
          ? (direction > 0 ? 0 : 59)
          : (current + direction) % 60;
      _commit();
    });
  }

  void _setPm(bool pm) {
    setState(() {
      _pm = pm;
      final hour = _hour;
      if (hour != null) _hour = (hour % 12) + (pm ? 12 : 0);
      _commit();
    });
  }

  void _clearHour() => setState(() => _hour = null);
  void _clearMinute() => setState(() => _minute = null);
  void _clearSecond() => setState(() => _second = null);

  // ── Focus movement ──────────────────────────────────────────────────────

  void _advanceFrom(FocusNode node) => _moveFrom(node, 1);

  void _moveFrom(FocusNode node, int direction) {
    final nodes = _activeNodes;
    final index = nodes.indexOf(node);
    if (index < 0) return;
    final target = index + direction;
    if (target >= 0 && target < nodes.length) {
      nodes[target].requestFocus();
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final motion = context.motion;

    final enabled = widget.enabled;

    // Mirrors NasikoTextBox/NasikoDateField: base fill, hairline border, r12;
    // focus-within swaps the border to the ring color; disabled dims.
    final Color borderColor = !enabled
        ? colors.borderDisabled
        : _focusWithin
            ? colors.borderFocus
            : colors.borderInput;
    final Color fillColor =
        enabled ? colors.backgroundBase : colors.backgroundDisabled;
    final Color separatorColor =
        enabled ? colors.foregroundSecondary : colors.foregroundDisabled;

    final separator = Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s2),
      child: Text(
        ':',
        style: typography.bodyPrimary.copyWith(color: separatorColor),
      ),
    );

    return Focus(
      // Non-focusable wrapper observing focus-within for the border ring.
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (value) => setState(() => _focusWithin = value),
      child: FocusTraversalGroup(
        child: AnimatedContainer(
          // Decorative focus border fade — raw token by convention.
          duration: motion.fast,
          curve: motion.enter,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s8,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(radii.r12),
            border: Border.all(color: borderColor, width: borderWidths.w1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TimeSegmentField(
                semanticLabel: 'Hour',
                value: _displayHour,
                min: _isAmPm ? 1 : 0,
                max: _isAmPm ? 12 : 23,
                enabled: enabled,
                focusNode: _hourNode,
                onInput: _setHourInput,
                onStep: _stepHour,
                onClear: _clearHour,
                onAdvance: () => _advanceFrom(_hourNode),
                onMove: (direction) => _moveFrom(_hourNode, direction),
              ),
              separator,
              _TimeSegmentField(
                semanticLabel: 'Minute',
                value: _minute,
                min: 0,
                max: 59,
                enabled: enabled,
                focusNode: _minuteNode,
                onInput: _setMinuteInput,
                onStep: _stepMinute,
                onClear: _clearMinute,
                onAdvance: () => _advanceFrom(_minuteNode),
                onMove: (direction) => _moveFrom(_minuteNode, direction),
              ),
              if (widget.showSeconds) ...[
                separator,
                _TimeSegmentField(
                  semanticLabel: 'Second',
                  value: _second,
                  min: 0,
                  max: 59,
                  enabled: enabled,
                  focusNode: _secondNode,
                  onInput: _setSecondInput,
                  onStep: _stepSecond,
                  onClear: _clearSecond,
                  onAdvance: () => _advanceFrom(_secondNode),
                  onMove: (direction) => _moveFrom(_secondNode, direction),
                ),
              ],
              if (_isAmPm) ...[
                SizedBox(width: spacing.s8),
                _PeriodSegmentField(
                  isPm: _pm,
                  enabled: enabled,
                  focusNode: _periodNode,
                  onChanged: _setPm,
                  onMove: (direction) => _moveFrom(_periodNode, direction),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One two-digit numeric segment (hour/minute/second).
class _TimeSegmentField extends StatefulWidget {
  const _TimeSegmentField({
    required this.semanticLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.focusNode,
    required this.onInput,
    required this.onStep,
    required this.onClear,
    required this.onAdvance,
    required this.onMove,
  });

  final String semanticLabel;

  /// Displayed value (already in display units), or null when unset.
  final int? value;

  final int min;
  final int max;
  final bool enabled;
  final FocusNode focusNode;

  /// A typed (clamped) value.
  final ValueChanged<int> onInput;

  /// ArrowUp (+1) / ArrowDown (-1).
  final ValueChanged<int> onStep;

  /// Backspace/Delete.
  final VoidCallback onClear;

  /// Two digits entered — focus the next segment.
  final VoidCallback onAdvance;

  /// ArrowLeft (-1) / ArrowRight (+1) between segments.
  final ValueChanged<int> onMove;

  @override
  State<_TimeSegmentField> createState() => _TimeSegmentFieldState();
}

class _TimeSegmentFieldState extends State<_TimeSegmentField> {
  /// In-progress digit entry, 0–2 characters.
  String _entry = '';

  bool _focused = false;

  @override
  void didUpdateWidget(covariant _TimeSegmentField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && _entry.isNotEmpty) {
      // External change (arrow step, clamping, controlled value): the entry
      // buffer no longer reflects the value — restart it.
      if (int.tryParse(_entry) != widget.value) _entry = '';
    }
  }

  /// Digit-entry semantics: append the digit, restart on a third digit,
  /// clamp into [min, max]; two digits advance focus to the next segment.
  void _handleDigit(String digit) {
    var entry = _entry.length >= 2 ? digit : '$_entry$digit';
    var value = int.parse(entry);
    if (value > widget.max) {
      value = widget.max;
      entry = value.toString();
    }
    if (value < widget.min) {
      value = widget.min;
      entry = value.toString();
    }
    _entry = entry;
    widget.onInput(value);
    if (entry.length >= 2) {
      _entry = '';
      widget.onAdvance();
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _entry = '';
      widget.onStep(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _entry = '';
      widget.onStep(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      widget.onMove(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      widget.onMove(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _entry = '';
      widget.onClear();
      return KeyEventResult.handled;
    }
    final character = event.character;
    if (character != null &&
        character.length == 1 &&
        character.codeUnitAt(0) >= 0x30 &&
        character.codeUnitAt(0) <= 0x39) {
      _handleDigit(character);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleFocusChange(bool value) {
    if (!value) _entry = '';
    setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final motion = context.motion;

    final enabled = widget.enabled;
    final text = widget.value == null
        ? '--'
        : widget.value!.toString().padLeft(2, '0');
    final Color textColor = !enabled
        ? colors.foregroundDisabled
        : widget.value != null
            ? colors.foregroundPrimary
            : colors.foregroundSecondary;

    return Semantics(
      label: widget.semanticLabel,
      value: text,
      textField: true,
      enabled: enabled,
      child: Focus(
        focusNode: widget.focusNode,
        canRequestFocus: enabled,
        onKeyEvent: _handleKey,
        onFocusChange: _handleFocusChange,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.text : MouseCursor.defer,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? widget.focusNode.requestFocus : null,
            child: AnimatedContainer(
              // Decorative focus highlight fade — raw token by convention.
              duration: motion.hover,
              curve: motion.enter,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s4,
                vertical: spacing.s2,
              ),
              decoration: BoxDecoration(
                color: _focused && enabled
                    ? colors.backgroundBrandSubtle
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(radii.r6),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: spacing.s24),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: typography.bodyPrimary.copyWith(color: textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AM/PM toggle segment: A/P set the period; ArrowUp/Down, Space, Enter, or
/// a tap toggle it.
class _PeriodSegmentField extends StatefulWidget {
  const _PeriodSegmentField({
    required this.isPm,
    required this.enabled,
    required this.focusNode,
    required this.onChanged,
    required this.onMove,
  });

  final bool isPm;
  final bool enabled;
  final FocusNode focusNode;
  final ValueChanged<bool> onChanged;
  final ValueChanged<int> onMove;

  @override
  State<_PeriodSegmentField> createState() => _PeriodSegmentFieldState();
}

class _PeriodSegmentFieldState extends State<_PeriodSegmentField> {
  bool _focused = false;

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      widget.onChanged(!widget.isPm);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      widget.onMove(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      widget.onMove(1);
      return KeyEventResult.handled;
    }
    final character = event.character?.toLowerCase();
    if (character == 'a') {
      widget.onChanged(false);
      return KeyEventResult.handled;
    }
    if (character == 'p') {
      widget.onChanged(true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final motion = context.motion;

    final enabled = widget.enabled;
    final text = widget.isPm ? 'PM' : 'AM';
    final Color textColor =
        enabled ? colors.foregroundPrimary : colors.foregroundDisabled;

    return Semantics(
      label: 'AM or PM',
      value: text,
      button: true,
      enabled: enabled,
      child: Focus(
        focusNode: widget.focusNode,
        canRequestFocus: enabled,
        onKeyEvent: _handleKey,
        onFocusChange: (value) => setState(() => _focused = value),
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled
                ? () {
                    widget.focusNode.requestFocus();
                    widget.onChanged(!widget.isPm);
                  }
                : null,
            child: AnimatedContainer(
              // Decorative focus highlight fade — raw token by convention.
              duration: motion.hover,
              curve: motion.enter,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s4,
                vertical: spacing.s2,
              ),
              decoration: BoxDecoration(
                color: _focused && enabled
                    ? colors.backgroundBrandSubtle
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(radii.r6),
              ),
              child: Text(
                text,
                style: typography.bodyPrimary.copyWith(color: textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Intent that opens the time field's picker popover.
class _OpenTimePickerIntent extends Intent {
  const _OpenTimePickerIntent();
}

/// A read-only time input that opens a [NasikoTimePicker] in a popover —
/// the time twin of [NasikoDateField], sharing its text-box visuals.
///
/// Shows the formatted [value] (or [placeholder] when empty) with a trailing
/// clock icon. Tapping the field — or pressing Enter, Space, or Arrow-Down
/// while focused — opens the picker with its hour segment focused. The
/// popover stays open while the user edits (times are set segment by
/// segment); Escape closes it and restores focus, tapping outside closes it
/// (both handled by [NasikoPopover]). [onChanged] fires live as complete
/// times are formed.
class NasikoTimeField extends StatefulWidget {
  const NasikoTimeField({
    super.key,
    this.value,
    required this.onChanged,
    this.placeholder = 'Select time',
    this.mode = NasikoTimePickerMode.h24,
    this.minTime,
    this.maxTime,
    this.showSeconds = false,
    this.enabled = true,
    this.format,
  });

  /// The currently selected time shown in the field.
  final NasikoTimeOfDay? value;

  /// Called with each complete time picked in the popover.
  final ValueChanged<NasikoTimeOfDay> onChanged;

  /// Hint text shown when [value] is null.
  final String placeholder;

  /// Presentation mode, forwarded to the picker and the default format.
  final NasikoTimePickerMode mode;

  /// Earliest selectable time, forwarded to the picker.
  final NasikoTimeOfDay? minTime;

  /// Latest selectable time, forwarded to the picker.
  final NasikoTimeOfDay? maxTime;

  /// Whether seconds are shown/edited.
  final bool showSeconds;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Formats [value] for display. Defaults to `13:05` in
  /// [NasikoTimePickerMode.h24] and `1:05 PM` in [NasikoTimePickerMode.amPm].
  final String Function(NasikoTimeOfDay)? format;

  @override
  State<NasikoTimeField> createState() => _NasikoTimeFieldState();
}

class _NasikoTimeFieldState extends State<NasikoTimeField> {
  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): _OpenTimePickerIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): _OpenTimePickerIntent(),
    SingleActivator(LogicalKeyboardKey.space): _OpenTimePickerIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown): _OpenTimePickerIntent(),
  };

  final FocusNode _focusNode = FocusNode(debugLabel: 'NasikoTimeField');
  bool _isFocused = false;
  final NasikoPopoverController _popover = NasikoPopoverController();

  @override
  void dispose() {
    _popover.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _open() {
    if (!widget.enabled) return;
    _focusNode.requestFocus();
    _popover.show();
  }

  String _formatValue(NasikoTimeOfDay value) {
    final custom = widget.format;
    if (custom != null) return custom(value);
    return switch (widget.mode) {
      NasikoTimePickerMode.h24 =>
        value.format24(withSeconds: widget.showSeconds),
      NasikoTimePickerMode.amPm =>
        value.format12(withSeconds: widget.showSeconds),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final motion = context.motion;
    final iconSizes = context.iconSize;

    final bool enabled = widget.enabled;
    final String? formatted =
        widget.value == null ? null : _formatValue(widget.value!);
    final String display = formatted ?? widget.placeholder;

    // Mirrors NasikoTextBox/NasikoDateField: base fill, hairline border, r12,
    // focused border swaps to the ring color; disabled dims fill/border/text.
    final Color borderColor = !enabled
        ? colors.borderDisabled
        : _isFocused
            ? colors.borderFocus
            : colors.borderInput;
    final Color fillColor =
        enabled ? colors.backgroundBase : colors.backgroundDisabled;
    final Color textColor = !enabled
        ? colors.foregroundDisabled
        : formatted != null
            ? colors.foregroundPrimary
            : colors.foregroundSecondary;
    final Color iconColor =
        enabled ? colors.foregroundIconTertiary : colors.foregroundDisabled;

    return NasikoPopover(
      controller: _popover,
      alignment: NasikoPopoverAlignment.start,
      popoverBuilder: (BuildContext context) => Padding(
        padding: EdgeInsets.all(context.spacing.s12),
        child: NasikoTimePicker(
          value: widget.value,
          mode: widget.mode,
          minTime: widget.minTime,
          maxTime: widget.maxTime,
          showSeconds: widget.showSeconds,
          autofocus: true,
          onChanged: widget.onChanged,
        ),
      ),
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: _focusNode,
        shortcuts: _shortcuts,
        actions: <Type, Action<Intent>>{
          _OpenTimePickerIntent: CallbackAction<_OpenTimePickerIntent>(
            onInvoke: (_OpenTimePickerIntent intent) {
              _open();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (bool value) =>
            setState(() => _isFocused = value),
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: Semantics(
          button: true,
          enabled: enabled,
          label: display,
          // excludeSemantics drops the GestureDetector's implicit tap action,
          // so re-expose activation for assistive tech here.
          onTap: enabled ? _open : null,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? _open : null,
            child: AnimatedContainer(
              // Decorative focus/hover border fade — raw token by convention.
              duration: motion.fast,
              curve: motion.enter,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s16,
                vertical: spacing.s12,
              ),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(radii.r12),
                border: Border.all(color: borderColor, width: borderWidths.w1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.bodyPrimary.copyWith(color: textColor),
                    ),
                  ),
                  SizedBox(width: spacing.s8),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedClock03,
                    size: iconSizes.s,
                    color: iconColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
