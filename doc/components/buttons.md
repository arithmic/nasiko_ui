# Buttons

The Nasiko UI button system provides multiple variants for different use cases, all with consistent sizing, spacing, and interaction states.

## Overview

| Component | Use Case |
|-----------|----------|
| `PrimaryButton` | Primary actions, CTAs |
| `SecondaryButton` | Secondary actions, cancel |
| `PrimaryIconButton` | Icon-only primary actions |
| `SecondaryIconButton` | Icon-only secondary actions |
| `PrimaryTextButton` | Tertiary text actions with emphasis |
| `SecondaryTextButton` | Links, minimal text actions |

## Size Variants

All buttons support three sizes via `NasikoButtonSize`:

| Size | Padding (V/H) | Font | Icon Size | Radius |
|------|---------------|------|-----------|--------|
| `large` | 20px / 24px | buttonPrimary (20px) | 28px | 10px |
| `medium` | 12px / 16px | buttonPrimary (20px) | 24px | 8px |
| `small` | 8px / 12px | bodySecondary (16px) | 20px | 8px |

## States

All buttons handle these states automatically:

- **Default** - Base appearance
- **Hover** - Visual feedback on mouse over
- **Focus** - Keyboard focus ring (yellow border)
- **Pressed** - Active/pressed state
- **Disabled** - Reduced opacity, non-interactive (when `onPressed` is `null`)

---

## PrimaryButton

High-emphasis button with brand fill color.

### Import

\`\`\`dart
import 'package:nasiko_ui/nasiko_ui.dart';
\`\`\`

### Basic Usage

\`\`\`dart
PrimaryButton(
  onPressed: () => print('Pressed!'),
  label: 'Submit',
)
\`\`\`

### With Icons

\`\`\`dart
// Leading icon
PrimaryButton(
  onPressed: () {},
  label: 'Continue',
  leadingIcon: Icons.arrow_forward,
)

// Trailing icon
PrimaryButton(
  onPressed: () {},
  label: 'Download',
  trailingIcon: Icons.download,
)

// Both icons
PrimaryButton(
  onPressed: () {},
  label: 'Share',
  leadingIcon: Icons.share,
  trailingIcon: Icons.arrow_forward,
)
\`\`\`

### Sizes

\`\`\`dart
PrimaryButton(
  onPressed: () {},
  label: 'Large Button',
  size: NasikoButtonSize.large,
)

PrimaryButton(
  onPressed: () {},
  label: 'Medium Button',
  size: NasikoButtonSize.medium, // Default
)

PrimaryButton(
  onPressed: () {},
  label: 'Small Button',
  size: NasikoButtonSize.small,
)
\`\`\`

### Disabled State

\`\`\`dart
PrimaryButton(
  onPressed: null, // Disabled when null
  label: 'Disabled',
)
\`\`\`

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `onPressed` | `VoidCallback?` | Yes | - | Tap callback. `null` = disabled |
| `label` | `String` | Yes | - | Button text |
| `leadingIcon` | `IconData?` | No | `null` | Icon before label |
| `trailingIcon` | `IconData?` | No | `null` | Icon after label |
| `size` | `NasikoButtonSize` | No | `medium` | Button size |

---

## SecondaryButton

Medium-emphasis outlined button.

### Basic Usage

\`\`\`dart
SecondaryButton(
  onPressed: () => print('Cancelled'),
  label: 'Cancel',
)
\`\`\`

### With Icons

\`\`\`dart
SecondaryButton(
  onPressed: () {},
  label: 'Edit',
  leadingIcon: Icons.edit,
)
\`\`\`

### Properties

Same as `PrimaryButton`.

---

## PrimaryIconButton

Icon-only button with brand fill.

### Basic Usage

\`\`\`dart
PrimaryIconButton(
  onPressed: () => print('Settings'),
  icon: Icons.settings,
)
\`\`\`

### Sizes

\`\`\`dart
PrimaryIconButton(
  onPressed: () {},
  icon: Icons.add,
  size: NasikoButtonSize.large, // Default
)

PrimaryIconButton(
  onPressed: () {},
  icon: Icons.add,
  size: NasikoButtonSize.small,
)
\`\`\`

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `onPressed` | `VoidCallback?` | Yes | - | Tap callback |
| `icon` | `IconData` | Yes | - | Button icon |
| `size` | `NasikoButtonSize` | No | `large` | Button size |

---

## SecondaryIconButton

Icon-only button with outline.

### Basic Usage

\`\`\`dart
SecondaryIconButton(
  onPressed: () => print('Delete'),
  icon: Icons.delete,
)
\`\`\`

### Properties

Same as `PrimaryIconButton`.

---

## PrimaryTextButton

Text button with brand color and optional border on hover.

### Basic Usage

\`\`\`dart
PrimaryTextButton(
  onPressed: () => print('Learn more'),
  label: 'Learn More',
)
\`\`\`

### With Icons

\`\`\`dart
PrimaryTextButton(
  onPressed: () {},
  label: 'View Details',
  trailingIcon: Icons.arrow_forward,
)
\`\`\`

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `onPressed` | `VoidCallback?` | Yes | - | Tap callback |
| `label` | `String` | Yes | - | Button text |
| `leadingIcon` | `IconData?` | No | `null` | Icon before label |
| `trailingIcon` | `IconData?` | No | `null` | Icon after label |

---

## SecondaryTextButton

Text button with underline on hover (link style).

### Basic Usage

\`\`\`dart
SecondaryTextButton(
  onPressed: () => print('Navigate'),
  label: 'View All Products',
)
\`\`\`

### With Icons

\`\`\`dart
SecondaryTextButton(
  onPressed: () {},
  label: 'Open Link',
  trailingIcon: Icons.open_in_new,
)
\`\`\`

### Properties

Same as `PrimaryTextButton`.

---

## Design Guidelines

### When to Use Each Variant

1. **PrimaryButton**: Main actions like "Submit", "Save", "Continue"
2. **SecondaryButton**: Alternative actions like "Cancel", "Back", "Skip"
3. **PrimaryIconButton**: Toolbar actions, floating actions
4. **SecondaryIconButton**: Secondary toolbar actions, less emphasis
5. **PrimaryTextButton**: Tertiary actions with some emphasis
6. **SecondaryTextButton**: Links, navigation, minimal actions

### Button Hierarchy

On any screen, follow this hierarchy:
- **One** primary action (PrimaryButton)
- **Few** secondary actions (SecondaryButton)
- **Many** tertiary actions (TextButtons)

### Accessibility

- All buttons have proper focus states
- Minimum touch target sizes are maintained
- Disabled states have reduced opacity for visibility
- Icons have proper sizing based on button size
