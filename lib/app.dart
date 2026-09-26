import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/design/theme.dart';
import 'features/settings/presentation/controllers/language_controller.dart';
import 'features/settings/presentation/controllers/theme_mode_controller.dart';
import 'l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: ref.watch(languageControllerProvider)?.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: SpaceTheme.light(),
      darkTheme: SpaceTheme.dark(),
      themeMode: ref.watch(themeModeControllerProvider).material,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: _ScaledTextScaler(
              media.textScaler,
              SpaceTheme.textScale,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

/// The system [TextScaler] (possibly nonlinear, e.g. Android 14) scaled by a
/// constant factor.
final class _ScaledTextScaler extends TextScaler {
  const _ScaledTextScaler(this.system, this.factor);

  final TextScaler system;
  final double factor;

  @override
  double scale(double fontSize) => system.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => system.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _ScaledTextScaler &&
      other.system == system &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(system, factor);
}
