import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A radio button component for single selection within a group.
///
/// Implements the Nasiko design system with four distinct visual states:
///
/// **Selected State (Default):**
/// - Size: 20px diameter
/// - Outer ring: Light gray (borderPrimary)
/// - Inner circle: Brand color (backgroundBrand)
///
/// **Hover State:**
/// - Size: 20px diameter
/// - Outer ring: Dark brand color (backgroundBrandHover)
/// - Inner circle: Dark brand color when selected
///
/// **Focused State (Active/Pressed):**
/// - Size: 24px diameter (expands from 20px)
/// - Outer ring: Brand color at 24px (backgroundBrand)
/// - Middle ring: Light gray at 20px (borderPrimary)
/// - Inner circle: Brand color when selected (12px diameter)
///
/// **Disabled State:**
/// - Size: 20px diameter
/// - Background fill: Light gray (backgroundDisabled)
/// - Border: Light gray (borderDisabled)
/// - Inner circle: Muted gray with transparency when selected (backgroundOverlay)
class NasikoRadio<T> extends StatefulWidget {
  const NasikoRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  /// The value represented by this radio button.
  final T value;

  /// The currently selected value for the group of radio buttons.
  final T? groupValue;

  /// Called when the radio button is tapped.
  /// If null, the radio button will be disabled.
  final ValueChanged<T?>? onChanged;

  @override
  State<NasikoRadio<T>> createState() => _NasikoRadioState<T>();
}

class _NasikoRadioState<T> extends State<NasikoRadio<T>> {
  /// Tracks whether the mouse is hovering over the radio button.
  bool _isHovering = false;

  /// Tracks whether the radio button is currently being pressed/focused.
  bool _isFocused = false;

  /// Whether this radio button is currently selected.
  bool get _isSelected => widget.value == widget.groupValue;

  /// Whether this radio button is disabled (onChanged is null).
  bool get _isDisabled => widget.onChanged == null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;
    final motion = context.motion;

    // Size expands to 24px when focused, otherwise stays at 20px
    final size = _isFocused ? iconSizes.m : iconSizes.s;

    // Main 20px ring color
    // (priority order: disabled > focused > hovering > default).
    final Color ringColor;
    if (_isDisabled) {
      // Disabled: Light gray border
      ringColor = colors.borderDisabled;
    } else if (_isFocused) {
      // Focused: Light gray 20px ring (brand 24px ring drawn separately)
      ringColor = colors.borderPrimary;
    } else if (_isHovering) {
      // Hover: Dark brand color outer ring
      ringColor = colors.backgroundBrandHover;
    } else {
      // Default: Light gray outer ring
      ringColor = colors.borderPrimary;
    }

    // Inner dot color; the dot scales to 0 when unselected, so a color is
    // always resolved (same priority order as the ring).
    final Color dotColor;
    if (_isDisabled) {
      // Muted gray inner circle with transparency
      dotColor = colors.backgroundOverlay.withValues(alpha: 0.4);
    } else if (_isFocused) {
      dotColor = colors.backgroundBrand;
    } else if (_isHovering) {
      dotColor = colors.backgroundBrandHover;
    } else {
      dotColor = colors.backgroundBrand;
    }

    return MouseRegion(
      cursor: _isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: _isDisabled ? null : (_) => setState(() => _isHovering = true),
      onExit: _isDisabled ? null : (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        // Keep the full (square) bounds tappable, matching the previous
        // CustomPaint hit area.
        behavior: HitTestBehavior.opaque,
        onTapDown: _isDisabled
            ? null
            : (_) => setState(() => _isFocused = true),
        onTapUp: _isDisabled
            ? null
            : (_) {
                setState(() => _isFocused = false);
                widget.onChanged?.call(widget.value);
              },
        onTapCancel: _isDisabled
            ? null
            : () => setState(() => _isFocused = false),
        child: AnimatedContainer(
          duration: motion.resolve(context, motion.fast),
          curve: motion.move,
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Brand focus ring at the box edge (24px when focused/pressed).
              Positioned.fill(
                child: AnimatedContainer(
                  duration: motion.resolve(context, motion.pressed),
                  curve: motion.enter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isFocused && !_isDisabled
                          ? colors.backgroundBrand
                          : Colors.transparent,
                      width: borderWidths.w1,
                    ),
                  ),
                ),
              ),
              // Main ring (20px diameter) + disabled background fill.
              AnimatedContainer(
                duration: motion.resolve(context, motion.hover),
                curve: motion.enter,
                width: iconSizes.s, // 20px
                height: iconSizes.s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isDisabled
                      ? colors.backgroundDisabled
                      : Colors.transparent,
                  border: Border.all(color: ringColor, width: borderWidths.w1),
                ),
              ),
              // Inner filled dot (12px diameter) — scales in on selection.
              AnimatedScale(
                scale: _isSelected ? 1.0 : 0.0,
                duration: motion.resolve(context, motion.fast),
                curve: motion.enter,
                child: AnimatedContainer(
                  duration: motion.resolve(context, motion.hover),
                  curve: motion.enter,
                  width: 12.0, // 12px diameter
                  height: 12.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
