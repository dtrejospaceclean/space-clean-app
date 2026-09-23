// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SP CLN';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginSubtitle => 'Usa tu correo y contraseña de trabajo.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get signInButton => 'Iniciar sesión';

  @override
  String get signOutButton => 'Cerrar sesión';

  @override
  String homeWelcome(String name) {
    return 'Bienvenido, $name';
  }

  @override
  String homeRoles(String roles) {
    return 'Roles: $roles';
  }

  @override
  String get splashLoadError => 'No pudimos restaurar tu sesión.';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get validationRequired => 'Este campo es obligatorio.';

  @override
  String get validationInvalidEmail => 'Ingresa un correo electrónico válido.';

  @override
  String validationMinLength(String min) {
    return 'Debe tener al menos $min caracteres.';
  }

  @override
  String validationMaxLength(String max) {
    return 'Debe tener como máximo $max caracteres.';
  }

  @override
  String get validationFailed => 'Revisa los campos marcados.';

  @override
  String get authInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get authSessionExpired => 'Tu sesión expiró. Vuelve a iniciar sesión.';

  @override
  String get authInsufficientPermission => 'No tienes permiso para hacer esto.';

  @override
  String get authInsufficientRole => 'Tu rol no permite esta acción.';

  @override
  String get errorsNetwork =>
      'No se puede conectar con el servidor. Revisa tu conexión.';

  @override
  String get errorsTooManyRequests =>
      'Demasiados intentos. Espera un momento y vuelve a intentarlo.';

  @override
  String get errorsNotFound => 'No encontramos lo que buscabas.';

  @override
  String get errorsInternal =>
      'Algo salió mal en el servidor. Vuelve a intentarlo.';

  @override
  String get errorsUnknown => 'Algo salió mal.';
}
