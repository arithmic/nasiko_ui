# Dropdown

A dropdown select component with an expandable menu for selecting from a list of options.

## Features

- Trigger button with leading icon, label, keyboard shortcut badge, and chevron
- Expandable scrollable menu with smooth animations
- Selected item highlighted with brand color
- Hover states for menu items
- Support for keyboard shortcuts display
- Disabled state support

## Import

\`\`\`dart
import 'package:nasiko_ui/nasiko_ui.dart';
\`\`\`

## NasikoDropdownItem

Model class representing a single dropdown item.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `value` | `T` | Yes | The value associated with this item |
| `label` | `String` | Yes | The display label for this item |
| `icon` | `IconData?` | No | Optional leading icon |
| `shortcut` | `String?` | No | Optional keyboard shortcut text (e.g., "⌘⇧B") |

## NasikoDropdown

### Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `items` | `List<NasikoDropdownItem<T>>` | - | Yes | The list of dropdown items |
| `selectedValue` | `T?` | - | Yes | Currently selected value |
| `onChanged` | `ValueChanged<T>` | - | Yes | Callback when selection changes |
| `leadingIcon` | `IconData?` | `null` | No | Leading icon for trigger button |
| `hint` | `String` | `'Select an option'` | No | Hint text when no item selected |
| `maxHeight` | `double` | `300.0` | No | Maximum height of dropdown menu |
| `enabled` | `bool` | `true` | No | Whether dropdown is enabled |

## Usage

### Basic Usage

\`\`\`dart
NasikoDropdown<String>(
  items: [
    NasikoDropdownItem(value: 'option1', label: 'Option 1'),
    NasikoDropdownItem(value: 'option2', label: 'Option 2'),
    NasikoDropdownItem(value: 'option3', label: 'Option 3'),
  ],
  selectedValue: selectedOption,
  onChanged: (value) {
    setState(() => selectedOption = value);
  },
)
\`\`\`

### With Leading Icon

\`\`\`dart
NasikoDropdown<String>(
  leadingIcon: Icons.settings_outlined,
  items: [
    NasikoDropdownItem(value: 'setting1', label: 'Setting 1'),
    NasikoDropdownItem(value: 'setting2', label: 'Setting 2'),
  ],
  selectedValue: selectedSetting,
  onChanged: (value) => setState(() => selectedSetting = value),
)
\`\`\`

### With Keyboard Shortcuts

\`\`\`dart
NasikoDropdown<String>(
  leadingIcon: Icons.settings_outlined,
  items: [
    NasikoDropdownItem(
      value: 'bold',
      label: 'Bold',
      shortcut: '⌘B',
    ),
    NasikoDropdownItem(
      value: 'italic',
      label: 'Italic',
      shortcut: '⌘I',
    ),
    NasikoDropdownItem(
      value: 'underline',
      label: 'Underline',
      shortcut: '⌘U',
    ),
  ],
  selectedValue: selectedFormat,
  onChanged: (value) => setState(() => selectedFormat = value),
)
\`\`\`

### Disabled State

\`\`\`dart
NasikoDropdown<String>(
  enabled: false,
  items: [...],
  selectedValue: selectedValue,
  onChanged: (value) {},
)
\`\`\`

## Visual States

### Trigger Button

- **Closed**: Surface background, primary border, chevron pointing down
- **Open**: Group background, brand border, chevron pointing up

### Menu Items

- **Default**: Transparent background
- **Hover**: Surface hover background
- **Selected**: Brand secondary background with brand border

## Accessibility

- The dropdown uses proper hit testing for touch and mouse interactions
- Overlay dismisses when tapping outside the menu
- Animations provide visual feedback for state changes
