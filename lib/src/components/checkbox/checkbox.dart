// lib/src/components/checkbox/nasiko_checkbox.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A single, raw checkbox.
///
/// This is the low-level component that is just the tappable box.
/// For a label and icon, see [NasikoCheckboxRow].
class NasikoCheckbox extends StatefulWidget {
  const NasikoCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  /// Whether the checkbox is currently checked.
  final bool isChecked;

  /// The callback to invoke when the checkbox is tapped.
  /// If `null`, the checkbox will be disabled.
  final ValueChanged<bool?>? onChanged;

  @override
  State<NasikoCheckbox> createState() => _NasikoCheckboxState();
}

class _NasikoCheckboxState extends State<NasikoCheckbox> {
  bool _isHovering = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;

    final bool isDisabled = widget.onChanged == null;
    final bool isInteracting = _isHovering || _isFocused;

    // --- Define styles based on state ---
    Color fillColor = Colors.transparent;
    Border? border;
    Icon? checkIcon;

    if (isDisabled) {
      fillColor = colors.backgroundDisabled;
      border = Border.all(color: colors.borderDisabled, width: borderWidths.w1);
    } else if (widget.isChecked) {
      fillColor = _isHovering
          ? colors.backgroundBrandHover
          : colors.backgroundBrand;

      // The focus ring is the same as the PrimaryButton
      if (_isFocused) {
        border = Border.all(
          color: colors.borderHover,
          width: borderWidths.w2,
          strokeAlign: BorderSide.strokeAlignOutside,
        );
      }

      checkIcon = Icon(
        Icons.check,
        size: iconSizes.s, // 20px
        color: colors.foregroundOnAction, // White
      );
    } else {
      // Unchecked
      fillColor = Colors.transparent;

      border = Border.all(
        color: isInteracting
            ? colors
                  .borderSecondary // Yellow on focus/hover
            : colors.borderPrimary, // Neutral default
        width: isInteracting ? borderWidths.w2 : borderWidths.w1,
      );
    }

    return FocusableActionDetector(
      onFocusChange: (isFocused) => setState(() => _isFocused = isFocused),
      onShowHoverHighlight: (isHovering) =>
          setState(() => _isHovering = isHovering),
      child: InkWell(
        onTap: isDisabled ? null : () => widget.onChanged!(!widget.isChecked),
        borderRadius: BorderRadius.circular(radii.r6),
        splashColor: colors.backgroundBrandSubtle,
        highlightColor: colors.backgroundBrandSubtle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: iconSizes.m, // 24px
          height: iconSizes.m, // 24px
          decoration: BoxDecoration(
            color: fillColor,
            border: border,
            borderRadius: BorderRadius.circular(radii.r6), // 6px radius
          ),
          child: checkIcon,
        ),
      ),
    );
  }
}
