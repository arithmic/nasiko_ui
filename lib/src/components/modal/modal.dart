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
  final motion = context.motion;

  // Keyboard behavior notes (verified against Flutter's ModalRoute):
  // - Escape: WidgetsApp maps Escape -> DismissIntent, and every ModalRoute
  //   installs a DismissAction that only pops when `barrierDismissible` is
  //   true — so Escape dismisses exactly when [isDismissible] is true.
  // - Focus trap: ModalRoute hosts its content inside its own FocusScope,
  //   so Tab traversal cannot leave the dialog while it is open.
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: motion.resolve(context, motion.base),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: motion.enter,
        reverseCurve: motion.exit,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
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

    // Use a Dialog for standard modal behavior and default barrier
    return Dialog(
      backgroundColor: backgroundColor ?? context.colors.backgroundBase,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radii.r8),
      ),
      child: Container(
        // Honor the caller's maxWidth (wide content like diagrams); the
        // classic dialog width stays the default.
        constraints: BoxConstraints(maxWidth: maxWidth ?? 680),
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
            autofocus: true,
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
            autofocus: true,
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
    bool autofocus = false,
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

    Widget result =
        fullWidth ? SizedBox(width: double.infinity, child: button) : button;
    if (autofocus) {
      result = _ModalAutofocus(child: result);
    }
    return result;
  }
}

/// Moves initial keyboard focus onto the modal's primary action button so
/// pressing Enter confirms immediately.
///
/// The design-system buttons don't expose `autofocus`/`focusNode`, so this
/// wrapper hosts a non-focusable anchor [Focus] node and, after the first
/// frame, focuses its first traversable descendant — the button's own
/// internal node. Focusing the real button node keeps the button's focus
/// ring and Enter/Space activation intact. A disabled button has no
/// traversable descendants, so this becomes a no-op; likewise it yields if
/// something inside the dialog (e.g. an autofocused field in `content`) has
/// already claimed focus.
class _ModalAutofocus extends StatefulWidget {
  const _ModalAutofocus({required this.child});

  final Widget child;

  @override
  State<_ModalAutofocus> createState() => _ModalAutofocusState();
}

class _ModalAutofocusState extends State<_ModalAutofocus> {
  final FocusNode _anchor = FocusNode(
    debugLabel: 'NasikoModal primary action autofocus anchor',
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Don't steal focus if something inside the dialog already claimed it.
      final scope = _anchor.enclosingScope;
      if (scope != null && scope.focusedChild != null) return;
      final descendants = _anchor.traversalDescendants;
      if (descendants.isNotEmpty) {
        descendants.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _anchor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _anchor,
      includeSemantics: false,
      child: widget.child,
    );
  }
}
