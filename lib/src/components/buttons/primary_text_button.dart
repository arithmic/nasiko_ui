import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_base.dart';

/// A primary text button for Nasiko UI with optional icons.
///
/// This button displays text with an optional underline on hover/focus.
/// Uses brand color (yellow500) for emphasis.
class PrimaryTextButton extends StatelessWidget {
  const PrimaryTextButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The text label displayed on the button.
  final String label;

  /// An optional icon to display before the label.
  final HugeIconsType? leadingIcon;

  /// An optional icon to display after the label. Only to use HugeIcon library.
  /// Ex: HugeIcons.strokeRoundedLoading01
  final HugeIconsType? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return buildNasikoTextButton(
      context,
      variant: NasikoButtonVariant.primary,
      onPressed: onPressed,
      label: label,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
    );
  }
}
