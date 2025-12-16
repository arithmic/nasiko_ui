import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Layout variant for the modal
enum NasikoModalVariant { horizontal, vertical }

// Helper function to easily display the modal
Future<T?> showNasikoModal<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  HugeIconsType? titleIcon,
  String? primaryButtonLabel,
  VoidCallback? onPrimaryAction,
  bool primaryButtonIsDanger = false,
  HugeIconsType? primaryButtonLeadingIcon,
  HugeIconsType? primaryButtonTrailingIcon,
  String? secondaryButtonLabel,
  VoidCallback? onSecondaryAction,
  bool secondaryButtonIsDanger = true,
  HugeIconsType? secondaryButtonLeadingIcon,
  HugeIconsType? secondaryButtonTrailingIcon,
  bool isDismissible = true,
  VoidCallback? onClose,
  NasikoModalVariant buttonLayout = NasikoModalVariant.horizontal,
  double? maxWidth,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    builder: (BuildContext dialogContext) {
      return NasikoModal(
        title: title,
        content: content,
        titleIcon: titleIcon,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryAction: onPrimaryAction,
        primaryButtonIsDanger: primaryButtonIsDanger,
        primaryButtonLeadingIcon: primaryButtonLeadingIcon,
        primaryButtonTrailingIcon: primaryButtonTrailingIcon,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryAction: onSecondaryAction,
        secondaryButtonIsDanger: secondaryButtonIsDanger,
        secondaryButtonLeadingIcon: secondaryButtonLeadingIcon,
        secondaryButtonTrailingIcon: secondaryButtonTrailingIcon,
        onClose: onClose ?? () => Navigator.of(dialogContext).pop(),
        buttonLayout: buttonLayout,
        maxWidth: maxWidth,
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
    this.titleIcon,
    this.primaryButtonLabel,
    this.onPrimaryAction,
    this.primaryButtonIsDanger = false,
    this.primaryButtonLeadingIcon,
    this.primaryButtonTrailingIcon,
    this.secondaryButtonLabel,
    this.onSecondaryAction,
    this.secondaryButtonIsDanger = true,
    this.secondaryButtonLeadingIcon,
    this.secondaryButtonTrailingIcon,
    this.buttonLayout = NasikoModalVariant.horizontal,
    this.maxWidth,
  });

  final String title;
  final Widget content;
  final VoidCallback onClose;

  /// Optional icon displayed before the title
  final HugeIconsType? titleIcon;

  // Primary Action Button
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryAction;
  final bool primaryButtonIsDanger;
  final HugeIconsType? primaryButtonLeadingIcon;
  final HugeIconsType? primaryButtonTrailingIcon;

  // Secondary Action Button
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryAction;
  final bool secondaryButtonIsDanger;
  final HugeIconsType? secondaryButtonLeadingIcon;
  final HugeIconsType? secondaryButtonTrailingIcon;

  // Button layout variant
  final NasikoModalVariant buttonLayout;

  /// Optional max width for the modal (defaults based on button layout)
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radii = context.radius;
    final iconSizes = context.iconSize;

    final isVertical = buttonLayout == NasikoModalVariant.vertical;
    final effectiveMaxWidth = maxWidth ?? (isVertical ? 300.0 : 764.0);

    // Use a Dialog for standard modal behavior and default barrier
    return Dialog(
      backgroundColor: colors.backgroundSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radii.r8),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header ---
            Row(
              children: [
                if (titleIcon != null) ...[
                  HugeIcon(icon: titleIcon!, size: iconSizes.m),
                  SizedBox(width: spacing.s12),
                ],
                Expanded(child: Text(title, style: typography.bodyPrimaryBold)),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: iconSizes.s,
                  ),
                  iconSize: iconSizes.s,
                  color: colors.foregroundSecondary,
                  onPressed: onClose,
                  splashRadius: iconSizes.s,
                ),
              ],
            ),
            SizedBox(height: spacing.s16),

            // --- Body Content ---
            Flexible(child: content),
            SizedBox(height: spacing.s16),

            // --- Divider (Above Footer) ---
            if (primaryButtonLabel != null || secondaryButtonLabel != null) ...[
              NasikoDivider(axis: NasikoDividerAxis.horizontal),
              SizedBox(height: spacing.s16),
            ],

            // --- Footer Actions ---
            if (primaryButtonLabel != null || secondaryButtonLabel != null)
              isVertical
                  ? _buildVerticalButtons(context)
                  : _buildHorizontalButtons(context),
          ],
        ),
      ),
    );
  }

  /// Build horizontal buttons for large modal variant
  Widget _buildHorizontalButtons(BuildContext context) {
    final spacing = context.spacing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Secondary Button
        if (secondaryButtonLabel != null) ...[
          _buildButton(
            context: context,
            label: secondaryButtonLabel!,
            onPressed: onSecondaryAction ?? onClose,
            isDanger: secondaryButtonIsDanger,
            leadingIcon: secondaryButtonLeadingIcon,
            trailingIcon: secondaryButtonTrailingIcon,
            isFullWidth: false,
          ),
          SizedBox(width: spacing.s16),
        ],

        // Primary Button
        if (primaryButtonLabel != null)
          _buildButton(
            context: context,
            label: primaryButtonLabel!,
            onPressed: onPrimaryAction ?? onClose,
            isDanger: primaryButtonIsDanger,
            leadingIcon: primaryButtonLeadingIcon,
            trailingIcon: primaryButtonTrailingIcon,
            isFullWidth: false,
          ),
      ],
    );
  }

  /// Build stacked buttons for vertical layout variant
  Widget _buildVerticalButtons(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Secondary Button (top)
        if (secondaryButtonLabel != null) ...[
          _buildButton(
            context: context,
            label: secondaryButtonLabel!,
            onPressed: onSecondaryAction ?? onClose,
            isDanger: secondaryButtonIsDanger,
            leadingIcon: secondaryButtonLeadingIcon,
            trailingIcon: secondaryButtonTrailingIcon,
            isFullWidth: true,
          ),
          SizedBox(height: spacing.s16),
        ],

        // Primary Button (bottom)
        if (primaryButtonLabel != null)
          _buildButton(
            context: context,
            label: primaryButtonLabel!,
            onPressed: onPrimaryAction ?? onClose,
            isDanger: primaryButtonIsDanger,
            leadingIcon: primaryButtonLeadingIcon,
            trailingIcon: primaryButtonTrailingIcon,
            isFullWidth: true,
          ),
      ],
    );
  }

  /// Helper method to build buttons with appropriate styling
  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required bool isDanger,
    required bool isFullWidth,
    HugeIconsType? leadingIcon,
    HugeIconsType? trailingIcon,
  }) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radii = context.radius;
    final iconSizes = context.iconSize;
    final borderWidths = context.borderWidth;

    Widget button;

    if (isDanger) {
      // Danger/Error outlined button
      button = OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.foregroundError,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: colors.borderError, width: borderWidths.w1),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s16,
            vertical: spacing.s12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radii.r8),
          ),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              HugeIcon(
                icon: leadingIcon,
                size: iconSizes.s,
                color: colors.foregroundError,
              ),
              SizedBox(width: spacing.s8),
            ],
            Text(
              label,
              style: typography.buttonSecondary.copyWith(
                color: colors.foregroundError,
              ),
            ),
            if (trailingIcon != null) ...[
              SizedBox(width: spacing.s8),
              HugeIcon(
                icon: trailingIcon,
                size: iconSizes.s,
                color: colors.foregroundError,
              ),
            ],
          ],
        ),
      );
    } else {
      // Primary brand button
      button = PrimaryButton(
        onPressed: onPressed,
        label: label,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      );
    }

    // Wrap in SizedBox for full width if needed
    if (isFullWidth && !isDanger) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
