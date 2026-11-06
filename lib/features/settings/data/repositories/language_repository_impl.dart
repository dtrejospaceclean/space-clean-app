import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/repositories/language_repository.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  const LanguageRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;

  /// Also read by the background push handler, which has no providers.
  static const key = 'settings.language';

  @override
  AppLanguage? get savedLanguage =>
      AppLanguage.tryParse(_preferences.getString(key));

  @override
  Future<void> saveLanguage(AppLanguage language) =>
      _preferences.setString(key, language.name);
}
