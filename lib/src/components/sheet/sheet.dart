import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// The screen edge a Nasiko sheet is attached to and slides in from.
enum NasikoSheetSide { left, right }

/// Default sheet width in logical pixels when no `width` is provided.
const double _kDefaultSheetWidth = 400.0;

/// Shows a full-height side sheet anchored to the chosen screen edge.
///
/// The sheet slides in from [side] over a dimmed barrier, matching the
/// `subtle & fast` motion personality (`context.motion.panel`, enter/exit
/// curves, reduced-motion aware). The surface uses the same styling language
/// as [NasikoModal]: `backgroundBase` fill, `borderPrimary` hairline, and
/// `r16` rounding on the inner edge only.
///
/// Returns a [Future] that resolves to the value passed to
/// `Navigator.pop(context, result)` from within the sheet, or `null` when it
/// is dismissed via the barrier or Escape.
///
/// ```dart
/// final saved = await showNasikoSheet<bool>(
///   context: context,
///   builder: (context) => const FilterPanel(),
/// );
/// ```
Future<T?> showNasikoSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  NasikoSheetSide side = NasikoSheetSide.right,
  double? width,
  bool isDismissible = true,
  Color? barrierColor,
}) {
  final motion = context.motion;
  final isRight = side == NasikoSheetSide.right;

  return showGeneralDialog<T>(
    context: context,
    // Barrier tap dismisses; Escape is handled by the route's built-in
    // DismissAction, which also respects barrierDismissible.
    barrierDismissible: isDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black54,
    transitionDuration: motion.resolve(context, motion.panel),
    // The slide lives inside pageBuilder (around the sheet itself) so the
    // fractional offset is relative to the sheet's width, not the screen's.
    // Return the child untouched here to skip the default page fade — the
    // barrier still fades with the route animation.
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        child,
    pageBuilder: (sheetContext, animation, secondaryAnimation) {
      final colors = sheetContext.colors;
      final radii = sheetContext.radius;
      final borderWidths = sheetContext.borderWidth;

      final innerRadius = Radius.circular(radii.r16);

      final curved = CurvedAnimation(
        parent: animation,
        curve: motion.enter,
        reverseCurve: motion.exit,
      );

      return Align(
        alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isRight ? 1 : -1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: SizedBox(
            // Clamp to the viewport so a 400px sheet never exceeds a
            // narrower window.
            width: math.min(
              width ?? _kDefaultSheetWidth,
              MediaQuery.sizeOf(sheetContext).width,
            ),
            height: double.infinity,
            child: Material(
              color: colors.backgroundBase,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                // Round the inner edge only — the outer edge sits flush
                // against the screen edge.
                borderRadius: isRight
                    ? BorderRadius.only(
                        topLeft: innerRadius,
                        bottomLeft: innerRadius,
                      )
                    : BorderRadius.only(
                        topRight: innerRadius,
                        bottomRight: innerRadius,
                      ),
                side: BorderSide(
                  color: colors.borderPrimary,
                  width: borderWidths.w1,
                ),
              ),
              child: SafeArea(child: Builder(builder: builder)),
            ),
          ),
        ),
      );
    },
  );
}
