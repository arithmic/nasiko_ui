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
