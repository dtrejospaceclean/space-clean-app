import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';

/// One design for both platforms, in light and dark: Manrope, rounded cards,
/// orange pill actions. Native behaviors (back gestures, dialogs, pickers)
/// stay.
abstract final class SpaceTheme {
  static const font = 'Manrope';

  /// App-wide text size, applied on top of the user's system text scale so
  /// accessibility sizing still works.
  static const textScale = 0.88;

  static ThemeData light() => _build(SpaceColors.light, Brightness.light);

  static ThemeData dark() => _build(SpaceColors.dark, Brightness.dark);

  static ThemeData _build(SpaceColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.accent,
      onSecondary: c.onAccent,
      tertiary: c.highlight,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.inkMuted,
      surfaceContainerHighest: c.sunken,
      outline: c.line,
      outlineVariant: c.line,
      error: c.danger,
      onError: c.onPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: font,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.ground,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
    );

    final text = base.textTheme.apply(
      fontFamily: font,
      bodyColor: c.ink,
      displayColor: c.ink,
    );

    return base.copyWith(
      textTheme: text.copyWith(
        // Page titles ("Today").
        headlineLarge: text.headlineLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.15,
        ),
        // Hero headlines (two tone).
        headlineMedium: text.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.15,
        ),
        // Big numbers in cards.
        headlineSmall: text.headlineSmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: text.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: text.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 16, height: 1.45),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, color: c.inkMuted),
        labelLarge: text.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.primary,
          disabledForegroundColor: c.onPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: font,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: font,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.sunken,
        hintStyle: TextStyle(color: c.inkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        // A visible edge (3.9:1) so filled fields read as fields.
        border: _field(c.inkSoft),
        enabledBorder: _field(c.inkSoft),
        disabledBorder: _field(c.line),
        focusedBorder: _field(c.primary, 2),
        errorBorder: _field(c.danger, 2),
        focusedErrorBorder: _field(c.danger, 2),
        errorStyle: TextStyle(
          color: c.danger,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        errorMaxLines: 3,
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.ground,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(SpaceRadius.card)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: c.primary,
        scaffoldBackgroundColor: c.ground,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: font, fontSize: 16, color: c.ink),
          actionTextStyle: TextStyle(
            fontFamily: font,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: c.accent,
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _field(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(SpaceRadius.inner),
        borderSide: BorderSide(color: color, width: width),
      );
}
