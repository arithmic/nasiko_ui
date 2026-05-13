import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';
import 'package:nasiko_ui/src/tokens/types.dart';

/// A circular or rounded-square avatar component for the Nasiko Design System.
///
/// Displays an image, text initials, or an icon.
class NasikoAvatar extends StatelessWidget {
  const NasikoAvatar({
    super.key,
    this.size = NasikoAvatarSize.medium,
    this.shape = NasikoAvatarShape.circle,
    this.imageUrl,
    this.text,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The size of the avatar. Defaults to [NasikoAvatarSize.medium].
  final NasikoAvatarSize size;

  /// The shape of the avatar. Defaults to [NasikoAvatarShape.circle].
  final NasikoAvatarShape shape;

  /// A URL for a network image. If provided, this takes
  /// precedence over `text` and `icon`.
  final String? imageUrl;

  /// Text to display (e.g., initials). This is shown if
  /// `imageUrl` is null.
  final String? text;

  /// An icon to display. This is shown if both `imageUrl`
  /// and `text` are null.
  final HugeIconsType? icon;

  /// Optional custom background color. If not provided,
  /// defaults to [NasikoColorTheme.backgroundGroup].
  final Color? backgroundColor;

  /// Optional custom foreground color. If not provided,
  /// defaults to [NasikoColorTheme.foregroundPrimary].
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    // 1. Resolve outer dimensions and content styles from `size`.
    //    Square corner radii are tuned per size so the rounding reads
    //    consistently regardless of the box dimension.
    final double diameter;
    final double squareCornerRadius;
    final TextStyle textStyle;
    final double iconSize;

    switch (size) {
      case NasikoAvatarSize.large:
        diameter = 64.0;
        squareCornerRadius = 12.0;
        textStyle = typography.buttonPrimary; // 20px
        iconSize = iconSizes.l;
        break;
      case NasikoAvatarSize.medium:
        diameter = 48.0;
        squareCornerRadius = 10.0;
        textStyle = typography.buttonSecondary; // 18px
        iconSize = iconSizes.m; // 24px
        break;
      case NasikoAvatarSize.small:
        diameter = 36.0;
        squareCornerRadius = 8.0;
        textStyle = typography.bodySecondary; // 16px
        iconSize = iconSizes.s; // 20px
        break;
    }

    // 2. Resolve content (image, text initials, or icon).
    DecorationImage? decorationImage;
    Widget? child;
    Color? bgColor = backgroundColor ?? colors.backgroundGroup;
    final Color fgColor = foregroundColor ?? colors.foregroundIconPrimary;

    if (imageUrl != null) {
      decorationImage = DecorationImage(
        image: NetworkImage(imageUrl!),
        fit: BoxFit.cover,
      );
      bgColor = null;
    } else if (text != null) {
      child = Text(text!, style: textStyle.copyWith(color: fgColor));
    } else {
      child = HugeIcon(
        icon: icon ?? HugeIcons.strokeRoundedRelieved01,
        size: iconSize,
        color: fgColor,
      );
    }

    // 3. Render. `BoxDecoration` requires `borderRadius` to be null when
    //    `shape: BoxShape.circle`, so we branch on shape here.
    final isCircle = shape == NasikoAvatarShape.circle;
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        image: decorationImage,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(squareCornerRadius),
      ),
      child: decorationImage == null ? child : null,
    );
  }
}
