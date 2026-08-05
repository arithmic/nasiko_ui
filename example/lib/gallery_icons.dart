// Gallery-local icon data — the example depends on nothing but nasiko_ui.
//
// Several nasiko_ui APIs (icon buttons, navigation rail items, command
// items, empty states, …) take `HugeIconsType` values. `HugeIconsType` is a
// plain data typedef (`List<List<dynamic>>`) re-exported through the
// nasiko_ui barrel: each element is `[svgElementName, attributeMap]`,
// rendered by nasiko_ui on a 24×24 viewBox with `currentColor` strokes —
// exactly the shape of the published HugeIcons constants.
//
// Rather than adding a direct hugeicons dependency, the gallery hand-rolls a
// small set of 24×24 stroke icons in that same format. Purely decorative;
// swap in real HugeIcons constants when copying snippets into an app.
import 'package:nasiko_ui/nasiko_ui.dart';

/// Shared stroke attributes matching the HugeIcons stroke-rounded style.
Map<String, String> _stroke(String key, String d) => {
      'key': key,
      'd': d,
      'stroke': 'currentColor',
      'strokeWidth': '1.5',
      'strokeLinecap': 'round',
      'strokeLinejoin': 'round',
    };

const Map<String, String> _circleAttrs = {
  'key': '0',
  'cx': '12',
  'cy': '12',
  'r': '9',
  'stroke': 'currentColor',
  'strokeWidth': '1.5',
  'strokeLinecap': 'round',
  'strokeLinejoin': 'round',
};

/// Plus inside a circle.
final HugeIconsType kIconAdd = [
  ['circle', _circleAttrs],
  ['path', _stroke('1', 'M12 8V16M8 12H16')],
];

/// Right-pointing arrow.
final HugeIconsType kIconArrowRight = [
  ['path', _stroke('0', 'M4 12H20M14 6L20 12L14 18')],
];

/// Magnifying glass.
final HugeIconsType kIconSearch = [
  [
    'path',
    _stroke(
      '0',
      'M17 17L21 21M19 11C19 15.4183 15.4183 19 11 19C6.58172 19 '
          '3 15.4183 3 11C3 6.58172 6.58172 3 11 3C15.4183 3 19 6.58172 '
          '19 11Z',
    ),
  ],
];

/// Person silhouette.
final HugeIconsType kIconUser = [
  [
    'path',
    _stroke(
      '0',
      'M12 11.5C14.2091 11.5 16 9.70914 16 7.5C16 5.29086 14.2091 3.5 '
          '12 3.5C9.79086 3.5 8 5.29086 8 7.5C8 9.70914 9.79086 11.5 '
          '12 11.5ZM5 20.5C5 17.1863 8.13401 14.5 12 14.5C15.866 14.5 '
          '19 17.1863 19 20.5',
    ),
  ],
];

/// Inbox tray.
final HugeIconsType kIconInbox = [
  [
    'path',
    _stroke(
      '0',
      'M3 13L6 5H18L21 13V19H3V13ZM3 13H8L9.5 15.5H14.5L16 13H21',
    ),
  ],
];

/// Document with folded corner and text lines.
final HugeIconsType kIconFile = [
  ['path', _stroke('0', 'M6 3H14L19 8V21H6V3ZM14 3V8H19')],
  ['path', _stroke('1', 'M9 13H16M9 17H13')],
];

/// Trash can.
final HugeIconsType kIconDelete = [
  [
    'path',
    _stroke(
      '0',
      'M4 7H20M9.5 7V4.5H14.5V7M6.5 7L7.5 20.5H16.5L17.5 7M10 11V16.5'
          'M14 11V16.5',
    ),
  ],
];

/// Circular refresh arrow.
final HugeIconsType kIconReload = [
  [
    'path',
    _stroke(
      '0',
      'M20 12C20 16.4183 16.4183 20 12 20C7.58172 20 4 16.4183 4 12C4 '
          '7.58172 7.58172 4 12 4C14.8273 4 17.3172 5.46679 18.7407 7.68213'
          'M19 3.5V7.5H15',
    ),
  ],
];

/// Paper plane.
final HugeIconsType kIconSend = [
  ['path', _stroke('0', 'M21 3L3 10.5L10 13.5M21 3L13.5 21L10 13.5M21 3L10 13.5')],
];

/// Info circle.
final HugeIconsType kIconInfo = [
  ['circle', _circleAttrs],
  ['path', _stroke('1', 'M12 16V11.5M12 8.25H12.01')],
];

/// Check mark.
final HugeIconsType kIconTick = [
  ['path', _stroke('0', 'M5 13L9.5 17.5L19 6.5')],
];

/// Horizontal ellipsis (three dots).
final HugeIconsType kIconMore = [
  ['path', _stroke('0', 'M6 12H6.01M12 12H12.01M18 12H18.01')],
];

/// Warning triangle with exclamation mark.
final HugeIconsType kIconAlert = [
  ['path', _stroke('0', 'M12 4.5L21 20H3L12 4.5Z')],
  ['path', _stroke('1', 'M12 10.5V14.5M12 17.25H12.01')],
];

/// Two overlapping coins.
final HugeIconsType kIconCoins = [
  [
    'path',
    _stroke(
      '0',
      'M9 14.5C12.0376 14.5 14.5 12.0376 14.5 9C14.5 5.96243 12.0376 '
          '3.5 9 3.5C5.96243 3.5 3.5 5.96243 3.5 9C3.5 12.0376 5.96243 '
          '14.5 9 14.5Z',
    ),
  ],
  [
    'path',
    _stroke(
      '1',
      'M9.9 14.4C10.6 17.9 13.7 20.5 17.4 20.5C19.1 20.5 20.5 19.1 '
          '20.5 17.4C20.5 13.7 17.9 10.6 14.4 9.9',
    ),
  ],
];
