# Theming Guide

This guide explains how to use and customize themes in Nasiko UI.

## Quick Start

### Using Default Theme

The simplest way to use Nasiko UI is with the default yellow theme:

```dart
import 'package:nasiko_ui/nasiko_ui.dart';

MaterialApp(
  theme: NasikoTheme.lightTheme,
  darkTheme: NasikoTheme.darkTheme,
  themeMode: ThemeMode.system,
  home: YourHomePage(),
)
```

## Dynamic Color Palettes

Nasiko UI supports **7 built-in color palettes** that can be switched dynamically:

- `NasikoColorPalette.yellow` (default)
- `NasikoColorPalette.orange`
- `NasikoColorPalette.red`
- `NasikoColorPalette.purple`
- `NasikoColorPalette.blue`
- `NasikoColorPalette.teal`
- `NasikoColorPalette.green`

### Using a Specific Palette

```dart
import 'package:nasiko_ui/nasiko_ui.dart';

MaterialApp(
  // Blue theme for light mode
  theme: NasikoTheme.light(NasikoColorPalette.blue),
  
  // Blue theme for dark mode
  darkTheme: NasikoTheme.dark(NasikoColorPalette.blue),
  
  home: YourHomePage(),
)
```

### Alternative Syntax

You can also use the `fromPalette` method for more control:

```dart
MaterialApp(
  theme: NasikoTheme.fromPalette(
    palette: NasikoColorPalette.teal,
    brightness: Brightness.light,
  ),
  darkTheme: NasikoTheme.fromPalette(
    palette: NasikoColorPalette.teal,
    brightness: Brightness.dark,
  ),
  home: YourHomePage(),
)
```

## Dynamic Theme Switching

To allow users to switch themes at runtime, use a state management solution:

### Example with StatefulWidget

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NasikoColorPalette _palette = NasikoColorPalette.yellow;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: NasikoTheme.fromPalette(
        palette: _palette,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: Scaffold(
        body: Column(
          children: [
            // Palette selector
            DropdownButton<NasikoColorPalette>(
              value: _palette,
              onChanged: (palette) {
                setState(() {
                  _palette = palette!;
                });
              },
              items: NasikoColorPalette.values.map((palette) {
                return DropdownMenuItem(
                  value: palette,
                  child: Text(palette.name),
                );
              }).toList(),
            ),
            
            // Dark mode toggle
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### Example with Provider

```dart
// 1. Create a theme provider
class ThemeProvider extends ChangeNotifier {
  NasikoColorPalette _palette = NasikoColorPalette.yellow;
  Brightness _brightness = Brightness.light;

  NasikoColorPalette get palette => _palette;
  Brightness get brightness => _brightness;

  ThemeData get theme => NasikoTheme.fromPalette(
    palette: _palette,
    brightness: _brightness,
  );

  void setPalette(NasikoColorPalette palette) {
    _palette = palette;
    notifyListeners();
  }

  void setBrightness(Brightness brightness) {
    _brightness = brightness;
    notifyListeners();
  }
}

// 2. Use it in your app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            theme: themeProvider.theme,
            home: YourHomePage(),
          );
        },
      ),
    );
  }
}

// 3. Switch palette anywhere in your app
void switchToPurple(BuildContext context) {
  context.read<ThemeProvider>().setPalette(NasikoColorPalette.purple);
}
```

## Accessing Theme Colors

### Using Context Extension

The easiest way to access colors in your widgets:

```dart
Widget build(BuildContext context) {
  return Container(
    color: context.colors.backgroundBrand,
    child: Text(
      'Hello',
      style: TextStyle(color: context.colors.foregroundOnAction),
    ),
  );
}
```

### Available Color Tokens

**Background Colors:**

- `backgroundBase`, `backgroundGroup`, `backgroundSurface`
- `backgroundBrand`, `backgroundBrandHover`, `backgroundBrandActive`, `backgroundBrandSubtle`
- `backgroundSecondaryBrand`, `backgroundSecondaryBrandHover`, `backgroundSecondaryBrandActive`
- `backgroundSuccess`, `backgroundWarning`, `backgroundError`, `backgroundInformation`

**Foreground Colors:**

- `foregroundPrimary`, `foregroundSecondary`, `foregroundDisabled`, `foregroundOnAction`
- `foregroundBrand`, `foregroundBrandHover`, `foregroundBrandLink`, `foregroundBrandHighlight`
- `foregroundSuccess`, `foregroundWarning`, `foregroundError`, `foregroundInformation`

**Border Colors:**

- `borderPrimary`, `borderSecondary`, `borderHover`, `borderDisabled`
- `borderSuccess`, `borderWarning`, `borderError`, `borderInformation`

See the complete list in the [NasikoColorTheme class](../lib/src/tokens/colors/colors.dart).

## Accessing Other Design Tokens

```dart
// Spacing
context.spacing.sm
context.spacing.md
context.spacing.lg

// Typography
context.typography.bodyMedium
context.typography.headingH3

// Border Radius
context.radius.sm
context.radius.md

// Border Width
context.borderWidth.thin
context.borderWidth.thick

// Icon Sizes
context.iconSize.sm
context.iconSize.md
```

## Best Practices

1. **Use semantic tokens**: Always use `context.colors.backgroundBrand` instead of hardcoded colors
2. **Support both themes**: Test your UI in both light and dark modes
3. **Respect user preferences**: Use `ThemeMode.system` to follow device settings
4. **Consistent palette**: Use one palette throughout your app for brand consistency
5. **Accessible colors**: All built-in palettes meet WCAG contrast requirements

## Advanced: Custom Color Palettes

If you need colors beyond the 7 built-in palettes, you can create custom themes:

```dart
// Create custom color theme
final customColors = NasikoColorTheme(
  backgroundBase: Color(0xFFFFFFFF),
  backgroundBrand: Color(0xFFFF6B6B), // Your custom brand color
  // ... define all required colors
);

// Create custom theme
final customTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Color(0xFFFF6B6B),
  ),
  extensions: [
    customColors,
    defaultNasikoSpacing,
    defaultNasikoTypography,
    defaultNasikoBorderRadius,
    defaultNasikoBorderWidth,
    defaultNasikoIconSize,
  ],
);
```

For more details, see the source code in `lib/src/tokens/colors/color_theme_factory.dart`.
