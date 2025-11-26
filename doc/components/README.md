# Components

Nasiko UI provides a comprehensive set of pre-built components that follow the design system guidelines.

## Table of Contents

- [Accordion](#accordion)
- [Avatar](#avatar)
- [Banner](#banner)
- [Breadcrumb](#breadcrumb)
- [Buttons](#buttons)
- [Card](#card)
- [Checkbox](#checkbox)
- [Chip](#chip)
- [Divider](#divider)
- [Input Field](#input-field)
- [List](#list)
- [Menu](#menu)
- [Modal](#modal)
- [Switch](#switch)
- [Table](#table)
- [Tab Bar](#tab-bar)
- [Toast](#toast)

---

## Buttons

A comprehensive button system with multiple variants and sizes.

### Variants

| Component | Description |
|-----------|-------------|
| `PrimaryButton` | High-emphasis filled button with brand color |
| `SecondaryButton` | Medium-emphasis outlined button |
| `PrimaryIconButton` | Icon-only filled button |
| `SecondaryIconButton` | Icon-only outlined button |
| `PrimaryTextButton` | Text button with brand color |
| `SecondaryTextButton` | Text button with underline on hover |

### PrimaryButton

The main call-to-action button.

\`\`\`dart
PrimaryButton(
  onPressed: () => print('Pressed!'),
  label: 'Get Started',
  leadingIcon: Icons.rocket_launch,
  trailingIcon: Icons.arrow_forward,
  size: NasikoButtonSize.medium,
)
\`\`\`

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `onPressed` | `VoidCallback?` | **required** | Callback when pressed. `null` for disabled state. |
| `label` | `String` | **required** | Button text |
| `leadingIcon` | `IconData?` | `null` | Icon before the label |
| `trailingIcon` | `IconData?` | `null` | Icon after the label |
| `size` | `NasikoButtonSize` | `medium` | Button size variant |

### SecondaryButton

Outlined button for secondary actions.

\`\`\`dart
SecondaryButton(
  onPressed: () => print('Cancel'),
  label: 'Cancel',
  size: NasikoButtonSize.medium,
)
\`\`\`

#### Properties

Same as `PrimaryButton`.

### PrimaryIconButton

Icon-only button with brand fill.

\`\`\`dart
PrimaryIconButton(
  onPressed: () => print('Settings'),
  icon: Icons.settings,
  size: NasikoButtonSize.large,
)
\`\`\`

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `onPressed` | `VoidCallback?` | **required** | Callback when pressed |
| `icon` | `IconData` | **required** | The icon to display |
| `size` | `NasikoButtonSize` | `large` | Button size variant |

### SecondaryIconButton

Icon-only button with outline style.

\`\`\`dart
SecondaryIconButton(
  onPressed: () => print('Edit'),
  icon: Icons.edit,
  size: NasikoButtonSize.medium,
)
\`\`\`

#### Properties

Same as `PrimaryIconButton`.

### PrimaryTextButton

Text button with optional icons.

\`\`\`dart
PrimaryTextButton(
  onPressed: () => print('Learn more'),
  label: 'Learn More',
  trailingIcon: Icons.arrow_forward,
)
\`\`\`

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `onPressed` | `VoidCallback?` | **required** | Callback when pressed |
| `label` | `String` | **required** | Button text |
| `leadingIcon` | `IconData?` | `null` | Icon before the label |
| `trailingIcon` | `IconData?` | `null` | Icon after the label |

### SecondaryTextButton

Text button with underline on hover.

\`\`\`dart
SecondaryTextButton(
  onPressed: () => print('View details'),
  label: 'View Details',
)
\`\`\`

#### Properties

Same as `PrimaryTextButton`.

### NasikoButtonSize

Defines the visual size of buttons.

| Value | Description |
|-------|-------------|
| `large` | Large size with more padding |
| `medium` | Default medium size |
| `small` | Compact small size |

---

## Accordion

An expandable content component for displaying collapsible sections.

\`\`\`dart
NasikoAccordion(
  items: [
    NasikoAccordionItem(
      title: 'Section 1',
      content: Text('Content for section 1'),
    ),
    NasikoAccordionItem(
      title: 'Section 2',
      content: Text('Content for section 2'),
    ),
  ],
  allowMultipleOpen: false,
  initialOpenIndex: 0,
)
\`\`\`

### NasikoAccordion Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<NasikoAccordionItem>` | **required** | List of accordion items |
| `allowMultipleOpen` | `bool` | `false` | Allow multiple items open at once |
| `initialOpenIndex` | `int?` | `0` | Initially open item (single mode) |
| `initialOpenIndices` | `Set<int>?` | `null` | Initially open items (multi mode) |

### NasikoAccordionItem Properties

| Property | Type | Description |
|----------|------|---------|-------------|
| `title` | `String` | Header text |
| `content` | `Widget` | Content widget when expanded |

---

## Avatar

A circular avatar component for displaying user images, initials, or icons.

\`\`\`dart
// Image avatar
NasikoAvatar(
  imageUrl: '<https://example.com/avatar.jpg>',
  size: NasikoAvatarSize.medium,
)

// Text avatar (initials)
NasikoAvatar(
  text: 'JD',
  size: NasikoAvatarSize.large,
)

// Icon avatar
NasikoAvatar(
  icon: Icons.person,
  size: NasikoAvatarSize.small,
)
\`\`\`

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | `NasikoAvatarSize` | `medium` | Avatar size |
| `imageUrl` | `String?` | `null` | Network image URL (highest priority) |
| `text` | `String?` | `null` | Text to display (e.g., initials) |
| `icon` | `IconData?` | `null` | Icon to display (lowest priority) |

### NasikoAvatarSize

| Value | Diameter |
|-------|----------|
| `large` | 56px |
| `medium` | 40px |
| `small` | 32px |

---

## Banner

A prominent message component for notifications and calls-to-action.

\`\`\`dart
NasikoBanner(
  title: 'Welcome!',
  content: 'Get started with our quick tutorial.',
  bannerIcon: AssetImage('assets/icon.png'),
  action: PrimaryButton(
    onPressed: () {},
    label: 'Start Tutorial',
  ),
  bannerType: NasikoBannerType.horizontal,
  onClose: () => print('Closed'),
)
\`\`\`

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `String` | **required** | Banner title |
| `content` | `String` | **required** | Descriptive text |
| `action` | `Widget` | **required** | Action widget (e.g., button) |
| `bannerIcon` | `ImageProvider?` | `null` | Icon image |
| `bannerType` | `NasikoBannerType` | `horizontal` | Layout orientation |
| `onClose` | `VoidCallback?` | `null` | Close button callback |

### NasikoBannerType

| Value | Description |
|-------|-------------|
| `horizontal` | Wide layout for larger spaces |
| `vertical` | Compact layout (280px width) |

---

## Breadcrumb

A navigation component showing the current page hierarchy.

\`\`\`dart
NasikoBreadcrumb(
  leadingIcon: Icons.home,
  items: [
    NasikoBreadcrumbItem(
      label: 'Home',
      onTap: () => print('Navigate home'),
    ),
    NasikoBreadcrumbItem(
      label: 'Products',
      onTap: () => print('Navigate to products'),
    ),
    NasikoBreadcrumbItem(
      label: 'Details', // Last item - not tappable
    ),
  ],
)
\`\`\`

### NasikoBreadcrumb Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<NasikoBreadcrumbItem>` | **required** | Breadcrumb items |
| `leadingIcon` | `IconData?` | `null` | Icon at the start |

### NasikoBreadcrumbItem Properties

| Property | Type | Description |
|----------|------|---------|-------------|
| `label` | `String` | Item text |
| `onTap` | `VoidCallback?` | Tap callback (`null` = current/disabled) |

---

## Card

A content card component for displaying rich content with optional image, badges, tags, and action buttons.

### NasikoCard

\`\`\`dart
NasikoCard(
  image: Image.network('<https://example.com/image.jpg>', fit: BoxFit.cover),
  badgeLabel: 'New',
  titleIcon: Icons.settings,
  title: 'Card Title',
  tags: ['Tag 1', 'Tag 2', 'Tag 3'],
  subtitle: 'This is a subtitle.',
  description: 'Detailed description text goes here.',
  primaryButtonLabel: 'Action',
  primaryButtonIcon: Icons.info,
  onPrimaryPressed: () {},
  secondaryButtonLabel: 'Cancel',
  onSecondaryPressed: () {},
)
\`\`\`

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `String` | **required** | Main title text |
| `image` | `Widget?` | `null` | Image widget at top of card |
| `badgeLabel` | `String?` | `null` | Badge text (e.g., "New") in top-right |
| `titleIcon` | `IconData?` | `null` | Icon before title |
| `tags` | `List<String>` | `[]` | List of tag labels as chips |
| `subtitle` | `String?` | `null` | Subtitle text below tags |
| `description` | `String?` | `null` | Description text |
| `primaryButtonLabel` | `String?` | `null` | Primary button text |
| `primaryButtonIcon` | `IconData?` | `null` | Primary button icon |
| `onPrimaryPressed` | `VoidCallback?` | `null` | Primary button callback |
| `secondaryButtonLabel` | `String?` | `null` | Secondary button text |
| `secondaryButtonIcon` | `IconData?` | `null` | Secondary button icon |
| `onSecondaryPressed` | `VoidCallback?` | `null` | Secondary button callback |
| `disabledButtonLabel` | `String?` | `null` | Text for disabled state (e.g., "Coming Soon") |
| `enabled` | `bool` | `true` | Whether card is enabled |
| `onTap` | `VoidCallback?` | `null` | Card tap callback |
| `width` | `double?` | `null` | Fixed card width |

### States

| State | Description |
|-------|-------------|
| Default | Normal appearance with subtle border |
| Hover | Elevated with brand-colored border |
| Disabled | Reduced opacity (50%), single disabled button |

### Examples

#### Minimal Card

\`\`\`dart
NasikoCard(
  title: 'Simple Card',
  description: 'A basic card with just title and description.',
)
\`\`\`

#### Card with Image and Badge

\`\`\`dart
NasikoCard(
  image: Image.network('<https://example.com/product.jpg>', fit: BoxFit.cover),
  badgeLabel: 'New',
  title: 'Product Name',
  titleIcon: Icons.inventory,
  tags: ['Category', 'Featured'],
  subtitle: 'Product subtitle',
  description: 'Product description goes here.',
  primaryButtonLabel: 'Buy Now',
  primaryButtonIcon: Icons.shopping_cart,
  onPrimaryPressed: () => addToCart(),
  secondaryButtonLabel: 'Details',
  onSecondaryPressed: () => showDetails(),
)
\`\`\`

#### Disabled Card

\`\`\`dart
NasikoCard(
  image: Image.network('<https://example.com/upcoming.jpg>', fit: BoxFit.cover),
  badgeLabel: 'Soon',
  title: 'Upcoming Feature',
  titleIcon: Icons.upcoming,
  tags: ['Preview'],
  description: 'This feature is coming soon.',
  enabled: false,
  disabledButtonLabel: 'Coming Soon',
)
\`\`\`

---

## Checkbox

Checkbox components for boolean selection.

### NasikoCheckbox

A standalone checkbox widget.

\`\`\`dart
NasikoCheckbox(
  isChecked: true,
  onChanged: (value) => print('Checked: $value'),
)
\`\`\`

#### Properties

| Property | Type | Description |
|----------|------|---------|-------------|
| `isChecked` | `bool` | Current checked state |
| `onChanged` | `ValueChanged<bool?>?` | Change callback (`null` = disabled) |

### NasikoCheckboxTile

A checkbox with label and optional icon.

\`\`\`dart
NasikoCheckboxTile(
  label: 'Enable notifications',
  icon: Icons.notifications,
  isChecked: true,
  onChanged: (value) => print('Checked: $value'),
)
\`\`\`

#### Properties

| Property | Type | Description |
|----------|------|---------|-------------|
| `label` | `String` | Text label |
| `isChecked` | `bool` | Current checked state |
| `onChanged` | `ValueChanged<bool?>?` | Change callback (`null` = disabled) |
| `icon` | `IconData?` | Optional leading icon |

---

## Divider

A horizontal or vertical line separator.

\`\`\`dart
// Horizontal divider
NasikoDivider(axis: NasikoDividerAxis.horizontal)

// Vertical divider (use in Row)
Row(
  children: [
    Text('Left'),
    NasikoDivider(axis: NasikoDividerAxis.vertical),
    Text('Right'),
  ],
)
\`\`\`

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `axis` | `NasikoDividerAxis` | `horizontal` | Divider orientation |

### NasikoDividerAxis

| Value | Description |
|-------|-------------|
| `horizontal` | Horizontal line |
| `vertical` | Vertical line |

---

## Input Field

A styled text input component.

\`\`\`dart
NasikoInputField(
  controller: _controller,
  label: 'Email',
  labelInfoIcon: Icons.info_outline,
  hintText: 'Enter your email',
  helperText: 'We will never share your email',
  leadingIcon: Icons.email,
  trailingIcon: Icons.check_circle,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  onChanged: (value) => print('Value: $value'),
)
\`\`\`

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController?` | `null` | Text controller |
| `label` | `String?` | `null` | Label above the field |
| `labelInfoIcon` | `IconData?` | `null` | Info icon next to label |
| `hintText` | `String?` | `null` | Placeholder text |
| `helperText` | `String?` | `null` | Helper text below field |
| `leadingIcon` | `IconData?` | `null` | Icon at start of field |
| `trailingIcon` | `IconData?` | `null` | Icon at end of field |
| `obscureText` | `bool` | `false` | Hide text (passwords) |
| `keyboardType` | `TextInputType?` | `null` | Keyboard type |
| `validator` | `FormFieldValidator<String>?` | `null` | Validation function |
| `onChanged` | `ValueChanged<String>?` | `null` | Change callback |

---

## List

List components for displaying items.

### NasikoList

A container for list items.

\`\`\`dart
NasikoList(
  children: [
    NasikoListItem(title: 'Item 1'),
    NasikoListItem(title: 'Item 2'),
  ],
)
\`\`\`

#### Properties

| Property | Type | Description |
|----------|------|---------|-------------|
| `children` | `List<NasikoListItem>` | List of items |

### NasikoListItem

A comprehensive list item with many display options.

\`\`\`dart
NasikoListItem(
  title: 'Settings',
  subtitle: 'Manage preferences',
  imageUrl: '<https://example.com/icon.png>',
  leadingIcon: Icons.settings,
  indentLevel: 0,
  isSelected: false,
  isDisabled: false,
  isExpanded: false,
  hasChildren: true,
  showStatusDot: true,
  badgeLabel: '3',
  badgeIcon: Icons.star,
  onTap: () => print('Tapped'),
  onToggleExpand: () => print('Toggle'),
)
\`\`\`

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `String` | **required** | Item title |
| `subtitle` | `String?` | `null` | Subtitle text |
| `imageUrl` | `String?` | `null` | Avatar image URL |
| `leadingIcon` | `IconData?` | `null` | Leading icon |
| `indentLevel` | `int` | `0` | Hierarchy depth |
| `isSelected` | `bool` | `false` | Selection state |
| `isDisabled` | `bool` | `false` | Disabled state |
| `isExpanded` | `bool` | `false` | Expanded state |
| `hasChildren` | `bool` | `false` | Show expand arrow |
| `showStatusDot` | `bool` | `false` | Show green status dot |
| `badgeLabel` | `String?` | `null` | Badge text |
| `badgeIcon` | `IconData?` | `null` | Badge icon |
| `onTap` | `VoidCallback?` | `null` | Tap callback |
| `onToggleExpand` | `VoidCallback?` | `null` | Expand toggle callback |

---

## Menu

A scrollable menu for navigation or selection.

\`\`\`dart
NasikoMenu(
  title: 'Categories',
  titleIcon: Icons.category,
  items: ['Electronics', 'Clothing', 'Books', 'Home'],
  selectedIndex: 0,
  onItemSelected: (index) => print('Selected: $index'),
  height: 300.0,
)
\`\`\`

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `String` | **required** | Menu title |
| `items` | `List<String>` | **required** | Menu item labels |
| `selectedIndex` | `int` | **required** | Currently selected index |
| `onItemSelected` | `ValueChanged<int>` | **required** | Selection callback |
| `titleIcon` | `IconData?` | `null` | Icon next to title |
| `height` | `double` | `300.0` | Menu container height |

---

## Modal

Dialog modal for alerts, confirmations, or forms.

### Using the helper function

\`\`\`dart
showNasikoModal(
  context: context,
  title: 'Confirm Action',
  content: Text('Are you sure you want to proceed?'),
  leadingIcon: Icons.warning_rounded,
  primaryButtonLabel: 'Confirm',
  onPrimaryAction: () {
    Navigator.of(context).pop();
    // Perform action
  },
  secondaryButtonLabel: 'Cancel',
  onSecondaryAction: () => Navigator.of(context).pop(),
  isDismissible: true,
);
\`\`\`

### showNasikoModal Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `context` | `BuildContext` | **required** | Build context |
| `title` | `String` | **required** | Modal title |
| `content` | `Widget` | **required** | Modal content |
| `leadingIcon` | `IconData?` | `null` | Large icon (for alerts) |
| `primaryButtonLabel` | `String?` | `null` | Primary button text |
| `onPrimaryAction` | `VoidCallback?` | `null` | Primary button callback |
| `secondaryButtonLabel` | `String?` | `null` | Secondary button text |
| `onSecondaryAction` | `VoidCallback?` | `null` | Secondary button callback |
| `isDismissible` | `bool` | `true` | Can dismiss by tapping outside |
| `onClose` | `VoidCallback?` | `null` | Close button callback |

### NasikoModal Widget

Can also be used directly as a widget.

\`\`\`dart
NasikoModal(
  title: 'Edit Profile',
  content: MyFormWidget(),
  onClose: () => Navigator.of(context).pop(),
  primaryButtonLabel: 'Save',
  onPrimaryAction: () => saveProfile(),
)
\`\`\`

---

## Switch

A toggle switch component.

\`\`\`dart
NasikoSwitch(
  value: true,
  onChanged: (value) => print('Toggled: $value'),
)
\`\`\`

### Properties

| Property | Type | Description |
|----------|------|---------|-------------|
| `value` | `bool` | Current toggle state |
| `onChanged` | `ValueChanged<bool>?` | Change callback (`null` = disabled) |

---

## Table

A data table component with sortable columns.

\`\`\`dart
NasikoTable(
  columns: [
    NasikoTableColumn(
      title: 'Name',
      flex: 2,
      alignment: Alignment.centerLeft,
      isSortable: true,
    ),
    NasikoTableColumn(
      title: 'Status',
      flex: 1,
    ),
    NasikoTableColumn(
      title: 'Actions',
      flex: 1,
      alignment: Alignment.centerRight,
    ),
  ],
  data: [
    [
      NasikoTableTextCell('John Doe'),
      Text('Active'),
      NasikoTableCopyCell(onCopy: () {}),
    ],
    [
      NasikoTableTextCell('Jane Smith'),
      Text('Inactive'),
      NasikoTableCopyCell(onCopy: () {}),
    ],
  ],
  bodyHeight: 400,
)
\`\`\`

### NasikoTable Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `columns` | `List<NasikoTableColumn>` | **required** | Column definitions |
| `data` | `List<List<Widget>>` | **required** | Row data (widgets) |
| `bodyHeight` | `double?` | `400` | Table body height |
| `bodyScrollController` | `ScrollController?` | `null` | Custom scroll controller |

### NasikoTableColumn Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `String` | **required** | Column header text |
| `flex` | `int` | `1` | Column flex weight |
| `alignment` | `Alignment` | `centerLeft` | Content alignment |
| `isSortable` | `bool` | `false` | Show sort indicator |

### Table Cell Components

| Component | Description |
|-----------|-------------|
| `NasikoTableTextCell` | Simple text cell |
| `NasikoTableCopyCell` | Cell with copy action |
| `NasikoTableCellItem` | Complex cell with multiple elements |

---

## Tab Bar

A horizontal tab navigation component.

\`\`\`dart
DefaultTabController(
  length: 3,
  child: Column(
    children: [
      NasikoTabBar(
        tabs: [
          NasikoTabItem(label: 'Overview', icon: Icons.dashboard),
          NasikoTabItem(label: 'Analytics', icon: Icons.analytics),
          NasikoTabItem(label: 'Settings', icon: Icons.settings),
        ],
        onTap: (index) => print('Tab: $index'),
      ),
      Expanded(
        child: TabBarView(
          children: [
            OverviewPage(),
            AnalyticsPage(),
            SettingsPage(),
          ],
        ),
      ),
    ],
  ),
)
\`\`\`

### NasikoTabBar Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `tabs` | `List<NasikoTabItem>` | **required** | Tab items |
| `controller` | `TabController?` | `null` | External tab controller |
| `onTap` | `ValueChanged<int>?` | `null` | Tab tap callback |

### NasikoTabItem Properties

| Property | Type | Description |
|----------|------|---------|-------------|
| `label` | `String` | Tab text |
| `icon` | `IconData` | Tab icon |

---

## Toast

Toast notifications for feedback messages.

### Using NasikoToastService

\`\`\`dart
// Success toast
NasikoToastService.showSuccess(context, 'Item saved successfully!');

// Error toast
NasikoToastService.showError(context, 'Failed to save item.');

// Custom toast
NasikoToastService.show(
  context,
  message: 'Processing...',
  type: NasikoToastType.info,
  duration: Duration(seconds: 5),
);
\`\`\`

### NasikoToastService Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `show` | `context`, `message`, `type`, `duration` | Show custom toast |
| `showSuccess` | `context`, `message` | Show success toast |
| `showError` | `context`, `message` | Show error toast |

### NasikoToastType

| Value | Icon | Color |
|-------|------|-------|
| `success` | check_circle | Green |
| `error` | cancel | Red |
| `warning` | warning | Orange |
| `info` | info | Blue |

### NasikoToast Widget

Can also be used directly as a widget.

\`\`\`dart
NasikoToast(
  type: NasikoToastType.success,
  message: 'Operation completed!',
)
\`\`\`

#### Properties

| Property | Type | Description |
|----------|------|---------|-------------|
| `type` | `NasikoToastType` | Toast type |
| `message` | `String` | Toast message |

---

## Chip

Chip components for displaying tags, filters, or selectable items. Supports both actionable (with delete) and non-actionable variants.

### NasikoChip

A single chip widget with optional leading icon and delete action.

\`\`\`dart
// Non-actionable chip
NasikoChip(
  label: 'Flutter',
  leadingIcon: Icons.code,
  variant: NasikoChipVariant.neutral,
)

// Actionable chip with delete
NasikoChip(
  label: 'Selected Tag',
  leadingIcon: Icons.label,
  variant: NasikoChipVariant.brand,
  onTap: () => print('Chip tapped'),
  onDelete: () => print('Delete chip'),
)

// Disabled chip
NasikoChip(
  label: 'Disabled',
  isDisabled: true,
)
\`\`\`

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `label` | `String` | **required** | Chip text |
| `leadingIcon` | `IconData?` | `null` | Icon before the label |
| `variant` | `NasikoChipVariant` | `neutral` | Visual style variant |
| `isDisabled` | `bool` | `false` | Disabled state |
| `onTap` | `VoidCallback?` | `null` | Chip tap callback |
| `onDelete` | `VoidCallback?` | `null` | Delete button callback (shows remove icon) |

### NasikoChipGroup

A horizontal scrollable row of chips.

\`\`\`dart
NasikoChipGroup(
  chips: [
    NasikoChip(label: 'All', variant: NasikoChipVariant.brand),
    NasikoChip(label: 'Design', leadingIcon: Icons.palette),
    NasikoChip(label: 'Development', leadingIcon: Icons.code),
    NasikoChip(label: 'Marketing', leadingIcon: Icons.campaign),
  ],
  spacing: 8.0,
)
\`\`\`

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `chips` | `List<NasikoChip>` | **required** | List of chips to display |
| `spacing` | `double` | `8.0` | Horizontal spacing between chips |

### NasikoChipVariant

| Value | Description |
|-------|-------------|
| `neutral` | Gray/neutral background (default, unselected state) |
| `brand` | Brand/yellow background (selected state) |

### States

Both variants support the following states:

| State | Description |
|-------|-------------|
| Default | Normal appearance |
| Hover | Slightly darker background on mouse hover |
| Pressed | Darker background when pressed |
| Disabled | Reduced opacity, non-interactive |

### Actionable vs Non-actionable

| Type | `onDelete` | Trailing Icon | Use Case |
|------|------------|---------------|----------|
| Non-actionable | `null` | Hidden | Display-only tags, labels |
| Actionable | Provided | Remove icon (−) | Removable filters, selections |
