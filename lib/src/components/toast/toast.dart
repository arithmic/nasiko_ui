// lib/src/components/toast/nasiko_toast.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/components/toast/toast_type.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// The visual component for a Nasiko Toast notification.
class NasikoToast extends StatelessWidget {
  const NasikoToast({super.key, required this.type, required this.message});

  final NasikoToastType type;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radii = context.radius;
    final iconSizes = context.iconSize;

    // Determine colors based on toast type
    final Color backgroundColor;
    final Color foregroundColor;
    final Color iconColor;

    switch (type) {
      case NasikoToastType.success:
        backgroundColor = colors.backgroundSuccess;
        foregroundColor = colors.foregroundConstantWhite;
        iconColor = colors.foregroundConstantWhite;
        break;
      case NasikoToastType.error:
        backgroundColor = colors.backgroundError;
        foregroundColor = colors.foregroundConstantWhite;
        iconColor = colors.foregroundConstantWhite;
        break;
      case NasikoToastType.warning:
        // Use a darker warning background for contrast with white text
        backgroundColor = context.colors.backgroundWarning;
        foregroundColor = colors.foregroundConstantWhite;
        iconColor = colors.foregroundConstantWhite;
        break;
      case NasikoToastType.info:
        backgroundColor = colors.backgroundInformation;
        foregroundColor = colors.foregroundConstantWhite;
        iconColor = colors.foregroundConstantWhite;
        break;
    }

    return Material(
      color: Colors.transparent, // Required to show the SnackBar content
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radii.r8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: iconSizes.m, color: iconColor),
            SizedBox(width: spacing.s8),
            // Message text
            Flexible(
              child: Text(
                message,
                style: typography.bodyPrimaryBold.copyWith(
                  color: foregroundColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
