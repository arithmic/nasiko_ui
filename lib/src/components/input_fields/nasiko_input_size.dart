/// Size variants for [NasikoInput].
///
/// A real density step: height, value font, padding, content-gap and icon size
/// all change together. (Figma variant values are `m` / `s`.)
enum NasikoInputSize {
  /// Default density — 36px box. Pairs in height with a *large* button.
  medium,

  /// Compact density — 28px box. Pairs in height with a *small* button.
  small,
}
