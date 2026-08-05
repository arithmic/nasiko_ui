import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_base.dart';

/// A destructive secondary button for Nasiko UI.
///
/// This is a medium-emphasis button that uses a light error background with error borders.
/// It should be used for destructive secondary actions on a screen.
class DestructiveSecondaryButton extends StatelessWidget {
  const DestructiveSecondaryButton({
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
      variant: NasikoButtonVariant.destructiveSecondary,
      onPressed: onPressed,
      label: label,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      size: size,
    );
  }
}
