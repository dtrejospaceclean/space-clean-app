import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// Theme for the app interior: restrained neutrals, brand orange as the accent.
/// Uses the platform fonts (Roboto / San Francisco).
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: BrandColors.orangeDeep,
          brightness: brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.neutral,
        ).copyWith(
          primary: brightness == Brightness.light
              ? BrandColors.orangeDeep
              : BrandColors.orangeBright,
        );

    return ThemeData(
      colorScheme: scheme,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: scheme.primary,
        brightness: brightness,
      ),
    );
  }
}
