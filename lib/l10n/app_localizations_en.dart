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
  String get tabProfile => 'Me';

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
  String get jobsNextDays => 'Next 7 days';

  @override
  String get noJobsAhead => 'No jobs in the next 7 days';

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
  String get assigneesReadOnly =>
      'Only owners and account managers can change who\'s in charge.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirmBody =>
      'Only accounts that were never used can be deleted. This can\'t be undone.';

  @override
  String get accountCreatedTitle => 'Account created';

  @override
  String get accountCreatedNotMember =>
      'To open it, ask an owner to add you to its team.';

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
}
