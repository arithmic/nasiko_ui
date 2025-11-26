# Nasiko UI - Flutter Design System

A comprehensive Flutter/Dart design system package for building consistent, beautiful, and accessible user interfaces.

## Installation

Add this to your package's `pubspec.yaml` file:

\`\`\`yaml
dependencies:
  nasiko_ui: ^0.0.1
\`\`\`

Then run:

\`\`\`bash
flutter pub get
\`\`\`

## Quick Start

### 1. Import the package

\`\`\`dart
import 'package:nasiko_ui/nasiko_ui.dart';
\`\`\`

### 2. Set up the theme

Wrap your app with the Nasiko theme:

\`\`\`dart
import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: NasikoTheme.lightTheme,
      darkTheme: NasikoTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}
\`\`\`

### 3. Use components

\`\`\`dart
PrimaryButton(
  onPressed: () => print('Pressed!'),
  label: 'Get Started',
  leadingIcon: Icons.arrow_forward,
)
\`\`\`

## Documentation

- [Design Tokens](tokens/README.md) - Colors, Typography, Spacing, and more
- [Components](components/README.md) - All available UI components

## Package Structure

\`\`\`
lib/
├── nasiko_ui.dart              # Main barrel file
└── src/
    ├── components/             # UI Components
    │   ├── accordion/
    │   ├── avatar/
    │   ├── banner/
    │   ├── breadcrumb/
    │   ├── buttons/
    │   ├── checkbox/
    │   ├── divider/
    │   ├── input_fields/
    │   ├── list/
    │   ├── menu/
    │   ├── modal/
    │   ├── switch/
    │   ├── table/
    │   ├── tabs/
    │   └── toast/
    ├── theme/                  # Theme configuration
    └── tokens/                 # Design tokens
        ├── colors/
        ├── typography.dart
        ├── spacing.dart
        ├── radius.dart
        ├── border_width.dart
        └── icon_size.dart
\`\`\`

## Requirements

- Dart SDK: ^3.9.0
- Flutter: >=1.17.0

## License

MIT License - see LICENSE file for details.
