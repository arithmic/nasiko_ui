# Nasiko Design Tokens Documentation

This document provides detailed reference for all design tokens available in the Nasiko UI design system.

## Color Tokens

### Background Colors

**Default Backgrounds:**

- `backgroundBase` - Main app background color
- `backgroundGroup` - Secondary background for grouped content
- `backgroundSurface` - Surface-level background (cards, containers)
- `backgroundSurfaceHover` - Hover state for surfaces
- `backgroundSurfaceActive` - Active/pressed state for surfaces
- `backgroundSurfaceSubtle` - Subtle background variation
- `backgroundOverlay` - Overlay surfaces (modals, dialogs)
- `backgroundDisabled` - Disabled state backgrounds

**Brand Backgrounds:**

- `backgroundBrand` - Primary brand color background
- `backgroundBrandHover` - Brand background on hover
- `backgroundBrandActive` - Brand background active state
- `backgroundBrandSubtle` - Subtle brand background

**Secondary Brand:**

- `backgroundSecondaryBrand` - Secondary brand color
- `backgroundSecondaryBrandHover` - Secondary brand hover
- `backgroundSecondaryBrandActive` - Secondary brand active

**Feedback Backgrounds:**

- `backgroundSuccess` - Success state background
- `backgroundWarning` - Warning state background
- `backgroundError` - Error state background
- `backgroundSuccessSubtle` / `backgroundWarningSubtle` / `backgroundErrorSubtle` - Extra-light feedback washes for large tinted areas
- `backgroundInformation` - Information state background (fixed blue — never brand-derived)
- `backgroundInformationOverlay` - Inverse overlay surface (tooltips): near-black in light mode, light sand in dark mode

### Foreground Colors (Text & Icons)

**Default Text:**

