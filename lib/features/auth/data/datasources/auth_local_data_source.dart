import 'package:shared_preferences/shared_preferences.dart';

/// Non-secret sign-in conveniences. Tokens live in `TokenStorage`.
class AuthLocalDataSource {
  const AuthLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  static const _emailKey = 'auth.rememberedEmail';

  String? get rememberedEmail => _preferences.getString(_emailKey);

  Future<void> rememberEmail(String email) =>
      _preferences.setString(_emailKey, email);

  Future<void> forgetEmail() => _preferences.remove(_emailKey);
}
