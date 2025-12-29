import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/src/components/avatar/avatar_size.dart';
import 'package:nasiko_ui/src/components/input_fields/input_field.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A circular avatar component for the Nasiko Design System.
///
/// Displays an image, text initials, or an icon.
class NasikoAvatar extends StatelessWidget {
  const NasikoAvatar({
    super.key,
    this.size = NasikoAvatarSize.medium,
    this.imageUrl,
    this.text,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The size of the avatar. Defaults to [NasikoAvatarSize.medium].
  final NasikoAvatarSize size;

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

    // 1. Determine size and styles from the 'size' property
    final double radius;
    final TextStyle textStyle;
    final double iconSize;

    switch (size) {
      case NasikoAvatarSize.large:
        radius = 32.0; // 64px diameter
        textStyle = typography.buttonPrimary; // 20px
        iconSize = iconSizes.m; // 24px
        break;
      case NasikoAvatarSize.medium:
        radius = 24.0; // 48px diameter
        textStyle = typography.buttonSecondary; // 18px
        iconSize = iconSizes.m; // 24px
        break;
      case NasikoAvatarSize.small:
        radius = 18.0; // 36px diameter
        textStyle = typography.bodySecondary; // 16px
        iconSize = iconSizes.s; // 20px
        break;
    }

    // 2. Determine the content of the avatar
    ImageProvider? backgroundImage;
    Widget? child;
    Color? bgColor = backgroundColor ?? colors.backgroundGroup;
    Color? fgColor = foregroundColor ?? colors.foregroundIconPrimary;

    if (imageUrl != null) {
      // Image avatar
      backgroundImage = NetworkImage(imageUrl!);
      bgColor = null; // Use image
    } else if (text != null) {
      // Text avatar
      child = Text(text!, style: textStyle.copyWith(color: fgColor));
    } else {
      // HugeIcon avatar (or default)
      child = HugeIcon(
        icon: icon ?? HugeIcons.strokeRoundedRelieved01,
        size: iconSize,
        color: fgColor,
      );
    }

    // 3. Render the CircleAvatar
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      backgroundImage: backgroundImage,
      // The child is only rendered if there is no background image
      child: backgroundImage == null ? child : null,
    );
  }
}
