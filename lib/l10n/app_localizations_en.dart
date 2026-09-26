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
  String get sectionWork => 'Work';

  @override
  String get sectionAccount => 'Account';

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
  String get filterAll => 'All';

  @override
  String get noUsersFound => 'No users match';

  @override
  String get noUsersFoundHint => 'Try another name or filter.';

  @override
  String get inactiveTag => 'Inactive';

  @override
  String get clientUserTag => 'Client';

  @override
  String get addUser => 'Add user';

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
  String get addAccount => 'Add account';

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
  String get addService => 'Add service';

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
  String get catalogTabServices => 'Services';

  @override
  String get catalogTabCategories => 'Categories';

  @override
  String get catalogTabUnits => 'Units';

  @override
  String get addCategory => 'Add category';

  @override
  String get addUnit => 'Add unit';

  @override
  String get searchCategoriesHint => 'Search categories';

  @override
  String get searchUnitsHint => 'Search name or abbreviation';

  @override
  String get allCategories => 'All categories';

  @override
  String get noMatchesFound => 'Nothing matches';

  @override
  String get noMatchesHint => 'Try another search or filter.';

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
  String get noUnitsToPick => 'Add a unit under Service catalog → Units first.';

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
  String get noCategoryGroup => 'No category';

  @override
  String get noDefaultPrice => 'No price';

  @override
  String shownAs(String abbreviation) {
    return 'Shown as $abbreviation';
  }

  @override
  String get clearFilter => 'Clear filter';

  @override
  String get createTitle => 'Create';
}
