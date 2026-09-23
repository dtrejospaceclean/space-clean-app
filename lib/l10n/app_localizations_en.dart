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
}
