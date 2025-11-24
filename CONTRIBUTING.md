# Contributing to Nasiko UI

Thank you for contributing to the Nasiko UI design system! This guide will help you add new tokens, components, or improvements.

## Adding New Design Tokens

### 1. Token Principles

Before adding a new token, ensure it follows these principles:

- **Semantic naming**: Name describes the purpose, not the value
- **Reusable**: The token will be used in multiple places
- **Consistent**: Follows existing scale patterns
- **Documented**: Clear description of when to use it

### 2. Adding a Color Token

Edit `lib/src/tokens/colors/colors.dart`:

\`\`\`dart
@immutable
class NasikoColorTheme extends ThemeExtension<NasikoColorTheme> {
  const NasikoColorTheme({
    // ... existing parameters ...
    required this.backgroundCustom,  // Add new parameter
  });

  // ... existing fields ...
  final Color backgroundCustom;  // Add new field
}

// Update lightColors constant
const NasikoColorTheme lightColors = NasikoColorTheme(
  // ... existing values ...
  backgroundCustom: customColor,
);

// Update darkColors constant
const NasikoColorTheme darkColors = NasikoColorTheme(
  // ... existing values ...
  backgroundCustom: darkCustomColor,
);
\`\`\`

### 3. Adding Spacing Token

Edit `lib/src/tokens/spacing.dart`:

\`\`\`dart
class NasikoSpacing extends ThemeExtension<NasikoSpacing> {
  const NasikoSpacing({
    // ... existing parameters ...
    required this.newSpacing,  // Add new spacing
  });

  // ... existing fields ...
  final double newSpacing;
}

const NasikoSpacing defaultNasikoSpacing = NasikoSpacing(
  // ... existing values ...
  newSpacing: 48.0,  // Your spacing value
);
\`\`\`

### 4. Adding Typography Token

Edit `lib/src/tokens/typography.dart`:

\`\`\`dart
class NasikoTypography extends ThemeExtension<NasikoTypography> {
  const NasikoTypography({
    // ... existing parameters ...
    required this.captionXS,  // Add new style
  });

  // ... existing fields ...
  final TextStyle captionXS;
}

const NasikoTypography defaultNasikoTypography = NasikoTypography(
  // ... existing values ...
  captionXS: TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
  ),
);
\`\`\`

## Adding Tests

For every new token, add corresponding tests to `test/nasiko_ui_test.dart`:

\`\`\`dart
group('New Token Group', () {
  test('New token is not null', () {
    expect(context.colors.backgroundCustom, isNotNull);
  });

  test('New token has correct value', () {
    expect(context.colors.backgroundCustom, equals(expectedColor));
  });

  test('New token works in both themes', () {
    final lightValue = lightColors.backgroundCustom;
    final darkValue = darkColors.backgroundCustom;
    expect(lightValue, isNotNull);
    expect(darkValue, isNotNull);
  });
});
\`\`\`

Run tests:

\`\`\`bash
flutter test
\`\`\`

All tests must pass before submitting a PR.

## Documentation

1. **Update TOKENS.md** - Add token reference in appropriate section
2. **Update README.md** - Add usage example if widely used
3. **Update Comments** - Add inline documentation in source files

Example:

\`\`\`dart
/// Custom background color for special branded sections.
///
/// Supports light and dark theme variants.
///
/// Light: [customLight]
/// Dark: [customDark]
final Color backgroundCustom;
\`\`\`

## Code Quality

### Style Guide

- Use trailing commas for multi-line lists/parameters
- Use const where possible (immutability)
- Avoid magic numbers - use token values instead
- Add comments for non-obvious logic

### Naming Conventions

**Colors:**

- Background: `background{Category}{Variant}`
- Foreground: `foreground{Category}{Variant}`
- Border: `border{Category}{Variant}`

**Other Tokens:**

- Scales: `xxs`, `xs`, `sm`, `md`, `lg`, `xl`, `2xl`, etc.
- Styles: `headingXL`, `bodyLG`, `labelSM`, etc.

**Categories:**

- `Brand`, `Primary`, `Secondary`, `Success`, `Error`, `Warning`, `Information`

## Before Submitting

1. Run `flutter analyze` - Check for lint issues
2. Run `flutter test` - All tests must pass
3. Run `flutter format lib/` - Format code
4. Update documentation
5. Test in light and dark themes

## PR Checklist

- [ ] New token follows naming conventions
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] Code formatted
- [ ] Works in light and dark themes
- [ ] No breaking changes to existing API

## Questions?

Refer to existing tokens for patterns and examples. When in doubt, check similar tokens in the codebase.
