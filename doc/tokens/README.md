# Design Tokens

Design tokens are the foundational values that define the visual design of the Nasiko UI system. They ensure consistency across all components and enable easy theming.

## Table of Contents

- [Colors](#colors)
- [Typography](#typography)
- [Spacing](#spacing)
- [Border Radius](#border-radius)
- [Border Width](#border-width)
- [Icon Sizes](#icon-sizes)

## Accessing Tokens

All tokens are available via BuildContext extensions:

\`\`\`dart
// Colors
final colors = context.colors;

// Typography
final typography = context.typography;

// Spacing
final spacing = context.spacing;

// Border Radius
final radius = context.radius;

// Border Width
final borderWidth = context.borderWidth;

// Icon Sizes
final iconSize = context.iconSize;
\`\`\`

---

## Colors

The color system is based on semantic naming for backgrounds, foregrounds, and borders.

### Usage

\`\`\`dart
Container(
  color: context.colors.backgroundBrand,
  child: Text(
    'Hello',
    style: TextStyle(color: context.colors.foregroundOnAction),
  ),
)
\`\`\`

### Background Colors

| Token | Description | Light Theme |
|-------|-------------|-------------|
| `backgroundBase` | Base background | White |
| `backgroundGroup` | Grouped content background | neutral/50 |
| `backgroundSurface` | Surface background | neutral/100 |
| `backgroundSurfaceHover` | Surface on hover | neutral/200 |
| `backgroundSurfaceActive` | Surface when active | neutral/300 |
| `backgroundSurfaceSubtle` | Subtle surface | neutral/500 |
| `backgroundOverlay` | Overlay/modal backdrop | neutral/500 |
| `backgroundDisabled` | Disabled state | neutral/200 |
| `backgroundBrand` | Primary brand | yellow/600 |
| `backgroundBrandHover` | Brand on hover | yellow/800 |
| `backgroundBrandActive` | Brand when active | yellow/500 |
| `backgroundBrandSubtle` | Subtle brand | yellow/200 |
| `backgroundSecondaryBrand` | Secondary brand | yellow/100 |
| `backgroundSecondaryBrandHover` | Secondary brand hover | yellow/200 |
| `backgroundSecondaryBrandActive` | Secondary brand active | yellow/100 |
| `backgroundSuccess` | Success feedback | green/100 |
| `backgroundWarning` | Warning feedback | orange/100 |
| `backgroundError` | Error feedback | red/100 |
| `backgroundInformation` | Info feedback | blue/100 |

### Foreground Colors

| Token | Description | Light Theme |
|-------|-------------|-------------|
| `foregroundPrimary` | Primary text | neutral/700 |
| `foregroundSecondary` | Secondary text | neutral/500 |
| `foregroundDisabled` | Disabled text | neutral/300 |
| `foregroundOnAction` | Text on action buttons | White |
| `foregroundIconPrimary` | Primary icons | neutral/700 |
| `foregroundIconSecondary` | Secondary icons | yellow/600 |
| `foregroundIconHover` | Icons on hover | yellow/800 |
| `foregroundConstantWhite` | Always white | White |
| `foregroundConstantBlack` | Always black | Black |
| `foregroundBrand` | Brand text | yellow/600 |
| `foregroundBrandHover` | Brand text hover | yellow/800 |
| `foregroundBrandLink` | Brand links | yellow/600 |
| `foregroundBrandHighlight` | Brand highlight | yellow/500 |
| `foregroundSuccess` | Success text | green/600 |
| `foregroundWarning` | Warning text | orange/600 |
| `foregroundError` | Error text | red/600 |
| `foregroundInformation` | Info text | blue/600 |

### Border Colors

| Token | Description | Light Theme |
|-------|-------------|-------------|
| `borderPrimary` | Default border | neutral/300 |
| `borderSecondary` | Brand border | yellow/600 |
| `borderHover` | Hover border | yellow/800 |
| `borderSuccess` | Success border | green/300 |
| `borderError` | Error border | red/300 |
| `borderWarning` | Warning border | orange/300 |
| `borderInformation` | Info border | blue/300 |
| `borderDisabled` | Disabled border | neutral/200 |

---

## Typography

The typography system uses two font families:
- **Chivo Mono** - For titles and buttons
- **Inter** - For body text, links, captions

### Usage

\`\`\`dart
Text(
  'Welcome',
  style: context.typography.titlePrimary,
)
\`\`\`

### Text Styles

| Token | Font | Size | Weight | Line Height |
|-------|------|------|--------|-------------|
| `titlePrimary` | Chivo Mono | 40px | Medium (500) | 48px |
| `titleSecondary` | Chivo Mono | 32px | Medium (500) | 38px |
| `buttonPrimary` | Chivo Mono | 20px | Medium (500) | 24px |
| `buttonSecondary` | Chivo Mono | 18px | Regular (400) | 20px |
| `bodyPrimary` | Inter | 20px | Regular (400) | 24px |
| `bodyPrimaryBold` | Inter | 20px | Medium (500) | 24px |
| `bodySecondary` | Inter | 16px | Regular (400) | 20px |
| `bodySecondaryBold` | Inter | 16px | Medium (500) | 20px |
| `bodyTertiary` | Inter | 12px | Regular (400) | 16px |
| `bodyTertiaryBold` | Inter | 12px | Semi-Bold (600) | 16px |
| `linkPrimary` | Inter | 16px | Regular (400) | 20px |
| `caption` | Inter | 12px | Regular Italic | 16px |
| `code` | Inter | 16px | Regular (400) | 20px |

---

## Spacing

A consistent spacing scale for margins, padding, and gaps.

### Usage

\`\`\`dart
Padding(
  padding: EdgeInsets.all(context.spacing.s16),
  child: Row(
    children: [
      Text('Item 1'),
      SizedBox(width: context.spacing.s8),
      Text('Item 2'),
    ],
  ),
)
\`\`\`

### Scale

| Token | Value |
|-------|-------|
| `s0` | 0px |
| `s2` | 2px |
| `s4` | 4px |
| `s8` | 8px |
| `s12` | 12px |
| `s16` | 16px |
| `s20` | 20px |
| `s24` | 24px |
| `s28` | 28px |
| `s36` | 36px |
| `s48` | 48px |
| `s64` | 64px |
| `s80` | 80px |

---

## Border Radius

Consistent corner rounding values.

### Usage

\`\`\`dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(context.radius.r8),
  ),
)
\`\`\`

### Scale

| Token | Value |
|-------|-------|
| `r0` | 0px |
| `r4` | 4px |
| `r6` | 6px |
| `r8` | 8px |
| `r10` | 10px |
| `r12` | 12px |
| `r16` | 16px |
| `r40` | 40px |

---

## Border Width

Standard border thickness values.

### Usage

\`\`\`dart
Container(
  decoration: BoxDecoration(
    border: Border.all(
      width: context.borderWidth.w1,
      color: context.colors.borderPrimary,
    ),
  ),
)
\`\`\`

### Scale

| Token | Value |
|-------|-------|
| `w0` | 0px |
| `w1` | 1px |
| `w2` | 2px |
| `w4` | 4px |
| `w8` | 8px |

---

## Icon Sizes

Standard icon dimensions.

### Usage

\`\`\`dart
Icon(
  Icons.settings,
  size: context.iconSize.m,
)
\`\`\`

### Scale

| Token | Value |
|-------|-------|
| `xs` | 16px |
| `s` | 20px |
| `m` | 24px |
| `l` | 28px |
