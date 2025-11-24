// lib/src/components/modal/nasiko_modal.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

// Helper function to easily display the modal
Future<T?> showNasikoModal<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  IconData? leadingIcon,
  String? primaryButtonLabel,
  VoidCallback? onPrimaryAction,
  String? secondaryButtonLabel,
  VoidCallback? onSecondaryAction,
  bool isDismissible = true,
  VoidCallback? onClose,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    builder: (BuildContext dialogContext) {
      return NasikoModal(
        title: title,
        content: content,
        leadingIcon: leadingIcon,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryAction: onPrimaryAction,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryAction: onSecondaryAction,
        onClose: onClose ?? () => Navigator.of(dialogContext).pop(),
      );
    },
  );
}

/// A customizable modal component for alerts, confirmations, or complex forms.
class NasikoModal extends StatelessWidget {
  const NasikoModal({
    super.key,
    required this.title,
    required this.content,
    required this.onClose,
    this.leadingIcon,
    this.primaryButtonLabel,
    this.onPrimaryAction,
    this.secondaryButtonLabel,
    this.onSecondaryAction,
  });

  final String title;
  final Widget content;
  final VoidCallback onClose;

  /// For Alert/Notification type modals (e.g., Icons.warning_rounded).
  final IconData? leadingIcon;

  // Primary Action Button (Right)
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryAction;

  // Secondary Action Button (Left)
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radii = context.radius;
    final iconSizes = context.iconSize;

    // Use a Dialog for standard modal behavior and default barrier
    return Dialog(
      backgroundColor: colors.backgroundSurface, // White/Surface background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radii.r12),
      ),
      insetPadding: EdgeInsets.all(spacing.s24),

      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header ---
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s24,
                spacing.s16,
                spacing.s8,
                spacing.s16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: typography.titleSecondary.copyWith(
                        color: colors.foregroundPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: iconSizes.m),
                    color: colors.foregroundSecondary,
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            // --- Divider (Below Header) ---
            NasikoDivider(axis: NasikoDividerAxis.horizontal),

            // --- Body Content ---
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  spacing.s24,
                  spacing.s24,
                  spacing.s24,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leadingIcon != null) ...[
                      Center(
                        child: Icon(
                          leadingIcon,
                          size: 64, // Large icon size for emphasis
                          color: colors
                              .foregroundWarning, // Assuming alert/warning color
                        ),
                      ),
                      SizedBox(height: spacing.s24),
                    ],
                    content,
                  ],
                ),
              ),
            ),

            // --- Divider (Above Footer) ---
            SizedBox(height: spacing.s24),
            NasikoDivider(axis: NasikoDividerAxis.horizontal),

            // --- Footer Actions ---
            if (primaryButtonLabel != null || secondaryButtonLabel != null)
              Padding(
                padding: EdgeInsets.all(spacing.s16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Secondary Button (Text Button / Low Emphasis)
                    if (secondaryButtonLabel != null) ...[
                      TextButton(
                        onPressed: onSecondaryAction ?? onClose,
                        child: Text(
                          secondaryButtonLabel!,
                          style: typography.buttonSecondary.copyWith(
                            color: colors.foregroundPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: spacing.s12),
                    ],

                    // Primary Button (High Emphasis)
                    if (primaryButtonLabel != null)
                      PrimaryButton(
                        onPressed: onPrimaryAction ?? onClose,
                        label: primaryButtonLabel!,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
