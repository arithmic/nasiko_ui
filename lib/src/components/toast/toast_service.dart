// lib/src/components/toast/nasiko_toast_service.dart

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
  }) {
    // 1. Ensure any previous toast is dismissed immediately
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 2. Display the new SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Use the custom Toast widget as content
        content: NasikoToast(type: type, message: message),
        duration: duration,
        // Make the background transparent so the Toast's color shows through
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        // Add padding around the toast to match the design spacing
        padding: EdgeInsets.all(context.spacing.s16),

        // This makes the SnackBar position itself centrally,
        // which matches the floating toast design
        margin: EdgeInsets.only(
          left: context.spacing.s24,
          right: context.spacing.s24,
          bottom: context.spacing.s48, // Lift it slightly off the bottom edge
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
}
