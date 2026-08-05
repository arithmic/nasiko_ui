import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_base.dart';

/// A tertiary icon button for Nasiko UI.
///
/// This is a low-emphasis icon-only button without an outline.
/// Supports three sizes: large, medium and small.
class TertiaryIconButton extends StatelessWidget {
  const TertiaryIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = NasikoButtonSize.large,
    this.statesController,
  });

  /// The callback that is called when the button is tapped.
  /// If `null`, the button will be displayed in the 'disabled' state.
  final VoidCallback? onPressed;

  /// The icon to display on the button.
  final HugeIconsType icon;

  /// The size of the button. Defaults to [NasikoButtonSize.large].
  final NasikoButtonSize size;

  /// Optional external controller for driving widget states (e.g. hover,
  /// pressed) from outside the button — used when [AbsorbPointer] or similar
  /// blocks pointer events from reaching the button directly.
  final WidgetStatesController? statesController;

  @override
  Widget build(BuildContext context) {
    return buildNasikoIconButton(
      context,
      variant: NasikoButtonVariant.tertiary,
      onPressed: onPressed,
      icon: icon,
      size: size,
      statesController: statesController,
    );
  }
}
