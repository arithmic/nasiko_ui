import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Shows an opinionated confirm/cancel dialog built on [showNasikoModal].
///
/// A thin wrapper for the everyday "Are you sure?" flow: [confirmLabel]
/// becomes the primary action (destructive intent when [isDestructive]) and
/// [cancelLabel] the secondary action. Resolves to `true` only when the user
/// confirms — cancelling, tapping the barrier, pressing Escape, or the close
/// button all resolve to `false`.
///
/// Provide either [message] (styled body text) or a custom [content] widget,
/// not both. With neither, the dialog shows title and actions only.
///
/// ```dart
/// final confirmed = await showNasikoConfirmDialog(
///   context: context,
///   title: 'Delete project?',
///   message: 'This action cannot be undone.',
///   confirmLabel: 'Delete',
///   isDestructive: true,
/// );
/// ```
Future<bool> showNasikoConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
  bool isDismissible = true,
}) async {
  assert(
    message == null || content == null,
    'Provide either message or content, not both.',
  );

  // showNasikoModal pushes onto the root navigator (showGeneralDialog's
  // default), so pop from the root navigator too — a nearest-navigator pop
  // would pop the wrong route inside nested-navigator apps.
  final navigator = Navigator.of(context, rootNavigator: true);
  final typography = context.typography;
  final colors = context.colors;

  final result = await showNasikoModal<bool>(
    context: context,
    title: title,
    content: content ??
        (message == null
            ? const SizedBox.shrink()
            : Text(
                message,
                style: typography.bodySecondary.copyWith(
                  color: colors.foregroundSecondary,
                ),
              )),
    primaryButtonLabel: confirmLabel,
    primaryButtonIntent: isDestructive
        ? NasikoModalButtonIntent.destructive
        : NasikoModalButtonIntent.normal,
    onPrimaryAction: () => navigator.pop(true),
    secondaryButtonLabel: cancelLabel,
    onSecondaryAction: () => navigator.pop(false),
    isDismissible: isDismissible,
  );

  // Barrier / Escape / close-button dismissal yields null — treat as cancel.
  return result ?? false;
}
