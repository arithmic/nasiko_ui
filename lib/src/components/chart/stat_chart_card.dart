import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '_chart_internals.dart';

/// What to show on the trailing (right) side of a [NasikoStatChartCard] header.
enum NasikoStatCardTrailing {
  /// Expand + overflow icon buttons.
  icons,

  /// A period dropdown (e.g. "This month").
  periodDropdown,

  /// A "View all" link.
  viewAllLink,

  /// Nothing.
  none,
}

/// The "Total spend" stat card from the dashboard screenshots: a header
/// (leading icon + title + optional info), an optional big headline value, an
/// optional trend delta line, and a chart body.
///
/// The card is decoupled from the chart widgets — pass any chart (or other
/// widget) as [child]. It mirrors [NasikoCard]'s chrome (surface, border,
/// radius, padding).
///
/// Set [collapsible] to `true` to show a maximize/minimize icon button that
/// toggles the card's WIDTH: maximize expands it to the full available width,
/// minimize restores it to its default [maxWidth]. The body (value + child) is
/// always visible. The button uses the same icon-button chrome as the default
/// [trailing], so the card looks identical to a static one. When [collapsible]
/// is `false` (default) the widget keeps its original behaviour and
/// [trailing]/[onExpand]/[onOverflow] apply.
///
/// [value] is optional: a chart card often has no single headline number, in
/// which case the value row is omitted entirely.
class NasikoStatChartCard extends StatefulWidget {
  const NasikoStatChartCard({
    super.key,
    required this.title,
    this.value,
    required this.child,
    this.leadingIcon = HugeIcons.strokeRoundedChartLineData01,
    this.infoTooltip,
    this.delta,
    this.deltaSuffix = 'vs last month',
    this.trailing = NasikoStatCardTrailing.icons,
    this.periods,
    this.selectedPeriod,
    this.onPeriodChanged,
    this.onExpand,
    this.onOverflow,
    this.onViewAll,
    this.maxWidth = double.infinity,
    this.collapsible = false,
    this.initiallyExpanded = true,
  });

  final String title;

  /// Optional big headline value. When null/empty the value row is omitted.
  final String? value;

  /// The chart (or any widget) rendered in the card body.
  final Widget child;

  final HugeIconsType leadingIcon;

  /// When set, an info icon is shown next to the title with this hover message.
  final String? infoTooltip;

  /// Optional trend delta shown beneath the value.
  final NasikoTrendDelta? delta;

  /// Suffix text after the delta (e.g. "vs last month").
  final String deltaSuffix;

  final NasikoStatCardTrailing trailing;

  /// Options for [NasikoStatCardTrailing.periodDropdown].
  final List<String>? periods;
  final String? selectedPeriod;
  final ValueChanged<String>? onPeriodChanged;

  /// Callbacks for [NasikoStatCardTrailing.icons].
  final VoidCallback? onExpand;
  final VoidCallback? onOverflow;

  /// Callback for [NasikoStatCardTrailing.viewAllLink].
  final VoidCallback? onViewAll;

  final double maxWidth;

  /// When true, the header shows a maximize/minimize button (in place of
  /// [trailing]) that toggles the card between its default [maxWidth] and the
  /// full available width.
  final bool collapsible;

  /// Reserved. No effect under the current width-toggle behaviour (the card
  /// always starts at its default [maxWidth]); kept for API stability.
  final bool initiallyExpanded;

  /// Key of the in-place collapse toggle, for tests.
  static const Key collapseToggleKey = Key('statChartCardCollapseToggle');

  @override
  State<NasikoStatChartCard> createState() => _NasikoStatChartCardState();
}

class _NasikoStatChartCardState extends State<NasikoStatChartCard> {
  /// Width toggle: false = default [maxWidth]; true = full available width.
  bool _maximized = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;

