import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';

/// One design for both platforms, in light and dark: Manrope, rounded cards,
/// orange pill actions. Native behaviors (back gestures, dialogs, pickers)
/// stay.
abstract final class SpaceTheme {
  static const font = 'Manrope';

  /// Every text renders at this share of its design size (the sizes set in
  /// the theme and widgets), on top of the phone's own text size setting.
  static const textScale = 0.9;

  /// `MaterialApp.builder`: applies [textScale] to the whole app.
  static Widget scaleText(BuildContext context, Widget? child) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: _ScaledText(media.textScaler, textScale),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

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
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        // Hero headlines (two tone).
        headlineMedium: text.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.15,
        ),
        // Big numbers in cards.
        headlineSmall: text.headlineSmall?.copyWith(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: text.titleMedium?.copyWith(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: text.titleSmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 15, height: 1.45),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 13, color: c.inkMuted),
        // Footnotes and helper text: the smallest size in the app.
        bodySmall: text.bodySmall?.copyWith(fontSize: 12.5),
        labelMedium: text.labelMedium?.copyWith(fontSize: 12.5),
        labelSmall: text.labelSmall?.copyWith(fontSize: 12.5),
        labelLarge: text.labelLarge?.copyWith(
          fontSize: 15,
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
            fontSize: 15,
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.sunken,
        hintStyle: TextStyle(color: c.inkMuted),
        contentPadding: const EdgeInsets.all(SpaceSpace.field),
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
          fontSize: 12.5,
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
      // Every pushed page slides in from the right on both platforms, with
      // the swipe-from-edge back gesture.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SlidePageTransitions(),
          TargetPlatform.iOS: SlidePageTransitions(),
        },
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: c.primary,
        scaffoldBackgroundColor: c.ground,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: font, fontSize: 15, color: c.ink),
          actionTextStyle: TextStyle(
            fontFamily: font,
            fontSize: 15,
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

/// The iOS page slide (the new page in from the right, the one under it
/// shifting left) and its edge-swipe back, used on both platforms. Instant
/// when the OS asks for reduced motion; the swipe back still works.
class SlidePageTransitions extends PageTransitionsBuilder {
  const SlidePageTransitions();

  static const _slide = CupertinoPageTransitionsBuilder();

  @override
  Duration get transitionDuration => _slide.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _slide.reverseTransitionDuration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      _slide.delegatedTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return CupertinoRouteTransitionMixin.buildPageTransitions(
        route,
        context,
        kAlwaysCompleteAnimation,
        kAlwaysDismissedAnimation,
        child,
      );
    }
    return _slide.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

/// The phone's text scaler times a fixed [factor], keeping the OS's own
/// (possibly nonlinear) scaling underneath.
class _ScaledText extends TextScaler {
  const _ScaledText(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  @Deprecated('Use scale() instead.')
  double get textScaleFactor => scale(1);

  @override
  bool operator ==(Object other) =>
      other is _ScaledText && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
