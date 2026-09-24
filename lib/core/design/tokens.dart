import 'package:flutter/widgets.dart';

/// Space Clean's interface tokens: a light blue-gray ground, white rounded
/// cards, logo orange as the primary (action) color, logo navy as secondary.
abstract final class SpaceColors {
  // Every color comes from the Space Clean logo: navy #0A4781, orange
  // #F45302, and its blue-gray tints (#7F9FBD, #CAD7E4, #EAEFF4).

  /// Page background: the logo's lightest blue-gray.
  static const ground = Color(0xFFEEF2F6);

  /// Cards, fields, the bottom bar.
  static const surface = Color(0xFFFFFFFF);

  /// Recessed areas inside a card (inputs on white, tracks).
  static const sunken = Color(0xFFF4F7FA);
  static const line = Color(0xFFDCE4EC);

  /// Text: a navy-black (16.7:1 on white).
  static const ink = Color(0xFF0B1F33);

  /// Secondary text (5.8:1 on white, 5.2:1 on the ground).
  static const inkMuted = Color(0xFF56677B);

  /// Second tone of large headlines, chevrons and field outlines
  /// (3.6:1 on the ground, 4.1:1 on white: large text and UI parts only).
  static const inkSoft = Color(0xFF66809C);

  /// Disabled controls only (exempt from contrast minimums).
  static const inkFaint = Color(0xFFA9B8C8);

  /// Primary: the logo orange deepened just enough to carry white text
  /// (4.55:1). Buttons, round "+" buttons, selected pills and toggles, the
  /// active tab, focus rings. Use on white or as a fill, not as small text
  /// on the ground (4.0:1).
  static const primary = Color(0xFFD14702);
  static const onPrimary = Color(0xFFFFFFFF);

  /// Logo navy, the secondary color: links, progress, banners, strong
  /// badges, info (9.4:1 on white).
  static const accent = Color(0xFF0A4781);
  static const accentSoft = Color(0xFFE3EBF4);
  static const onAccent = Color(0xFFFFFFFF);

  /// Logo orange as drawn in the logo: graphic marks only (3.45:1 on white).
  /// Orange text uses [highlightInk]; orange fills behind text use [primary].
  static const highlight = Color(0xFFF45302);
  static const highlightSoft = Color(0xFFFEEDE3);

  /// Orange text/icons on [highlightSoft] (5.6:1).
  static const highlightInk = Color(0xFFA83A02);

  static const success = Color(0xFF15803D);
  static const successSoft = Color(0xFFDDF3E4);

  /// Text/icons on [successSoft] (6.1:1).
  static const successInk = Color(0xFF166534);
  static const danger = Color(0xFFB91C1C);
  static const dangerSoft = Color(0xFFFDE8E8);
}

abstract final class SpaceRadius {
  static const card = 24.0;
  static const inner = 16.0;
  static const pill = 999.0;
}

abstract final class SpaceSpace {
  /// Page side margin.
  static const page = 20.0;

  /// Gap between cards.
  static const gap = 12.0;

  /// Card inner padding.
  static const card = 20.0;
}
