import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/threshold_palette.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_language.dart';
import '../controllers/language_controller.dart';

/// EN/ES switch for the sign-in screens. Material segmented button on
/// Android, sliding segmented control on iOS.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  static const _names = {AppLanguage.en: 'English', AppLanguage.es: 'Español'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ThresholdPalette.of(context);
    final l10n = AppLocalizations.of(context);
    final current =
        ref.watch(languageControllerProvider) ??
        AppLanguage.tryParse(Localizations.localeOf(context).languageCode) ??
        AppLanguage.en;
    void select(AppLanguage? language) {
      if (language != null && language != current) {
        ref.read(languageControllerProvider.notifier).select(language);
      }
    }

    TextStyle labelStyle(bool selected) => TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: selected ? palette.ground : palette.onGround,
    );

    return Semantics(
      label: l10n.languageLabel,
      container: true,
      child: useCupertino(context)
          ? CupertinoSlidingSegmentedControl<AppLanguage>(
              groupValue: current,
              backgroundColor: palette.switchTrack,
              thumbColor: palette.onGround,
              padding: const EdgeInsets.all(3),
              onValueChanged: select,
              children: {
                for (final language in AppLanguage.values)
                  language: Semantics(
                    label: _names[language],
                    excludeSemantics: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(
                        language.name.toUpperCase(),
                        style: labelStyle(language == current),
                      ),
                    ),
                  ),
              },
            )
          : SegmentedButton<AppLanguage>(
              showSelectedIcon: false,
              selected: {current},
              onSelectionChanged: (selection) => select(selection.single),
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: const WidgetStatePropertyAll(Size(56, 48)),
                side: WidgetStatePropertyAll(
                  BorderSide(color: palette.onGround, width: 1.5),
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? palette.onGround
                      : Colors.transparent,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? palette.ground
                      : palette.onGround,
                ),
                textStyle: WidgetStatePropertyAll(
                  Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              segments: [
                for (final language in AppLanguage.values)
                  ButtonSegment(
                    value: language,
                    label: Text(language.name.toUpperCase()),
                    tooltip: _names[language],
                  ),
              ],
            ),
    );
  }
}
