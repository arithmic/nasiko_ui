import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

void main() {
  runApp(const PaletteSwitcherExample());
}

/// Example demonstrating dynamic palette switching in Nasiko UI.
///
/// This shows how to allow users to switch between different color palettes
/// at runtime, dynamically updating the entire app's theme.
class PaletteSwitcherExample extends StatefulWidget {
  const PaletteSwitcherExample({super.key});

  @override
  State<PaletteSwitcherExample> createState() => _PaletteSwitcherExampleState();
}

class _PaletteSwitcherExampleState extends State<PaletteSwitcherExample> {
  NasikoColorPalette _selectedPalette = NasikoColorPalette.yellow;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1512, 1024),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Nasiko UI - Palette Switcher',
          theme: NasikoTheme.fromPalette(
            palette: _selectedPalette,
            brightness: _isDarkMode ? Brightness.dark : Brightness.light,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Palette Switcher Example'),
              actions: [
                // Dark mode toggle
                IconButton(
                  icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    setState(() {
                      _isDarkMode = !_isDarkMode;
                    });
                  },
                ),
              ],
            ),
            body: Builder(
              builder: (context) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Palette Selector
                      Text(
                        'Select Color Palette',
                        style: context.typography.titleSecondary,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: NasikoColorPalette.values.map((palette) {
                          final isSelected = palette == _selectedPalette;
                          return NasikoChip(
                            label: _getPaletteName(palette),
                            variant: isSelected
                                ? NasikoChipVariant.brand
                                : NasikoChipVariant.neutral,
                            onTap: () {
                              setState(() {
                                _selectedPalette = palette;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // Sample Components
                      Text(
                        'Sample Components',
                        style: context.typography.titleSecondary,
                      ),
                      const SizedBox(height: 16),

                      // Buttons
                      Text('Buttons', style: context.typography.bodyPrimary),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          NasikoButton(
                            type: NasikoButtonType.primary,
                            onPressed: () {},
                            label: 'Primary',
                          ),
                          NasikoButton(
                            type: NasikoButtonType.secondary,
                            onPressed: () {},
                            label: 'Secondary',
                          ),
                          NasikoButton(
                            type: NasikoButtonType.tertiary,
                            onPressed: () {},
                            label: 'Tertiary',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Card with content
                      NasikoCard(
                        title: 'Sample Card',
                        description:
                            'This card demonstrates how the color palette affects all components throughout the design system.',
                      ),
                      const SizedBox(height: 24),

                      // Color Preview
                      Text(
                        'Brand Colors Preview',
                        style: context.typography.bodyPrimary,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ColorBox(
                              color: context.colors.backgroundBrand,
                              label: 'Brand',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ColorBox(
                              color: context.colors.backgroundBrandHover,
                              label: 'Brand Hover',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ColorBox(
                              color: context.colors.backgroundBrandSubtle,
                              label: 'Brand Subtle',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _getPaletteName(NasikoColorPalette palette) {
    switch (palette) {
      case NasikoColorPalette.sand:
        return 'Sand';
      case NasikoColorPalette.yellow:
        return 'Yellow';
      case NasikoColorPalette.orange:
        return 'Orange';
      case NasikoColorPalette.red:
        return 'Red';
      case NasikoColorPalette.purple:
        return 'Purple';
      case NasikoColorPalette.blue:
        return 'Blue';
      case NasikoColorPalette.teal:
        return 'Teal';
      case NasikoColorPalette.green:
        return 'Green';
    }
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.borderPrimary),
      ),
      child: Center(
        child: Text(
          label,
          style: context.typography.bodyTertiary.copyWith(
            color: context.colors.foregroundOnAction,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
