import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'gallery_scaffold.dart';

void main() {
  runApp(const GalleryApp());
}

/// Nasiko UI component gallery.
///
/// The review surface for design/motion changes and the manual QA bed for
/// dark mode: every public nasiko_ui component, in every meaningful state.
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  ThemeMode _themeMode = ThemeMode.light;
  NasikoColorPalette _palette = NasikoColorPalette.yellow;

  @override
  Widget build(BuildContext context) {
    // Mirrors the consumer app's ScreenUtil setup (nasiko_ui re-exports
    // flutter_screenutil; token values like 16.sp depend on it).
    return ScreenUtilInit(
      designSize: const Size(1512, 1024),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Nasiko UI Gallery',
          debugShowCheckedModeBanner: false,
          theme: NasikoTheme.fromPalette(
            palette: _palette,
            brightness: Brightness.light,
          ),
          darkTheme: NasikoTheme.fromPalette(
            palette: _palette,
            brightness: Brightness.dark,
          ),
          themeMode: _themeMode,
          home: GalleryScaffold(
            themeMode: _themeMode,
            palette: _palette,
            onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
            onPaletteChanged: (palette) => setState(() => _palette = palette),
          ),
        );
      },
    );
  }
}
