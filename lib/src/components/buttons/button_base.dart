// lib/src/components/buttons/button_base.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'button_layout.dart';
import 'button_press_scale.dart';

/// Shared styling engine for all Nasiko buttons.
///
/// Each public button class (PrimaryButton, SecondaryIconButton, ...) is a
/// thin facade that forwards its constructor arguments into one of the three
/// builders below ([buildNasikoLabelButton], [buildNasikoIconButton],
/// [buildNasikoTextButton]). The per-variant state -> color decisions live in
/// the [NasikoButtonSpec] resolvers in this file and nowhere else.
///
/// Internal to the package: intentionally not exported from `buttons.dart`
/// (same policy as `button_layout.dart` and `button_press_scale.dart`).

/// Raw palette red700, historically hardcoded by the destructive variants
/// (hover foreground/border). Intentionally NOT a semantic token:
/// `colors.foregroundError` is red600 in light but red400 in dark, while the
/// design uses this exact value in both themes. Centralized here so the hex
/// exists in exactly one place.
const Color kDestructiveHoverRed700 = Color(0xFFB91C1C);

/// Raw palette red600, historically hardcoded as the hover border of
/// [DestructiveSecondaryButton]. Matches light-theme `foregroundError` by
/// value only (dark theme differs), so it stays a named constant rather than
/// a token. See [kDestructiveHoverRed700].
const Color kDestructiveHoverRed600 = Color(0xFFDC2626);

/// The visual variant of a Nasiko button.
///
/// Library-internal: combined with the button kind (label / icon / text) it
/// selects the state-color matrix for one concrete button class.
enum NasikoButtonVariant {
  primary,
  secondary,
  tertiary,
  destructive,
  destructiveSecondary,
  link,
}

/// The resolved state -> visual matrix for one concrete button.
///
/// Only carries what actually differs between variants; the shared chrome
/// (padding, fixed size, elevation 0, transparent shadow/overlay,
/// `animationDuration: context.motion.fast`, tap target) is applied by
/// [buildNasikoButtonStyle].
@immutable
class NasikoButtonSpec {
  const NasikoButtonSpec({
    required this.foregroundColor,
    this.backgroundColor,
    this.side,
    this.borderRadius,
    this.textStyle,
  });

  /// Per-state text/icon color.
  final WidgetStateProperty<Color> foregroundColor;

  /// Per-state fill. Null for text-like buttons that never paint one.
  final WidgetStateProperty<Color>? backgroundColor;

  /// Per-state border. A null resolved value keeps the shape's own side
  /// (i.e. no border) — `ButtonStyleButton` merges this into the shape via
  /// `shape.copyWith(side: side)`, exactly like the previous per-file
  /// resolvers that built the side into the shape directly.
  final WidgetStateProperty<BorderSide?>? side;

  /// Corner radius. Null means "do not set a shape at all" (secondary text /
  /// link buttons never did).
  final double? borderRadius;

  /// Per-state text style. Null for icon buttons.
  final WidgetStateProperty<TextStyle>? textStyle;
}

/// Builds the full [ButtonStyle] for a Nasiko button: shared chrome plus the
/// per-variant [spec].
ButtonStyle buildNasikoButtonStyle(
  BuildContext context, {
  required NasikoButtonLayout layout,
  required NasikoButtonSpec spec,
  bool iconButton = false,
}) {
  return ButtonStyle(
    padding: WidgetStateProperty.all(layout.padding),
    minimumSize: iconButton ? WidgetStateProperty.all(Size.zero) : null,
    fixedSize: WidgetStateProperty.all(
      iconButton
          ? Size.square(layout.minHeight)
          : Size.fromHeight(layout.minHeight),
    ),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    animationDuration: context.motion.fast,
    textStyle: spec.textStyle,
    elevation: WidgetStateProperty.all(0),
    shadowColor: WidgetStateProperty.all(Colors.transparent),
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    backgroundColor: spec.backgroundColor,
    foregroundColor: spec.foregroundColor,
    side: spec.side,
    shape: spec.borderRadius == null
        ? null
        : WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(spec.borderRadius!),
            ),
          ),
  );
}

// ---------------------------------------------------------------------------
// Shared widget builders (one per button kind)
// ---------------------------------------------------------------------------

