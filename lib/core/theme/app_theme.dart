import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// Theme for the app interior: white and neutral surfaces, logo navy for
/// actions (matching the sign-in button), brand orange as the accent.
/// Uses the platform fonts (Roboto / San Francisco).
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final light = brightness == Brightness.light;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: BrandColors.navy,
          brightness: brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.neutral,
        ).copyWith(
          primary: light ? BrandColors.navy : const Color(0xFF9CC3F0),
          tertiary: light ? BrandColors.orangeDeep : BrandColors.orangeBright,
          surface: light ? Colors.white : null,
        );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: scheme.primary,
        brightness: brightness,
      ),
    );
  }
}
