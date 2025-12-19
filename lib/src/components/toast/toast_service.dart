// lib/src/components/toast/toast_service.dart

import 'package:flutter/material.dart';
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
  }) {
    // 1. Ensure any previous toast is dismissed immediately
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 2. Display the new SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Use the custom Toast widget as content
        content: Align(
           alignment: Alignment.centerRight, // can be made configurable, rihgt now it will be shown at the bottom right of the screen
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
          ),
        ),
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        // Add padding around the toast to match the design spacing
        padding: EdgeInsets.all(context.spacing.s16),

        margin: EdgeInsets.only(
          left: context.spacing.s24,
          bottom: context.spacing.s48,
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
