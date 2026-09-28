import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/settings_providers.dart';
import '../../domain/entities/app_language.dart';

/// The app's forced locale, or `null` to follow the device.
final languageControllerProvider =
    NotifierProvider<LanguageController, AppLanguage?>(LanguageController.new);

class LanguageController extends Notifier<AppLanguage?> {
  @override
  AppLanguage? build() => ref.watch(languageRepositoryProvider).savedLanguage;

  Future<void> select(AppLanguage language) async {
    state = language;
    await ref.read(languageRepositoryProvider).saveLanguage(language);
  }
}

extension AppLanguageLocale on AppLanguage {
  Locale get locale => Locale(name);
}

/// The language in effect: the saved choice, or the phone's when it's one
/// the app speaks.
AppLanguage currentLanguage(BuildContext context, WidgetRef ref) =>
    ref.watch(languageControllerProvider) ??
    AppLanguage.tryParse(Localizations.localeOf(context).languageCode) ??
    AppLanguage.en;
