import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_language.dart';
import '../controllers/language_controller.dart';

/// EN/ES pill toggle. [compact] shows codes ("EN") for headers; otherwise
/// full names for settings.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key, this.compact = false});

  final bool compact;

  static const _names = {AppLanguage.en: 'English', AppLanguage.es: 'Español'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(languageControllerProvider) ??
        AppLanguage.tryParse(Localizations.localeOf(context).languageCode) ??
        AppLanguage.en;
    return PillToggle<AppLanguage>(
      semanticLabel: AppLocalizations.of(context).languageLabel,
      expand: !compact,
      track: compact ? SpaceColors.surface : SpaceColors.sunken,
      options: {
        for (final l in AppLanguage.values)
          l: compact ? l.name.toUpperCase() : _names[l]!,
      },
      selected: current,
      onChanged: (l) => ref.read(languageControllerProvider.notifier).select(l),
    );
  }
}
