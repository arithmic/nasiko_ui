// test/helpers/harness.dart
//
// Shared test harness for the nasiko_ui test suite.
//
// Every widget in this package may resolve dimensions through
// flutter_screenutil (`.w` / `.h` / `.sp`), so ScreenUtil MUST be configured
// before any Nasiko theme or widget is built. The harness does this twice,
// belt and braces:
//   1. `ScreenUtil.configure(...)` before pumping (so `NasikoTheme.lightTheme`
//      — whose typography calls `.sp` — can be evaluated safely), and
//   2. a `ScreenUtilInit` ancestor in the pumped tree (the supported runtime
//      path, kept in sync with the design size below).
//
// Determinism rules baked in here:
//   * No network images are ever loaded (no widget in this suite uses one).
//   * The window size and devicePixelRatio are pinned per test and reset in
//     tear-down, so goldens are stable across machines.
//   * Callers finish one-shot animations with explicit `tester.pump(...)`
//     durations or `pumpAndSettle()`; NEVER `pumpAndSettle` while a repeating
//     animation (skeleton shimmer, indeterminate progress, spinner) is on
//     screen — it will time out. Use fixed pumps there.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// The design canvas the package was specced against.
const Size kNasikoDesignSize = Size(1512, 1024);

/// Default logical test surface. Close to (but intentionally not equal to)
/// the design size, so ScreenUtil scaling stays exercised in most tests.
const Size kNasikoDefaultSurface = Size(1400, 900);

/// Key of the [RepaintBoundary] captured by [expectGolden].
const Key kGoldenBoundaryKey = ValueKey<String>('nasiko-golden-boundary');

/// Finder for the golden capture boundary created by [goldenFrame].
Finder get goldenBoundaryFinder => find.byKey(kGoldenBoundaryKey);

/// Pins the test window to [surface] (dpr 1.0) and configures ScreenUtil.
/// Resets both in tear-down so tests never leak window state.
Future<void> _configureSurface(WidgetTester tester, Size surface) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Pre-configure so `.sp`/`.w`/`.h` are usable even before ScreenUtilInit's
  // first build (NasikoTheme getters run inside the app builder regardless).
  ScreenUtil.configure(
    data: MediaQueryData(size: surface),
    designSize: kNasikoDesignSize,
    minTextAdapt: true,
    splitScreenMode: false,
  );
}

Widget _app({required Widget home, required ThemeMode brightness}) {
  return ScreenUtilInit(
    designSize: kNasikoDesignSize,
    minTextAdapt: true,
    splitScreenMode: false,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: NasikoTheme.lightTheme,
      darkTheme: NasikoTheme.darkTheme,
      themeMode: brightness,
      home: home,
    ),
  );
}

/// Pumps [child] centered on a Nasiko-themed [Scaffold].
///
/// [brightness] selects the light or dark package theme. [surface] pins the
/// logical window size for the test. One extra frame is pumped so
/// post-frame callbacks scheduled during the first build have run.
Future<void> pumpNasiko(
  WidgetTester tester,
  Widget child, {
  ThemeMode brightness = ThemeMode.light,
  Size surface = kNasikoDefaultSurface,
}) async {
  await _configureSurface(tester, surface);
  await tester.pumpWidget(
    _app(
      home: Scaffold(body: Center(child: child)),
      brightness: brightness,
    ),
  );
  await tester.pump();
}

/// Variant of [pumpNasiko] for overlay components (select, combobox, popup
/// menu, popover, modal/palette launchers).
///
/// The child is anchored top-left with padding, leaving the rest of the
/// surface free for the overlay to open into (menus open downward by
/// default and flip when space is tight — anchoring at the top keeps the
/// downward path deterministic).
Future<void> pumpNasikoOverlayHost(
  WidgetTester tester,
  Widget child, {
  ThemeMode brightness = ThemeMode.light,
  Size surface = kNasikoDefaultSurface,
}) async {
  await _configureSurface(tester, surface);
  await tester.pumpWidget(
    _app(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
      brightness: brightness,
    ),
  );
  await tester.pump();
}

/// Wraps [child] for golden capture: a keyed [RepaintBoundary] painting the
/// theme's base background behind the widget (so dark-mode goldens are
/// legible and the PNG has no transparent halo).
Widget goldenFrame(Widget child) {
  return RepaintBoundary(
    key: kGoldenBoundaryKey,
    child: Builder(
      builder: (context) => ColoredBox(
        color: context.colors.backgroundBase,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    ),
  );
}

/// Compares the [goldenFrame] boundary against `goldens/<name>.png`
/// (relative to the calling test file's directory).
Future<void> expectGolden(WidgetTester tester, String name) async {
  await expectLater(
    goldenBoundaryFinder,
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Captures the whole app surface (including overlays, dialogs, and
/// popovers, which render outside any widget-level [RepaintBoundary]).
/// Prefer a small [surface] when using this so the PNG stays compact.
Future<void> expectFullScreenGolden(WidgetTester tester, String name) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Returns the theme-mode suffix used in golden file names.
String brightnessSuffix(ThemeMode mode) =>
    mode == ThemeMode.dark ? 'dark' : 'light';

/// The two theme modes every golden is captured in.
const List<ThemeMode> kGoldenThemeModes = <ThemeMode>[
  ThemeMode.light,
  ThemeMode.dark,
];
