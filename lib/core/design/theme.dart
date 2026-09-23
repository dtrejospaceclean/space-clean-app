import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';

/// One theme for both platforms: Manrope, gray ground, white cards, black
/// pill actions. Native behaviors (back gestures, dialogs, pickers) stay.
abstract final class SpaceTheme {
  static const font = 'Manrope';

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: SpaceColors.ink,
      onPrimary: Colors.white,
      secondary: SpaceColors.accent,
      onSecondary: SpaceColors.onAccent,
      tertiary: SpaceColors.highlight,
      surface: SpaceColors.surface,
      onSurface: SpaceColors.ink,
      onSurfaceVariant: SpaceColors.inkMuted,
      surfaceContainerHighest: SpaceColors.sunken,
      outline: SpaceColors.line,
      outlineVariant: SpaceColors.line,
      error: SpaceColors.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: font,
      colorScheme: scheme,
      scaffoldBackgroundColor: SpaceColors.ground,
      splashFactory: InkSparkle.splashFactory,
    );

    final text = base.textTheme.apply(
      fontFamily: font,
      bodyColor: SpaceColors.ink,
      displayColor: SpaceColors.ink,
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
        bodyMedium: text.bodyMedium?.copyWith(
          fontSize: 14,
          color: SpaceColors.inkMuted,
        ),
        labelLarge: text.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SpaceColors.ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SpaceColors.ink,
          disabledForegroundColor: Colors.white,
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
          foregroundColor: SpaceColors.accent,
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
        fillColor: SpaceColors.sunken,
        hintStyle: const TextStyle(color: SpaceColors.inkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        // A visible edge (3.9:1) so filled fields read as fields.
        border: _field(SpaceColors.inkSoft),
        enabledBorder: _field(SpaceColors.inkSoft),
        disabledBorder: _field(SpaceColors.line),
        focusedBorder: _field(SpaceColors.accent, 2),
        errorBorder: _field(SpaceColors.danger, 2),
        focusedErrorBorder: _field(SpaceColors.danger, 2),
        errorStyle: const TextStyle(
          color: SpaceColors.danger,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        errorMaxLines: 3,
      ),
      dividerTheme: const DividerThemeData(
        color: SpaceColors.line,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SpaceColors.ground,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: SpaceColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(SpaceRadius.card)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SpaceColors.ink,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: SpaceColors.accent,
        scaffoldBackgroundColor: SpaceColors.ground,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: font,
            fontSize: 16,
            color: SpaceColors.ink,
          ),
          actionTextStyle: TextStyle(
            fontFamily: font,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: SpaceColors.accent,
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
