import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_base.dart';

/// A primary icon button for Nasiko UI.
///
/// This is a high-emphasis icon-only button with brand color fill.
/// Supports three sizes: large, medium and small.
class PrimaryIconButton extends StatelessWidget {
  const PrimaryIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = NasikoButtonSize.large,
    this.isLoading,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The icon to display on the button.
  final HugeIconsType icon;

  /// The size of the button. Defaults to [NasikoButtonSize.large].
  final NasikoButtonSize size;

  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    return buildNasikoIconButton(
      context,
      variant: NasikoButtonVariant.primary,
      onPressed: onPressed,
      icon: icon,
      size: size,
      isLoading: isLoading,
    );
  }
}
