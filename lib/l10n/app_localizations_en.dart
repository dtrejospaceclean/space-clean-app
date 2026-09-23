// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SP CLN';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Use your work email and password.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signOutButton => 'Sign out';

  @override
  String homeWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String homeRoles(String roles) {
    return 'Roles: $roles';
  }

  @override
  String get splashLoadError => 'We couldn\'t restore your session.';

  @override
  String get retryButton => 'Try again';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationInvalidEmail => 'Enter a valid email address.';

  @override
  String validationMinLength(String min) {
    return 'Must be at least $min characters.';
  }

  @override
  String validationMaxLength(String max) {
    return 'Must be at most $max characters.';
  }

  @override
  String get validationFailed => 'Some fields need your attention.';

  @override
  String get authInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authSessionExpired => 'Your session expired. Sign in again.';

  @override
  String get authInsufficientPermission =>
      'You don\'t have permission to do that.';

  @override
  String get authInsufficientRole => 'Your role doesn\'t allow this action.';

  @override
  String get errorsNetwork => 'Can\'t reach the server. Check your connection.';

  @override
  String get errorsTooManyRequests =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get errorsNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorsInternal => 'Something went wrong on our side. Try again.';

  @override
  String get errorsUnknown => 'Something went wrong.';
}
