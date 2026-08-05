# Nasiko UI Gallery

A dependency-free component gallery for the `nasiko_ui` design system — the
review surface for design/motion changes and the manual QA bed for dark mode.

## Run it

```bash
cd example
flutter run -d chrome
```

## What's inside

- Every public `nasiko_ui` component, one page per component area, with
  labeled sections per state (Default / Disabled / Loading / …).
- A toolbar with a light/dark/system theme toggle and a `NasikoColorPalette`
  switcher (both built with `NasikoSelect`).
- A Motion page that replays entrance animations (skeleton → content swap,
  built-in reveals, progress sweep) against the `context.motion` tokens.

## Ground rules baked into the code

- Only the public API: everything imports `package:nasiko_ui/nasiko_ui.dart`;
  no `src/` deep imports and no extra packages. APIs like icon buttons and
  rail items require `HugeIconsType` values, so `lib/gallery_icons.dart`
  hand-rolls a small 24×24 stroke-icon set in the same
  `[element, attributes]` data format the published HugeIcons constants use
  (the typedef is re-exported through the nasiko_ui barrel) — every icon is
  funnelled through that one file.
- No hardcoded colors — `context.colors` tokens everywhere.
- Buttons rendered as a group always share one `NasikoButtonSize`.
- All demo data is fake and inline; the gallery works fully offline.

Note on fonts: nasiko_ui deliberately ships no font assets, so the gallery
falls back to the platform default instead of Inter / Chivo Mono. Declare the
families in your own app (see the note in `nasiko_ui/pubspec.yaml`).
