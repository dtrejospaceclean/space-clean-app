import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/theme_mode_repository.dart';

class ThemeModeRepositoryImpl implements ThemeModeRepository {
  const ThemeModeRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;

  static const _key = 'settings.theme_mode';

  @override
  AppThemeMode? get savedThemeMode =>
      AppThemeMode.tryParse(_preferences.getString(_key));

  @override
  Future<void> saveThemeMode(AppThemeMode mode) =>
      _preferences.setString(_key, mode.name);
}
