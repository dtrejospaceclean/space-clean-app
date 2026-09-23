// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Space Clean';

  @override
  String get loginTitle => 'Iniciar sesión';

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

  @override
  String get brandTagline =>
      'Un Solo Aliado. Toda Solución para tu Instalación.';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get notYou => '¿No eres tú?';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get emailHint => 'tu@empresa.com';

  @override
  String get resetTitle => 'Restablece tu contraseña';

  @override
  String get resetEmailIntro =>
      'Ingresa el correo con el que inicias sesión. Te enviaremos un código de 6 dígitos.';

  @override
  String get sendCodeButton => 'Enviar código';

  @override
  String get codeTitle => 'Ingresa el código';

  @override
  String codeIntro(String email) {
    return 'Enviamos un código de 6 dígitos a $email. Puede tardar un minuto en llegar.';
  }

  @override
  String get codeLabel => 'Código de 6 dígitos';

  @override
  String get codeIncomplete => 'Ingresa los 6 dígitos.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get resendCode => 'Enviar un código nuevo';

  @override
  String resendIn(String seconds) {
    return 'Nuevo código en $seconds s';
  }

  @override
  String get codeResent => 'Enviamos un código nuevo.';

  @override
  String get newPasswordTitle => 'Elige una contraseña nueva';

  @override
  String get newPasswordIntro =>
      'La usarás para iniciar sesión de ahora en adelante.';

  @override
  String get newPasswordLabel => 'Contraseña nueva';

  @override
  String get confirmPasswordLabel => 'Repite la contraseña nueva';

  @override
  String ruleMinLength(String min) {
    return 'Al menos $min caracteres';
  }

  @override
  String get ruleMatch => 'Las dos contraseñas coinciden';

  @override
  String get ruleMet => 'Listo';

  @override
  String get ruleNotMet => 'Pendiente';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden.';

  @override
  String get savePasswordButton => 'Guardar contraseña';

  @override
  String get resetDoneTitle => 'Contraseña actualizada';

  @override
  String get resetDoneBody => 'Inicia sesión con tu contraseña nueva.';

  @override
  String get backToSignIn => 'Volver a iniciar sesión';

  @override
  String get errorsFeatureUnavailable =>
      'Aún no se puede restablecer la contraseña desde la app. Pide a tu supervisor o administrador que la restablezca.';

  @override
  String get tabToday => 'Hoy';

  @override
  String get tabAccounts => 'Cuentas';

  @override
  String get tabProfile => 'Yo';

  @override
  String get todayTitle => 'Hoy';

  @override
  String greeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get noJobsToday => 'No hay trabajos hoy';

  @override
  String get noJobsTodayHint =>
      'Cuando te programen un trabajo, aparecerá aquí.';

  @override
  String someAccountsFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count cuentas no se pudieron cargar. Desliza hacia abajo para reintentar.',
      one: '1 cuenta no se pudo cargar. Desliza hacia abajo para reintentar.',
    );
    return '$_temp0';
  }

  @override
  String get accountsTitle => 'Cuentas';

  @override
  String get noAccounts => 'Aún no tienes cuentas';

  @override
  String get noAccountsHint =>
      'Pide a tu supervisor que te agregue a una cuenta de cliente.';

  @override
  String get clientStatusProspect => 'Prospecto';

  @override
  String get clientStatusInactive => 'Inactiva';

  @override
  String yourRole(String role) {
    return 'Tu rol: $role';
  }

  @override
  String get sectionWork => 'Trabajo';

  @override
  String get sectionAccount => 'Cuenta';

  @override
  String get moduleJobs => 'Trabajos';

  @override
  String get moduleCalendar => 'Calendario';

  @override
  String get moduleComplaints => 'Quejas';

  @override
  String get moduleTasks => 'Tareas';

  @override
  String get moduleProposals => 'Propuestas';

  @override
  String get moduleContracts => 'Contratos';

  @override
  String get moduleScope => 'Alcance del trabajo';

  @override
  String get moduleTeam => 'Equipo';

  @override
  String get moduleInfo => 'Datos de la cuenta';

  @override
  String get moduleFiles => 'Archivos';

  @override
  String get comingSoon => 'Pronto';

  @override
  String get noModules => 'Todavía no tienes acceso a nada en esta cuenta.';

  @override
  String get jobsNextDays => 'Próximos 7 días';

  @override
  String get noJobsAhead => 'No hay trabajos en los próximos 7 días';

  @override
  String get jobStatusScheduled => 'Programado';

  @override
  String get jobStatusInProgress => 'En curso';

  @override
  String get jobStatusCompleted => 'Completado';

  @override
  String get jobStatusCancelled => 'Cancelado';

  @override
  String get jobStatusUnknown => 'Desconocido';

  @override
  String get jobWhen => 'Cuándo';

  @override
  String get jobWhere => 'Dónde';

  @override
  String get jobCrew => 'Equipo';

  @override
  String get jobChecklist => 'Lista de tareas';

  @override
  String get jobInstructions => 'Instrucciones';

  @override
  String get noCrewAssigned => 'Nadie asignado todavía';

  @override
  String checklistProgress(int done, int total) {
    return '$done de $total listas';
  }

  @override
  String get noChecklist => 'Sin lista de tareas';

  @override
  String get roleOwner => 'Propietario';

  @override
  String get roleAccountManager => 'Gerente de cuenta';

  @override
  String get roleSupervisor => 'Supervisor';

  @override
  String get roleCrew => 'Personal de limpieza';

  @override
  String get roleClient => 'Cliente';

  @override
  String get profileTitle => 'Yo';

  @override
  String get sectionSettings => 'Ajustes';

  @override
  String get signOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get signOutConfirmBody =>
      'Necesitarás tu correo y contraseña para volver a entrar.';

  @override
  String get cancelButton => 'Cancelar';
}
