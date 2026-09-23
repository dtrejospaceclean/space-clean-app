import 'package:flutter/widgets.dart';

/// Space Clean's interface tokens: a soft gray ground, white rounded cards
/// with no borders or shadows, near-black ink and actions, logo navy as the
/// strong accent, brand orange as the highlight.
abstract final class SpaceColors {
  /// Page background.
  static const ground = Color(0xFFF1F1F3);

  /// Cards, fields, the bottom bar.
  static const surface = Color(0xFFFFFFFF);

  /// Recessed areas inside a card (inputs on white, tracks).
  static const sunken = Color(0xFFF4F4F6);
  static const line = Color(0xFFE6E6EA);

  static const ink = Color(0xFF111114);

  /// Secondary text on white and on the ground (5.3:1 on white).
  static const inkMuted = Color(0xFF6B6B75);

  /// Second tone of large headlines, chevrons and field outlines
  /// (3.5:1 on the ground, 3.9:1 on white: large text and UI parts only).
  static const inkSoft = Color(0xFF80808A);

  /// Disabled controls only (exempt from contrast minimums).
  static const inkFaint = Color(0xFFA2A2AB);

  /// Logo navy: banners, active states, progress, links.
  static const accent = Color(0xFF0A4781);
  static const accentSoft = Color(0xFFDCE8F6);
  static const onAccent = Color(0xFFFFFFFF);

  /// Brand orange: highlights and "in progress".
  static const highlight = Color(0xFFC2410C);
  static const highlightSoft = Color(0xFFFCE7DC);

  /// Text/icons on [highlightSoft] (6.1:1).
  static const highlightInk = Color(0xFF9A3412);

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
