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
  String unreadNotifications(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notificaciones sin leer',
      one: '1 notificación sin leer',
    );
    return '$_temp0';
  }

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
  String get reorderModules => 'Ordenar';

  @override
  String get reorderModulesHint =>
      'Arrastra las asas para cambiar el orden. Es el mismo en todas las cuentas.';

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
  String get noUsersFound => 'Ningún usuario coincide';

  @override
  String get noUsersFoundHint => 'Prueba con otro nombre o correo.';

  @override
  String get inactiveTag => 'Inactivo';

  @override
  String get clientUserTag => 'Cliente';

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
  String get assigneesNoAccess =>
      'Solo como referencia. Para dar acceso a esta cuenta, agrega a la persona en Equipo.';

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

  @override
  String get appearanceLabel => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get builtInRoleNameHelp =>
      'Los roles integrados conservan su nombre. Puedes cambiar la descripción.';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get changePasswordHint =>
      'Actualiza la contraseña con la que inicias sesión';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get changePasswordFootnote =>
      'Seguirás con la sesión iniciada en este teléfono.';

  @override
  String get authWrongCurrentPassword => 'Tu contraseña actual no es correcta.';

  @override
  String get passwordChangedTitle => 'Contraseña cambiada';

  @override
  String get passwordChangedBody =>
      'Usa tu nueva contraseña la próxima vez que inicies sesión.';

  @override
  String profileEmailFootnote(String email) {
    return 'Inicias sesión con $email. Para cambiarlo, pídeselo a un propietario.';
  }

  @override
  String get servicesTitle => 'Catálogo de servicios';

  @override
  String get adminServicesHint => 'Servicios, categorías y unidades';

  @override
  String get newServiceTitle => 'Nuevo servicio';

  @override
  String get editServiceTitle => 'Editar servicio';

  @override
  String get searchServicesHint => 'Buscar por nombre o categoría';

  @override
  String get noServicesYet => 'Aún no hay servicios';

  @override
  String get noServicesYetHint =>
      'Agrega los servicios que ofreces para usarlos en propuestas y alcances.';

  @override
  String get noServicesFound => 'Ningún servicio coincide';

  @override
  String get noServicesFoundHint =>
      'Prueba con otro nombre, categoría o filtro.';

  @override
  String perUnit(String unit) {
    return 'por $unit';
  }

  @override
  String get sectionService => 'Servicio';

  @override
  String get sectionPricing => 'Precio';

  @override
  String get serviceNameLabel => 'Nombre';

  @override
  String get serviceCategoryLabel => 'Categoría';

  @override
  String get unitOfMeasureLabel => 'Unidad de medida';

  @override
  String get defaultPriceLabel => 'Precio base por unidad';

  @override
  String get defaultPriceHelp =>
      'Rellena el precio unitario en las propuestas nuevas. Déjalo vacío para fijarlo cada vez.';

  @override
  String get invalidPrice => 'Escribe un monto como 0.12 o 25.';

  @override
  String get serviceInactiveHelp =>
      'Los servicios inactivos siguen en las propuestas y alcances existentes, pero no se pueden elegir para nuevos.';

  @override
  String get serviceCatalogNotFound => 'Este servicio ya no existe.';

  @override
  String get serviceCatalogSomeNotFound =>
      'Uno de los servicios no existe o está inactivo. Actualiza e inténtalo de nuevo.';

  @override
  String get searchCategoriesHint => 'Buscar categorías';

  @override
  String get searchUnitsHint => 'Buscar por nombre o abreviatura';

  @override
  String get noMatchesFound => 'Nada coincide';

  @override
  String get noMatchesHint => 'Prueba con otra búsqueda.';

  @override
  String get noCategoriesYet => 'Aún no hay categorías';

  @override
  String get noCategoriesYetHint =>
      'Las categorías agrupan tus servicios, como Limpieza general o Cuidado de pisos.';

  @override
  String get noUnitsYet => 'Aún no hay unidades';

  @override
  String get noUnitsYetHint =>
      'Agrega cómo cobras los servicios, como Pie cuadrado, Hora o Visita.';

  @override
  String serviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servicios',
      one: '1 servicio',
      zero: 'Sin servicios',
    );
    return '$_temp0';
  }

  @override
  String get newCategoryTitle => 'Nueva categoría';

  @override
  String get editCategoryTitle => 'Editar categoría';

  @override
  String get newUnitTitle => 'Nueva unidad';

  @override
  String get editUnitTitle => 'Editar unidad';

  @override
  String get catalogCategoryLabel => 'Categoría';

  @override
  String get catalogUnitLabel => 'Unidad de medida';

  @override
  String get categoryNameHint => 'p. ej., Limpieza general';

  @override
  String get unitNameHint => 'p. ej., Pie cuadrado';

  @override
  String get categoryDescriptionLabel => 'Descripción';

  @override
  String get abbreviationLabel => 'Abreviatura';

  @override
  String get abbreviationHint => 'p. ej., pie²';

  @override
  String get abbreviationHelp =>
      'Se muestra junto a los precios: \$0.12 / pie². Déjala vacía para usar el nombre.';

  @override
  String get categoryInactiveHelp =>
      'Las categorías inactivas siguen en los servicios existentes, pero no se pueden elegir para nuevos.';

  @override
  String get unitInactiveHelp =>
      'Las unidades inactivas siguen en los servicios existentes, pero no se pueden elegir para nuevos.';

  @override
  String get deleteCategory => 'Eliminar categoría';

  @override
  String get deleteUnit => 'Eliminar unidad';

  @override
  String lookupInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count servicios la usan, así que no se puede eliminar. Márcala como inactiva.',
      one: '1 servicio la usa, así que no se puede eliminar. Márcala como inactiva.',
    );
    return '$_temp0';
  }

  @override
  String get lookupNameTaken => 'Ya existe otra con este nombre.';

  @override
  String get noUnitsToPick =>
      'Primero agrega una unidad: Catálogo de servicios → + → Gestionar unidades.';

  @override
  String get serviceCatalogCategoryNotFound =>
      'Esta categoría se eliminó o está inactiva. Elige otra.';

  @override
  String get serviceCatalogUnitNotFound =>
      'Esta unidad se eliminó o está inactiva. Elige otra.';

  @override
  String get serviceCategoriesNotFound => 'Esta categoría ya no existe.';

  @override
  String get serviceCategoriesInUse =>
      'Hay servicios que usan esta categoría, así que no se puede eliminar. Márcala como inactiva.';

  @override
  String get unitsOfMeasureNotFound => 'Esta unidad ya no existe.';

  @override
  String get unitsOfMeasureInUse =>
      'Hay servicios que usan esta unidad, así que no se puede eliminar. Márcala como inactiva.';

  @override
  String get noDefaultPrice => 'Sin precio';

  @override
  String shownAs(String abbreviation) {
    return 'Se muestra como $abbreviation';
  }

  @override
  String get createTitle => 'Crear';

  @override
  String get manageCategories => 'Gestionar categorías';

  @override
  String get manageUnits => 'Gestionar unidades';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String get unitsTitle => 'Unidades de medida';

  @override
  String get activeTag => 'Activo';

  @override
  String get moduleContacts => 'Contactos';

  @override
  String get moduleContactsHint => 'Personas del cliente';

  @override
  String get noContactsYet => 'Aún no hay contactos';

  @override
  String get noContactsYetHint =>
      'Agrega con + a las personas con las que tratas en esta cuenta.';

  @override
  String get primaryContactTag => 'Principal';

  @override
  String get billingContactTag => 'Facturación';

  @override
  String get contactTitle => 'Contacto';

  @override
  String get newContactTitle => 'Nuevo contacto';

  @override
  String get editContact => 'Editar contacto';

  @override
  String get deleteContact => 'Eliminar contacto';

  @override
  String get deleteContactWithLoginBody =>
      'Su acceso se mantiene: podrá seguir iniciando sesión y viendo esta cuenta. No se puede deshacer.';

  @override
  String get contactHasLogin => 'Tiene acceso';

  @override
  String get contactHasLoginHint => 'Inicia sesión como cliente de esta cuenta';

  @override
  String get giveLogin => 'Dar acceso';

  @override
  String signsInWith(String email) {
    return 'Iniciará sesión con $email';
  }

  @override
  String get giveLoginNeedsEmail => 'Primero agrega un correo a este contacto';

  @override
  String giveLoginFootnote(String name) {
    return '$name verá esta cuenta en la app como cliente.';
  }

  @override
  String get loginCreatedTitle => 'Acceso creado';

  @override
  String loginCreatedBody(String email) {
    return 'Ya puede iniciar sesión con $email y la contraseña que definiste. Compártela en privado.';
  }

  @override
  String get notesLabel => 'Notas';

  @override
  String get sectionPerson => 'Persona';

  @override
  String get firstNameLabel => 'Nombre';

  @override
  String get lastNameLabel => 'Apellido';

  @override
  String get jobTitleLabel => 'Cargo';

  @override
  String get jobTitleHint => 'p. ej. Gerente de mantenimiento';

  @override
  String get contactNotesHint => 'p. ej. Prefiere llamadas por la mañana';

  @override
  String get contactRoleLabel => 'Rol en la cuenta';

  @override
  String get contactRoleHelp =>
      'Una cuenta tiene un contacto principal y uno de facturación. Elegirlo aquí se lo quita a quien lo tenía.';

  @override
  String get clientContactsNotFound => 'Este contacto ya no existe.';

  @override
  String get clientContactsEmailRequired =>
      'Agrega un correo a este contacto antes de darle acceso.';

  @override
  String get clientContactsLoginExists => 'Este contacto ya tiene acceso.';

  @override
  String get moduleLocations => 'Ubicaciones';

  @override
  String get moduleLocationsHint => 'Sitios, accesos e instrucciones';

  @override
  String get searchLocationsHint => 'Buscar nombre, dirección o ciudad';

  @override
  String get noLocationsYet => 'Aún no hay ubicaciones';

  @override
  String get noLocationsYetHint =>
      'Agrega con + los sitios donde se hace el trabajo.';

  @override
  String get locationTitle => 'Ubicación';

  @override
  String get newLocationTitle => 'Nueva ubicación';

  @override
  String get editLocation => 'Editar ubicación';

  @override
  String get deleteLocation => 'Eliminar ubicación';

  @override
  String get locationNameHint => 'p. ej. Torre A – Piso 3';

  @override
  String get sectionAddress => 'Dirección';

  @override
  String get sectionSiteDetails => 'Detalles del sitio';

  @override
  String get sectionUsedBy => 'En uso por';

  @override
  String get squareFootageLabel => 'Superficie (pies²)';

  @override
  String squareFootageValue(String value) {
    return '$value pies²';
  }

  @override
  String get floorCountLabel => 'Pisos';

  @override
  String get accessCodesLabel => 'Códigos de acceso';

  @override
  String get accessCodesHelp =>
      'Códigos de puerta o alarma. Solo los miembros de esta cuenta los ven.';

  @override
  String get specialInstructionsLabel => 'Instrucciones especiales';

  @override
  String get specialInstructionsHint =>
      'p. ej. Usar la entrada de servicio después de las 6 PM';

  @override
  String get invalidSquareFootage => 'Ingresa un número como 12000 o 850.5.';

  @override
  String get invalidWholeNumber => 'Ingresa un número entero.';

  @override
  String scopeOfWorkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alcances de trabajo',
      one: '1 alcance de trabajo',
      zero: 'Ningún alcance de trabajo',
    );
    return '$_temp0';
  }

  @override
  String jobCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trabajos',
      one: '1 trabajo',
      zero: 'Ningún trabajo',
    );
    return '$_temp0';
  }

  @override
  String get locationInUse =>
      'Hay alcances de trabajo o trabajos que usan esta ubicación, así que no se puede eliminar.';

  @override
  String get locationsNotFound => 'Esta ubicación ya no existe.';

  @override
  String get streetAddressLabel => 'Calle y número';

  @override
  String get invalidPhone => 'Ingresa un número de teléfono de 10 dígitos.';

  @override
  String get moduleTeamHint => 'Quién trabaja aquí y qué puede hacer';

  @override
  String get moduleTimeline => 'Historial';

  @override
  String get noTeamYet => 'Aún no hay nadie en este equipo';

  @override
  String get noTeamYetHint => 'Agrega personas con +.';

  @override
  String get customAccessTag => 'Acceso personalizado';

  @override
  String get memberTitle => 'Miembro del equipo';

  @override
  String get sectionAccess => 'Acceso';

  @override
  String get editAccess => 'Editar acceso';

  @override
  String get addMemberTitle => 'Agregar al equipo';

  @override
  String get memberUserLabel => 'Persona';

  @override
  String get baseRoleLabel => 'Rol en esta cuenta';

  @override
  String get baseRoleChangeHelp =>
      'Cambiar el rol restablece el acceso a lo predeterminado de ese rol.';

  @override
  String get accessHelp => 'Al quitar Ver se quita todo lo demás de esa área.';

  @override
  String get resetAccess => 'Restablecer lo predeterminado del rol';

  @override
  String get addMemberHelp =>
      'El acceso empieza con lo predeterminado del rol. Podrás ajustarlo después de agregarlo.';

  @override
  String get noOneToAdd =>
      'Todas las personas activas ya están en este equipo.';

  @override
  String get removeMember => 'Quitar del equipo';

  @override
  String removeMemberConfirmTitle(String name) {
    return '¿Quitar a $name?';
  }

  @override
  String get removeMemberConfirmBody =>
      'Perderá el acceso a esta cuenta. Su usuario y su historial se conservan.';

  @override
  String get removeButton => 'Quitar';

  @override
  String get teamReadOnly => 'Solo los propietarios pueden cambiar el equipo.';

  @override
  String get accessView => 'Ver';

  @override
  String get accessEdit => 'Editar';

  @override
  String get accessAssign => 'Asignar';

  @override
  String get accessDownload => 'Descargar';

  @override
  String get accessUpload => 'Subir';

  @override
  String get accessManage => 'Gestionar';

  @override
  String get membersNotFound => 'Esta persona ya no está en este equipo.';

  @override
  String get membersUserNotActive =>
      'Este usuario está desactivado. Reactívalo antes de agregarlo.';

  @override
  String get languageAndAppearance => 'Idioma y apariencia';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get themeSystemHint => 'Sigue el modo claro u oscuro de tu teléfono';

  @override
  String get themeSystemSummary => 'Tema del sistema';

  @override
  String get themeLightSummary => 'Tema claro';

  @override
  String get themeDarkSummary => 'Tema oscuro';

  @override
  String get moduleProposalsHint => 'Embudo, precios y versiones';

  @override
  String get proposalStageLead => 'Prospecto';

  @override
  String get proposalStageWalkthrough => 'Visita';

  @override
  String get proposalStagePricing => 'Cotización';

  @override
  String get proposalStageProposal => 'Propuesta';

  @override
  String get proposalStageNegotiation => 'Negociación';

  @override
  String get proposalStageApproved => 'Aprobada';

  @override
  String get proposalStageUnknown => 'Otra etapa';

  @override
  String get noProposalsYet => 'Aún no hay propuestas';

  @override
  String get noProposalsYetHint => 'Crea una con +.';

  @override
  String get newProposalTitle => 'Nueva propuesta';

  @override
  String get proposalTitle => 'Propuesta';

  @override
  String get editProposal => 'Editar propuesta';

  @override
  String get deleteProposal => 'Eliminar propuesta';

  @override
  String get deleteProposalConfirmTitle => '¿Eliminar esta propuesta?';

  @override
  String get deleteProposalConfirmBody =>
      'Se eliminarán todas sus versiones y conceptos. No se puede deshacer.';

  @override
  String get newVersionTitle => 'Nueva versión';

  @override
  String get approveProposalTitle => 'Aprobar propuesta';

  @override
  String get approveButton => 'Aprobar';

  @override
  String proposalVersion(int number) {
    return 'Versión $number';
  }

  @override
  String get proposalNoLineItems => 'Aún sin conceptos';

  @override
  String proposalMoreItems(int count, String description) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$description y $count más',
      one: '$description y 1 más',
    );
    return '$_temp0';
  }

  @override
  String proposalPreparedBy(String name) {
    return 'Preparada por $name';
  }

  @override
  String proposalApprovedBy(String name, String date) {
    return 'Aprobada por $name el $date';
  }

  @override
  String proposalApprovedOn(String date) {
    return 'Aprobada el $date';
  }

  @override
  String get pipelineStageLabel => 'Etapa';

  @override
  String get validUntilLabel => 'Válida hasta';

  @override
  String get agreedPriceLabel => 'Precio acordado';

  @override
  String get agreedPriceHelp => 'Opcional hasta que se apruebe la propuesta.';

  @override
  String get lineItemsTotalLabel => 'Total de conceptos';

  @override
  String get versionNoteLabel => 'Nota de la versión';

  @override
  String get versionNoteHint => 'p. ej., Descuento por contrato anual';

  @override
  String get sectionLineItems => 'Conceptos';

  @override
  String lineItemTitle(int number) {
    return 'Concepto $number';
  }

  @override
  String get addLineItem => 'Agregar concepto';

  @override
  String get addLineItemShort => 'Concepto';

  @override
  String get lineItemsEmpty =>
      'Ninguno todavía. Toca + abajo para agregar uno.';

  @override
  String get removeLineItem => 'Quitar concepto';

  @override
  String get lineItemServiceLabel => 'Del catálogo';

  @override
  String get lineItemDescriptionLabel => 'Descripción';

  @override
  String get lineItemQuantityLabel => 'Cantidad';

  @override
  String lineItemQuantityUnitLabel(String unit) {
    return 'Cantidad ($unit)';
  }

  @override
  String get lineItemUnitPriceLabel => 'Precio unitario';

  @override
  String lineItemTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get invalidQuantity => 'Escribe un número como 12000 o 2.5.';

  @override
  String get serviceNotInCatalog => 'Ya no está en el catálogo';

  @override
  String get sectionVersions => 'Versiones';

  @override
  String get currentVersionTag => 'Actual';

  @override
  String get olderVersionNotice =>
      'Esta es una versión anterior, guardada como historial. Solo la versión actual puede cambiar.';

  @override
  String get approvedProposalNote =>
      'Una propuesta aprobada no se puede cambiar.';

  @override
  String get newVersionHelp =>
      'La versión actual queda en el historial tal como está.';

  @override
  String get approveHelp =>
      'Al aprobarla, esta versión queda fija con el precio acordado.';

  @override
  String get proposalsNotFound => 'Esta propuesta ya no existe.';

  @override
  String get proposalsNotCurrentVersion =>
      'Solo la versión actual se puede cambiar. Agrega una nueva versión.';

  @override
  String get proposalsAlreadyApproved =>
      'Esta propuesta está aprobada y no se puede cambiar.';

  @override
  String get proposalsHasRelatedRecords =>
      'Un contrato usa esta propuesta, así que no se puede eliminar.';

  @override
  String get proposalsAgreedPriceRequired =>
      'Escribe el precio acordado para aprobarla.';

  @override
  String get noPriceYet => 'Aún sin precio';

  @override
  String get editLineItem => 'Editar concepto';

  @override
  String lineItemError(int number, String message) {
    return 'Concepto $number: $message';
  }

  @override
  String get searchProposalsHint => 'Busca servicios, notas o etapa';

  @override
  String proposalValidUntil(String date) {
    return 'Válida hasta el $date';
  }

  @override
  String proposalExpiredOn(String date) {
    return 'Venció el $date';
  }

  @override
  String get moduleContractsHint => 'Condiciones, firmas y renovaciones';

  @override
  String get noContractsYet => 'Aún no hay contratos';

  @override
  String get noContractsYetHint =>
      'Crea uno con + o desde una propuesta aprobada.';

  @override
  String get contractsFilterLabel => 'Mostrar';

  @override
  String get contractsFilterAll => 'Todos';

  @override
  String contractsFilterExpiring(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Por vencer ($count)',
      zero: 'Por vencer',
    );
    return '$_temp0';
  }

  @override
  String get noContractsExpiring => 'Nada por vencer';

  @override
  String get noContractsExpiringHint =>
      'Ningún contrato activo vence en los próximos 30 días.';

  @override
  String contractFromProposal(int number) {
    return 'De la versión $number de la propuesta';
  }

  @override
  String contractFrom(String date) {
    return 'Desde el $date';
  }

  @override
  String get contractStatusDraft => 'Borrador';

  @override
  String get contractStatusActive => 'Activo';

  @override
  String get contractStatusExpired => 'Vencido';

  @override
  String get contractStatusCancelled => 'Cancelado';

  @override
  String get contractStatusUnknown => 'Otro estado';

  @override
  String get contractExpiringSoon => 'Por vencer';

  @override
  String get contractTitle => 'Contrato';

  @override
  String get newContractTitle => 'Nuevo contrato';

  @override
  String get editContract => 'Editar contrato';

  @override
  String get deleteContract => 'Eliminar contrato';

  @override
  String get keepContract => 'Conservarlo';

  @override
  String get deleteContractConfirmTitle => '¿Eliminar este borrador?';

  @override
  String get deleteContractConfirmBody =>
      'Se eliminará el borrador del contrato. Esto no se puede deshacer.';

  @override
  String get cancelContract => 'Cancelar contrato';

  @override
  String get cancelContractConfirmTitle => '¿Cancelar este contrato?';

  @override
  String get cancelContractConfirmBody =>
      'Queda en el historial de la cuenta, pero ya no se podrá editar ni firmar.';

  @override
  String get cancelledContractNotice =>
      'Este contrato está cancelado. Se conserva como historial y no puede cambiar.';

  @override
  String get contractValueLabel => 'Valor del contrato';

  @override
  String get contractValueFromProposalHelp =>
      'Parte del precio acordado de la propuesta.';

  @override
  String get contractProposalLabel => 'Propuesta';

  @override
  String get contractStartLabel => 'Fecha de inicio';

  @override
  String get contractExpirationLabel => 'Fecha de vencimiento';

  @override
  String get expirationBeforeStart =>
      'Elige un día igual o posterior a la fecha de inicio.';

  @override
  String get noEndDate => 'Sin fecha de fin';

  @override
  String get sectionTerm => 'Vigencia';

  @override
  String get paymentTermsLabel => 'Condiciones de pago';

  @override
  String get paymentTermsHint => 'p. ej. Neto 30';

  @override
  String get autoRenewLabel => 'Se renueva automáticamente';

  @override
  String get autoRenewOn => 'Se renueva automáticamente';

  @override
  String get autoRenewOff => 'No se renueva automáticamente';

  @override
  String get cancellationNoticeLabel => 'Aviso de cancelación';

  @override
  String get cancellationNoticeHelp =>
      'Días de aviso necesarios para cancelar.';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String contractDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vence en $count días',
      one: 'Vence mañana',
      zero: 'Vence hoy',
    );
    return '$_temp0';
  }

  @override
  String get signatureLabel => 'Firma';

  @override
  String get signedOnLabel => 'Firmado el';

  @override
  String contractSignedBy(String name, String date) {
    return 'Firmado por $name el $date';
  }

  @override
  String contractSignedOn(String date) {
    return 'Firmado el $date';
  }

  @override
  String get contractNotSigned => 'Sin firmar';

  @override
  String get signContract => 'Firmar contrato';

  @override
  String get signContractHelp =>
      'Al firmar quedas registrado como firmante y el contrato pasa a activo.';

  @override
  String get createContract => 'Crear contrato';

  @override
  String get contractsNotFound => 'Este contrato ya no existe.';

  @override
  String get contractsValueRequired => 'Ingresa el valor del contrato.';

  @override
  String get contractsProposalNotApproved =>
      'Un contrato solo puede partir de una propuesta aprobada.';

  @override
  String get contractsAlreadySigned => 'Este contrato ya está firmado.';

  @override
  String get contractsCancelled =>
      'Este contrato está cancelado y no puede cambiar.';

  @override
  String get contractsOnlyDraftsDeletable =>
      'Solo se puede eliminar un contrato en borrador. Cancélalo en su lugar.';

  @override
  String get contractsHasRelatedRecords =>
      'Hay alcances de trabajo o facturas que usan este contrato, así que no se puede eliminar.';

  @override
  String get markExpired => 'Marcar como vencido';

  @override
  String get markExpiredConfirmTitle => '¿Marcar este contrato como vencido?';

  @override
  String get markExpiredConfirmBody =>
      'Queda en el historial de la cuenta y todavía se puede editar.';

  @override
  String contractEndedOn(String date) {
    return 'Terminó el $date';
  }

  @override
  String get moduleScopeHint => 'Áreas, frecuencia y horarios';

  @override
  String get scopesOfOneContract => 'Se muestran los alcances de un contrato.';

  @override
  String get noScopesYet => 'Aún no hay alcances de trabajo';

  @override
  String get noScopesYetHint =>
      'Agrega uno con + por cada área de una ubicación.';

  @override
  String get noTimeWindows => 'Sin horarios';

  @override
  String scheduleAndMore(String schedule, int count) {
    return '$schedule y $count más';
  }

  @override
  String get scopeWholeSite => 'Todo el sitio';

  @override
  String get everyDay => 'Todos los días';

  @override
  String get frequencyDaily => 'Diario';

  @override
  String get frequencyWeekly => 'Semanal';

  @override
  String get frequencyBiweekly => 'Cada 2 semanas';

  @override
  String get frequencyMonthly => 'Mensual';

  @override
  String get frequencyQuarterly => 'Trimestral';

  @override
  String get frequencyAnnual => 'Anual';

  @override
  String get frequencyOneTime => 'Una sola vez';

  @override
  String get frequencyUnknown => 'Otra frecuencia';

  @override
  String get scopeTitle => 'Alcance de trabajo';

  @override
  String get newScopeTitle => 'Nuevo alcance de trabajo';

  @override
  String get editScope => 'Editar alcance';

  @override
  String get deleteScope => 'Eliminar alcance';

  @override
  String get deleteScopeConfirmTitle => '¿Eliminar este alcance?';

  @override
  String get deleteScopeConfirmBody =>
      'Se eliminarán el alcance y sus horarios. Esto no se puede deshacer.';

  @override
  String get scopeHasJobsNote =>
      'Este alcance ya generó trabajos, así que no se puede eliminar. Pausa sus horarios en su lugar.';

  @override
  String get sectionTimeWindows => 'Horarios';

  @override
  String get sectionSchedule => 'Programación';

  @override
  String get sectionDetails => 'Detalles';

  @override
  String get sectionHours => 'Horas';

  @override
  String get timeWindowPaused => 'En pausa';

  @override
  String get timeWindowsEmpty => 'Ninguno aún. Toca + abajo para agregar uno.';

  @override
  String get windowsNeedWeekdays => 'Elige los días de cada horario.';

  @override
  String get addTimeWindow => 'Agregar horario';

  @override
  String get addTimeWindowShort => 'Horario';

  @override
  String get editTimeWindow => 'Editar horario';

  @override
  String get removeTimeWindow => 'Quitar horario';

  @override
  String get weekdaysLabel => 'Días';

  @override
  String get pickWeekdays => 'Elige al menos un día.';

  @override
  String get startTimeLabel => 'Inicio';

  @override
  String get endTimeLabel => 'Fin';

  @override
  String get noEndTime => 'Sin hora de fin';

  @override
  String get endBeforeStart => 'Elige una hora posterior al inicio.';

  @override
  String get timeWindowActiveLabel => 'Activo';

  @override
  String get timeWindowActiveHelp =>
      'Un horario en pausa sigue en el alcance, pero no genera trabajo nuevo.';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get areaNameLabel => 'Área';

  @override
  String get areaNameHint => 'p. ej. Recepción';

  @override
  String get areaNameHelp => 'Déjalo vacío si cubre todo el sitio.';

  @override
  String get scopeServiceLabel => 'Servicio';

  @override
  String get frequencyLabel => 'Frecuencia';

  @override
  String get estimatedDurationLabel => 'Duración estimada';

  @override
  String get estimatedDurationHelp => 'En minutos.';

  @override
  String minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String get instructionsLabel => 'Instrucciones';

  @override
  String get instructionsHint => 'p. ej. Trapear con limpiador neutro';

  @override
  String get exclusionsLabel => 'No incluye';

  @override
  String get exclusionsHint => 'p. ej. Sala de servidores (piso 4)';

  @override
  String get requiredSuppliesLabel => 'Insumos';

  @override
  String get requiredSuppliesHint => 'p. ej. Paños de microfibra';

  @override
  String get scopesNotFound => 'Este alcance de trabajo ya no existe.';

  @override
  String get scopesDaysOfWeekRequired =>
      'El trabajo semanal necesita los días de cada horario.';

  @override
  String get scopesHasJobs =>
      'Este alcance ya generó trabajos, así que no se puede eliminar. Pausa sus horarios en su lugar.';

  @override
  String get scopeNeedsContract =>
      'Esta cuenta aún no tiene un contrato activo o en borrador. Agrega uno en Contratos primero.';

  @override
  String get scopeNeedsLocation =>
      'Esta cuenta aún no tiene ubicaciones. Agrega una en Ubicaciones primero.';

  @override
  String get scopeNoServices => 'El catálogo no tiene servicios activos.';
}
