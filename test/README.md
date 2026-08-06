# nasiko_ui test suite

## Layout

| Path | What lives there |
| --- | --- |
| `helpers/harness.dart` | Shared pump helpers (`pumpNasiko`, `pumpNasikoOverlayHost`), golden frame/capture helpers, window pinning. |
| `goldens/` | Golden (screenshot) tests, light + dark per frame. Baselines land in `goldens/goldens/*.png`. `parity_golden_test.dart` covers the advanced interaction components (slider, toggle group, input OTP, alert). |
| `behavior/` | Interaction tests: select, combobox, popup menu, modal, data table, calendar, command palette, field — plus the parity wave: slider, toggle group, input OTP, context menu, hover card, resizable, time picker. |
| `a11y/` | Semantics assertions and `meetsGuideline` checks. `parity_a11y_test.dart` covers slider/toggle/OTP/context-menu semantics. |
| `nasiko_ui_test.dart`, `text_box_test.dart` | Pre-existing package tests (theme/tokens, text box focus). |

## Running

```sh
flutter test                      # everything
flutter test test/behavior        # interaction tests only
flutter test test/goldens         # golden comparisons only
flutter test test/a11y            # semantics / guidelines only
```

## Goldens

Baseline PNGs are **not committed yet** — the first run of `test/goldens`
will fail until baselines are generated:

```sh
flutter test --update-goldens test/goldens
```

Commit the generated `test/goldens/goldens/*.png` files.

**Platform sensitivity:** golden rendering differs subtly across host
platforms (text anti-aliasing, shadow rasterization). Generate and compare
baselines on ONE canonical platform — whichever runs CI — and regenerate
there rather than mixing macOS/Linux/Windows baselines. If contributors run
goldens locally on a different OS, expect noise; treat CI as the source of
truth (or guard golden tests behind a platform check if this ever becomes a
problem).

Note the package intentionally bundles no fonts (see `pubspec.yaml`); tests
render with the test framework's default font, which is deterministic per
platform.

## Harness conventions

- Always pump through `pumpNasiko` (centered child on a themed Scaffold) or
  `pumpNasikoOverlayHost` (top-left anchored, for anything that opens an
  overlay: select, combobox, popup menu, popover, dialogs/palettes). Both
  configure ScreenUtil (design size 1512×1024) **before** any Nasiko widget
  or theme getter runs, and pin the window (default 1400×900, dpr 1.0) with
  tear-down resets.
- Goldens wrap content in `goldenFrame(...)` and capture with
  `expectGolden(tester, name)`; overlay frames that render outside the
  widget boundary use `expectFullScreenGolden` with a small `surface:`.
- Every golden is captured in both theme modes via `kGoldenThemeModes` +
  `brightnessSuffix`.

## Determinism rules

- **Never `pumpAndSettle` while a repeating animation is on screen**: the
  skeleton shimmer (`NasikoSkeletonScope`, data-table `isLoading`), spinners
  (`NasikoSpinner` / `CircularProgressIndicator`), indeterminate progress,
  and a blinking caret in golden captures (pin
  `EditableText.debugDeterministicCursor` there instead). Use fixed
  `tester.pump(Duration(...))` steps.
- Motion tokens used for bounded pumps: hover 120 ms, fast 150 ms,
  base 200 ms, panel 250 ms, page 300 ms. Field/table helper transitions run
  at `fast`; month swaps and dialog entrances at `base`.
- The combobox debounce is a real 250 ms timer: advance it explicitly and
  **flush it before the test ends** (a pending timer fails the test).
- Prefer specific finders (exact cell text, `find.descendant`, recorded
  positions) over index-based `find.byType(...).at(n)` where the widget set
  mutates (e.g. the data-table header checkbox is swapped for a private
  dash widget when the page is partially selected).
- Calendar tests pin `initialMonth`/`selected` (August 2026) so nothing
  depends on `DateTime.now()`. Only the visual "today" marker is
  date-dependent, and no test or golden asserts it.

## Known first-run risks / flaky candidates

Written statically (no local Flutter SDK); check these on the first real run:

1. **Golden baselines missing** — expected; generate with
   `--update-goldens` (see above).
2. **`a11y/a11y_test.dart` semantics-node targeting** — `tester.getSemantics`
   walks up from excluded text to the owning node (select trigger, menu
   items). If a Flutter upgrade changes node boundaries, retarget the finder
   rather than loosening the matcher.
3. **`containsSemantics(isExpanded: ...)`** on the select trigger requires
   the Flutter version to expose the expanded flag through the matcher
   (Flutter ≥ 3.16; the pinned SDK is far newer).
4. **Calendar keyboard tests** focus the grid via
   `Focus.of(day-cell context)` — relies on the grid being the nearest
   `Focus` ancestor of a day cell. If the widget grows an inner Focus,
   switch to sending Tab traversal instead.
5. **Command palette Enter test** asserts callback-after-pop ordering
   (`['closed', 'selected:…']`). The `closed` entry resolves from the dialog
   future; if ordering flakes, assert set membership plus palette-closed
   instead.
6. **Combobox debounce boundary test** (existing) pumps 249 ms + 1 ms; exact
   timer boundaries are usually stable under fake async but this is the
   sharpest timing assert in the suite.
7. **Data-table indeterminate test** re-taps the header checkbox by its
   recorded screen position (the dash replacement is a private widget).
   If layout shifts between states, the tapAt misses — recapture the
   position after each state change.
8. **Skipped tests document lib gaps, not test debt**: `NasikoCheckbox` /
   `NasikoRadio` expose no checked-state semantics, and 28 px small buttons
   cannot meet the android 48 dp tap-target guideline. Unskip alongside the
   lib fixes.
9. **Anchored-overlay portal sync is post-frame** (context menu, hover
   card, time-field popover): visibility changes need TWO pumps — one for
   the frame that flips the flag, one for the portal's rebuild. Timer
   boundaries in `hover_card_test.dart` therefore pump `duration` + one
   extra frame.
10. **Parity-suite geometry assumptions**: the slider maps pointer x with
    `thumbBox = spacing.s28` read as a raw 28 (unscaled) and the resizable
    divider is `spacing.s8` = 8 px wide; drag asserts in
    `resizable_test.dart` rely on clamped drags landing exactly on min/max
    (slop-independent). If the spacing tokens are ever ScreenUtil-scaled,
    recompute the surface widths.
11. **Private-type finders**: context-menu (`_NasikoContextMenuSurface`,
    `_NasikoContextMenuDividerTile`) and resizable (`_ResizableDivider`)
    tests locate internals via `runtimeType.toString()` predicates — rename
    the lib classes and these finders must follow.
12. **OTP backspace test** drives `EditableText`'s hardware-key delete
    path (`sendKeyEvent(backspace)`); if a Flutter upgrade changes that
    plumbing, fall back to `enterText` with the shortened code.
