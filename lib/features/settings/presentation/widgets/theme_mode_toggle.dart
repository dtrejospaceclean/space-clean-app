import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../controllers/theme_mode_controller.dart';

/// System / Light / Dark pill toggle for settings.
class ThemeModeToggle extends ConsumerWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PillToggle<AppThemeMode>(
      semanticLabel: l10n.appearanceLabel,
      track: context.colors.sunken,
      options: {
        AppThemeMode.system: l10n.themeSystem,
        AppThemeMode.light: l10n.themeLight,
        AppThemeMode.dark: l10n.themeDark,
      },
      selected: ref.watch(themeModeControllerProvider),
      onChanged: (mode) =>
          ref.read(themeModeControllerProvider.notifier).select(mode),
    );
  }
}
