# Card Component

A content card component that displays rich content with optional image, title, tags, description, and action buttons. The card integrates with other Nasiko UI components (Chips and Buttons) for a cohesive design.

## Features

- Optional hero image with badge overlay
- Title with optional leading icon
- Tags displayed using `NasikoChip` components
- Subtitle and description text
- Action buttons using `PrimaryButton` and `SecondaryButton`
- Three states: default, hover, and disabled
- Hover elevation effect

## Import

\`\`\`dart
import 'package:nasiko_ui/nasiko_ui.dart';
\`\`\`

## Basic Usage

\`\`\`dart
NasikoCard(
  title: 'Card Title',
  subtitle: 'This is a good card.',
  description: 'Some description text here.',
)
\`\`\`

## With Image and Badge

\`\`\`dart
NasikoCard(
  image: Image.network(
    '<https://example.com/image.jpg>',
    fit: BoxFit.cover,
  ),
  badgeLabel: 'New',
  title: 'Featured Card',
  subtitle: 'This is a featured card.',
)
\`\`\`

## With Tags and Actions

\`\`\`dart
NasikoCard(
  titleIcon: Icons.settings,
  title: 'Settings Card',
  tags: ['Tag 1', 'Tag 2', 'Tag 3'],
  subtitle: 'Configure your settings.',
  description: 'Accepted Input: URL of a public GitHub repository',
  primaryButtonLabel: 'Save',
  primaryButtonIcon: Icons.save,
  onPrimaryPressed: () => print('Save pressed'),
  secondaryButtonLabel: 'Cancel',
  secondaryButtonIcon: Icons.close,
  onSecondaryPressed: () => print('Cancel pressed'),
)
\`\`\`

## Disabled State

\`\`\`dart
NasikoCard(
  image: Image.network('<https://example.com/image.jpg>'),
  badgeLabel: 'New',
  title: 'Coming Soon',
  tags: ['Tag 1', 'Tag 2'],
  subtitle: 'This feature is coming soon.',
  enabled: false,
  disabledButtonLabel: 'Coming Soon',
)
\`\`\`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `image` | `Widget?` | `null` | Optional image widget displayed at the top |
| `badgeLabel` | `String?` | `null` | Badge text in top-right corner of image |
| `titleIcon` | `IconData?` | `null` | Icon displayed before the title |
| `title` | `String` | **required** | Main title text |
| `tags` | `List<String>` | `[]` | List of tag labels displayed as chips |
| `subtitle` | `String?` | `null` | Subtitle text below tags |
| `description` | `String?` | `null` | Description text below subtitle |
| `primaryButtonLabel` | `String?` | `null` | Label for primary action button |
| `primaryButtonIcon` | `IconData?` | `null` | Leading icon for primary button |
| `onPrimaryPressed` | `VoidCallback?` | `null` | Callback for primary button |
| `secondaryButtonLabel` | `String?` | `null` | Label for secondary action button |
| `secondaryButtonIcon` | `IconData?` | `null` | Leading icon for secondary button |
| `onSecondaryPressed` | `VoidCallback?` | `null` | Callback for secondary button |
| `disabledButtonLabel` | `String?` | `null` | Label for disabled state button |
| `enabled` | `bool` | `true` | Whether the card is enabled |
| `onTap` | `VoidCallback?` | `null` | Callback when card is tapped |
| `width` | `double?` | `null` | Fixed width for the card |

## States

### Default

- Full color content
- Border color: `borderPrimary`
- Background: `backgroundSurface`

### Hover

- Elevated shadow effect
- Border color changes to `borderSecondary` (brand)
- Slight lift appearance

### Disabled

- Content opacity reduced to 50%
- Badge uses disabled colors
- Tags appear disabled
- Shows single disabled button if `disabledButtonLabel` is provided

## Card Anatomy

\`\`\`
┌─────────────────────────────────────┐
│  ┌─────────────────────────────┐    │
│  │         Image              [Badge]│
│  └─────────────────────────────┘    │
│                                      │
│  [Icon] Title                        │
│                                      │
│  [Tag] [Tag] [Tag]                   │
│                                      │
│  Subtitle (bold)                     │
│  Description text                    │
│                                      │
│  [Primary Button] [Secondary Button] │
└─────────────────────────────────────┘
\`\`\`

## Integration with Other Components

The Card component uses:

- `NasikoChip` for displaying tags
- `PrimaryButton` for primary actions
- `SecondaryButton` for secondary actions

All these components follow the same design token system for consistent styling.
