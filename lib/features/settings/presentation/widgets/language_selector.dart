import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/adaptive.dart';
import '../../domain/entities/app_language.dart';
import '../controllers/language_controller.dart';

/// Language control for settings inside the app, in the platform's default
/// styling (the sign-in screens use `LanguageSwitch`).
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const _names = {AppLanguage.en: 'English', AppLanguage.es: 'Español'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(languageControllerProvider) ??
        AppLanguage.tryParse(Localizations.localeOf(context).languageCode) ??
        AppLanguage.en;
    void select(AppLanguage? language) {
      if (language != null) {
        ref.read(languageControllerProvider.notifier).select(language);
      }
    }

    if (useCupertino(context)) {
      return CupertinoSlidingSegmentedControl<AppLanguage>(
        groupValue: current,
        onValueChanged: select,
        children: {
          for (final l in AppLanguage.values)
            l: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(_names[l]!),
            ),
        },
      );
    }
    return SegmentedButton<AppLanguage>(
      showSelectedIcon: false,
      selected: {current},
      onSelectionChanged: (s) => select(s.single),
      segments: [
        for (final l in AppLanguage.values)
          ButtonSegment(value: l, label: Text(_names[l]!)),
      ],
    );
  }
}
