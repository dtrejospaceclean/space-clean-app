import '../entities/app_language.dart';

abstract interface class LanguageRepository {
  /// The language the user picked, or `null` to follow the device.
  AppLanguage? get savedLanguage;

  Future<void> saveLanguage(AppLanguage language);
}
