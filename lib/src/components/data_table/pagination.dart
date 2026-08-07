// lib/src/components/data_table/pagination.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../buttons/button_layout.dart';
import '../buttons/button_press_scale.dart';

/// A compact, keyboard-accessible page switcher for Nasiko UI.
///
/// Renders a previous/next chevron pair around a windowed list of numbered
/// page buttons with ellipses for collapsed ranges, e.g.
/// `< 1 … 5 [6] 7 … 20 >`. The current page is highlighted with the same
/// fill as [PrimaryButton]; all other controls use the tertiary style.
///
/// All controls share [NasikoButtonSize.small] — button groups must never
/// mix sizes. Hover/press/focus states animate through the button system
/// (`context.motion.fast`), and the whole control carries a
/// `'Page N of M'` semantics label.
///
/// [page] is a zero-based index; labels are rendered one-based.
class NasikoPagination extends StatelessWidget {
  const NasikoPagination({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onPageChanged,
    this.maxVisiblePages = 7,
  })  : assert(pageCount > 0, 'pageCount must be at least 1.'),
        assert(
          page >= 0 && page < pageCount,
          'page must be within 0..pageCount - 1.',
        ),
        assert(
          maxVisiblePages >= 5,
          'maxVisiblePages must be at least 5 to fit the first page, the '
          'last page, the current page, and the ellipses.',
        );

  /// The current page as a zero-based index.
  final int page;

  /// Total number of pages. Must be at least 1.
  final int pageCount;

  /// Called with the new zero-based page index when the user picks a page.
  final ValueChanged<int> onPageChanged;

  /// Maximum number of page slots (numbers + ellipses) to show between the
  /// chevrons. Must be at least 5. Defaults to 7.
  final int maxVisiblePages;

  /// The visible page slots: zero-based page indices, with `null` marking
  /// an ellipsis.
  List<int?> _visibleItems() {
    if (pageCount <= maxVisiblePages) {
      return List<int?>.generate(pageCount, (i) => i);
    }

    final int last = pageCount - 1;

    // Near the start: 1 2 3 4 5 … N
    if (page < maxVisiblePages - 3) {
      return <int?>[
        for (var i = 0; i <= maxVisiblePages - 3; i++) i,
        null,
        last,
      ];
    }

    // Near the end: 1 … N-4 N-3 N-2 N-1 N
    if (page > pageCount - maxVisiblePages + 2) {
      return <int?>[
        0,
        null,
        for (var i = pageCount - maxVisiblePages + 2; i <= last; i++) i,
      ];
    }

    // Middle: 1 … p-1 p p+1 … N
    final int innerCount = maxVisiblePages - 4;
    final int start = page - (innerCount - 1) ~/ 2;
    return <int?>[
      0,
      null,
      for (var i = start; i < start + innerCount; i++) i,
      null,
      last,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final items = _visibleItems();

    return Semantics(
      container: true,
      label: 'Page ${page + 1} of $pageCount',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'Previous page',
            child: TertiaryIconButton(
              size: NasikoButtonSize.small,
              icon: HugeIcons.strokeRoundedArrowLeft01,
              onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
            ),
          ),
          for (final item in items) ...[
            SizedBox(width: spacing.s4),
            if (item == null)
              const _PaginationEllipsis()
            else
              _PageNumberButton(
                index: item,
                isCurrent: item == page,
                onPressed: item == page ? null : () => onPageChanged(item),
              ),
          ],
          SizedBox(width: spacing.s4),
          Semantics(
            label: 'Next page',
            child: TertiaryIconButton(
              size: NasikoButtonSize.small,
              icon: HugeIcons.strokeRoundedArrowRight01,
              onPressed:
                  page < pageCount - 1 ? () => onPageChanged(page + 1) : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// A collapsed-range marker sized to match the small button slots.
class _PaginationEllipsis extends StatelessWidget {
  const _PaginationEllipsis();

  @override
  Widget build(BuildContext context) {
    final layout = iconButtonLayout(context, NasikoButtonSize.small);

    return ExcludeSemantics(
      child: SizedBox(
        width: layout.minHeight,
        height: layout.minHeight,
        child: Center(
          child: Text(
            '…',
            style: context.typography.buttonSecondary.copyWith(
              color: context.colors.foregroundSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// A single numbered page button.
///
/// The current page uses the [PrimaryButton] fill and is not interactive;
/// other pages use the tertiary button treatment. Sized to match the
/// small [TertiaryIconButton] chevrons.
class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({
    required this.index,
    required this.isCurrent,
    required this.onPressed,
  });

  /// Zero-based page index; rendered one-based.
  final int index;

  /// Whether this button represents the current page.
  final bool isCurrent;

  /// Tap handler; `null` for the (non-interactive) current page.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final spacing = context.spacing;
    final layout = iconButtonLayout(context, NasikoButtonSize.small);

    final style = ButtonStyle(
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(horizontal: spacing.s8),
      ),
      minimumSize: WidgetStateProperty.all(Size.square(layout.minHeight)),
      fixedSize: WidgetStateProperty.all(Size.fromHeight(layout.minHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      animationDuration: context.motion.fast,
      textStyle: WidgetStateProperty.all(typography.buttonSecondary),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(Colors.transparent),

      // --- Background Color ---
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (isCurrent) {
          // Current page: same fill scale as PrimaryButton.
          if (states.contains(WidgetState.hovered)) {
            return colors.foregroundConstantBlackSecondary;
          }
          return colors.foregroundPrimary;
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.backgroundSecondaryBrand;
        }
        return Colors.transparent;
      }),

      // --- Foreground Color ---
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (isCurrent) {
          return colors.foregroundOnAction;
        }
        if (states.contains(WidgetState.disabled)) {
          return colors.foregroundDisabled;
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.foregroundIconSecondary;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.foregroundIconHover;
        }
        return colors.foregroundIconTertiary;
      }),

      // --- Shape & Focus Ring ---
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        BorderSide borderSide = BorderSide.none;

        if (states.contains(WidgetState.focused)) {
          borderSide = BorderSide(
            color: colors.borderFocus,
            width: borderWidths.w2,
            strokeAlign: BorderSide.strokeAlignOutside,
          );
        } else if (!isCurrent &&
            (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed))) {
          borderSide = BorderSide(
            color: colors.borderPrimary,
            width: borderWidths.w1,
          );
        }

        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.r8),
          side: borderSide,
        );
      }),
    );

    final Widget button = TextButton(
      onPressed: onPressed,
      style: style,
      child: Text('${index + 1}'),
    );

    return Semantics(
      label: 'Page ${index + 1}',
      selected: isCurrent,
      child: ButtonPressScale(enabled: onPressed != null, child: button),
    );
  }
}
