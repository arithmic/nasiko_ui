# Nasiko UI

A comprehensive, production-ready design system package for [Nasiko](https://nasiko.app) Flutter applications. Provides a complete token system, theming infrastructure, and semantic design patterns.

## Features

- **Complete Token System**: Colors, spacing, typography, border radius, border width, and icon sizes
- **Light & Dark Themes**: Built-in support for multiple color schemes using Flutter's `ThemeExtension`
- **Semantic Naming**: Intuitive color and component naming aligned with Material Design 3
- **Easy Access**: BuildContext extensions for convenient token access throughout your app
- **Production Ready**: Immutable, well-tested, and ready for scale
- **Type Safe**: Full Dart type safety with null safety support

## Installation

Add `nasiko_ui` to your `pubspec.yaml`:

\`\`\`yaml
dependencies:
  nasiko_ui:
    path: ../nasiko_ui
\`\`\`

Then run:

\`\`\`bash
flutter pub get
\`\`\`

## Quick Start

### 1. Set Up the Theme

Wrap your app with `MaterialApp` and apply the Nasiko theme:

\`\`\`dart
import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: NasikoTheme.lightTheme,
      darkTheme: NasikoTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
\`\`\`

### 2. Access Design Tokens

Use BuildContext extensions to access tokens anywhere in your widget tree:

\`\`\`dart
class MyButton extends StatelessWidget {
  const MyButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: context.colors.backgroundBrand,
        borderRadius: context.borderRadius.md,
      ),
      child: Text(
        'Press Me',
        style: context.typography.bodySM.copyWith(
          color: context.colors.foregroundOnAction,
        ),
      ),
    );
  }
}
\`\`\`

## Token System

### Colors

Access semantic color tokens via `context.colors`:

\`\`\`dart
// Background Colors
context.colors.backgroundBase         // Main background
context.colors.backgroundBrand        // Primary brand background
context.colors.backgroundSuccess      // Success state background
context.colors.backgroundError        // Error state background

// Foreground Colors (Text & Icons)
context.colors.foregroundPrimary      // Primary text
context.colors.foregroundSecondary    // Secondary text
context.colors.foregroundBrand        // Brand text
context.colors.foregroundDisabled     // Disabled state text

// Border Colors
context.colors.borderPrimary          // Primary borders
context.colors.borderSecondary        // Secondary borders
context.colors.borderError            // Error state borders
\`\`\`

**Light & Dark Themes**: Colors automatically adapt when switching themes.

### Spacing

Consistent spacing values via `context.spacing`:

\`\`\`dart
context.spacing.xxs   // 4px
context.spacing.xs    // 8px
context.spacing.sm    // 12px
context.spacing.md    // 16px
context.spacing.lg    // 24px
context.spacing.xl    // 32px
\`\`\`

### Typography

Pre-configured text styles via `context.typography`:

\`\`\`dart
// Headings
context.typography.headingXL     // Extra Large (32px, 700)
context.typography.headingLG     // Large (28px, 700)
context.typography.headingMD     // Medium (24px, 600)
context.typography.headingSM     // Small (20px, 600)

// Body
context.typography.bodyLG        // Large (16px, 400)
context.typography.bodyMD        // Medium (14px, 400)
context.typography.bodySM        // Small (12px, 400)
\`\`\`

### Border Radius

Predefined border radius values via `context.borderRadius`:

\`\`\`dart
context.borderRadius.xs      // 4px
context.borderRadius.sm      // 8px
context.borderRadius.md      // 12px
context.borderRadius.lg      // 16px
\`\`\`

### Border Width

Consistent border widths via `context.borderWidth`:

\`\`\`dart
context.borderWidth.hairline   // 0.5px
context.borderWidth.thin       // 1px
context.borderWidth.base       // 2px
context.borderWidth.thick      // 3px
\`\`\`

### Icon Sizes

Predefined icon dimensions via `context.iconSize`:

\`\`\`dart
context.iconSize.xs    // 16px
context.iconSize.sm    // 20px
context.iconSize.md    // 24px
context.iconSize.lg    // 32px
\`\`\`

## Advanced Usage

### Creating Custom Components

Build components that leverage the design system:

\`\`\`dart
class NasikoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const NasikoCard({
    required this.child,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.spacing.md),
        decoration: BoxDecoration(
          color: context.colors.backgroundSurface,
          borderRadius: context.borderRadius.md,
          border: Border.all(
            color: context.colors.borderPrimary,
            width: context.borderWidth.thin,
          ),
        ),
        child: child,
      ),
    );
  }
}
\`\`\`

### Manual Theme Access

If needed, access the full theme directly:

\`\`\`dart
final theme = NasikoTheme.lightTheme;
final colorScheme = theme.colorScheme;
\`\`\`

### Modifying Tokens at Runtime

Create modified theme copies for dynamic styling:

\`\`\`dart
final customColors = context.colors.copyWith(
  foregroundPrimary: Colors.red,
);
\`\`\`

## Color Palette Reference

The design system uses a carefully curated 10-color palette:

- **Neutral**: Grays from off-white to charcoal (50-900)
- **Yellow**: Primary brand color with full spectrum (100-900)
- **Orange**: Warning and accent color (100-900)
- **Red**: Error and alert states (100-900)
- **Green**: Success states (100-900)
- **Blue**: Information and secondary (100-900)

Plus: Purple, Teal, and additional utility colors.

## Testing

Run the comprehensive test suite:

\`\`\`bash
flutter test
\`\`\`

Tests cover:

- Light & dark theme configuration
- Color token values and interpolation
- Token immutability and copyWith functionality
- BuildContext extension access
- Typography hierarchy
- Spacing scale validation
- Border radius and width consistency

## Project Structure

\`\`\`
lib/
├── nasiko_ui.dart                 # Main package export
├── src/
│   ├── theme/
│   │   ├── theme.dart            # Theme configuration
│   │   └── color_schemes.dart    # Material 3 color schemes
│   └── tokens/
│       ├── tokens.dart           # Token exports
│       ├── colors/
│       │   ├── colors.dart       # Color tokens
│       │   └── _color_palette.dart
│       ├── spacing.dart
│       ├── typography.dart
│       ├── radius.dart
│       ├── border_width.dart
│       └── icon_size.dart
\`\`\`

## Contributing

When adding new tokens or modifying existing ones:

1. Update the token file in `lib/src/tokens/`
2. Ensure the token is exported from `tokens.dart`
3. Update `README.md` with token documentation
4. Add comprehensive tests to `test/nasiko_ui_test.dart`
5. Run `flutter test` to ensure all tests pass

## Naming Conventions

### Colors

- `background*` - Background surfaces and layers
- `foreground*` - Text, icons, and interactive elements
- `border*` - Border colors
- Suffixes: `Brand`, `Primary`, `Secondary`, `Success`, `Error`, `Warning`, `Information`

### Other Tokens

- `xxs`, `xs`, `sm`, `md`, `lg`, `xl` - Size scales (ascending order)
- `XL`, `LG`, `MD`, `SM` - Typography variants

## Browser/Platform Support

- Flutter 1.17.0 and above
- Dart 3.9.0 and above

## License

MIT License

## Support

For issues or questions, please refer to the [Nasiko documentation](https://nasiko.app/docs).
