// lib/src/components/forms/nasiko_switch.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';
import 'switch_size.dart';

/// A custom-styled switch component based on the Nasiko design.
class NasikoSwitch extends StatelessWidget {
  const NasikoSwitch({
    super.key,
    required this.value,
    this.size = NasikoSwitchSize.large,
    required this.onChanged,
  });

  /// Whether this switch is currently on or off.
  final bool value;
  final NasikoSwitchSize size;

  /// Called when the user toggles the switch.
  /// If null, the switch is disabled.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderWidths = context.borderWidth;
    final spacing = context.spacing;
    // Define the custom style for the Switch
    final materialStateProperty = WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      // --- Disabled State (Overrides all other states) ---
      if (states.contains(WidgetState.disabled)) {
        // Disabled Track color (neutral/200 or similar subtle background)
        if (value) {
          return colors.backgroundDisabled; // Disabled ON state
        }
        return colors.backgroundDisabled; // Disabled OFF state
      }

      // --- Active State (Switch is ON) ---
      if (value) {
        // Active Track color (Brand color)
        return colors.backgroundBrand;
      }

      // --- Inactive State (Switch is OFF) ---
      // Inactive Track color (e.g., backgroundSurfaceSubtle)
      return colors.backgroundSurfaceSubtle;
    });

    // Define the custom thumb color (the circle)
    final thumbColorProperty = WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      // --- Disabled State ---
      if (states.contains(WidgetState.disabled)) {
        return colors.foregroundDisabled;
      }
      // --- Active/Inactive Thumb Color (Constant White) ---
      return colors.foregroundConstantWhite;
    });

    return SizedBox(
      height: size == NasikoSwitchSize.small ? spacing.s20 : spacing.s24,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Switch.adaptive(
          value: value,
          onChanged: onChanged,

          // Use the custom color properties defined above
          trackColor: materialStateProperty,
          thumbColor: thumbColorProperty,

          // Apply a rounded shape and a subtle border/outline when unchecked
          trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.borderDisabled;
            }
            // Show primary border when unchecked
            if (!value) {
              return colors.borderPrimary;
            }
            // No border when checked, let the brand color handle the track
            return Colors.transparent;
          }),
          trackOutlineWidth: WidgetStateProperty.all(borderWidths.w1),

          // The default Flutter thumb radius and track size look appropriate
          // for the design, which has a 2:1 ratio (track width:height)
        ),
      ),
    );
  }
}
