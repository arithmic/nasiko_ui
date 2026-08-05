import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Month abbreviations indexed by `DateTime.month - 1` (no intl dependency).
const List<String> _monthAbbreviations = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Default `d MMM yyyy` style formatter, e.g. `3 Aug 2026`.
String _defaultFormat(DateTime date) =>
    '${date.day} ${_monthAbbreviations[date.month - 1]} ${date.year}';

/// Intent that opens the date field's calendar popover.
class _OpenCalendarIntent extends Intent {
  const _OpenCalendarIntent();
}

/// A read-only date input that opens a [NasikoCalendar] in a popover.
///
/// Shows the formatted [value] (or [placeholder] when empty) with a trailing
/// calendar icon, using the same fill/border/radius/focus visuals as
/// [NasikoTextBox]. Tapping the field — or pressing Enter, Space, or
/// Arrow-Down while it has focus — opens the calendar; picking a date calls
/// [onChanged], closes the popover, and returns focus to the field. Escape
/// closes the popover and restores focus (handled by [NasikoPopover]).
class NasikoDateField extends StatefulWidget {
  const NasikoDateField({
    super.key,
    this.value,
    required this.onChanged,
    this.placeholder = 'Select date',
    this.minDate,
    this.maxDate,
    this.enabled = true,
    this.format,
  });

  /// Formats [value] for display. Defaults to a `d MMM yyyy` style
  /// (`3 Aug 2026`) built from const month abbreviations.
  final String Function(DateTime)? format;

  /// Whether the field accepts interaction. When false it renders in the
  /// disabled style and cannot be focused or opened.
  final bool enabled;

  /// Latest selectable date, forwarded to the calendar.
  final DateTime? maxDate;

  /// Earliest selectable date, forwarded to the calendar.
  final DateTime? minDate;

  /// Called with the picked date when the user selects a day.
  final ValueChanged<DateTime> onChanged;

  /// Hint text shown when [value] is null.
  final String placeholder;

  /// The currently selected date shown in the field.
  final DateTime? value;

  @override
  State<NasikoDateField> createState() => _NasikoDateFieldState();
}

class _NasikoDateFieldState extends State<NasikoDateField> {
  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): _OpenCalendarIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): _OpenCalendarIntent(),
        SingleActivator(LogicalKeyboardKey.space): _OpenCalendarIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): _OpenCalendarIntent(),
      };

  final FocusNode _focusNode = FocusNode(debugLabel: 'NasikoDateField');
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

  void _handlePicked(DateTime date) {
    widget.onChanged(date);
    _popover.hide();
    _focusNode.requestFocus();
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
    final String? formatted = widget.value == null
        ? null
        : (widget.format ?? _defaultFormat)(widget.value!);
    final String display = formatted ?? widget.placeholder;

    // Mirrors NasikoTextBox: base fill, hairline border, r12, focused border
    // swaps to the brand ring color; disabled dims fill/border/text.
    final Color borderColor = !enabled
        ? colors.borderDisabled
        : _isFocused
        ? colors.borderSecondary
        : colors.borderPrimary;
    final Color fillColor = enabled
        ? colors.backgroundBase
        : colors.backgroundDisabled;
    final Color textColor = !enabled
        ? colors.foregroundDisabled
        : formatted != null
        ? colors.foregroundPrimary
        : colors.foregroundSecondary;
    final Color iconColor = enabled
        ? colors.foregroundIconTertiary
        : colors.foregroundDisabled;

    return NasikoPopover(
      controller: _popover,
      alignment: NasikoPopoverAlignment.start,
      popoverBuilder: (BuildContext context) => Padding(
        padding: EdgeInsets.all(context.spacing.s12),
        child: NasikoCalendar(
          selected: widget.value,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          onChanged: _handlePicked,
        ),
      ),
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: _focusNode,
        shortcuts: _shortcuts,
        actions: <Type, Action<Intent>>{
          _OpenCalendarIntent: CallbackAction<_OpenCalendarIntent>(
            onInvoke: (_OpenCalendarIntent intent) {
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
                    icon: HugeIcons.strokeRoundedCalendar03,
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
