import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

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

    // Size expands to 24px when focused, otherwise stays at 20px
    final size = _isFocused ? 24.0 : 20.0;

    return MouseRegion(
      cursor: _isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: _isDisabled ? null : (_) => setState(() => _isHovering = true),
      onExit: _isDisabled ? null : (_) => setState(() => _isHovering = false),
      child: GestureDetector(
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
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RadioPainter(
              isSelected: _isSelected,
              isDisabled: _isDisabled,
              isHovering: _isHovering,
              isFocused: _isFocused,
              colors: colors,
              borderWidths: borderWidths,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering the radio button with state-based styling.
class _RadioPainter extends CustomPainter {
  const _RadioPainter({
    required this.isSelected,
    required this.isDisabled,
    required this.isHovering,
    required this.isFocused,
    required this.colors,
    required this.borderWidths,
  });

  /// Whether the radio button is currently selected.
  final bool isSelected;

  /// Whether the radio button is disabled.
  final bool isDisabled;

  /// Whether the mouse is hovering over the radio button.
  final bool isHovering;

  /// Whether the radio button is currently focused/pressed.
  final bool isFocused;

  /// Color theme for the radio button.
  final NasikoColorTheme colors;

  /// Border widths for drawing strokes.
  final NasikoBorderWidthTheme borderWidths;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = 10.0; // 20px diameter
    final innerRadius = 6.0; // 12px diameter (half of 24px focused size)

    // Determine colors based on current state (priority order: disabled > focused > hovering > default)
    Color outerRingColor;
    Color? innerCircleColor;

    if (isDisabled) {
      // Disabled: Light gray border
      outerRingColor = colors.borderDisabled;
      if (isSelected) {
        // Muted gray inner circle with transparency
        innerCircleColor = colors.backgroundOverlay.withValues(alpha: 0.4);
      }
    } else if (isFocused) {
      // Focused: Light gray 20px ring, brand color 24px ring (drawn separately)
      outerRingColor = colors.borderPrimary;
      if (isSelected) {
        innerCircleColor = colors.backgroundBrand;
      }
    } else if (isHovering) {
      // Hover: Dark brand color outer ring
      outerRingColor = colors.backgroundBrandHover;
      if (isSelected) {
        innerCircleColor = colors.backgroundBrandHover;
      }
    } else {
      // Default: Light gray outer ring
      outerRingColor = colors.borderPrimary;
      if (isSelected) {
        innerCircleColor = colors.backgroundBrand;
      }
    }

    // Step 1: Draw filled background for disabled state
    if (isDisabled) {
      final bgPaint = Paint()
        ..color = colors.backgroundDisabled
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, baseRadius, bgPaint);
    }

    // Step 2: Draw outer ring for focused state (24px diameter, brand color)
    if (isFocused) {
      final outerPaint = Paint()
        ..color = colors.backgroundBrand
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidths.w1;
      canvas.drawCircle(center, 12.0 - borderWidths.w1 / 2, outerPaint);
    }

    // Step 3: Draw main ring (20px diameter, color varies by state)
    final mainPaint = Paint()
      ..color = outerRingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidths.w1;
    canvas.drawCircle(center, baseRadius - borderWidths.w1 / 2, mainPaint);

    // Step 4: Draw inner filled circle when selected (12px diameter)
    if (innerCircleColor != null) {
      final innerPaint = Paint()
        ..color = innerCircleColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, innerRadius, innerPaint);
    }
  }

  @override
  bool shouldRepaint(_RadioPainter oldDelegate) {
    // Repaint when any state changes
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.isDisabled != isDisabled ||
        oldDelegate.isHovering != isHovering ||
        oldDelegate.isFocused != isFocused;
  }
}