/// Builds a label button (text label with optional leading/trailing icons):
/// PrimaryButton, SecondaryButton, TertiaryButton, DestructiveButton,
/// DestructiveSecondaryButton, DestructiveTextButton (`quiet: true`).
Widget buildNasikoLabelButton(
  BuildContext context, {
  required NasikoButtonVariant variant,
  required VoidCallback? onPressed,
  required String label,
  HugeIconsType? leadingIcon,
  HugeIconsType? trailingIcon,
  NasikoButtonSize size = NasikoButtonSize.large,
  bool quiet = false,
}) {
  final isQuiet = quiet || variant == NasikoButtonVariant.tertiary;
  final layout = isQuiet
      ? quietButtonLayout(context, size)
      : standardButtonLayout(context, size);
  final spec = _labelSpec(context, variant, size: size, quiet: isQuiet);
  final style = buildNasikoButtonStyle(context, layout: layout, spec: spec);
  final child = _labelChild(layout, label, leadingIcon, trailingIcon);

  // Primary and (standard) destructive were always ElevatedButtons; every
  // other label variant an OutlinedButton. Kept as-is so unset ButtonStyle
  // defaults stay identical.
  final Widget button = switch (variant) {
    NasikoButtonVariant.primary => ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    ),
    NasikoButtonVariant.destructive when !isQuiet => ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    ),
    _ => OutlinedButton(onPressed: onPressed, style: style, child: child),
  };

  return ButtonPressScale(enabled: onPressed != null, child: button);
}

/// Builds an icon-only button: PrimaryIconButton, SecondaryIconButton,
/// TertiaryIconButton, DestructiveIconButton.
Widget buildNasikoIconButton(
  BuildContext context, {
  required NasikoButtonVariant variant,
  required VoidCallback? onPressed,
  required HugeIconsType icon,
  NasikoButtonSize size = NasikoButtonSize.large,
  bool? isLoading,
  WidgetStatesController? statesController,
}) {
  final layout = iconButtonLayout(context, size);
  final spec = _iconSpec(context, variant);
  final style = buildNasikoButtonStyle(
    context,
    layout: layout,
    spec: spec,
    iconButton: true,
  );

  // Pre-existing split, preserved byte-for-byte: secondary/tertiary size the
  // icon via IconButton.iconSize (IconTheme), primary/destructive pass the
  // size to HugeIcon directly. Not normalized — HugeIcon may not read
  // IconTheme, so unifying could change rendered icon sizes.
  final sizeViaIconButton =
      variant == NasikoButtonVariant.secondary ||
      variant == NasikoButtonVariant.tertiary;

  final Widget iconChild = (isLoading ?? false)
      ? SizedBox(
          width: layout.iconSize,
          height: layout.iconSize,
          child: CircularProgressIndicator(strokeWidth: context.borderWidth.w2),
        )
      : sizeViaIconButton
      ? HugeIcon(icon: icon)
      : HugeIcon(icon: icon, size: layout.iconSize);

  final Widget button = IconButton(
    onPressed: onPressed,
    style: style,
    statesController: statesController,
    icon: iconChild,
    iconSize: sizeViaIconButton ? layout.iconSize : null,
  );

  return ButtonPressScale(enabled: onPressed != null, child: button);
}

/// Builds a text-only button (TextButton based): PrimaryTextButton,
/// SecondaryTextButton, LinkButton.
Widget buildNasikoTextButton(
  BuildContext context, {
  required NasikoButtonVariant variant,
  required VoidCallback? onPressed,
  required String label,
  HugeIconsType? leadingIcon,
  HugeIconsType? trailingIcon,
  Color? foregroundColor,
}) {
  final layout = variant == NasikoButtonVariant.link
      ? linkButtonLayout(context)
      : textButtonLayout(context);
  final spec = _textSpec(context, variant, foregroundColor: foregroundColor);
  final style = buildNasikoButtonStyle(context, layout: layout, spec: spec);

  final Widget button = TextButton(
    onPressed: onPressed,
    style: style,
    child: _labelChild(layout, label, leadingIcon, trailingIcon),
  );

  return ButtonPressScale(enabled: onPressed != null, child: button);
}

