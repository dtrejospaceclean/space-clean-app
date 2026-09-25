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

  @override
  String get sectionAdministration => 'Administración';

  @override
  String get usersTitle => 'Usuarios';

  @override
  String get rolesTitle => 'Roles';

  @override
  String get searchUsersHint => 'Buscar por nombre, correo o ID de empleado';

  @override
  String get filterActive => 'Activos';

  @override
  String get filterInactive => 'Inactivos';

  @override
  String get filterAll => 'Todos';

  @override
  String get noUsersFound => 'Ningún usuario coincide';

  @override
  String get noUsersFoundHint => 'Prueba con otro nombre o filtro.';

  @override
  String get inactiveTag => 'Inactivo';

  @override
  String get clientUserTag => 'Cliente';

  @override
  String get addUser => 'Agregar usuario';

  @override
  String get editUser => 'Editar usuario';

  @override
  String get newUserTitle => 'Nuevo usuario';

  @override
  String get saveButton => 'Guardar';

  @override
  String get sectionContact => 'Contacto';

  @override
  String get sectionEmployment => 'Empleo';

  @override
  String get sectionEmergency => 'Contacto de emergencia';

  @override
  String get sectionRoles => 'Roles';

  @override
  String get sectionSignIn => 'Acceso';

  @override
  String get nameLabel => 'Nombre completo';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get employeeIdLabel => 'ID de empleado';

  @override
  String get employmentTypeLabel => 'Tipo de empleo';

  @override
  String get payRateLabel => 'Tarifa (por hora)';

  @override
  String get hireDateLabel => 'Fecha de contratación';

  @override
  String get emergencyNameLabel => 'Nombre';

  @override
  String get emergencyPhoneLabel => 'Teléfono';

  @override
  String get initialPasswordLabel => 'Contraseña';

  @override
  String get newPasswordOptionalLabel => 'Contraseña nueva (opcional)';

  @override
  String get passwordHelpCreate =>
      'Al menos 12 caracteres. Compártela con la persona en privado.';

  @override
  String get passwordHelpEdit =>
      'Déjala vacía para conservar la contraseña actual.';

  @override
  String get employmentFullTime => 'Tiempo completo';

  @override
  String get employmentPartTime => 'Medio tiempo';

  @override
  String get employmentContractor => 'Contratista';

  @override
  String get notSet => 'Sin definir';

  @override
  String get chooseButton => 'Elegir';

  @override
  String get doneButton => 'Listo';

  @override
  String get invalidPayRate => 'Ingresa un monto como 18.50.';

  @override
  String get noRolesSelected =>
      'Sin roles: esta persona todavía no puede hacer nada.';

  @override
  String get deactivateUser => 'Desactivar usuario';

  @override
  String get reactivateUser => 'Reactivar usuario';

  @override
  String deactivateConfirmTitle(String name) {
    return '¿Desactivar a $name?';
  }

  @override
  String get deactivateConfirmBody =>
      'No podrá iniciar sesión. Su historial se conserva y puedes reactivarlo después.';

  @override
  String get deactivateButton => 'Desactivar';

  @override
  String get reactivateButton => 'Reactivar';

  @override
  String get userInactiveNotice =>
      'Este usuario está desactivado y no puede iniciar sesión.';

  @override
  String get readOnlyNotice =>
      'Solo los propietarios pueden cambiar usuarios y roles.';

  @override
  String get addRole => 'Agregar rol';

  @override
  String get editRole => 'Editar rol';

  @override
  String get roleNameLabel => 'Nombre';

  @override
  String get roleNameHelp => 'Minúsculas, números y _ (p. ej. jefe_de_piso)';

  @override
  String get roleDescriptionLabel => 'Descripción (opcional)';

  @override
  String get roleNameInvalid =>
      'Usa minúsculas, números y _, empezando con una letra.';

  @override
  String get builtInRole => 'Predefinido';

  @override
  String roleUserCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usuarios',
      one: '1 usuario',
      zero: 'Sin usuarios',
    );
    return '$_temp0';
  }

  @override
  String get deleteRole => 'Eliminar rol';

  @override
  String deleteRoleConfirmTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get deleteRoleConfirmBody => 'Esto no se puede deshacer.';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get roleInUseHint =>
      'Quita este rol a sus usuarios antes de eliminarlo.';

  @override
  String get usersEmailTaken => 'Otro usuario ya tiene este correo.';

  @override
  String get rolesStillAssigned => 'Este rol todavía está asignado a usuarios.';

  @override
  String get rolesSystemRole =>
      'Los roles predefinidos no se pueden renombrar ni eliminar.';

  @override
  String get rolesSomeNotFound =>
      'Uno de los roles elegidos ya no existe. Actualiza e inténtalo de nuevo.';

  @override
  String get usersNotFound => 'Este usuario ya no existe.';

  @override
  String get errorsUniqueViolation => 'Ese valor ya está en uso.';

  @override
  String jobsTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trabajos hoy',
      one: '1 trabajo hoy',
      zero: 'Nada programado hoy',
    );
    return '$_temp0';
  }

  @override
  String get yourJobs => 'Tus trabajos';

  @override
  String get statToDo => 'Pendientes';

  @override
  String accountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentas',
      one: '1 cuenta',
      zero: 'Aún no tienes cuentas',
    );
    return '$_temp0';
  }

  @override
  String get comingSoonLong => 'Próximamente';

  @override
  String get openSection => 'Abrir';

  @override
  String get clientStatusActive => 'Activa';

  @override
  String get addAccount => 'Añadir cuenta';

  @override
  String get newAccountTitle => 'Nueva cuenta';

  @override
  String get editAccount => 'Editar cuenta';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionBilling => 'Facturación';

  @override
  String get sectionPeopleInCharge => 'Responsables';

  @override
  String get legalNameLabel => 'Razón social';

  @override
  String get dbaLabel => 'Nombre comercial';

  @override
  String get dbaHelp =>
      'El nombre que se usa a diario, si es distinto de la razón social.';

  @override
  String get industryLabel => 'Sector';

  @override
  String get serviceTypeLabel => 'Tipo de servicio';

  @override
  String get serviceTypeHint => 'p. ej. Limpieza de oficinas';

  @override
  String get accountStatusLabel => 'Estado de la cuenta';

  @override
  String get taxIdLabel => 'Identificación fiscal';

  @override
  String get billingAddressLabel => 'Dirección';

  @override
  String get billingCityLabel => 'Ciudad';

  @override
  String get billingStateLabel => 'Estado o provincia';

  @override
  String get billingZipLabel => 'Código postal';

  @override
  String get salespersonLabel => 'Vendedor';

  @override
  String get assigneesReadOnly =>
      'Solo los propietarios y gerentes de cuenta pueden cambiar a los responsables.';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirmBody =>
      'Solo se pueden eliminar cuentas que nunca se usaron. Esto no se puede deshacer.';

  @override
  String get accountCreatedTitle => 'Cuenta creada';

  @override
  String get accountCreatedNotMember =>
      'Para abrirla, pide a un propietario que te añada a su equipo.';

  @override
  String get clientsHasRelatedRecords =>
      'Esta cuenta tiene historial (propuestas, contratos, ubicaciones, trabajos o facturas), así que no se puede eliminar. Cambia su estado a Inactiva.';

  @override
  String get clientsAssigneeNotActive =>
      'El gerente de cuenta, el supervisor y el vendedor deben ser usuarios activos.';

  @override
  String get clientsNotFound => 'Esta cuenta ya no existe.';

  @override
  String get searchAccountsHint => 'Buscar por nombre o identificación fiscal';

  @override
  String get noAccountsFound => 'Ninguna cuenta coincide';

  @override
  String get noAccountsFoundHint =>
      'Prueba con otro nombre o identificación fiscal.';

  @override
  String get searchingLabel => 'Buscando…';

  @override
  String get moduleJobsHint => 'Agenda, equipo y avance';

  @override
  String get moduleInfoHint => 'Facturación y responsables';

  @override
  String get adminUsersHint => 'Personal y accesos de clientes';

  @override
  String get adminRolesHint => 'Roles del personal y quién los tiene';

  @override
  String get usersCannotDeactivateSelf =>
      'No puedes desactivar tu propia cuenta.';

  @override
  String get ownAccountNotice =>
      'Esta es tu cuenta. No puedes desactivarte; otro propietario sí puede.';

  @override
  String get editProfile => 'Editar perfil';
}
