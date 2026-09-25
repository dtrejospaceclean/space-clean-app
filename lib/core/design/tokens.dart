import 'package:flutter/material.dart';

/// Space Clean's interface colors, as a theme extension with a [light] and
/// a [dark] palette. Read them with `context.colors` so widgets follow the
/// active theme.
///
/// Every color comes from the Space Clean logo: navy #0A4781, orange
/// #F45302, and its blue-gray tints (#7F9FBD, #CAD7E4, #EAEFF4). Contrast
/// notes below are for the light palette; the dark one meets the same
/// minimums against its own surfaces.
@immutable
class SpaceColors extends ThemeExtension<SpaceColors> {
  const SpaceColors({
    required this.ground,
    required this.surface,
    required this.sunken,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.inkSoft,
    required this.inkFaint,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.highlight,
    required this.highlightSoft,
    required this.highlightInk,
    required this.success,
    required this.successSoft,
    required this.successInk,
    required this.danger,
    required this.dangerSoft,
  });

  /// Blue-gray ground, white cards.
  static const light = SpaceColors(
    ground: Color(0xFFEEF2F6),
    surface: Color(0xFFFFFFFF),
    sunken: Color(0xFFF4F7FA),
    line: Color(0xFFDCE4EC),
    ink: Color(0xFF0B1F33),
    inkMuted: Color(0xFF56677B),
    inkSoft: Color(0xFF66809C),
    inkFaint: Color(0xFFA9B8C8),
    primary: Color(0xFFD14702),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF0A4781),
    accentSoft: Color(0xFFE3EBF4),
    onAccent: Color(0xFFFFFFFF),
    highlight: Color(0xFFF45302),
    highlightSoft: Color(0xFFFEEDE3),
    highlightInk: Color(0xFFA83A02),
    success: Color(0xFF15803D),
    successSoft: Color(0xFFDDF3E4),
    successInk: Color(0xFF166534),
    danger: Color(0xFFB91C1C),
    dangerSoft: Color(0xFFFDE8E8),
  );

  /// Night navy ground, slightly lifted navy cards. The logo navy is too
  /// dark to read here, so [accent] becomes its light tint (8.1:1 on the
  /// surface) with navy text on top. The orange action color stays.
  static const dark = SpaceColors(
    ground: Color(0xFF0B1420),
    surface: Color(0xFF152232),
    sunken: Color(0xFF0F1A27),
    line: Color(0xFF26384C),
    ink: Color(0xFFE9EFF5),
    inkMuted: Color(0xFFA6B6C7),
    inkSoft: Color(0xFF7E97B1),
    inkFaint: Color(0xFF4B5E73),
    primary: Color(0xFFD14702),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF8FBCEB),
    accentSoft: Color(0xFF1A3450),
    onAccent: Color(0xFF0B1F33),
    highlight: Color(0xFFF45302),
    highlightSoft: Color(0xFF3B2013),
    highlightInk: Color(0xFFFFA474),
    success: Color(0xFF4ADE80),
    successSoft: Color(0xFF12301F),
    successInk: Color(0xFF86EFAC),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF3A1719),
  );

  /// Page background.
  final Color ground;

  /// Cards, fields, the bottom bar.
  final Color surface;

  /// Recessed areas inside a card (inputs, tracks).
  final Color sunken;
  final Color line;

  /// Text: navy-black on light (16.7:1 on white).
  final Color ink;

  /// Secondary text (5.8:1 on white, 5.2:1 on the ground).
  final Color inkMuted;

  /// Second tone of large headlines, chevrons and field outlines (large
  /// text and UI parts only: 4.1:1 on white).
  final Color inkSoft;

  /// Disabled controls only (exempt from contrast minimums).
  final Color inkFaint;

  /// The logo orange deepened to carry white text (4.55:1). Buttons, round
  /// "+" buttons, selected pills and toggles, the active tab, focus rings.
  /// Use as a fill or on surfaces, not as small text.
  final Color primary;
  final Color onPrimary;

  /// Logo navy (light) or its tint (dark): links, progress, banners, strong
  /// badges, info.
  final Color accent;
  final Color accentSoft;

  /// Text and icons on an [accent] fill.
  final Color onAccent;

  /// Logo orange as drawn in the logo: graphic marks only. Orange text uses
  /// [highlightInk]; orange fills behind text use [primary].
  final Color highlight;
  final Color highlightSoft;

  /// Orange text/icons on [highlightSoft].
  final Color highlightInk;

  final Color success;
  final Color successSoft;

  /// Text/icons on [successSoft].
  final Color successInk;
  final Color danger;
  final Color dangerSoft;

  static SpaceColors of(BuildContext context) =>
      Theme.of(context).extension<SpaceColors>() ?? light;

  @override
  SpaceColors copyWith() => this;

  @override
  SpaceColors lerp(SpaceColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SpaceColors(
      ground: l(ground, other.ground),
      surface: l(surface, other.surface),
      sunken: l(sunken, other.sunken),
      line: l(line, other.line),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      inkSoft: l(inkSoft, other.inkSoft),
      inkFaint: l(inkFaint, other.inkFaint),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      onAccent: l(onAccent, other.onAccent),
      highlight: l(highlight, other.highlight),
      highlightSoft: l(highlightSoft, other.highlightSoft),
      highlightInk: l(highlightInk, other.highlightInk),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      successInk: l(successInk, other.successInk),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
    );
  }
}

extension SpaceColorsContext on BuildContext {
  /// The active theme's [SpaceColors].
  SpaceColors get colors => SpaceColors.of(this);
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
