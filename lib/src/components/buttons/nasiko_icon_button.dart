import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A square, icon-only button following the DESIGN-2 restructure. Shares the
/// [NasikoButtonType] / [NasikoButtonTone] / [NasikoButtonSize] axes with
/// [NasikoButton] but keeps true square geometry (28 / 32 / 36).
///
/// `link` type behaves like `ghost` here (no underline applies to an icon).
class NasikoIconButton extends StatelessWidget {
  const NasikoIconButton({
    super.key,
    required this.type,
    required this.icon,
    required this.onPressed,
    this.tone = NasikoButtonTone.default_,
    this.size = NasikoButtonSize.medium,
    this.isLoading = false,
    this.statesController,
  });

  final NasikoButtonType type;
  final NasikoButtonTone tone;
  final NasikoButtonSize size;
  final HugeIconsType icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Optional external controller for driving the button's interaction state
  /// (e.g. so a surrounding region can reflect hover/pressed onto this button).
  final WidgetStatesController? statesController;

  @override
  Widget build(BuildContext context) {
    assert(
      tone == NasikoButtonTone.default_ ||
          type == NasikoButtonType.primary ||
          type == NasikoButtonType.secondary,
      'destructive tone is only supported for primary and secondary buttons',
    );

    final colors = context.colors;
    final layout = buttonLayoutV2(context, size);
    final borderWidth = context.borderWidth;
    final strokeWidth = context.iconStrokeWidth.width;

    NasikoButtonColors resolve(Set<WidgetState> states) =>
        resolveButtonColors(colors, type, tone, buttonStateFrom(states));

    final style = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      fixedSize: WidgetStateProperty.all(Size.square(layout.height)),
      minimumSize: WidgetStateProperty.all(Size.square(layout.height)),
      maximumSize: WidgetStateProperty.all(Size.square(layout.height)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.resolveWith((s) => resolve(s).fill),
      foregroundColor:
          WidgetStateProperty.resolveWith((s) => resolve(s).foreground),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        final resolved = resolve(states);
        if (resolved.focusRing != null) {
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(layout.focusRadius),
            side: BorderSide(
              color: resolved.focusRing!,
              width: borderWidth.w1,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          );
        }
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(layout.bodyRadius),
          side: resolved.border == null
              ? BorderSide.none
              : BorderSide(color: resolved.border!, width: borderWidth.w1),
        );
      }),
    );

    return IconButton(
      onPressed: onPressed,
      style: style,
      statesController: statesController,
      icon: isLoading
          ? SizedBox(
              width: layout.iconSize,
              height: layout.iconSize,
              child: CircularProgressIndicator(strokeWidth: borderWidth.w2),
            )
          : HugeIcon(
              icon: icon,
              size: layout.iconSize,
              strokeWidth: strokeWidth,
            ),
    );
  }
}
