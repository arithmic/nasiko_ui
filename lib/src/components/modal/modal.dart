import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Layout variant for the modal
enum NasikoModalVariant { horizontal, vertical }

enum NasikoModalTitleType { normal, success, error }

enum NasikoModalButtonHierarchy { primary, secondary, tertiary }

enum NasikoModalButtonIntent { normal, destructive }

// Helper function to easily display the modal
Future<T?> showNasikoModal<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  HugeIconsType? titleIcon,
  String? primaryButtonLabel,
  VoidCallback? onPrimaryAction,
  bool primaryButtonIsDanger = false,
  NasikoModalButtonHierarchy primaryButtonHierarchy =
      NasikoModalButtonHierarchy.primary,
  NasikoModalButtonIntent? primaryButtonIntent,
  HugeIconsType? primaryButtonLeadingIcon,
  HugeIconsType? primaryButtonTrailingIcon,
  String? secondaryButtonLabel,
  VoidCallback? onSecondaryAction,
  bool secondaryButtonIsDanger = false,
  NasikoModalButtonHierarchy secondaryButtonHierarchy =
      NasikoModalButtonHierarchy.tertiary,
  NasikoModalButtonIntent? secondaryButtonIntent,
  HugeIconsType? secondaryButtonLeadingIcon,
  HugeIconsType? secondaryButtonTrailingIcon,
  bool isDismissible = true,
  VoidCallback? onClose,
  NasikoModalVariant buttonLayout = NasikoModalVariant.horizontal,
  double? maxWidth,
  Color? backgroundColor,
  NasikoModalTitleType titleType = NasikoModalTitleType.normal,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    builder: (BuildContext dialogContext) {
      return NasikoModal(
        title: title,
        content: content,
        titleIcon: titleIcon,
        titleType: titleType,
        backgroundColor: backgroundColor,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryAction: onPrimaryAction,
        primaryButtonHierarchy: primaryButtonHierarchy,
        primaryButtonIntent:
            primaryButtonIntent ??
            (primaryButtonIsDanger
                ? NasikoModalButtonIntent.destructive
                : NasikoModalButtonIntent.normal),
        primaryButtonLeadingIcon: primaryButtonLeadingIcon,
        primaryButtonTrailingIcon: primaryButtonTrailingIcon,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryAction: onSecondaryAction,
        secondaryButtonHierarchy: secondaryButtonHierarchy,
        secondaryButtonIntent:
            secondaryButtonIntent ??
            (secondaryButtonIsDanger
                ? NasikoModalButtonIntent.destructive
                : NasikoModalButtonIntent.normal),
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
    required this.primaryButtonHierarchy,
    required this.primaryButtonIntent,
    required this.secondaryButtonHierarchy,
    required this.secondaryButtonIntent,
    this.titleIcon,
    this.primaryButtonLabel,
    this.onPrimaryAction,
    this.primaryButtonLeadingIcon,
    this.primaryButtonTrailingIcon,
    this.secondaryButtonLabel,
    this.onSecondaryAction,
    this.secondaryButtonLeadingIcon,
    this.secondaryButtonTrailingIcon,
    this.buttonLayout = NasikoModalVariant.horizontal,
    this.maxWidth,
    this.backgroundColor,
    this.titleType = NasikoModalTitleType.normal,
  });

  final String title;
  final Widget content;
  final VoidCallback onClose;

  /// Optional icon displayed before the title
  final HugeIconsType? titleIcon;
  final NasikoModalTitleType titleType;

  // Primary Action Button
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryAction;
  final NasikoModalButtonHierarchy primaryButtonHierarchy;
  final NasikoModalButtonIntent primaryButtonIntent;
  final HugeIconsType? primaryButtonLeadingIcon;
  final HugeIconsType? primaryButtonTrailingIcon;

  // Secondary Action Button
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryAction;
  final NasikoModalButtonHierarchy secondaryButtonHierarchy;
  final NasikoModalButtonIntent secondaryButtonIntent;
  final HugeIconsType? secondaryButtonLeadingIcon;
  final HugeIconsType? secondaryButtonTrailingIcon;

  // Button layout variant
  final NasikoModalVariant buttonLayout;

  /// Optional max width for the modal (defaults based on button layout)
  /// Don't use "w" or "h" suffixes of ScreenUtill.
  final double? maxWidth;
  final Color? backgroundColor;

  Color _titleColor(BuildContext context) {
    final color = context.colors;
    switch (titleType) {
      case NasikoModalTitleType.success:
        return color.foregroundSuccess;
      case NasikoModalTitleType.error:
        return color.foregroundError;
      case NasikoModalTitleType.normal:
        return color.foregroundPrimary;
    }
  }

  Color _iconColor(BuildContext context) {
    final color = context.colors;
    switch (titleType) {
      case NasikoModalTitleType.success:
        return color.foregroundSuccess;
      case NasikoModalTitleType.error:
        return color.foregroundError;
      case NasikoModalTitleType.normal:
        return color.foregroundIconPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final radii = context.radius;

    final isVertical = buttonLayout == NasikoModalVariant.vertical;
    final screenWidth = MediaQuery.of(context).size.width;
  

    // Use a Dialog for standard modal behavior and default barrier
    return Dialog(
      backgroundColor: backgroundColor ?? context.colors.backgroundBase,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radii.r8),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 680),
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            SizedBox(height: spacing.s16),
            Flexible(child: content),
            if (primaryButtonLabel != null || secondaryButtonLabel != null) ...[
              SizedBox(height: spacing.s16),
              NasikoDivider(axis: NasikoDividerAxis.horizontal),
              SizedBox(height: spacing.s16),
              isVertical
                  ? _buildVerticalButtons(context)
                  : _buildHorizontalButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    return Row(
      children: [
        if (titleIcon != null) ...[
          HugeIcon(
            icon: titleIcon!,
            size: iconSizes.m,
            color: _iconColor(context),
          ),
          SizedBox(width: spacing.s12),
        ],
        Expanded(
          child: Text(
            title,
            style: typography.bodyPrimaryBold.copyWith(
              color: _titleColor(context),
            ),
          ),
        ),
        IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            size: iconSizes.xs,
          ),
          onPressed: onClose,
        ),
      ],
    );
  }

  Widget _buildHorizontalButtons(BuildContext context) {
    final spacing = context.spacing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Secondary Button
        if (secondaryButtonLabel != null) ...[
          _buildActionButton(
            label: secondaryButtonLabel!,
            onPressed: onSecondaryAction ?? onClose,
            hierarchy: secondaryButtonHierarchy,
            intent: secondaryButtonIntent,
            leadingIcon: secondaryButtonLeadingIcon,
            trailingIcon: secondaryButtonTrailingIcon,
            fullWidth: false,
          ),
          SizedBox(width: spacing.s16),
        ],

        // Primary Button
        if (primaryButtonLabel != null)
          _buildActionButton(
            label: primaryButtonLabel!,
            onPressed: onPrimaryAction,
            hierarchy: primaryButtonHierarchy,
            intent: primaryButtonIntent,
            leadingIcon: primaryButtonLeadingIcon,
            trailingIcon: primaryButtonTrailingIcon,
            fullWidth: false,
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
          _buildActionButton(
            label: secondaryButtonLabel!,
            onPressed: onSecondaryAction ?? onClose,
            hierarchy: secondaryButtonHierarchy,
            intent: secondaryButtonIntent,
            leadingIcon: secondaryButtonLeadingIcon,
            trailingIcon: secondaryButtonTrailingIcon,
            fullWidth: true,
          ),
          SizedBox(height: spacing.s16),
        ],

        // Primary Button (bottom)
        if (primaryButtonLabel != null)
          _buildActionButton(
            label: primaryButtonLabel!,
            onPressed: onPrimaryAction,
            hierarchy: primaryButtonHierarchy,
            intent: primaryButtonIntent,
            leadingIcon: primaryButtonLeadingIcon,
            trailingIcon: primaryButtonTrailingIcon,
            fullWidth: true,
          ),
      ],
    );
  }

  /// Helper method to build buttons with appropriate styling
  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required NasikoModalButtonHierarchy hierarchy,
    required NasikoModalButtonIntent intent,
    required bool fullWidth,
    HugeIconsType? leadingIcon,
    HugeIconsType? trailingIcon,
  }) {
    Widget button;

    switch (hierarchy) {
      case NasikoModalButtonHierarchy.primary:
        button = intent == NasikoModalButtonIntent.destructive
            ? DestructiveButton(
                label: label,
                size: NasikoButtonSize.small,
                onPressed: onPressed,
                leadingIcon: leadingIcon,
                trailingIcon: trailingIcon,
              )
            : PrimaryButton(
                label: label,
                size: NasikoButtonSize.small,
                onPressed: onPressed,
                leadingIcon: leadingIcon,
                trailingIcon: trailingIcon,
              );
        break;

      case NasikoModalButtonHierarchy.secondary:
        button = intent == NasikoModalButtonIntent.destructive
            ? DestructiveSecondaryButton(
                label: label,
                size: NasikoButtonSize.small,
                onPressed: onPressed,
                leadingIcon: leadingIcon,
                trailingIcon: trailingIcon,
              )
            : SecondaryButton(
                label: label,
                size: NasikoButtonSize.small,
                onPressed: onPressed,
                leadingIcon: leadingIcon,
                trailingIcon: trailingIcon,
              );
        break;

      case NasikoModalButtonHierarchy.tertiary:
        button = intent == NasikoModalButtonIntent.destructive
            ? DestructiveTextButton(
                label: label,
                size: NasikoButtonSize.small,
                onPressed: onPressed,
                leadingIcon: leadingIcon,
                trailingIcon: trailingIcon,
              )
            : TertiaryButton(
                label: label,
                size: NasikoButtonSize.small,
                onPressed: onPressed,
                leadingIcon: leadingIcon,
                trailingIcon: trailingIcon,
              );
        break;
    }

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
