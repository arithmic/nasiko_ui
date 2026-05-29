// lib/src/components/toast/toast.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// The visual component for a Nasiko Toast notification.
class NasikoToast extends StatelessWidget {
  const NasikoToast({
    super.key,
    required this.type,
    required this.message,
    this.onCancel,
    this.showCancel = true,
    this.inProgress,
  });

  final NasikoToastType type;
  final String message;
  final VoidCallback? onCancel;
  final bool showCancel;
  final bool? inProgress;

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

    final IconData icon;

    switch (type) {
      case NasikoToastType.success:
        icon = Icons.check_box;
        break;
      case NasikoToastType.error:
        icon = Icons.cancel;
        break;
      case NasikoToastType.warning:
        icon = Icons.warning;
        break;
      case NasikoToastType.info:
        icon = Icons.info;
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
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: iconSizes.m,
                height: iconSizes.m,
                child: inProgress == true
                    ? CircularProgressIndicator(
                        strokeWidth: context.borderWidth.w1,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      )
                    : Icon(icon, size: iconSizes.m, color: iconColor),
              ),
              inProgress == true
                  ? SizedBox(width: spacing.s8)
                  : SizedBox(width: spacing.s4),

              Expanded(
                child: Text(
                  message,
                  style: typography.bodySecondaryBold.copyWith(
                    color: foregroundColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (showCancel)
                SecondaryTextButton(onPressed: onCancel, label: 'Cancel', foregroundColor : colors.foregroundConstantWhite),
            ],
          ),
        ),
      ),
    );
  }
}