/// The shared `Row(icon? label icon?)` child used by label and text buttons.
Widget _labelChild(
  NasikoButtonLayout layout,
  String label,
  HugeIconsType? leadingIcon,
  HugeIconsType? trailingIcon,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Leading Icon
      if (leadingIcon != null) ...[
        HugeIcon(icon: leadingIcon, size: layout.iconSize),
        SizedBox(width: layout.iconSpacing),
      ],

      // Label
      Text(label),

      // Trailing Icon
      if (trailingIcon != null) ...[
        SizedBox(width: layout.iconSpacing),
        HugeIcon(icon: trailingIcon, size: layout.iconSize),
      ],
    ],
  );
}

// ---------------------------------------------------------------------------
// Per-variant state-color matrices
// ---------------------------------------------------------------------------

TextStyle _sizedTextStyle(BuildContext context, NasikoButtonSize size) {
  final typography = context.typography;
  return switch (size) {
    NasikoButtonSize.large => typography.buttonPrimary,
    NasikoButtonSize.medium ||
    NasikoButtonSize.small => typography.buttonSecondary,
  };
}

NasikoButtonSpec _labelSpec(
  BuildContext context,
  NasikoButtonVariant variant, {
  required NasikoButtonSize size,
  required bool quiet,
}) {
  final colors = context.colors;
  final typography = context.typography;
  final radii = context.radius;
  final borderWidths = context.borderWidth;

  // Standard label buttons round r10 when large, r8 otherwise; quiet label
  // buttons (tertiary, destructive text) always use r8.
  final sizedRadius = size == NasikoButtonSize.large ? radii.r10 : radii.r8;

  switch (variant) {
    case NasikoButtonVariant.primary:
      return NasikoButtonSpec(
        textStyle: WidgetStateProperty.all(_sizedTextStyle(context, size)),
        borderRadius: sizedRadius,
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.backgroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.foregroundConstantBlackSecondary;
          }
          if (states.contains(WidgetState.pressed)) {
            return colors.foregroundPrimary;
          }
          // Default state
          return colors.foregroundPrimary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          // Default, Hover, Focus, Pressed
          return colors.foregroundOnAction;
        }),
        // Focus ring only; every other state has no border.
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colors.borderSecondary,
              width: borderWidths.w2,
              strokeAlign: BorderSide.strokeAlignOutside,
            );
          }
          return null;
        }),
      );

    case NasikoButtonVariant.secondary:
      return NasikoButtonSpec(
        textStyle: WidgetStateProperty.all(switch (size) {
          NasikoButtonSize.large => typography.buttonPrimaryBold,
          NasikoButtonSize.medium ||
          NasikoButtonSize.small => typography.buttonSecondaryBold,
        }),
        borderRadius: sizedRadius,
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.backgroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.backgroundSecondaryBrandHover;
          }
          // Default, Focused, Pressed states
          return colors.backgroundSecondaryBrand;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          // Default, Hover, Focus, Pressed
          return colors.foregroundPrimary;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colors.borderDisabled,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.focused)) {
            // Focused state with border outside and 2px gap
            return BorderSide(
              color: colors.borderSecondary,
              width: borderWidths.w2,
              strokeAlign: BorderSide.strokeAlignOutside,
            );
          } else if (states.contains(WidgetState.hovered)) {
            return BorderSide(
              color: colors.borderHover,
              width: borderWidths.w1,
            );
          }
          // Default state
          return BorderSide(
            color: colors.borderSecondary,
            width: borderWidths.w1,
          );
        }),
      );

    case NasikoButtonVariant.tertiary:
      return NasikoButtonSpec(
        textStyle: WidgetStateProperty.all(_sizedTextStyle(context, size)),
        borderRadius: radii.r8,
        backgroundColor: WidgetStateProperty.all(colors.backgroundBase),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.foregroundIconHover;
          }
          // Default, Focus, Pressed
          return colors.foregroundPrimary;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colors.borderDisabled,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.hovered)) {
            return BorderSide(
              color: colors.borderSecondary,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colors.borderSecondary,
              width: borderWidths.w2,
            );
          }
          // Default state
          return BorderSide(
            color: colors.borderPrimary,
            width: borderWidths.w1,
          );
        }),
      );

    case NasikoButtonVariant.destructive when !quiet:
      return NasikoButtonSpec(
        textStyle: WidgetStateProperty.all(_sizedTextStyle(context, size)),
        borderRadius: sizedRadius,
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.backgroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.foregroundError; // red700 for hover
          }
          if (states.contains(WidgetState.focused)) {
            return colors.backgroundError; // red600
          }
          // Default state
          return colors.backgroundBase;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.foregroundOnAction;
          }
          // Default, Focus, Pressed
          return colors.foregroundError;
        }),
        // Original resolver: default w1 outside, disabled none, focused w2
        // outside — with focused taking precedence over disabled.
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colors.borderError,
              width: borderWidths.w2,
              strokeAlign: BorderSide.strokeAlignOutside,
            );
          }
          if (states.contains(WidgetState.disabled)) {
            return BorderSide.none;
          }
          return BorderSide(
            color: colors.borderError,
            width: borderWidths.w1,
            strokeAlign: BorderSide.strokeAlignOutside,
          );
        }),
      );

    // DestructiveTextButton: the quiet destructive label variant.
    case NasikoButtonVariant.destructive:
      return NasikoButtonSpec(
        textStyle: WidgetStateProperty.all(_sizedTextStyle(context, size)),
        borderRadius: radii.r8,
        backgroundColor: WidgetStateProperty.all(colors.backgroundBase),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return kDestructiveHoverRed700;
          }
          // Default, Focus, Pressed
          return colors.foregroundError;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colors.borderDisabled,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.hovered)) {
            return BorderSide(
              color: kDestructiveHoverRed700,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colors.borderError,
              width: borderWidths.w2,
            );
          }
          // Default state
          return BorderSide(color: colors.borderError, width: borderWidths.w1);
        }),
      );

    case NasikoButtonVariant.destructiveSecondary:
      return NasikoButtonSpec(
        textStyle: WidgetStateProperty.all(_sizedTextStyle(context, size)),
        borderRadius: sizedRadius,
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.backgroundDisabled;
          }
          // Default, Hover, Focused, Pressed states
          return colors.backgroundError;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          // Default, Hover, Focus, Pressed
          return colors.foregroundError;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colors.borderDisabled,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.focused)) {
            // Focused state with border outside and 2px gap
            return BorderSide(
              color: colors.borderError,
              width: borderWidths.w2,
              strokeAlign: BorderSide.strokeAlignOutside,
            );
          } else if (states.contains(WidgetState.hovered)) {
            return BorderSide(
              color: kDestructiveHoverRed600,
              width: borderWidths.w1,
            );
          }
          // Default state
          return BorderSide(color: colors.borderError, width: borderWidths.w1);
        }),
      );

    case NasikoButtonVariant.link:
      throw UnsupportedError('link is not a label button variant');
  }
}

