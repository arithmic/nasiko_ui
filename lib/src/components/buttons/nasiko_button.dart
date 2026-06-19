import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A text button with optional leading/trailing icons, following the DESIGN-2
/// restructure: emphasis ([type]) and intent ([tone]) are orthogonal axes.
///
/// `destructive` tone is only styled for [NasikoButtonType.primary] and
/// [NasikoButtonType.secondary]; it is ignored for tertiary, ghost, and link.
class NasikoButton extends StatelessWidget {
  const NasikoButton({
    super.key,
    required this.type,
    required this.label,
    required this.onPressed,
    this.tone = NasikoButtonTone.default_,
    this.size = NasikoButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
  });

  final NasikoButtonType type;
  final NasikoButtonTone tone;
  final NasikoButtonSize size;
  final String label;
  final VoidCallback? onPressed;
  final HugeIconsType? leadingIcon;
  final HugeIconsType? trailingIcon;

  /// When true the button shows a spinner in place of its content and is not
  /// interactive.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    assert(
      tone == NasikoButtonTone.default_ ||
          type == NasikoButtonType.primary ||
          type == NasikoButtonType.secondary,
      'destructive tone is only supported for primary and secondary buttons',
    );

    final colors = context.colors;
    final typography = context.typography;
    final layout = buttonLayoutV2(context, size);
    final strokeWidth = context.iconStrokeWidth.width;
    final borderWidth = context.borderWidth;
    final isLink = type == NasikoButtonType.link;

    // The link type uses the dedicated link text style (underlined); other
    // types use the size-based button text style.
    final textStyle = isLink
        ? typography.linkPrimary
        : switch (size) {
            NasikoButtonSize.large => typography.buttonPrimary,
            NasikoButtonSize.medium ||
            NasikoButtonSize.small => typography.buttonSecondary,
          };

    NasikoButtonColors resolve(Set<WidgetState> states) =>
        resolveButtonColors(colors, type, tone, buttonStateFrom(states));

    final style = ButtonStyle(
      padding: WidgetStateProperty.all(layout.padding),
      fixedSize: WidgetStateProperty.all(Size.fromHeight(layout.height)),
      minimumSize: WidgetStateProperty.all(Size(0, layout.height)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStateProperty.all(textStyle),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.resolveWith((s) => resolve(s).fill),
      foregroundColor:
          WidgetStateProperty.resolveWith((s) => resolve(s).foreground),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        final resolved = resolve(states);
        // The focus ring is drawn outside at the focus radius; otherwise the
        // body border (if any) is drawn at the body radius.
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

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? SizedBox(
              width: layout.iconSize,
              height: layout.iconSize,
              child: CircularProgressIndicator(strokeWidth: borderWidth.w2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  HugeIcon(
                    icon: leadingIcon!,
                    size: layout.iconSize,
                    strokeWidth: strokeWidth,
                  ),
                  SizedBox(width: layout.contentGap),
                ],
                Text(label),
                if (trailingIcon != null) ...[
                  SizedBox(width: layout.contentGap),
                  HugeIcon(
                    icon: trailingIcon!,
                    size: layout.iconSize,
                    strokeWidth: strokeWidth,
                  ),
                ],
              ],
            ),
    );
  }
}
