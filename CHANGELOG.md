## 0.1.0

### Color system overhaul (WCAG-verified)

**Accessibility (measured, all 16 palette × brightness variants):**

- Brand fills now pair with a per-palette `foregroundOnBrand` (dark ink on light hues, white on dark hues) — every combination ≥4.5:1; light-hue palettes rest on the brighter 500 weight
- Brand text/links moved to contrast-safe weights (700/600 light, 300 dark) — previously 2.98:1 on white for yellow
- Feedback foregrounds now AA on their tinted backgrounds (700-weight light, 300-weight dark)
- Fixed dark-theme tooltip/inverse overlay (was a translucent 1.64:1 surface; now opaque, 9.96:1); `NasikoTooltip` and rail tooltips use the overlay pair
- Material `ColorScheme` is now derived 1:1 from `NasikoColorTheme` (`NasikoColorSchemeFactory.fromNasikoColors`) — fixes inverted error roles, the 500/600 primary mismatch, and unreadable `onSurfaceVariant`/`onTertiary` combinations
- Destructive button hover reds are theme-resolved (hardcoded red700 measured 2.83:1 in dark)
- New `test/contrast_guard_test.dart` CI gate sweeps every token pairing

**New tokens:**

- `foregroundOnBrand`, `foregroundErrorHover`, `borderFocus`, `borderInput`, `backgroundSuccessSubtle` / `backgroundWarningSubtle` / `backgroundErrorSubtle` (all optional with safe fallbacks)
- `NasikoElevationTheme` (`context.elevation.low/overlay/modal`) — warm-tinted shadows in light, surface-ramp-led dark; replaces all hand-rolled `BoxShadow`s (including the banner's off-palette slate)

**Color-theory changes:**

- Information is a fixed blue in every palette (was brand-derived — semantics changed with the brand)
- New warm near-black `foregroundPrimary`/`foregroundConstantBlack` (sandInk #26211C), hue-matched to the sand surfaces; constant tokens now identical across themes
- Interaction states follow an adjacent-ramp-step rule; disabled fills/borders no longer collide with hover
- Unified neutral scrim (`backgroundOverlay`, black 45%/60%) used by all sheets/modals/dialogs
- Keyboard focus rings use dedicated `borderFocus` (distinct from hover); form controls use the stronger `borderInput` tier

**Defaults:** `lightColors`/`darkColors` and `lightColorScheme`/`darkColorScheme` are now delegated to the factories (no drift possible). `lightColorScheme`/`darkColorScheme` changed from `const` to `final`.

## 0.0.1

### Initial Release

**Design Tokens:**

- Color tokens with light and dark theme support (68 semantic colors)
- Spacing tokens (13 values: s0 to s80)
- Typography tokens (13 text styles with Inter and Chivo Mono fonts)
- Border radius tokens (8 values: r0 to r40)
- Border width tokens (5 values: w0 to w8)
- Icon size tokens (4 values: xs, s, m, l)

**Theme System:**

- `NasikoTheme.lightTheme` and `NasikoTheme.darkTheme` configurations
- Material 3 ColorScheme integration
- BuildContext extensions for convenient token access

**Button Components:**

- `PrimaryButton` - Filled button with brand colors
- `SecondaryButton` - Outlined button with hover fill
- `PrimaryTextButton` - Text-only button with brand colors
- `SecondaryTextButton` - Text-only button with neutral colors
- `PrimaryIconButton` - Icon-only button with brand colors
- `SecondaryIconButton` - Icon-only button with outlined style

**Features:**

- Three button sizes: large, medium, small
- Full state support: default, hover, focus, disabled
- Optional leading and trailing icons
- Smooth state transitions
\`\`\`

```text file="LICENSE"
MIT License

Copyright (c) 2024 Nasiko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