NasikoButtonSpec _iconSpec(BuildContext context, NasikoButtonVariant variant) {
  final colors = context.colors;
  final radii = context.radius;
  final borderWidths = context.borderWidth;

  switch (variant) {
    case NasikoButtonVariant.primary:
      return NasikoButtonSpec(
        borderRadius: radii.r8,
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.backgroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.backgroundSecondaryBrandHover;
          }
          return colors.backgroundSecondaryBrand;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          return colors.foregroundIconPrimary;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colors.borderDisabled,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.hovered)) {
            return BorderSide(
              color: colors.borderHover,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colors.borderSecondary,
              width: borderWidths.w2,
            );
          }
          return BorderSide(
            color: colors.borderSecondary,
            width: borderWidths.w1,
          );
        }),
      );

    case NasikoButtonVariant.secondary:
      return NasikoButtonSpec(
        borderRadius: radii.r10,
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.backgroundDisabled;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          if (states.contains(WidgetState.pressed)) {
            return colors.foregroundIconHover;
          }
          return colors.foregroundIconPrimary;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colors.borderDisabled,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.hovered)) {
            return BorderSide(
              color: colors.borderHover,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colors.borderSecondary,
              width: borderWidths.w2,
            );
          }
          return BorderSide(
            color: colors.borderPrimary,
            width: borderWidths.w1,
          );
        }),
      );

    case NasikoButtonVariant.tertiary:
      return NasikoButtonSpec(
        borderRadius: radii.r8,
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.backgroundDisabled;
          }
          if (states.contains(WidgetState.pressed)) {
            return colors.backgroundSecondaryBrand;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          if (states.contains(WidgetState.pressed)) {
            return colors.foregroundIconSecondary;
          }
          return colors.foregroundIconTertiary;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colors.borderDisabled,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.pressed)) {
            return BorderSide(
              color: Colors.transparent,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colors.borderPrimary,
              width: borderWidths.w1,
            );
          }
          return BorderSide(color: Colors.transparent, width: borderWidths.w1);
        }),
      );

    case NasikoButtonVariant.destructive:
      return NasikoButtonSpec(
        borderRadius: radii.r10,
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            // Pre-existing: uses backgroundError (not backgroundDisabled like
            // the icon siblings). Preserved — changing it would be a visual
            // change to disabled destructive icon buttons.
            return colors.backgroundError;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          // Default, Hover, Pressed, Focus (original had a hover/pressed
          // branch returning this same value).
          return colors.foregroundError;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colors.borderDisabled,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.hovered)) {
            return BorderSide(
              color: kDestructiveHoverRed700,
              width: borderWidths.w1,
            );
          } else if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colors.borderError,
              width: borderWidths.w2,
            );
          }
          return BorderSide(color: colors.borderError, width: borderWidths.w1);
        }),
      );

    case NasikoButtonVariant.destructiveSecondary:
    case NasikoButtonVariant.link:
      throw UnsupportedError('$variant is not an icon button variant');
  }
}

