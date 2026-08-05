import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_base.dart';

/// A destructive icon button for Nasiko UI.
///
/// This is a medium-emphasis icon-only button with outline style.
/// Supports three sizes: large, medium and small.
class DestructiveIconButton extends StatelessWidget {
  const DestructiveIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = NasikoButtonSize.large,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The icon to display on the button.
  final HugeIconsType icon;

  /// The size of the button. Defaults to [NasikoButtonSize.large].
  final NasikoButtonSize size;

  @override
  Widget build(BuildContext context) {
    return buildNasikoIconButton(
      context,
      variant: NasikoButtonVariant.destructive,
      onPressed: onPressed,
      icon: icon,
      size: size,
    );
  }
}
