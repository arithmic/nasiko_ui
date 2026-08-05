// lib/src/components/buttons/primary_button.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_base.dart';

/// The primary call-to-action button for Nasiko UI.
///
/// This is a high-emphasis button that uses the 'brand' color.
/// It should be used for the most important action on a screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.size = NasikoButtonSize.large,
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

  /// The size of the button. Defaults to [NasikoButtonSize.large].
  final NasikoButtonSize size;

  @override
  Widget build(BuildContext context) {
    return buildNasikoLabelButton(
      context,
      variant: NasikoButtonVariant.primary,
      onPressed: onPressed,
      label: label,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      size: size,
    );
  }
}