NasikoButtonSpec _textSpec(
  BuildContext context,
  NasikoButtonVariant variant, {
  Color? foregroundColor,
}) {
  final colors = context.colors;
  final typography = context.typography;
  final radii = context.radius;
  final borderWidths = context.borderWidth;

  switch (variant) {
    case NasikoButtonVariant.primary:
      return NasikoButtonSpec(
        textStyle: WidgetStateProperty.all(typography.buttonSecondary),
        borderRadius: radii.r8,
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          return colors.foregroundBrand;
        }),
        // Brand outline on hover/focus only.
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colors.foregroundBrand,
              width: borderWidths.w1,
            );
          }
          return null;
        }),
      );

    case NasikoButtonVariant.secondary:
      return NasikoButtonSpec(
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return foregroundColor ??
                colors.foregroundBrand; // Darker brand color (yellow/800)
          }
          if (states.contains(WidgetState.focused)) {
            return foregroundColor ?? colors.foregroundIconHover;
          }
          return foregroundColor ??
              colors.foregroundPrimary; // Default brand color (yellow/600)
        }),
        // Styles the text *and* applies the underline.
        textStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final baseStyle = typography.bodySecondary;

          if (states.contains(WidgetState.disabled)) {
            return baseStyle.copyWith(color: colors.foregroundDisabled);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return baseStyle.copyWith(
              color: colors.foregroundBrandHover,
              decoration: TextDecoration.underline,
              decorationColor: colors.foregroundBrandHover,
              decorationThickness: borderWidths.w1,
            );
          }
          // Default state
          return baseStyle.copyWith(
            color: colors.foregroundBrand,
            decoration: TextDecoration.none,
          );
        }),
      );

    case NasikoButtonVariant.link:
      return NasikoButtonSpec(
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.foregroundDisabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.foregroundBrand; // Darker brand color (yellow/800)
          }
          if (states.contains(WidgetState.focused)) {
            return colors.foregroundIconHover;
          }
          return colors.foregroundPrimary;
        }),
        // linkPrimary carries the underline; hover/focus recolors it.
        textStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final baseStyle = typography.linkPrimary;

          if (states.contains(WidgetState.disabled)) {
            return baseStyle.copyWith(color: colors.foregroundDisabled);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return baseStyle.copyWith(
              color: colors.foregroundBrandHover,
              decorationColor: colors.foregroundBrandHover,
              decorationThickness: borderWidths.w1,
            );
          }
          // Default state
          return baseStyle.copyWith(color: colors.foregroundBrand);
        }),
      );

    case NasikoButtonVariant.tertiary:
    case NasikoButtonVariant.destructive:
    case NasikoButtonVariant.destructiveSecondary:
      throw UnsupportedError('$variant is not a text button variant');
  }
}
