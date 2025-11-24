// lib/src/components/avatar/nasiko_avatar.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/components/avatar/avatar_size.dart';
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
  final IconData? icon;

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
        radius = 28.0; // 56px diameter
        textStyle = typography.buttonPrimary; // 20px
        iconSize = iconSizes.l; // 28px
        break;
      case NasikoAvatarSize.medium:
        radius = 20.0; // 40px diameter
        textStyle = typography.buttonSecondary; // 18px
        iconSize = iconSizes.m; // 24px
        break;
      case NasikoAvatarSize.small:
        radius = 16.0; // 32px diameter
        textStyle = typography.bodySecondaryBold; // 16px
        iconSize = iconSizes.s; // 20px
        break;
    }

    // 2. Determine the content of the avatar
    ImageProvider? backgroundImage;
    Widget? child;
    Color? backgroundColor = colors.backgroundSurface; // neutral/100

    if (imageUrl != null) {
      // Image avatar
      backgroundImage = NetworkImage(imageUrl!);
      backgroundColor = null; // Use image
    } else if (text != null) {
      // Text avatar
      child = Text(
        text!,
        style: textStyle.copyWith(color: colors.foregroundPrimary),
      );
    } else {
      // Icon avatar (or default)
      child = Icon(
        icon ?? Icons.sentiment_satisfied_alt_outlined,
        size: iconSize,
        color: colors.foregroundSecondary,
      );
    }

    // 3. Render the CircleAvatar
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: backgroundImage,
      // The child is only rendered if there is no background image
      child: backgroundImage == null ? child : null,
    );
  }
}
