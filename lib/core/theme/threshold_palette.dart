import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'brand_colors.dart';

/// Colors for the "threshold" screens (splash, sign-in, password reset).
/// Light: white ground with the full-color logo, navy action, orange links.
/// Dark: ember ground with the white logo and a bright-orange action.
@immutable
class ThresholdPalette {
  const ThresholdPalette({
    required this.ground,
    required this.onGround,
    required this.onGroundMuted,
    required this.link,
    required this.field,
    required this.fieldText,
    required this.fieldHint,
    required this.fieldBorder,
    required this.fieldFocus,
    required this.fieldError,
    required this.action,
    required this.onAction,
    required this.noticeError,
    required this.noticeInfo,
    required this.onNotice,
    required this.switchTrack,
    required this.logoAsset,
    required this.systemOverlay,
  });

  static const light = ThresholdPalette(
    ground: Colors.white,
    onGround: Color(0xFF1C1917),
    // Stone 600: 7.6:1 on white.
    onGroundMuted: Color(0xFF57534E),
    // Brand orange keeps the brand present on white: 5.2:1.
    link: BrandColors.orangeDeep,
    field: Colors.white,
    fieldText: Color(0xFF1C1917),
    fieldHint: Color(0xFF6B5E57),
    // Stone 500: 4.8:1, so outlines survive bright light.
    fieldBorder: Color(0xFF78716C),
    fieldFocus: BrandColors.navy,
    // 6.5:1 on white.
    fieldError: BrandColors.danger,
    action: BrandColors.navy,
    onAction: Colors.white,
    noticeError: Color(0xFFFEF2F2),
    noticeInfo: Color(0xFFEFF6FF),
    onNotice: Color(0xFF1C1917),
    switchTrack: Color(0xFFE7E5E4),
    logoAsset: 'assets/brand/space_clean_logo.svg',
    systemOverlay: SystemUiOverlayStyle.dark,
  );

  /// Ember ground with bright orange as the accent.
  static const dark = ThresholdPalette(
    ground: BrandColors.ember,
    onGround: Colors.white,
    onGroundMuted: Color(0xFFFED7AA),
    link: Colors.white,
    field: Color(0xFF5A1F0B),
    fieldText: Colors.white,
    fieldHint: Color(0xFFE9B99A),
    // 4.4:1 against ember, so empty fields still read as fields.
    fieldBorder: Color(0xFFEA580C),
    fieldFocus: BrandColors.orangeBright,
    // Errors never appear as orange on orange.
    fieldError: Colors.white,
    action: BrandColors.orangeBright,
    onAction: BrandColors.ember,
    noticeError: Color(0xFFFFF7ED),
    noticeInfo: Color(0xFFFFF7ED),
    onNotice: Color(0xFF1C1917),
    switchTrack: Color(0x33FFFFFF),
    logoAsset: 'assets/brand/space_clean_logo_white.svg',
    systemOverlay: SystemUiOverlayStyle.light,
  );

  static ThresholdPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  final Color ground;
  final Color onGround;
  final Color onGroundMuted;

  /// Text actions ("Forgot password?", "Not you?").
  final Color link;
  final Color field;
  final Color fieldText;
  final Color fieldHint;
  final Color fieldBorder;
  final Color fieldFocus;

  /// Error text under fields and code boxes.
  final Color fieldError;
  final Color action;
  final Color onAction;
  final Color noticeError;
  final Color noticeInfo;
  final Color onNotice;

  /// Track behind the iOS language switch.
  final Color switchTrack;
  final String logoAsset;

  /// Status and navigation bar icon brightness for this ground.
  final SystemUiOverlayStyle systemOverlay;
}
