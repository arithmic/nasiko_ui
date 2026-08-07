// lib/src/components/checkbox/nasiko_checkbox.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

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

  /// Whether the latest visual change came from hover/focus rather than a
  /// check-state change. Hover polish runs at `motion.hover`, check toggles
  /// at `motion.fast`.
  bool _interactionDriven = false;

  @override
  void didUpdateWidget(NasikoCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isChecked != widget.isChecked) {
      _interactionDriven = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;
    final motion = context.motion;

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
          color: colors.borderFocus,
          width: borderWidths.w2,
          strokeAlign: BorderSide.strokeAlignOutside,
        );
      }

      checkIcon = Icon(
        Icons.check,
        key: const ValueKey('checked'),
        size: iconSizes.s, // 20px
        color: colors.foregroundOnBrand, // Ink on light-hue fills, white on dark-hue
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
      onFocusChange: (isFocused) => setState(() {
        _interactionDriven = true;
        _isFocused = isFocused;
      }),
      onShowHoverHighlight: (isHovering) => setState(() {
        _interactionDriven = true;
        _isHovering = isHovering;
      }),
      child: InkWell(
        onTap: isDisabled ? null : () => widget.onChanged!(!widget.isChecked),
        borderRadius: BorderRadius.circular(radii.r6),
        splashColor: colors.backgroundBrandSubtle,
        highlightColor: colors.backgroundBrandSubtle,
        child: AnimatedContainer(
          duration: motion.resolve(
            context,
            _interactionDriven ? motion.hover : motion.fast,
          ),
          curve: motion.enter,
          width: iconSizes.m, // 24px
          height: iconSizes.m, // 24px
          decoration: BoxDecoration(
            color: fillColor,
            border: border,
            borderRadius: BorderRadius.circular(radii.r6), // 6px radius
          ),
          // The check mark scales up (0.6 -> 1.0) and fades in on check,
          // reversing on uncheck.
          child: AnimatedSwitcher(
            duration: motion.resolve(context, motion.fast),
            switchInCurve: motion.enter,
            switchOutCurve: motion.exit,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
                child: child,
              ),
            ),
            child: checkIcon ??
                const SizedBox.shrink(key: ValueKey('unchecked')),
          ),
        ),
      ),
    );
  }
}
