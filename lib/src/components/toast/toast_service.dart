// lib/src/components/toast/toast_service.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';
import 'package:nasiko_ui/src/components/toast/toast.dart';
import 'package:nasiko_ui/src/components/toast/toast_type.dart';
import 'package:nasiko_ui/src/tokens/spacing.dart';

/// A service class to easily display Nasiko Toasts (SnackBars).
class NasikoToastService {
  NasikoToastService._();

  /// Shows a [NasikoToast] with the specified message and type.
  static void show(
    BuildContext context, {
    required String message,
    required NasikoToastType type,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onCancel,
    bool showCancel = true,
    bool inProgress = false,
  }) {
    // 1. Ensure any previous toast is dismissed immediately
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 2. Display the new SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Use the custom Toast widget as content
        content: Align(
          alignment: Alignment.center,
          widthFactor: 1,
          child: NasikoToast(
            type: type,
            message: message,
            onCancel:
                onCancel ??
                () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
            showCancel: showCancel,
            inProgress: inProgress,
          ),
        ),
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        // Add padding around the toast to match the design spacing
        padding: EdgeInsets.all(context.spacing.s16.r),

        margin: EdgeInsets.only(
          left: context.spacing.s24.w,
          bottom: context.spacing.s48.h,
        ),
      ),
    );
  }

  // --- Convenience Methods ---

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: NasikoToastType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: NasikoToastType.error);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: NasikoToastType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: NasikoToastType.info);
  }
}
