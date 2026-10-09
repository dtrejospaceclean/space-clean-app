// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Space Clean';

  @override
  String get loginTitle => 'Sign in';

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

  @override
  String get brandTagline => 'One Partner. Every Facility Solution.';

  @override
  String get languageLabel => 'Language';

  @override
  String get notYou => 'Not you?';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get emailHint => 'you@company.com';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetEmailIntro =>
      'Enter the email you sign in with. We\'ll send you a 6-digit code.';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get codeTitle => 'Enter the code';

  @override
  String codeIntro(String email) {
    return 'We sent a 6-digit code to $email. It may take a minute to arrive.';
  }

  @override
  String get codeLabel => '6-digit code';

  @override
  String get codeIncomplete => 'Enter all 6 digits.';

  @override
  String get continueButton => 'Continue';

  @override
  String get resendCode => 'Send a new code';

  @override
  String resendIn(String seconds) {
    return 'New code in $seconds s';
  }

  @override
  String get codeResent => 'We sent a new code.';

  @override
  String get newPasswordTitle => 'Choose a new password';

  @override
  String get newPasswordIntro => 'You\'ll use it to sign in from now on.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Repeat new password';

  @override
  String ruleMinLength(String min) {
    return 'At least $min characters';
  }

  @override
  String get ruleMatch => 'Both passwords match';

  @override
  String get ruleMet => 'Done';

  @override
  String get ruleNotMet => 'Not yet';

  @override
  String get passwordsDontMatch => 'The passwords don\'t match.';

  @override
  String get savePasswordButton => 'Save password';

  @override
  String get resetDoneTitle => 'Password updated';

  @override
  String get resetDoneBody => 'Sign in with your new password.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get errorsFeatureUnavailable =>
      'Password reset isn\'t available in the app yet. Ask your supervisor or admin to reset your password.';

  @override
  String get tabToday => 'Today';

  @override
  String get tabAccounts => 'Accounts';

  @override
  String unreadNotifications(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread notifications',
      one: '1 unread notification',
    );
    return '$_temp0';
  }

  @override
  String get todayTitle => 'Today';

  @override
  String greeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get noJobsToday => 'No jobs today';

  @override
  String get noJobsTodayHint =>
      'When a job is scheduled for you, it shows up here.';

  @override
  String someAccountsFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts couldn\'t load. Pull down to try again.',
      one: '1 account couldn\'t load. Pull down to try again.',
    );
    return '$_temp0';
  }

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get noAccounts => 'No accounts yet';

  @override
  String get noAccountsHint =>
      'Ask your manager to add you to a client account.';

  @override
  String get clientStatusProspect => 'Prospect';

  @override
  String get clientStatusInactive => 'Inactive';

  @override
  String yourRole(String role) {
    return 'Your role: $role';
  }

  @override
  String get moduleJobs => 'Jobs';

  @override
  String get moduleCalendar => 'Calendar';

  @override
  String get moduleComplaints => 'Complaints';

  @override
  String get moduleTasks => 'Tasks';

  @override
  String get moduleProposals => 'Proposals';

  @override
  String get moduleContracts => 'Contracts';

  @override
  String get moduleScope => 'Scope of work';

  @override
  String get moduleTeam => 'Team';

  @override
  String get moduleInfo => 'Account details';

  @override
  String get moduleFiles => 'Files';

  @override
  String get comingSoon => 'Soon';

  @override
  String get noModules =>
      'You don\'t have access to anything in this account yet.';

  @override
  String get reorderModules => 'Reorder';

  @override
  String get reorderModulesHint =>
      'Drag the handles to set the order. It\'s the same in every account.';

  @override
  String get noJobsAhead => 'No upcoming jobs';

  @override
  String get jobStatusScheduled => 'Scheduled';

  @override
  String get jobStatusInProgress => 'In progress';

  @override
  String get jobStatusCompleted => 'Completed';

  @override
  String get jobStatusCancelled => 'Cancelled';

  @override
  String get jobStatusUnknown => 'Unknown';

  @override
  String get jobWhen => 'When';

  @override
  String get jobWhere => 'Where';

  @override
  String get jobCrew => 'Crew';

  @override
  String get jobChecklist => 'Checklist';

  @override
  String get jobInstructions => 'Instructions';

  @override
  String get noCrewAssigned => 'No one assigned yet';

  @override
  String checklistProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get noChecklist => 'No checklist';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAccountManager => 'Account manager';

  @override
  String get roleSupervisor => 'Supervisor';

  @override
  String get roleCrew => 'Crew';

  @override
  String get roleClient => 'Client';

  @override
  String get profileTitle => 'Me';

  @override
  String get sectionSettings => 'Settings';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmBody =>
      'You\'ll need your email and password to sign in again.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get sectionAdministration => 'Administration';

  @override
  String get usersTitle => 'Users';

  @override
  String get rolesTitle => 'Roles';

  @override
  String get searchUsersHint => 'Search name, email or employee ID';

  @override
  String get filterActive => 'Active';

  @override
  String get filterInactive => 'Inactive';

  @override
  String get noUsersFound => 'No users match';

  @override
  String get noUsersFoundHint => 'Try another name or email.';

  @override
  String get inactiveTag => 'Inactive';

  @override
  String get clientUserTag => 'Client';

  @override
  String get editUser => 'Edit user';

  @override
  String get newUserTitle => 'New user';

  @override
  String get saveButton => 'Save';

  @override
  String get sectionContact => 'Contact';

  @override
  String get sectionEmployment => 'Employment';

  @override
  String get sectionEmergency => 'Emergency contact';

  @override
  String get sectionRoles => 'Roles';

  @override
  String get sectionSignIn => 'Sign-in';

  @override
  String get nameLabel => 'Full name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get employeeIdLabel => 'Employee ID';

  @override
  String get employmentTypeLabel => 'Employment type';

  @override
  String get payRateLabel => 'Pay rate (per hour)';

  @override
  String get hireDateLabel => 'Hire date';

  @override
  String get emergencyNameLabel => 'Name';

  @override
  String get emergencyPhoneLabel => 'Phone';

  @override
  String get initialPasswordLabel => 'Password';

  @override
  String get newPasswordOptionalLabel => 'New password (optional)';

  @override
  String get passwordHelpCreate =>
      'At least 12 characters. Share it with the person privately.';

  @override
  String get passwordHelpEdit => 'Leave empty to keep the current password.';

  @override
  String get employmentFullTime => 'Full-time';

  @override
  String get employmentPartTime => 'Part-time';

  @override
  String get employmentContractor => 'Contractor';

  @override
  String get notSet => 'Not set';

  @override
  String get chooseButton => 'Choose';

  @override
  String get doneButton => 'Done';

  @override
  String get invalidPayRate => 'Enter an amount like 18.50.';

  @override
  String get noRolesSelected => 'No roles: this person can\'t do anything yet.';

  @override
  String get deactivateUser => 'Deactivate user';

  @override
  String get reactivateUser => 'Reactivate user';

  @override
  String deactivateConfirmTitle(String name) {
    return 'Deactivate $name?';
  }

  @override
  String get deactivateConfirmBody =>
      'They won\'t be able to sign in. Their history stays, and you can reactivate them later.';

  @override
  String get deactivateButton => 'Deactivate';

  @override
  String get reactivateButton => 'Reactivate';

  @override
  String get userInactiveNotice =>
      'This user is deactivated and can\'t sign in.';

  @override
  String get readOnlyNotice => 'Only owners can change users and roles.';

  @override
  String get addRole => 'Add role';

  @override
  String get editRole => 'Edit role';

  @override
  String get roleNameLabel => 'Name';

  @override
  String get roleNameHelp =>
      'Lowercase letters, numbers and _ (e.g. floor_lead)';

  @override
  String get roleDescriptionLabel => 'Description (optional)';

  @override
  String get roleNameInvalid =>
      'Use lowercase letters, numbers and _, starting with a letter.';

  @override
  String get builtInRole => 'Built-in';

  @override
  String roleUserCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count users',
      one: '1 user',
      zero: 'No users',
    );
    return '$_temp0';
  }

  @override
  String get deleteRole => 'Delete role';

  @override
  String deleteRoleConfirmTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteRoleConfirmBody => 'This can\'t be undone.';

  @override
  String get deleteButton => 'Delete';

  @override
  String get roleInUseHint =>
      'Remove this role from its users before deleting it.';

  @override
  String get usersEmailTaken => 'Another user already has this email.';

  @override
  String get rolesStillAssigned => 'This role is still assigned to users.';

  @override
  String get rolesSystemRole => 'Built-in roles can\'t be renamed or deleted.';

  @override
  String get rolesSomeNotFound =>
      'One of the selected roles no longer exists. Refresh and try again.';

  @override
  String get usersNotFound => 'This user no longer exists.';

  @override
  String get errorsUniqueViolation => 'That value is already in use.';

  @override
  String jobsTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs today',
      one: '1 job today',
      zero: 'Nothing scheduled today',
    );
    return '$_temp0';
  }

  @override
  String get yourJobs => 'Your jobs';

  @override
  String get statToDo => 'To do';

  @override
  String accountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
      zero: 'No accounts yet',
    );
    return '$_temp0';
  }

  @override
  String get comingSoonLong => 'Coming soon';

  @override
  String get openSection => 'Open';

  @override
  String get clientStatusActive => 'Active';

  @override
  String get newAccountTitle => 'New account';

  @override
  String get editAccount => 'Edit account';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionBilling => 'Billing';

  @override
  String get sectionPeopleInCharge => 'People in charge';

  @override
  String get legalNameLabel => 'Legal name';

  @override
  String get dbaLabel => 'Trade name (DBA)';

  @override
  String get dbaHelp =>
      'The name people use, if different from the legal name.';

  @override
  String get industryLabel => 'Industry';

  @override
  String get serviceTypeLabel => 'Service type';

  @override
  String get serviceTypeHint => 'e.g. Office cleaning';

  @override
  String get accountStatusLabel => 'Status';

  @override
  String get taxIdLabel => 'Tax ID';

  @override
  String get billingAddressLabel => 'Address';

  @override
  String get billingCityLabel => 'City';

  @override
  String get billingStateLabel => 'State';

  @override
  String get billingZipLabel => 'ZIP code';

  @override
  String get salespersonLabel => 'Salesperson';

  @override
  String get assigneesNoAccess =>
      'For reference only. To give someone access to this account, add them in Team.';

  @override
  String get assigneesReadOnly =>
      'Only owners and account managers can change who\'s in charge.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirmBody =>
      'This can\'t be undone. If the account has history, you\'ll see everything that would go with it before anything is deleted.';

  @override
  String get accountCreatedTitle => 'Account created';

  @override
  String get accountCreatedNotMember =>
      'To open it, ask an owner to add you to its team.';

  @override
  String get purgeAccountTitle => 'Delete everything';

  @override
  String purgeAccountWarning(String name) {
    return 'This deletes $name and everything in it: proposals, contracts, scopes of work, calendar, locations, jobs, complaints, tasks, invoices, payments, contacts and team. Its client logins are turned off. This can\'t be undone. To keep the history, set the account to Inactive instead.';
  }

  @override
  String get purgeAccountConfirmLabel => 'Type the legal name to confirm';

  @override
  String get purgeAccountButton => 'Delete account and history';

  @override
  String get clientsHasRelatedRecords =>
      'This account has history (proposals, contracts, locations, jobs or invoices), so it can\'t be deleted. Set its status to Inactive instead.';

  @override
  String get clientsAssigneeNotActive =>
      'The account manager, supervisor and salesperson must be active users.';

  @override
  String get clientsNotFound => 'This account no longer exists.';

  @override
  String get searchAccountsHint => 'Search name or tax ID';

  @override
  String get noAccountsFound => 'No accounts match';

  @override
  String get noAccountsFoundHint => 'Try another name or tax ID.';

  @override
  String get searchingLabel => 'Searching…';

  @override
  String get moduleJobsHint => 'Schedule, crew and progress';

  @override
  String get moduleInfoHint => 'Billing and people in charge';

  @override
  String get adminUsersHint => 'Staff and client sign-ins';

  @override
  String get adminRolesHint => 'Staff roles and who has them';

  @override
  String get usersCannotDeactivateSelf =>
      'You can\'t deactivate your own account.';

  @override
  String get ownAccountNotice =>
      'This is your account. You can\'t deactivate yourself; another owner can.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePhoto => 'Change profile photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromLibrary => 'Choose from library';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get photoAccessDenied =>
      'Space Clean can\'t use the camera or your photos. Allow access in Settings and try again.';

  @override
  String get photoPickFailed =>
      'That photo couldn\'t be opened. Try another one.';

  @override
  String get usersPhotoRequired => 'No photo was received. Try again.';

  @override
  String get usersPhotoInvalidType => 'Use a JPEG, PNG or WebP photo.';

  @override
  String get usersPhotoTooLarge =>
      'That photo is over 5 MB. Choose a smaller one.';

  @override
  String get appearanceLabel => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get builtInRoleNameHelp =>
      'Built-in roles keep their name. You can change the description.';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordHint => 'Update the password you sign in with';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get changePasswordFootnote => 'You\'ll stay signed in on this phone.';

  @override
  String get authWrongCurrentPassword => 'Your current password is incorrect.';

  @override
  String get passwordChangedTitle => 'Password changed';

  @override
  String get passwordChangedBody =>
      'Use your new password the next time you sign in.';

  @override
  String profileEmailFootnote(String email) {
    return 'You sign in with $email. To change it, ask an owner.';
  }

  @override
  String get servicesTitle => 'Service catalog';

  @override
  String get adminServicesHint => 'Services, categories and units';

  @override
  String get newServiceTitle => 'New service';

  @override
  String get editServiceTitle => 'Edit service';

  @override
  String get searchServicesHint => 'Search name or category';

  @override
  String get noServicesYet => 'No services yet';

  @override
  String get noServicesYetHint =>
      'Add the services you offer so proposals and scopes can use them.';

  @override
  String get noServicesFound => 'No services match';

  @override
  String get noServicesFoundHint => 'Try another name, category or filter.';

  @override
  String perUnit(String unit) {
    return 'per $unit';
  }

  @override
  String get sectionService => 'Service';

  @override
  String get sectionPricing => 'Pricing';

  @override
  String get serviceNameLabel => 'Name';

  @override
  String get serviceCategoryLabel => 'Category';

  @override
  String get unitOfMeasureLabel => 'Unit of measure';

  @override
  String get defaultPriceLabel => 'Default price per unit';

  @override
  String get defaultPriceHelp =>
      'Pre-fills the unit price on new proposals. Leave empty to price each time.';

  @override
  String get invalidPrice => 'Enter an amount like 0.12 or 25.';

  @override
  String get serviceInactiveHelp =>
      'Inactive services stay on existing proposals and scopes, but can\'t be picked for new ones.';

  @override
  String get serviceCatalogNotFound => 'This service no longer exists.';

  @override
  String get serviceCatalogSomeNotFound =>
      'One of the services is unknown or inactive. Refresh and try again.';

  @override
  String get searchCategoriesHint => 'Search categories';

  @override
  String get searchUnitsHint => 'Search name or abbreviation';

  @override
  String get noMatchesFound => 'Nothing matches';

  @override
  String get noMatchesHint => 'Try another search.';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get noCategoriesYetHint =>
      'Categories group your services, like Janitorial or Floor care.';

  @override
  String get noUnitsYet => 'No units yet';

  @override
  String get noUnitsYetHint =>
      'Add how you price services, like Square foot, Hour or Visit.';

  @override
  String serviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services',
      one: '1 service',
      zero: 'No services',
    );
    return '$_temp0';
  }

  @override
  String get newCategoryTitle => 'New category';

  @override
  String get editCategoryTitle => 'Edit category';

  @override
  String get newUnitTitle => 'New unit';

  @override
  String get editUnitTitle => 'Edit unit';

  @override
  String get catalogCategoryLabel => 'Category';

  @override
  String get catalogUnitLabel => 'Unit of measure';

  @override
  String get categoryNameHint => 'e.g. Janitorial';

  @override
  String get unitNameHint => 'e.g. Square foot';

  @override
  String get categoryDescriptionLabel => 'Description';

  @override
  String get abbreviationLabel => 'Abbreviation';

  @override
  String get abbreviationHint => 'e.g. sq ft';

  @override
  String get abbreviationHelp =>
      'Shown next to prices: \$0.12 / sq ft. Leave empty to use the name.';

  @override
  String get categoryInactiveHelp =>
      'Inactive categories stay on existing services, but can\'t be picked for new ones.';

  @override
  String get unitInactiveHelp =>
      'Inactive units stay on existing services, but can\'t be picked for new ones.';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get deleteUnit => 'Delete unit';

  @override
  String lookupInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count services use this, so it can\'t be deleted. Set it to Inactive instead.',
      one: '1 service uses this, so it can\'t be deleted. Set it to Inactive instead.',
    );
    return '$_temp0';
  }

  @override
  String get lookupNameTaken => 'Another one already has this name.';

  @override
  String get noUnitsToPick =>
      'Add a unit first: Service catalog → + → Manage units.';

  @override
  String get serviceCatalogCategoryNotFound =>
      'This category was removed or set to inactive. Pick another.';

  @override
  String get serviceCatalogUnitNotFound =>
      'This unit was removed or set to inactive. Pick another.';

  @override
  String get serviceCategoriesNotFound => 'This category no longer exists.';

  @override
  String get serviceCategoriesInUse =>
      'Services still use this category, so it can\'t be deleted. Set it to Inactive instead.';

  @override
  String get unitsOfMeasureNotFound => 'This unit no longer exists.';

  @override
  String get unitsOfMeasureInUse =>
      'Services still use this unit, so it can\'t be deleted. Set it to Inactive instead.';

  @override
  String get noDefaultPrice => 'No price';

  @override
  String shownAs(String abbreviation) {
    return 'Shown as $abbreviation';
  }

  @override
  String get createTitle => 'Create';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get manageUnits => 'Manage units';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get unitsTitle => 'Units of measure';

  @override
  String get activeTag => 'Active';

  @override
  String get moduleContacts => 'Contacts';

  @override
  String get moduleContactsHint => 'People at the client';

  @override
  String get noContactsYet => 'No contacts yet';

  @override
  String get noContactsYetHint =>
      'Add the people you deal with at this account with +.';

  @override
  String get primaryContactTag => 'Primary';

  @override
  String get billingContactTag => 'Billing';

  @override
  String get contactTitle => 'Contact';

  @override
  String get newContactTitle => 'New contact';

  @override
  String get editContact => 'Edit contact';

  @override
  String get deleteContact => 'Delete contact';

  @override
  String get deleteContactWithLoginBody =>
      'Their login stays: they can still sign in and see this account. This can\'t be undone.';

  @override
  String get contactHasLogin => 'Has a login';

  @override
  String get contactHasLoginHint => 'Signs in as a client of this account';

  @override
  String get giveLogin => 'Give a login';

  @override
  String signsInWith(String email) {
    return 'Will sign in with $email';
  }

  @override
  String get giveLoginNeedsEmail => 'Add an email to this contact first';

  @override
  String giveLoginFootnote(String name) {
    return '$name will see this account in the app as a client.';
  }

  @override
  String get loginCreatedTitle => 'Login created';

  @override
  String loginCreatedBody(String email) {
    return 'They can now sign in with $email and the password you set. Share it with them privately.';
  }

  @override
  String get notesLabel => 'Notes';

  @override
  String get sectionPerson => 'Person';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get jobTitleLabel => 'Job title';

  @override
  String get jobTitleHint => 'e.g. Facilities Manager';

  @override
  String get contactNotesHint => 'e.g. Prefers calls in the morning';

  @override
  String get contactRoleLabel => 'Role at the account';

  @override
  String get contactRoleHelp =>
      'An account has one primary and one billing contact. Choosing one here takes it from whoever had it.';

  @override
  String get clientContactsNotFound => 'This contact no longer exists.';

  @override
  String get clientContactsEmailRequired =>
      'Add an email to this contact before giving them a login.';

  @override
  String get clientContactsLoginExists => 'This contact already has a login.';

  @override
  String get moduleLocations => 'Locations';

  @override
  String get moduleLocationsHint => 'Sites, access and instructions';

  @override
  String get searchLocationsHint => 'Search name, address or city';

  @override
  String get noLocationsYet => 'No locations yet';

  @override
  String get noLocationsYetHint =>
      'Add the sites where the work happens with +.';

  @override
  String get locationTitle => 'Location';

  @override
  String get newLocationTitle => 'New location';

  @override
  String get editLocation => 'Edit location';

  @override
  String get deleteLocation => 'Delete location';

  @override
  String get locationNameHint => 'e.g. Tower A – Floor 3';

  @override
  String get sectionAddress => 'Address';

  @override
  String get sectionSiteDetails => 'Site details';

  @override
  String get sectionUsedBy => 'Used by';

  @override
  String get squareFootageLabel => 'Square footage';

  @override
  String squareFootageValue(String value) {
    return '$value sq ft';
  }

  @override
  String get floorCountLabel => 'Floors';

  @override
  String get accessCodesLabel => 'Access codes';

  @override
  String get accessCodesHelp =>
      'Door or alarm codes. Only members of this account see them.';

  @override
  String get specialInstructionsLabel => 'Special instructions';

  @override
  String get specialInstructionsHint =>
      'e.g. Use the service entrance after 6 PM';

  @override
  String get invalidSquareFootage => 'Enter a number like 12000 or 850.5.';

  @override
  String get invalidWholeNumber => 'Enter a whole number.';

  @override
  String scopeOfWorkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scopes of work',
      one: '1 scope of work',
      zero: 'No scopes of work',
    );
    return '$_temp0';
  }

  @override
  String jobCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs',
      one: '1 job',
      zero: 'No jobs',
    );
    return '$_temp0';
  }

  @override
  String get locationInUse =>
      'Scopes of work or jobs use this location, so it can\'t be deleted.';

  @override
  String get locationsNotFound => 'This location no longer exists.';

  @override
  String get streetAddressLabel => 'Street address';

  @override
  String get invalidPhone => 'Enter a 10-digit phone number.';

  @override
  String get moduleTeamHint => 'Who works here and what they can do';

  @override
  String get moduleTimeline => 'Timeline';

  @override
  String get noTeamYet => 'No one on this team yet';

  @override
  String get noTeamYetHint => 'Add people with +.';

  @override
  String get customAccessTag => 'Custom access';

  @override
  String get memberTitle => 'Team member';

  @override
  String get sectionAccess => 'Access';

  @override
  String get editAccess => 'Edit access';

  @override
  String get addMemberTitle => 'Add to team';

  @override
  String get memberUserLabel => 'Person';

  @override
  String get baseRoleLabel => 'Role on this account';

  @override
  String get baseRoleChangeHelp =>
      'Changing the role resets access to that role\'s defaults.';

  @override
  String get accessHelp => 'Turning off View turns off the rest of that area.';

  @override
  String get resetAccess => 'Reset to the role\'s defaults';

  @override
  String get addMemberHelp =>
      'Access starts at the role\'s defaults. You can adjust it after adding them.';

  @override
  String get noOneToAdd => 'Everyone active is already on this team.';

  @override
  String get removeMember => 'Remove from team';

  @override
  String removeMemberConfirmTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeMemberConfirmBody =>
      'They\'ll lose access to this account. Their user and history stay.';

  @override
  String get removeButton => 'Remove';

  @override
  String get teamReadOnly => 'Only owners can change the team.';

  @override
  String get accessView => 'View';

  @override
  String get accessEdit => 'Edit';

  @override
  String get accessAssign => 'Assign';

  @override
  String get accessDownload => 'Download';

  @override
  String get accessUpload => 'Upload';

  @override
  String get accessManage => 'Manage';

  @override
  String get membersNotFound => 'This person is no longer on this team.';

  @override
  String get membersUserNotActive =>
      'This user is deactivated. Reactivate them before adding them.';

  @override
  String get languageAndAppearance => 'Language and appearance';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get themeSystemHint => 'Matches your phone\'s light or dark mode';

  @override
  String get themeSystemSummary => 'System theme';

  @override
  String get themeLightSummary => 'Light theme';

  @override
  String get themeDarkSummary => 'Dark theme';

  @override
  String get moduleProposalsHint => 'Pipeline, pricing and versions';

  @override
  String get proposalStageLead => 'Lead';

  @override
  String get proposalStageWalkthrough => 'Walkthrough';

  @override
  String get proposalStagePricing => 'Pricing';

  @override
  String get proposalStageProposal => 'Proposal';

  @override
  String get proposalStageNegotiation => 'Negotiation';

  @override
  String get proposalStageApproved => 'Approved';

  @override
  String get proposalStageUnknown => 'Other stage';

  @override
  String get noProposalsYet => 'No proposals yet';

  @override
  String get noProposalsYetHint => 'Start one with +.';

  @override
  String get newProposalTitle => 'New proposal';

  @override
  String get proposalTitle => 'Proposal';

  @override
  String get editProposal => 'Edit proposal';

  @override
  String get deleteProposal => 'Delete proposal';

  @override
  String get deleteProposalConfirmTitle => 'Delete this proposal?';

  @override
  String get deleteProposalConfirmBody =>
      'Every version and its line items will be deleted. This can\'t be undone.';

  @override
  String get newVersionTitle => 'New version';

  @override
  String get approveProposalTitle => 'Approve proposal';

  @override
  String get approveButton => 'Approve';

  @override
  String proposalVersion(int number) {
    return 'Version $number';
  }

  @override
  String get proposalNoLineItems => 'No line items yet';

  @override
  String proposalMoreItems(int count, String description) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$description and $count more',
      one: '$description and 1 more',
    );
    return '$_temp0';
  }

  @override
  String proposalPreparedBy(String name) {
    return 'Prepared by $name';
  }

  @override
  String proposalApprovedBy(String name, String date) {
    return 'Approved by $name on $date';
  }

  @override
  String proposalApprovedOn(String date) {
    return 'Approved on $date';
  }

  @override
  String get pipelineStageLabel => 'Stage';

  @override
  String get validUntilLabel => 'Valid until';

  @override
  String get agreedPriceLabel => 'Agreed price';

  @override
  String get agreedPriceHelp => 'Optional until the proposal is approved.';

  @override
  String get lineItemsTotalLabel => 'Line items total';

  @override
  String get versionNoteLabel => 'Version note';

  @override
  String get versionNoteHint => 'e.g. Annual contract discount';

  @override
  String get sectionLineItems => 'Line items';

  @override
  String lineItemTitle(int number) {
    return 'Item $number';
  }

  @override
  String get addLineItem => 'Add line item';

  @override
  String get addLineItemShort => 'Line item';

  @override
  String get lineItemsEmpty => 'None yet. Tap + below to add one.';

  @override
  String get removeLineItem => 'Remove item';

  @override
  String get lineItemServiceLabel => 'From the catalog';

  @override
  String get lineItemDescriptionLabel => 'Description';

  @override
  String get lineItemQuantityLabel => 'Quantity';

  @override
  String lineItemQuantityUnitLabel(String unit) {
    return 'Quantity ($unit)';
  }

  @override
  String get lineItemUnitPriceLabel => 'Unit price';

  @override
  String lineItemTotal(String amount) {
    return 'Line total: $amount';
  }

  @override
  String get invalidQuantity => 'Enter a number like 12000 or 2.5.';

  @override
  String get serviceNotInCatalog => 'No longer in the catalog';

  @override
  String get sectionVersions => 'Versions';

  @override
  String get currentVersionTag => 'Current';

  @override
  String get olderVersionNotice =>
      'This is an earlier version, kept as history. Only the current version can change.';

  @override
  String get approvedProposalNote => 'An approved proposal can\'t change.';

  @override
  String get newVersionHelp =>
      'The current version stays in the history as it is.';

  @override
  String get approveHelp => 'Approving locks this version at the agreed price.';

  @override
  String get proposalsNotFound => 'This proposal no longer exists.';

  @override
  String get proposalsNotCurrentVersion =>
      'Only the current version can change. Add a new version instead.';

  @override
  String get proposalsAlreadyApproved =>
      'This proposal is approved and can\'t change.';

  @override
  String get proposalsHasRelatedRecords =>
      'A contract uses this proposal, so it can\'t be deleted.';

  @override
  String get proposalsAgreedPriceRequired =>
      'Enter the agreed price to approve it.';

  @override
  String get noPriceYet => 'No price yet';

  @override
  String get editLineItem => 'Edit line item';

  @override
  String lineItemError(int number, String message) {
    return 'Item $number: $message';
  }

  @override
  String get searchProposalsHint => 'Search services, notes or stage';

  @override
  String proposalValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String proposalExpiredOn(String date) {
    return 'Expired $date';
  }

  @override
  String get moduleContractsHint => 'Terms, signatures and renewals';

  @override
  String get noContractsYet => 'No contracts yet';

  @override
  String get noContractsYetHint =>
      'Start one with +, or from an approved proposal.';

  @override
  String get contractsFilterLabel => 'Show';

  @override
  String get contractsFilterAll => 'All';

  @override
  String contractsFilterExpiring(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expiring soon ($count)',
      zero: 'Expiring soon',
    );
    return '$_temp0';
  }

  @override
  String get noContractsExpiring => 'Nothing expiring soon';

  @override
  String get noContractsExpiringHint =>
      'No active contract ends in the next 30 days.';

  @override
  String contractFromProposal(int number) {
    return 'From proposal version $number';
  }

  @override
  String contractFrom(String date) {
    return 'From $date';
  }

  @override
  String get contractStatusDraft => 'Draft';

  @override
  String get contractStatusActive => 'Active';

  @override
  String get contractStatusExpired => 'Expired';

  @override
  String get contractStatusCancelled => 'Cancelled';

  @override
  String get contractStatusUnknown => 'Other status';

  @override
  String get contractExpiringSoon => 'Expiring soon';

  @override
  String get contractTitle => 'Contract';

  @override
  String get newContractTitle => 'New contract';

  @override
  String get editContract => 'Edit contract';

  @override
  String get deleteContract => 'Delete contract';

  @override
  String get keepContract => 'Keep it';

  @override
  String get deleteContractConfirmTitle => 'Delete this draft?';

  @override
  String get deleteContractConfirmBody =>
      'The draft contract will be deleted. This can\'t be undone.';

  @override
  String get cancelContract => 'Cancel contract';

  @override
  String get cancelContractConfirmTitle => 'Cancel this contract?';

  @override
  String get cancelContractConfirmBody =>
      'It stays in the account\'s history, but it can\'t be edited or signed again.';

  @override
  String get cancelledContractNotice =>
      'This contract is cancelled. It\'s kept as history and can\'t change.';

  @override
  String contractTermLength(String length) {
    return 'Term: $length';
  }

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get contractScheduleSection => 'Contract schedule & terms';

  @override
  String get contractExecutionSection => 'Execution & documents';

  @override
  String get contractSignedMark => 'Signed';

  @override
  String get contractValueLabel => 'Contract value';

  @override
  String get contractValueFromProposalHelp =>
      'Starts from the proposal\'s agreed price.';

  @override
  String get contractProposalLabel => 'Proposal';

  @override
  String get contractStartLabel => 'Start date';

  @override
  String get contractExpirationLabel => 'Expiration date';

  @override
  String get expirationBeforeStart => 'Pick a day on or after the start date.';

  @override
  String get noEndDate => 'No end date';

  @override
  String get sectionTerm => 'Term';

  @override
  String get paymentTermsLabel => 'Payment terms';

  @override
  String get paymentTermsHint => 'e.g. Net 30';

  @override
  String get autoRenewLabel => 'Renews automatically';

  @override
  String get autoRenewOn => 'Renews automatically';

  @override
  String get autoRenewOff => 'Doesn\'t renew automatically';

  @override
  String get cancellationNoticeLabel => 'Cancellation notice';

  @override
  String get cancellationNoticeHelp => 'Days of notice needed to cancel.';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String contractDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expires in $count days',
      one: 'Expires tomorrow',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String get signatureLabel => 'Signature';

  @override
  String get signedOnLabel => 'Signed on';

  @override
  String contractSignedBy(String name, String date) {
    return 'Signed by $name on $date';
  }

  @override
  String contractSignedOn(String date) {
    return 'Signed on $date';
  }

  @override
  String get contractNotSigned => 'Not signed yet';

  @override
  String get signContract => 'Sign contract';

  @override
  String get signContractHelp =>
      'Signing records you as the signer and makes the contract active.';

  @override
  String get createContract => 'Create contract';

  @override
  String get contractsNotFound => 'This contract no longer exists.';

  @override
  String get contractsValueRequired => 'Enter the contract value.';

  @override
  String get contractsProposalNotApproved =>
      'A contract can only come from an approved proposal.';

  @override
  String get contractsAlreadySigned => 'This contract is already signed.';

  @override
  String get contractsCancelled =>
      'This contract is cancelled and can\'t change.';

  @override
  String get contractsOnlyDraftsDeletable =>
      'Only a draft contract can be deleted. Cancel it instead.';

  @override
  String get contractsHasRelatedRecords =>
      'Scopes of work or invoices use this contract, so it can\'t be deleted.';

  @override
  String get markExpired => 'Mark expired';

  @override
  String get markExpiredConfirmTitle => 'Mark this contract expired?';

  @override
  String get markExpiredConfirmBody =>
      'It stays in the account\'s history and can still be edited.';

  @override
  String contractEndedOn(String date) {
    return 'Ended $date';
  }

  @override
  String get moduleScopeHint => 'Areas, frequency and time windows';

  @override
  String get scopesOfOneContract => 'Showing one contract\'s scopes.';

  @override
  String get noScopesYet => 'No scopes of work yet';

  @override
  String get noScopesYetHint => 'Add one with + for each area of a location.';

  @override
  String get noTimeWindows => 'No time windows';

  @override
  String scheduleAndMore(String schedule, int count) {
    return '$schedule and $count more';
  }

  @override
  String get scopeWholeSite => 'Whole site';

  @override
  String get everyDay => 'Every day';

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyBiweekly => 'Every 2 weeks';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyQuarterly => 'Quarterly';

  @override
  String get frequencyAnnual => 'Yearly';

  @override
  String get frequencyOneTime => 'One time';

  @override
  String get frequencyUnknown => 'Other frequency';

  @override
  String get scopeTitle => 'Scope of work';

  @override
  String get newScopeTitle => 'New scope of work';

  @override
  String get editScope => 'Edit scope';

  @override
  String get deleteScope => 'Delete scope';

  @override
  String get deleteScopeConfirmTitle => 'Delete this scope?';

  @override
  String get deleteScopeConfirmBody =>
      'The scope and its time windows will be deleted. This can\'t be undone.';

  @override
  String get scopeHasJobsNote =>
      'This scope already produced jobs, so it can\'t be deleted. Pause its time windows instead.';

  @override
  String get sectionTimeWindows => 'Time windows';

  @override
  String get sectionSchedule => 'Schedule';

  @override
  String get sectionDetails => 'Details';

  @override
  String get sectionHours => 'Hours';

  @override
  String get timeWindowPaused => 'Paused';

  @override
  String get timeWindowsEmpty => 'None yet. Tap + below to add one.';

  @override
  String get windowsNeedWeekdays => 'Pick the weekdays of each time window.';

  @override
  String get addTimeWindow => 'Add time window';

  @override
  String get addTimeWindowShort => 'Time window';

  @override
  String get editTimeWindow => 'Edit time window';

  @override
  String get removeTimeWindow => 'Remove time window';

  @override
  String get weekdaysLabel => 'Days';

  @override
  String get pickWeekdays => 'Pick at least one day.';

  @override
  String get startTimeLabel => 'Starts';

  @override
  String get endTimeLabel => 'Ends';

  @override
  String get noEndTime => 'No end time';

  @override
  String get endBeforeStart => 'Pick a time after the start.';

  @override
  String get timeWindowActiveLabel => 'Running';

  @override
  String get timeWindowActiveHelp =>
      'A paused window stays on the scope but makes no new work.';

  @override
  String get locationLabel => 'Location';

  @override
  String get areaNameLabel => 'Area';

  @override
  String get areaNameHint => 'e.g. Lobby';

  @override
  String get areaNameHelp => 'Leave empty if it covers the whole site.';

  @override
  String get scopeServiceLabel => 'Service';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get estimatedDurationLabel => 'Estimated duration';

  @override
  String get estimatedDurationHelp => 'In minutes.';

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
  String get instructionsLabel => 'Instructions';

  @override
  String get instructionsHint => 'e.g. Mop with neutral cleaner';

  @override
  String get exclusionsLabel => 'Not included';

  @override
  String get exclusionsHint => 'e.g. Server room (4th floor)';

  @override
  String get requiredSuppliesLabel => 'Supplies';

  @override
  String get requiredSuppliesHint => 'e.g. Microfiber cloths';

  @override
  String get scopesNotFound => 'This scope of work no longer exists.';

  @override
  String get scopesDaysOfWeekRequired =>
      'Weekly work needs the days of each time window.';

  @override
  String get scopesHasJobs =>
      'This scope already produced jobs, so it can\'t be deleted. Pause its time windows instead.';

  @override
  String get scopeNeedsContract =>
      'This account has no active or draft contract yet. Add one under Contracts first.';

  @override
  String get scopeNeedsLocation =>
      'This account has no locations yet. Add one under Locations first.';

  @override
  String get scopeNoServices => 'The service catalog has no active services.';

  @override
  String get moduleCalendarHint => 'Visits by day, moves and one-offs';

  @override
  String get eventStatusScheduled => 'Scheduled';

  @override
  String get eventStatusRescheduled => 'Moved';

  @override
  String get eventStatusCancelled => 'Cancelled';

  @override
  String get eventStatusConverted => 'Job';

  @override
  String get eventStatusUnknown => 'Other status';

  @override
  String eventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
      zero: 'no events',
    );
    return '$_temp0';
  }

  @override
  String get goToToday => 'Go to today';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get nothingScheduled => 'Nothing scheduled';

  @override
  String get nothingScheduledHint =>
      'Add a one-off visit with +. Visits from scopes of work appear on their own.';

  @override
  String get eventTitle => 'Event';

  @override
  String get newEventTitle => 'New event';

  @override
  String get editEvent => 'Edit event';

  @override
  String get deleteEvent => 'Delete event';

  @override
  String get keepEvent => 'Keep it';

  @override
  String get deleteEventConfirmTitle => 'Delete this event?';

  @override
  String get deleteEventConfirmBody =>
      'It will be removed from the calendar. This can\'t be undone.';

  @override
  String get cancelEvent => 'Cancel event';

  @override
  String get cancelEventConfirmTitle => 'Cancel this event?';

  @override
  String get cancelEventConfirmBody =>
      'It stays on the calendar as cancelled and can\'t be changed again.';

  @override
  String get eventCancelledNotice =>
      'This event is cancelled and can\'t change.';

  @override
  String get eventConvertedNotice =>
      'This event became a job, so it\'s changed from the job now.';

  @override
  String get eventFromScope => 'From a scope of work';

  @override
  String get eventOneOff => 'One-off';

  @override
  String get assignedToLabel => 'Assigned to';

  @override
  String get rescheduleEvent => 'Reschedule';

  @override
  String get sectionMoves => 'Moves';

  @override
  String movedFrom(String when) {
    return 'From $when';
  }

  @override
  String movedTo(String when) {
    return 'to $when';
  }

  @override
  String movedBy(String name) {
    return 'by $name';
  }

  @override
  String get eventTitleLabel => 'Title';

  @override
  String get eventTitleHint => 'e.g. Deep clean';

  @override
  String get sectionWhen => 'When';

  @override
  String get eventDateLabel => 'Day';

  @override
  String eventMoveHelp(String day, String time) {
    return '$day at $time. To change the day or start, use Reschedule.';
  }

  @override
  String get eventNoScopes => 'This account has no scopes of work yet.';

  @override
  String get eventNoLocations =>
      'This account has no locations yet. Add one under Locations first.';

  @override
  String get eventNoMembers => 'This account has no active team members yet.';

  @override
  String get sectionNewTime => 'New day and time';

  @override
  String get rescheduleReasonLabel => 'Reason';

  @override
  String get rescheduleReasonHint => 'e.g. Client asked for Thursday';

  @override
  String get rescheduleHelp => 'The current day and time stay in its history.';

  @override
  String get calendarNotFound => 'This event no longer exists.';

  @override
  String get calendarBadRange => 'That range of days is too wide.';

  @override
  String get calendarCancelled => 'This event is cancelled and can\'t change.';

  @override
  String get calendarAlreadyConverted => 'This event already became a job.';

  @override
  String get deleteGeneratedEventConfirmBody =>
      'It will be removed from the calendar and won\'t come back when the month is filled from its scope again. This can\'t be undone.';

  @override
  String get jobsPeriodLabel => 'Which jobs';

  @override
  String get jobsUpcoming => 'Upcoming';

  @override
  String get jobsPast => 'Past 30 days';

  @override
  String get noJobsAheadHint =>
      'Add one with +, or create one from a calendar event.';

  @override
  String get noPastJobs => 'No jobs in the past 30 days';

  @override
  String get newJobTitle => 'New job';

  @override
  String get editJob => 'Edit job';

  @override
  String get deleteJob => 'Delete job';

  @override
  String get keepJob => 'Keep it';

  @override
  String get deleteJobConfirmTitle => 'Delete this job?';

  @override
  String get deleteJobConfirmBody =>
      'It will be removed with its crew and checklist. This can\'t be undone.';

  @override
  String get cancelJob => 'Cancel job';

  @override
  String get cancelJobConfirmTitle => 'Cancel this job?';

  @override
  String get cancelJobConfirmBody =>
      'It stays in the list as cancelled and can\'t be changed again.';

  @override
  String get jobCancelledNotice =>
      'This job was cancelled, so it can\'t change.';

  @override
  String get editButton => 'Edit';

  @override
  String get noChecklistItems => 'No checklist yet';

  @override
  String checkedInAt(String time) {
    return 'In $time';
  }

  @override
  String checkedOutAt(String time) {
    return 'Out $time';
  }

  @override
  String get jobTypeLabel => 'Type';

  @override
  String get jobTypeRecurring => 'Recurring';

  @override
  String get jobTypeSpecial => 'One-off';

  @override
  String doneAtBy(String time, String name) {
    return '$time by $name';
  }

  @override
  String get jobStartedLabel => 'Started';

  @override
  String get jobCompletedLabel => 'Completed';

  @override
  String get qualityScoreLabel => 'Quality score';

  @override
  String qualityScoreValue(String score) {
    return '$score of 5';
  }

  @override
  String get clientSignoffLabel => 'Client sign-off';

  @override
  String get cleanerNotesLabel => 'Crew notes';

  @override
  String get checklistItemDone => 'Done';

  @override
  String get checklistItemOpen => 'Not done';

  @override
  String get editCrewTitle => 'Edit crew';

  @override
  String get editCrewHelp =>
      'Active team members of this account. People who stay keep their check-in times.';

  @override
  String get editChecklistTitle => 'Edit checklist';

  @override
  String get addChecklistItem => 'Add checklist item';

  @override
  String get addChecklistItemShort => 'Item';

  @override
  String checklistResetWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items are ticked. Saving a change clears the ticks.',
      one: '1 item is ticked. Saving a change clears the tick.',
    );
    return '$_temp0';
  }

  @override
  String checklistFull(int max) {
    return 'A checklist holds up to $max items.';
  }

  @override
  String get checklistEmptyHint => 'No items yet. Add them with +.';

  @override
  String checklistItemLabel(int number) {
    return 'Item $number';
  }

  @override
  String get checklistEditHelp =>
      'The crew ticks these off on site, in this order. Blank items are left out.';

  @override
  String get jobNameLabel => 'Title';

  @override
  String get jobNameHint => 'e.g. Nightly clean';

  @override
  String endsNextDay(String time) {
    return '$time (next day)';
  }

  @override
  String get jobEndHelp => 'An end before the start is on the next day.';

  @override
  String get jobInstructionsHint => 'e.g. Alarm code is at the front desk';

  @override
  String get openJob => 'Open job';

  @override
  String get createJobFromEvent => 'Create job';

  @override
  String get jobsNotFound => 'This job no longer exists.';

  @override
  String get jobsNotAssigned => 'You\'re not on this job\'s crew.';

  @override
  String get jobsAssigneeNotActive =>
      'Someone picked for the crew is no longer active.';

  @override
  String get jobsLocationRequired =>
      'This event has no location. Add one before creating a job.';

  @override
  String get jobsClosed =>
      'This job is completed or cancelled, so it can\'t change.';

  @override
  String get jobsAlreadyCompleted => 'This job is already completed.';

  @override
  String get jobsOnlyScheduledDeletable =>
      'Only a job that hasn\'t started can be deleted.';

  @override
  String get tickChecklistItem => 'Tick off';

  @override
  String get reopenChecklistItem => 'Reopen';

  @override
  String get checkIn => 'Check in';

  @override
  String get checkOut => 'Check out';

  @override
  String get startJob => 'Start job';

  @override
  String get completeJob => 'Complete job';

  @override
  String get completeJobTitle => 'Complete job';

  @override
  String youCheckedIn(String time) {
    return 'You checked in at $time.';
  }

  @override
  String youCheckedInOut(String inTime, String outTime) {
    return 'You checked in at $inTime and out at $outTime.';
  }

  @override
  String checklistStillOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count checklist items aren\'t ticked yet.',
      one: '1 checklist item isn\'t ticked yet.',
    );
    return '$_temp0';
  }

  @override
  String get qualityScoreHelp =>
      'Optional. 5 is the best. Tap the score again to clear it.';

  @override
  String get cleanerNotesHint => 'e.g. Restroom faucet is leaking';

  @override
  String get clientSignoffHint => 'e.g. María López';

  @override
  String get clientSignoffHelp =>
      'Optional. The client\'s name, if they checked the work on site.';

  @override
  String get jobsNotScheduled =>
      'Only a scheduled job can be started. It may have started already.';

  @override
  String get jobsNotInProgress =>
      'Only a job in progress can be completed. Start it first.';

  @override
  String get jobsAlreadyCheckedIn => 'You already checked in to this job.';

  @override
  String get jobsNotCheckedIn => 'Check in before checking out.';

  @override
  String get jobsChecklistItemNotFound =>
      'That checklist item no longer exists.';

  @override
  String get jobProgressCompleted => 'Task completion';

  @override
  String get jobProgressActive => 'Active progress';

  @override
  String checklistProgressPercent(int done, int total, int percent) {
    return '$done of $total done ($percent%)';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String jobsOnDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs scheduled',
      one: '1 job scheduled',
      zero: 'Nothing scheduled',
    );
    return '$_temp0';
  }

  @override
  String get jobsFilter => 'Filter by status';

  @override
  String jobsFilterOn(String status) {
    return 'Filtered: $status';
  }

  @override
  String get noJobsOnDay => 'No jobs this day';

  @override
  String get noJobsMatchFilter => 'No jobs with this status this day';

  @override
  String get dayHasJobs => 'has jobs';

  @override
  String get moreActions => 'More actions';

  @override
  String checklistCompletedCount(int done, int total) {
    return '$done of $total completed';
  }

  @override
  String percentDone(int percent) {
    return '$percent% done';
  }

  @override
  String get reviewTasks => 'Review tasks';

  @override
  String get copyButton => 'Copy';

  @override
  String get copiedButton => 'Copied';

  @override
  String get eventCheckedIn => 'Checked in';

  @override
  String get eventCheckedOut => 'Checked out';

  @override
  String get eventWorkCompleted => 'Work completed';

  @override
  String get activityTitle => 'Activity';

  @override
  String activityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }
}
