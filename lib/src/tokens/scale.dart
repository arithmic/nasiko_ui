// This file holds the raw numeric primitives of the design system.
//
// It is the bottom layer of the token architecture:
//   scale/* (raw)  ->  font/size/*, font/lineheight/*, space/* (tiers)
//                  ->  font/[role]/* (role)  ->  text style
//
// Spacing, typography, and (in future) icon sizing reference these
// primitives so that editing a single raw value cascades everywhere it
// is consumed. Mirrors how `_color_palette.dart` holds raw color values.

/// Raw numeric scale primitives, in logical pixels.
///
/// Only the steps actually consumed by the tier layers are defined.
const double scale0 = 0.0;
const double scale1 = 1.0;
const double scale2 = 2.0;
const double scale4 = 4.0;
const double scale5 = 5.0;
const double scale6 = 6.0;
const double scale7 = 7.0;
const double scale8 = 8.0;
const double scale12 = 12.0;
const double scale13 = 13.0;
const double scale14 = 14.0;
const double scale16 = 16.0;
const double scale18 = 18.0;
const double scale20 = 20.0;
const double scale24 = 24.0;
const double scale28 = 28.0;
const double scale32 = 32.0;
const double scale36 = 36.0;
const double scale40 = 40.0;
const double scale48 = 48.0;
const double scale64 = 64.0;
const double scale80 = 80.0;
