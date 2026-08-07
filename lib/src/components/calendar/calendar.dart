import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

// ─── Const name tables (no intl dependency) ─────────────────────────────────

/// Two-letter weekday headers, Monday first.
const List<String> _weekdayHeaders = <String>[
  'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su', //
];

/// Full weekday names indexed by `DateTime.weekday - 1` (Monday = 1).
const List<String> _weekdayNames = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Full month names indexed by `DateTime.month - 1`.
const List<String> _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

// ─── Pure date math (date-only, DST-safe) ───────────────────────────────────
// Never use Duration arithmetic across days: DateTime(y, m, d + n) lets the
// DateTime constructor normalize overflow without timezone/DST drift.

/// Normalizes [d] to midnight local time (date-only).
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Adds [n] calendar days to date-only [d] via constructor normalization.
DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

/// The first day of the month containing [d].
DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);

/// Adds [n] months to a first-of-month [month].
DateTime _addMonths(DateTime month, int n) =>
    DateTime(month.year, month.month + n);

/// Number of days in the month containing [month] (day 0 of the next month
/// is the last day of this one).
int _daysInMonth(DateTime month) =>
    DateTime(month.year, month.month + 1, 0).day;

/// Shifts a date-only [d] by [n] months, clamping the day-of-month to the
/// target month's length (31 Jan +1 month -> 28/29 Feb, not 2/3 Mar).
DateTime _addMonthsClamped(DateTime d, int n) {
  final DateTime month = DateTime(d.year, d.month + n);
  final int lastDay = _daysInMonth(month);
  return DateTime(month.year, month.month, d.day <= lastDay ? d.day : lastDay);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Accessibility label such as `Monday, 3 August 2026`.
String _semanticDateLabel(DateTime day) =>
    '${_weekdayNames[day.weekday - 1]}, '
    '${day.day} ${_monthNames[day.month - 1]} ${day.year}';

// ─── Keyboard intents ────────────────────────────────────────────────────────

enum _CalendarNavKind {
  left,
  right,
  up,
  down,
  weekStart,
  weekEnd,
  previousMonth,
  nextMonth,
}

/// Intent for moving the internal focused-day highlight.
class _CalendarNavIntent extends Intent {
  const _CalendarNavIntent._(this.kind);

  static const _CalendarNavIntent left =
      _CalendarNavIntent._(_CalendarNavKind.left);
  static const _CalendarNavIntent right =
      _CalendarNavIntent._(_CalendarNavKind.right);
  static const _CalendarNavIntent up = _CalendarNavIntent._(_CalendarNavKind.up);
  static const _CalendarNavIntent down =
      _CalendarNavIntent._(_CalendarNavKind.down);
  static const _CalendarNavIntent weekStart =
      _CalendarNavIntent._(_CalendarNavKind.weekStart);
  static const _CalendarNavIntent weekEnd =
      _CalendarNavIntent._(_CalendarNavKind.weekEnd);
  static const _CalendarNavIntent previousMonth =
      _CalendarNavIntent._(_CalendarNavKind.previousMonth);
  static const _CalendarNavIntent nextMonth =
      _CalendarNavIntent._(_CalendarNavKind.nextMonth);

  final _CalendarNavKind kind;
}

// ─── NasikoCalendar ──────────────────────────────────────────────────────────

/// A month-grid calendar for picking a single date.
///
/// Weeks start on Monday. The grid always renders six rows; days that belong
/// to the previous/next month are dimmed and non-interactive. Today gets a
/// hairline marker, the selected day gets the primary-action fill, and days
/// outside [minDate]/[maxDate] are disabled.
///
/// Keyboard: the grid is a single focus stop. Arrow keys move an internal
/// focused-day highlight (±1 day / ±7 days), Home/End jump to the start/end
/// of the week, PageUp/PageDown move ±1 month, and Enter/Space select the
/// focused day.
class NasikoCalendar extends StatefulWidget {
  const NasikoCalendar({
    super.key,
    this.selected,
    required this.onChanged,
    this.minDate,
    this.maxDate,
    this.initialMonth,
  });

  /// The currently selected date. Only the date component is considered.
  final DateTime? selected;

  /// Called with the picked date (normalized to date-only) when a day is
  /// tapped or selected via Enter/Space.
  final ValueChanged<DateTime> onChanged;

  /// Earliest selectable date (inclusive). Days before it are disabled.
  final DateTime? minDate;

  /// Latest selectable date (inclusive). Days after it are disabled.
  final DateTime? maxDate;

  /// Month shown initially. Defaults to the month of [selected], or the
  /// current month when nothing is selected.
  final DateTime? initialMonth;

  @override
  State<NasikoCalendar> createState() => _NasikoCalendarState();
}

class _NasikoCalendarState extends State<NasikoCalendar> {
  /// First day of the month currently shown in the grid.
  late DateTime _visibleMonth;

  /// The day the keyboard highlight sits on (date-only).
  late DateTime _focusedDay;

  /// +1 when the last month change navigated forward, -1 backward. Drives
  /// the AnimatedSwitcher slide direction.
  int _slideDirection = 1;

  /// Whether the grid's focus highlight should be painted.
  bool _showFocusRing = false;

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowLeft): _CalendarNavIntent.left,
    SingleActivator(LogicalKeyboardKey.arrowRight): _CalendarNavIntent.right,
    SingleActivator(LogicalKeyboardKey.arrowUp): _CalendarNavIntent.up,
    SingleActivator(LogicalKeyboardKey.arrowDown): _CalendarNavIntent.down,
    SingleActivator(LogicalKeyboardKey.home): _CalendarNavIntent.weekStart,
    SingleActivator(LogicalKeyboardKey.end): _CalendarNavIntent.weekEnd,
    SingleActivator(LogicalKeyboardKey.pageUp):
        _CalendarNavIntent.previousMonth,
    SingleActivator(LogicalKeyboardKey.pageDown): _CalendarNavIntent.nextMonth,
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  DateTime? get _min =>
      widget.minDate == null ? null : _dateOnly(widget.minDate!);
  DateTime? get _max =>
      widget.maxDate == null ? null : _dateOnly(widget.maxDate!);

  @override
  void initState() {
    super.initState();
    final DateTime anchor =
        widget.selected != null ? _dateOnly(widget.selected!) : _today();
    _focusedDay = _clampToRange(anchor);
    _visibleMonth = _monthOf(
      widget.initialMonth ?? widget.selected ?? _focusedDay,
    );
  }

  @override
  void didUpdateWidget(covariant NasikoCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final DateTime? selected = widget.selected;
    if (selected != null &&
        (oldWidget.selected == null ||
            !_sameDay(_dateOnly(oldWidget.selected!), _dateOnly(selected)))) {
      final DateTime day = _dateOnly(selected);
      _focusedDay = day;
      final DateTime month = _monthOf(day);
      if (month != _visibleMonth) {
        _slideDirection = month.isAfter(_visibleMonth) ? 1 : -1;
        _visibleMonth = month;
      }
    }
  }

  DateTime _today() => _dateOnly(DateTime.now());

  /// Clamps a date-only [day] into the [minDate]/[maxDate] range.
  DateTime _clampToRange(DateTime day) {
    final DateTime? min = _min;
    final DateTime? max = _max;
    if (min != null && day.isBefore(min)) return min;
    if (max != null && day.isAfter(max)) return max;
    return day;
  }

  /// Whether a date-only [day] falls outside the selectable range.
  bool _isOutOfRange(DateTime day) {
    final DateTime? min = _min;
    final DateTime? max = _max;
    if (min != null && day.isBefore(min)) return true;
    if (max != null && day.isAfter(max)) return true;
    return false;
  }

  bool get _canGoPrevious {
    final DateTime? min = _min;
    return min == null || _visibleMonth.isAfter(_monthOf(min));
  }

  bool get _canGoNext {
    final DateTime? max = _max;
    return max == null || _visibleMonth.isBefore(_monthOf(max));
  }

  /// Moves the visible month by [delta] months (header chevrons), carrying
  /// the focused-day highlight along so keyboard focus never goes off-grid.
  void _goToMonth(int delta) {
    setState(() {
      _slideDirection = delta > 0 ? 1 : -1;
      _visibleMonth = _addMonths(_visibleMonth, delta);
      _focusedDay = _clampToRange(_addMonthsClamped(_focusedDay, delta));
    });
  }

  void _handleNav(_CalendarNavIntent intent) {
    DateTime next;
    switch (intent.kind) {
      case _CalendarNavKind.left:
        next = _addDays(_focusedDay, -1);
      case _CalendarNavKind.right:
        next = _addDays(_focusedDay, 1);
      case _CalendarNavKind.up:
        next = _addDays(_focusedDay, -7);
      case _CalendarNavKind.down:
        next = _addDays(_focusedDay, 7);
      case _CalendarNavKind.weekStart:
        next = _addDays(_focusedDay, -(_focusedDay.weekday - 1));
      case _CalendarNavKind.weekEnd:
        next = _addDays(
          _focusedDay,
          DateTime.daysPerWeek - _focusedDay.weekday,
        );
      case _CalendarNavKind.previousMonth:
        next = _addMonthsClamped(_focusedDay, -1);
      case _CalendarNavKind.nextMonth:
        next = _addMonthsClamped(_focusedDay, 1);
    }
    next = _clampToRange(next);
    setState(() {
      final DateTime month = _monthOf(next);
      if (month != _visibleMonth) {
        _slideDirection = month.isAfter(_visibleMonth) ? 1 : -1;
        _visibleMonth = month;
      }
      _focusedDay = next;
    });
  }

  void _activateFocusedDay() {
    if (_isOutOfRange(_focusedDay)) return;
    widget.onChanged(_focusedDay);
  }

  void _handleDayTap(DateTime day) {
    setState(() => _focusedDay = day);
    widget.onChanged(day);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    // Pin the calendar to the grid's intrinsic width so the header row's
    // Expanded label works inside loose/overlay constraints (popover, dialog)
    // without stretching the surface.
    return SizedBox(
      width: spacing.s36 * DateTime.daysPerWeek,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: spacing.s8),
          FocusableActionDetector(
            shortcuts: _shortcuts,
            actions: <Type, Action<Intent>>{
              _CalendarNavIntent: CallbackAction<_CalendarNavIntent>(
                onInvoke: (_CalendarNavIntent intent) {
                  _handleNav(intent);
                  return null;
                },
              ),
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (ActivateIntent intent) {
                  _activateFocusedDay();
                  return null;
                },
              ),
            },
            onShowFocusHighlight: (bool value) =>
                setState(() => _showFocusRing = value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWeekdayHeader(context),
                SizedBox(height: spacing.s4),
                _buildAnimatedGrid(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // Both chevrons share the same NasikoButtonSize — grouped actions must
    // never mix sizes (design convention).
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TertiaryIconButton(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          size: NasikoButtonSize.small,
          onPressed: _canGoPrevious ? () => _goToMonth(-1) : null,
        ),
        Expanded(
          child: Text(
            '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
            textAlign: TextAlign.center,
            style: typography.bodyPrimaryBold.copyWith(
              color: colors.foregroundPrimary,
            ),
          ),
        ),
        TertiaryIconButton(
          icon: HugeIcons.strokeRoundedArrowRight01,
          size: NasikoButtonSize.small,
          onPressed: _canGoNext ? () => _goToMonth(1) : null,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final double cellSize = context.spacing.s36;

    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final String label in _weekdayHeaders)
            SizedBox(
              width: cellSize,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: typography.bodyTertiary.copyWith(
                  color: colors.foregroundSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGrid(BuildContext context) {
    final motion = context.motion;

    return AnimatedSwitcher(
      // Structural month swap — resolve() disables it under reduced motion.
      duration: motion.resolve(context, motion.base),
      switchInCurve: motion.enter,
      switchOutCurve: motion.exit,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // The incoming grid carries the current month's key; the outgoing
        // one slides the opposite way so the swap reads as travel.
        final bool incoming =
            child.key == ValueKey<DateTime>(_visibleMonth);
        final double fromX =
            (incoming ? 8.0 : -8.0) * _slideDirection.toDouble();
        return FadeTransition(
          opacity: animation,
          child: AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (BuildContext context, Widget? child) {
              return Transform.translate(
                offset: Offset(fromX * (1 - animation.value), 0),
                child: child,
              );
            },
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<DateTime>(_visibleMonth),
        child: _buildGrid(context, _visibleMonth),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, DateTime month) {
    final double cellSize = context.spacing.s36;
    final DateTime today = _today();
    final DateTime? selected =
        widget.selected == null ? null : _dateOnly(widget.selected!);

    // Lead-in from the Monday on/before the 1st; always six rows (42 cells)
    // so month height never jumps.
    final DateTime firstOfMonth = DateTime(month.year, month.month);
    final int leadDays = firstOfMonth.weekday - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int row = 0; row < 6; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int col = 0; col < 7; col++)
                _buildCell(
                  context,
                  DateTime(
                    month.year,
                    month.month,
                    1 - leadDays + row * 7 + col,
                  ),
                  month: month,
                  today: today,
                  selected: selected,
                  cellSize: cellSize,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    DateTime day, {
    required DateTime month,
    required DateTime today,
    required DateTime? selected,
    required double cellSize,
  }) {
    final bool inMonth = day.month == month.month && day.year == month.year;
    return _DayCell(
      day: day,
      size: cellSize,
      inMonth: inMonth,
      disabled: _isOutOfRange(day),
      isSelected: selected != null && _sameDay(day, selected),
      isToday: _sameDay(day, today),
      showFocusRing:
          inMonth && _showFocusRing && _sameDay(day, _focusedDay),
      onTap: () => _handleDayTap(day),
    );
  }
}

/// A single day cell: hover fade, today marker, selected fill, focus ring.
class _DayCell extends StatefulWidget {
  const _DayCell({
    required this.day,
    required this.size,
    required this.inMonth,
    required this.disabled,
    required this.isSelected,
    required this.isToday,
    required this.showFocusRing,
    required this.onTap,
  });

  final DateTime day;
  final double size;
  final bool inMonth;
  final bool disabled;
  final bool isSelected;
  final bool isToday;
  final bool showFocusRing;
  final VoidCallback onTap;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final motion = context.motion;

    // Out-of-month days: dimmed, non-interactive, invisible to a11y.
    if (!widget.inMonth) {
      return ExcludeSemantics(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: Text(
              '${widget.day.day}',
              style: typography.bodySecondary.copyWith(
                color: colors.foregroundDisabled,
              ),
            ),
          ),
        ),
      );
    }

    final bool interactive = !widget.disabled;

    final Color background = widget.isSelected
        ? colors.foregroundPrimary // Same fill primary buttons use.
        : (_isHovered && interactive
            ? colors.backgroundSurfaceHover
            : Colors.transparent);

    final Color foreground = widget.disabled
        ? colors.foregroundDisabled
        : widget.isSelected
            ? colors.foregroundOnAction
            : colors.foregroundPrimary;

    // Focus ring wins over the subtle today marker.
    final BoxBorder? border = widget.showFocusRing
        ? Border.all(color: colors.borderFocus, width: borderWidths.w2)
        : widget.isToday
            ? Border.all(color: colors.borderPrimary, width: borderWidths.w1)
            : null;

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Semantics(
        button: true,
        enabled: interactive,
        selected: widget.isSelected,
        label: _semanticDateLabel(widget.day),
        // excludeSemantics drops the GestureDetector's implicit tap action,
        // so re-expose activation for assistive tech here.
        onTap: interactive ? widget.onTap : null,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: interactive ? widget.onTap : null,
          child: AnimatedContainer(
            // Decorative hover fade — raw token by convention.
            duration: motion.hover,
            curve: motion.enter,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(radii.r8),
              border: border,
            ),
            child: Center(
              child: Text(
                '${widget.day.day}',
                style: typography.bodySecondary.copyWith(color: foreground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Modal date picker ───────────────────────────────────────────────────────

/// Shows a modal dialog containing a [NasikoCalendar] and resolves with the
/// picked date, or `null` when dismissed.
///
/// Uses the same fade + scale entrance as [showNasikoModal]; Escape and
/// barrier taps dismiss (Flutter's ModalRoute maps Escape to [DismissIntent]
/// when the barrier is dismissible).
Future<DateTime?> showNasikoDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? minDate,
  DateTime? maxDate,
}) {
  final motion = context.motion;

  return showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: context.colors.backgroundOverlay,
    transitionDuration: motion.resolve(context, motion.base),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: motion.enter,
        reverseCurve: motion.exit,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final colors = dialogContext.colors;
      final spacing = dialogContext.spacing;
      final radii = dialogContext.radius;
      final borderWidths = dialogContext.borderWidth;

      return Dialog(
        backgroundColor: colors.backgroundBase,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.r16),
          side: BorderSide(color: colors.borderPrimary, width: borderWidths.w1),
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.s16),
          child: NasikoCalendar(
            selected: initialDate,
            minDate: minDate,
            maxDate: maxDate,
            onChanged: (DateTime date) =>
                Navigator.of(dialogContext).pop(date),
          ),
        ),
      );
    },
  );
}
