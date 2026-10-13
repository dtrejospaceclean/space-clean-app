import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_language.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../controllers/app_version_provider.dart';
import '../controllers/language_controller.dart';
import '../controllers/theme_mode_controller.dart';

/// Each language in its own words, so it can be found without reading the
/// current one.
const languageEndonyms = {AppLanguage.en: 'English', AppLanguage.es: 'Español'};

extension SettingsLabels on AppLocalizations {
  /// A language's name in the app's current language.
  String languageName(AppLanguage language) => switch (language) {
    AppLanguage.en => languageEnglish,
    AppLanguage.es => languageSpanish,
  };

  /// "System theme", "Light theme", "Dark theme".
  String themeSummary(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => themeSystemSummary,
    AppThemeMode.light => themeLightSummary,
    AppThemeMode.dark => themeDarkSummary,
  };
}

/// Me → Settings: the app's language and light or dark appearance (both
/// apply at once and are remembered on this phone), then which version is
/// installed, to tell support or check an update arrived.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const path = '/me/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = currentLanguage(context, ref);
    final theme = ref.watch(themeModeControllerProvider);
    final version = ref.watch(appVersionProvider).value;

    return SpacePage(
      title: l10n.sectionSettings,
      slivers: [
        PageBox(top: 4, child: SectionHeader(title: l10n.languageLabel)),
        PageBox(
          top: 0,
          child: ListCard(
            children: [
              for (final option in AppLanguage.values)
                ChoiceRow(
                  title: languageEndonyms[option]!,
                  // "Español" / "Spanish" when the app is in English.
                  subtitle: switch (l10n.languageName(option)) {
                    final name when name != languageEndonyms[option] => name,
                    _ => null,
                  },
                  selected: option == language,
                  onSelect: () => ref
                      .read(languageControllerProvider.notifier)
                      .select(option),
                ),
            ],
          ),
        ),
        PageBox(top: 12, child: SectionHeader(title: l10n.appearanceLabel)),
        PageBox(
          top: 0,
          child: ListCard(
            children: [
              for (final (option, icon, label, hint) in [
                (
                  AppThemeMode.system,
                  Icons.brightness_auto_outlined,
                  l10n.themeSystem,
                  l10n.themeSystemHint,
                ),
                (
                  AppThemeMode.light,
                  Icons.light_mode_outlined,
                  l10n.themeLight,
                  null,
                ),
                (
                  AppThemeMode.dark,
                  Icons.dark_mode_outlined,
                  l10n.themeDark,
                  null,
                ),
              ])
                ChoiceRow(
                  leading: IconBadge(icon: icon),
                  title: label,
                  subtitle: hint,
                  selected: option == theme,
                  onSelect: () => ref
                      .read(themeModeControllerProvider.notifier)
                      .select(option),
                ),
            ],
          ),
        ),
        PageBox(top: 12, child: SectionHeader(title: l10n.aboutLabel)),
        PageBox(
          top: 0,
          child: ListCard(
            children: [
              // Dashes until the phone answers, which is all but instant.
              FactRow(label: l10n.appVersionLabel, value: version?.version),
            ],
          ),
        ),
      ],
    );
  }
}
