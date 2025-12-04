// lib/src/components/toast/toast.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/components/buttons/primary_text_button.dart';
import 'package:nasiko_ui/src/components/toast/toast_type.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// The visual component for a Nasiko Toast notification.
class NasikoToast extends StatelessWidget {
  const NasikoToast({
    super.key,
    required this.type,
    required this.message,
    this.onCancel,
    this.showCancel = true,
  });

  final NasikoToastType type;
  final String message;
  final VoidCallback? onCancel;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radii = context.radius;
    final iconSizes = context.iconSize;

    final Color backgroundColor;
    final Color foregroundColor;
    final Color iconColor;

    switch (type) {
      case NasikoToastType.success:
        backgroundColor = colors.backgroundSuccess;
        foregroundColor = colors.foregroundSuccess;
        iconColor = colors.foregroundSuccess;
        break;
      case NasikoToastType.error:
        backgroundColor = colors.backgroundError;
        foregroundColor = colors.foregroundError;
        iconColor = colors.foregroundError;
        break;
      case NasikoToastType.warning:
        backgroundColor = colors.backgroundWarning;
        foregroundColor = colors.foregroundWarning;
        iconColor = colors.foregroundWarning;
        break;
      case NasikoToastType.info:
        backgroundColor = colors.backgroundInformation;
        foregroundColor = colors.foregroundInformation;
        iconColor = colors.foregroundInformation;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minWidth: 400),
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
            SizedBox(
              width: iconSizes.m,
              height: iconSizes.m,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            ),
            SizedBox(width: spacing.s12),
            Flexible(
              child: Text(
                message,
                style: typography.bodySecondaryBold.copyWith(
                  color: foregroundColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showCancel) ...[
              SizedBox(width: spacing.s36),
              PrimaryTextButton(onPressed: onCancel, label: 'Cancel'),
            ],
          ],
        ),
      ),
    );
  }
}
