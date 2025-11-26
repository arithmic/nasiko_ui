# Chip Component

Chips are compact elements that represent an input, attribute, or action. They can be actionable (with delete functionality) or non-actionable (display only).

## Components

| Component | Description |
|-----------|-------------|
| `NasikoChip` | Individual chip element |
| `NasikoChipGroup` | Horizontal group of chips |
| `NasikoChipVariant` | Enum for chip visual variants |

---

## NasikoChip

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `label` | `String` | **Required** | The text displayed on the chip |
| `leadingIcon` | `IconData?` | `null` | Optional icon before the label |
| `onTap` | `VoidCallback?` | `null` | Callback when chip is tapped |
| `onDelete` | `VoidCallback?` | `null` | Callback for delete action. Shows remove icon when set |
| `variant` | `NasikoChipVariant` | `neutral` | Visual style variant |
| `enabled` | `bool` | `true` | Whether the chip is enabled |

### Variants

| Variant | Description |
|---------|-------------|
| `NasikoChipVariant.neutral` | Gray background - default/unselected state |
| `NasikoChipVariant.brand` | Yellow/brand background - selected state |

### States

- **Default**: Base appearance
- **Hover**: Slightly darker background
- **Pressed**: Darker background
- **Disabled**: Faded appearance, no interaction

### Usage

\`\`\`dart
// Non-actionable chip (display only)
NasikoChip(
  label: 'Tag',
  leadingIcon: Icons.music_note,
)

// Actionable chip with delete
NasikoChip(
  label: 'Tag',
  leadingIcon: Icons.music_note,
  onDelete: () => print('Delete pressed'),
)

// Brand/selected variant
NasikoChip(
  label: 'Selected',
  leadingIcon: Icons.music_note,
  variant: NasikoChipVariant.brand,
  onTap: () => print('Chip tapped'),
  onDelete: () => print('Delete pressed'),
)

// Disabled chip
NasikoChip(
  label: 'Disabled',
  enabled: false,
)
\`\`\`

---

## NasikoChipGroup

A horizontal container for displaying multiple chips with consistent spacing.

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `children` | `List<Widget>` | **Required** | List of chip widgets |
| `spacing` | `double?` | `s8` | Spacing between chips |
| `scrollable` | `bool` | `true` | Whether group scrolls horizontally |

### Usage

\`\`\`dart
NasikoChipGroup(
  children: [
    NasikoChip(label: 'Tag 1', onDelete: () {}),
    NasikoChip(label: 'Tag 2', onDelete: () {}),
    NasikoChip(
      label: 'Selected',
      variant: NasikoChipVariant.brand,
      onDelete: () {},
    ),
  ],
)
\`\`\`

---

## Design Guidelines

### When to Use

- **Filters**: Allow users to filter content
- **Tags**: Display metadata or categories
- **Selections**: Show selected options from a list
- **Input chips**: Represent complex information in compact form

### Actionable vs Non-actionable

| Type | Use Case |
|------|----------|
| **Actionable** | User can remove/dismiss the chip (shows delete icon) |
| **Non-actionable** | Display-only, no user interaction |

### Accessibility

- Chips use semantic colors for proper contrast
- Disabled state clearly communicates non-interactivity
- Focus states handled for keyboard navigation
