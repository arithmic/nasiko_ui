// lib/src/components/toast/nasiko_toast_type.dart

import 'package:flutter/material.dart';

/// Defines the color, icon, and emphasis for different types of toasts.
enum NasikoToastType {
  success,
  error,
  warning,
  info;

  /// Gets the appropriate icon for the toast type.
  IconData get icon {
    switch (this) {
      case NasikoToastType.success:
        return Icons.check_circle_rounded;
      case NasikoToastType.error:
        return Icons.cancel_rounded;
      case NasikoToastType.warning:
        return Icons.warning_rounded;
      case NasikoToastType.info:
        return Icons.info_rounded;
    }
  }
}
