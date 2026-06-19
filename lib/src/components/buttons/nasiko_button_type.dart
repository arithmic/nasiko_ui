/// Emphasis axis for [NasikoButton] / [NasikoIconButton].
///
/// Mirrors the DESIGN-2 Figma `Type` property. `link` is a Flutter-only
/// affordance kept for inline navigation actions (text-only, underlined).
enum NasikoButtonType { primary, secondary, tertiary, ghost, link }

/// Intent axis for [NasikoButton] / [NasikoIconButton].
///
/// `destructive` is only styled for [NasikoButtonType.primary] and
/// [NasikoButtonType.secondary]; it is ignored (with a debug assert) for
/// tertiary, ghost, and link.
enum NasikoButtonTone { default_, destructive }
