// lib/src/components/buttons/secondary_text_button.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_base.dart';

/// A secondary text button for Nasiko UI with optional icons.
///
/// This button displays text with an optional underline on hover/focus.
/// It uses the brand color for a "link" like appearance.
class SecondaryTextButton extends StatelessWidget {
  const SecondaryTextButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.foregroundColor,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The text label displayed on the button.
  final String label;

  /// An optional icon to display before the label.
  final HugeIconsType? leadingIcon;

  /// An optional icon to display after the label.
  final HugeIconsType? trailingIcon;

  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return buildNasikoTextButton(
      context,
      variant: NasikoButtonVariant.secondary,
      onPressed: onPressed,
      label: label,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      foregroundColor: foregroundColor,
    );
  }
}
