import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_base.dart';

/// The secondary call-to-action button for Nasiko UI.
///
/// This is a medium-emphasis button that uses an outlined style with the 'brand' color.
/// It should be used for secondary actions on a screen.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
      variant: NasikoButtonVariant.secondary,
      onPressed: onPressed,
      label: label,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      size: size,
    );
  }
}