    final hasValue = widget.value != null && widget.value!.isNotEmpty;
    // Collapsible acts as a WIDTH toggle: maximize -> full available width,
    // minimize -> the card's default [maxWidth]. The body is always visible.
    // When an ancestor [NasikoMaximizeScope] is present, IT owns the maximize
    // state — so a layout (e.g. a responsive grid) can reflow the maximized
    // card to a full-width row instead of the card silently trying to grow
    // inside a fixed-width cell it can't escape. With no scope the card manages
    // the toggle itself, as before.
    final scope =
        widget.collapsible ? NasikoMaximizeScope.maybeOf(context) : null;
    final isMaximized = scope?.maximized ?? _maximized;
    final onToggleMaximized =
        scope?.onToggle ?? () => setState(() => _maximized = !_maximized);
    final effectiveMaxWidth =
        (widget.collapsible && isMaximized) ? double.infinity : widget.maxWidth;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Container(
          padding: EdgeInsets.all(spacing.s20),
          decoration: BoxDecoration(
            color: colors.backgroundBase,
            borderRadius: BorderRadius.circular(radii.r8),
            border: Border.all(color: colors.borderPrimary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, isMaximized, onToggleMaximized),
              if (hasValue) ...[
                SizedBox(height: spacing.s16h),
                _buildValueRow(context, typography, colors),
              ],
              SizedBox(height: spacing.s16h),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isMaximized,
    VoidCallback onToggleMaximized,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    return Row(
      children: [
        // Left group (icon + title + info) takes all the space except the
        // trailing, and stays left-aligned inside it — so the trailing button
        // is pinned to the true right edge instead of floating (a Flexible
        // title + a Spacer would split the free space and leave a gap).
        Expanded(
          child: Row(
            children: [
              HugeIcon(
                icon: widget.leadingIcon,
                size: iconSizes.s,
                color: colors.foregroundPrimary,
              ),
              SizedBox(width: spacing.s8w),
              Flexible(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodySecondaryBold.copyWith(
                    color: colors.foregroundPrimary,
                  ),
                ),
              ),
              if (widget.infoTooltip != null) ...[
                SizedBox(width: spacing.s8w),
                NasikoTooltip(
                  message: widget.infoTooltip!,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    size: iconSizes.xs,
                    color: colors.foregroundIconSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: spacing.s8w),
        _buildTrailing(context, isMaximized, onToggleMaximized),
      ],
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    bool isMaximized,
    VoidCallback onToggleMaximized,
  ) {
    final spacing = context.spacing;

    // Collapsible mode keeps the SAME icon-button chrome as the default `icons`
    // trailing (so a collapsible card is visually identical to the gallery
    // example), but the maximize/minimize button toggles the body in place
    // instead of firing an external callback.
    if (widget.collapsible) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TertiaryIconButton(
            key: NasikoStatChartCard.collapseToggleKey,
            icon: isMaximized
                ? HugeIcons.strokeRoundedMinimizeScreen
                : HugeIcons.strokeRoundedMaximizeScreen,
            onPressed: onToggleMaximized,
            size: NasikoButtonSize.small,
          ),
          if (widget.onOverflow != null) ...[
            SizedBox(width: spacing.s8w),
            TertiaryIconButton(
              icon: HugeIcons.strokeRoundedMoreVertical,
              onPressed: widget.onOverflow!,
              size: NasikoButtonSize.small,
            ),
          ],
        ],
      );
    }

    switch (widget.trailing) {
      case NasikoStatCardTrailing.icons:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onExpand != null)
              TertiaryIconButton(
                icon: HugeIcons.strokeRoundedMaximizeScreen,
                onPressed: widget.onExpand!,
                size: NasikoButtonSize.small,
              ),
            if (widget.onExpand != null && widget.onOverflow != null)
              SizedBox(width: spacing.s8w),
            if (widget.onOverflow != null)
              TertiaryIconButton(
                icon: HugeIcons.strokeRoundedMoreVertical,
                onPressed: widget.onOverflow!,
                size: NasikoButtonSize.small,
              ),
          ],
        );
      case NasikoStatCardTrailing.periodDropdown:
        return _PeriodDropdown(
          periods: widget.periods ?? const [],
          selected: widget.selectedPeriod,
          onChanged: widget.onPeriodChanged,
        );
      case NasikoStatCardTrailing.viewAllLink:
        return LinkButton(
          label: 'View all',
          onPressed: widget.onViewAll ?? () {},
        );
      case NasikoStatCardTrailing.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildValueRow(
    BuildContext context,
    NasikoTypography typography,
    NasikoColorTheme colors,
  ) {
    final spacing = context.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            widget.value!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.titlePrimary.copyWith(
              color: colors.foregroundPrimary,
            ),
          ),
        ),
        if (widget.delta != null) ...[
          SizedBox(width: spacing.s12w),
          Padding(
            padding: EdgeInsets.only(bottom: spacing.s4h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${trendArrow(widget.delta!.direction)} ${widget.delta!.label}',
                  style: typography.bodyTertiaryBold.copyWith(
                    color: trendColor(context, widget.delta!.direction),
                  ),
                ),
                SizedBox(width: spacing.s8w),
                Text(
                  widget.deltaSuffix,
                  style: typography.bodyTertiary.copyWith(
                    color: colors.foregroundSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({
    required this.periods,
    required this.selected,
    required this.onChanged,
  });

  final List<String> periods;
  final String? selected;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final iconSizes = context.iconSize;

    return NasikoPopupMenu(
      width: 160,
      items: [for (final p in periods) NasikoPopupMenuItemData(label: p)],
      onItemSelected: (index) {
        if (index >= 0 && index < periods.length) {
          onChanged?.call(periods[index]);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s12w,
          vertical: spacing.s8h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radii.r8),
          border: Border.all(color: colors.borderPrimary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected ?? (periods.isNotEmpty ? periods.first : ''),
              style: typography.bodyTertiary.copyWith(
                color: colors.foregroundPrimary,
              ),
            ),
            SizedBox(width: spacing.s8w),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              size: iconSizes.xs,
              color: colors.foregroundIconSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Hands control of a collapsible [NasikoStatChartCard]'s maximize state to an
/// ancestor layout.
///
/// A collapsible card grows by widening itself, which does nothing when it
/// lives in a fixed-width grid cell it can't escape. Wrap each grid tile in a
/// scope so the grid owns the state: the card's maximize button reflects
/// [maximized] and taps call [onToggle], leaving the layout free to reflow the
/// maximized card onto its own full-width row. Cards with no scope above them
/// keep managing their own width toggle.
class NasikoMaximizeScope extends InheritedWidget {
  const NasikoMaximizeScope({
    super.key,
    required this.maximized,
    required this.onToggle,
    required super.child,
  });

  /// Whether the card below this scope is currently maximized.
  final bool maximized;

  /// Called when the card's maximize/minimize button is tapped.
  final VoidCallback onToggle;

  static NasikoMaximizeScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NasikoMaximizeScope>();

  @override
  bool updateShouldNotify(NasikoMaximizeScope oldWidget) =>
      maximized != oldWidget.maximized || onToggle != oldWidget.onToggle;
}
