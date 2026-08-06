# internal/ — shared interaction primitives

Library-internal building blocks. Nothing here is exported from
`lib/nasiko_ui.dart`; components import these with relative paths.

Built on Nasiko tokens/motion with no added dependencies. See NOTICE at the
repo root for third-party attributions.

## Files

- **`anchored_overlay.dart`** — `NasikoAnchoredOverlay`, the anchored-overlay
  engine (OverlayPortal + declarative `visible`), plus
  `NasikoAnchoredPositionDelegate`. Used by `NasikoPopover`.
- **`interaction_states.dart`** — `NasikoInteractionStates`, one widget
  tracking hovered/pressed/focused/disabled together
  (FocusableActionDetector + translucent Listener + GestureDetector),
  with Enter/Space activation and an opt-in press-scale hook matching
  `ButtonPressScale`. Standard base for future interactive components.
- **`overlay_reveal.dart`** — `NasikoOverlayReveal`, the shared one-shot
  entrance (fade + 4px slide, `motion.base`/`motion.enter`, reduced-motion
  aware). The anchored-overlay engine applies it automatically,
  direction-aware from the resolved side.

## Anchor model (sealed `NasikoAnchorBase`)

- **`NasikoAutoAnchor`** — preferred `side` + cross-axis `alignment`, `gap`,
  `offset`, `screenPadding`. Measured positioning: the delegate receives the
  surface's laid-out size, flips to the opposite side on overflow, and clamps
  to padded screen bounds (no invisible measuring frame — measurement
  happens inside the layout delegate in a single pass). The anchor rect is
  re-measured on scroll and window resize.
- **`NasikoManualAnchor`** — pure `CompositedTransformFollower`
  (target/follower alignment + offset). Paint-time accurate, no flip/clamp.
- **`NasikoGlobalAnchor`** — absolute point in overlay coordinates (zero-size
  anchor) with the same flip + clamp pipeline. For right-click / long-press
  context menus.

The `overlayBuilder` receives the **resolved** side (post-flip), for arrows
or side-dependent styling. Dismissal (tap-outside, Escape, focus restore)
deliberately stays with the caller — the engine is positioning + entrance
only.

## Migration notes: menu / select (later wave)

- `NasikoPopupMenu` (`menu/menu.dart`): replace its hand-rolled
  `OverlayEntry` + `Positioned` math with `NasikoAnchoredOverlay(visible:,
  anchor: NasikoAutoAnchor(side: bottom, alignment: end, gap: spacing.s4))`
  — its "right-align, flip left on clip" behavior maps to `alignment: end`
  plus the engine's clamping; its `openUpward` heuristic becomes the exact
  measured flip. The full-screen barrier `GestureDetector` becomes a
  `TapRegion` pair (see popover). Keep its `FocusScope`/arrow-key layer
  as the overlay content.
- `NasikoSelect` / combobox (`select/select.dart`): same shape; pass the
  field width via the surface, use `alignment: start`. Gains horizontal
  clamping for narrow viewports.
- Menu items / options are candidates for `NasikoInteractionStates`
  (replaces per-item MouseRegion + FocusableActionDetector wiring).