- `foregroundPrimary` - Primary text color (warm ink)
- `foregroundSecondary` - Secondary text color (less prominent)
- `foregroundDisabled` - Disabled text color
- `foregroundOnAction` - Text on the inverse action fill (the primary button's near-black/near-white fill)
- `foregroundOnBrand` - Text/icons on brand fills (checkmarks, selected days, brand avatars); ink on light-hue palettes, white on dark-hue palettes

**Icons:**

- `foregroundIconPrimary` - Primary icon color
- `foregroundIconSecondary` - Secondary icon color
- `foregroundIconHover` - Icon hover state

**Constants (Non-themeable — identical in light and dark):**

- `foregroundConstantWhite` - Pure white (0xFFFFFFFF)
- `foregroundConstantBlack` - Warm ink near-black (0xFF26211C)
- `foregroundConstantBlackSecondary` - sand800 (0xFF3A3430)

**Brand Text:**

- `foregroundBrand` - Brand text color
- `foregroundBrandHover` - Brand text on hover
- `foregroundBrandLink` - Brand link text
- `foregroundBrandHighlight` - Brand highlight text

**Feedback Text:**

- `foregroundSuccess` - Success text color (AA on `backgroundSuccess`)
- `foregroundWarning` - Warning text color (AA on `backgroundWarning`)
- `foregroundError` - Error text color (AA on `backgroundError`)
- `foregroundErrorHover` - Hover shade for quiet destructive actions
- `foregroundInformation` - Information text color (fixed blue)
- `foregroundInformationOverlay` - Text on the inverse overlay surface

### Border Colors

- `borderPrimary` - Decorative hairline border
- `borderInput` - Functional border for form controls (the border IS the affordance)
- `borderSecondary` - Brand accent border
- `borderHover` - Border on hover states
- `borderFocus` - Keyboard focus ring (≥3:1 against the page background)
- `borderSuccess` - Success state border
- `borderError` - Error state border
- `borderWarning` - Warning state border
- `borderInformation` - Information state border
- `borderDisabled` - Disabled state border

## Elevation Tokens

Shadows are tokenized (`context.elevation`) — components never hand-roll `BoxShadow`s:

| Token | Use |
|-------|-----|
| `low` | Resting cards, banners |
| `overlay` | Menus, popovers, dropdowns, hover cards |
| `modal` | Dialogs, sheets (above the scrim) |

Light theme shadows are warm-tinted (sand800-based, not pure black); the dark theme carries elevation via the surface ramp and keeps shadows minimal.

## Spacing Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `xxs` | 4px | Extra tight spacing, icon padding |
| `xs` | 8px | Tight spacing, small gaps |
| `sm` | 12px | Small spacing, button padding |
| `md` | 16px | Default spacing, general use |
| `lg` | 24px | Large spacing, section margins |
| `xl` | 32px | Extra large spacing, major sections |
| `2xl` | 40px | Large gaps between sections |
| `3xl` | 48px | Major layout spacing |
| `4xl` | 56px | Extra large gaps |
| `5xl` | 64px | Maximum spacing |
| `6xl` | 72px | Hero sections |
| `7xl` | 80px | Extra large gaps |
| `8xl` | 88px | Maximum gaps |

## Typography Tokens

### Heading Styles

| Style | Size | Weight | Line Height | Use |
|-------|------|--------|-------------|-----|
| `headingXL` | 32px | 700 | 40px | Main page headings |
| `headingLG` | 28px | 700 | 36px | Section headings |
| `headingMD` | 24px | 600 | 32px | Subsection headings |
| `headingSM` | 20px | 600 | 28px | Small headings |
| `headingXS` | 18px | 600 | 26px | Extra small headings |

### Body Styles

| Style | Size | Weight | Line Height | Use |
|-------|------|--------|-------------|-----|
| `bodyLG` | 16px | 400 | 24px | Main body text |
| `bodyMD` | 14px | 400 | 22px | Secondary body text |
| `bodySM` | 12px | 400 | 18px | Small text, captions |

### Label Styles

| Style | Size | Weight | Line Height | Use |
|-------|------|--------|-------------|-----|
| `labelLG` | 14px | 600 | 20px | Large labels |
| `labelMD` | 12px | 600 | 18px | Medium labels |
| `labelSM` | 11px | 600 | 16px | Small labels |

### Font Families

- **Inter** - Primary font for body and most text
- **Chivo Mono** - Monospace font for code and technical content

## Border Radius Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `xs` | 4px | Subtle rounding, small elements |
| `sm` | 8px | Small buttons, minor elements |
| `md` | 12px | Default rounding, cards |
| `lg` | 16px | Large cards, modals |
| `xl` | 20px | Extra large components |
| `2xl` | 24px | Hero elements |

## Border Width Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `hairline` | 0.5px | Very subtle borders |
| `thin` | 1px | Default borders |
| `base` | 2px | Prominent borders |
| `thick` | 3px | Bold borders, focus states |
| `thicker` | 4px | Maximum prominence |

## Icon Size Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `xs` | 16px | Inline icons, badges |
| `sm` | 20px | Toolbar icons |
| `md` | 24px | Default icon size |
| `lg` | 32px | Large icons, buttons |

## Theme Switching

All tokens automatically adapt when switching between light and dark themes:

\`\`\`dart
MaterialApp(
  theme: NasikoTheme.lightTheme,
  darkTheme: NasikoTheme.darkTheme,
  themeMode: ThemeMode.system, // Follow system setting
)
\`\`\`

## Using Tokens in Components

Access tokens via BuildContext extensions:

\`\`\`dart
// Inside any widget with build context
Container(
  padding: EdgeInsets.all(context.spacing.md),
  decoration: BoxDecoration(
    color: context.colors.backgroundSurface,
    borderRadius: context.borderRadius.md,
    border: Border.all(
      color: context.colors.borderPrimary,
      width: context.borderWidth.thin,
    ),
  ),
  child: Text(
    'Styled Text',
    style: context.typography.bodyMD.copyWith(
      color: context.colors.foregroundPrimary,
    ),
  ),
)
\`\`\`

## Token Principles

1. **Semantic Naming** - Names describe purpose, not color value
2. **Scale-based** - Tokens follow consistent scales (xxs → xl)
3. **Theme-aware** - All tokens support light and dark modes
4. **Immutable** - Tokens are constants and cannot be modified
5. **Type Safe** - All tokens are strongly typed
