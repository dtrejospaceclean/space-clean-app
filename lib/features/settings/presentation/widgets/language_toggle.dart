import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_language.dart';
import '../controllers/language_controller.dart';

/// Compact EN/ES pill toggle for screen headers (sign-in). Signed-in users
/// change the language in Me → Settings.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => PillToggle<AppLanguage>(
    semanticLabel: AppLocalizations.of(context).languageLabel,
    expand: false,
    track: context.colors.surface,
    options: {for (final l in AppLanguage.values) l: l.name.toUpperCase()},
    selected: currentLanguage(context, ref),
    onChanged: (l) => ref.read(languageControllerProvider.notifier).select(l),
  );
}
