import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Space Clean'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @signOutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String homeWelcome(String name);

  /// No description provided for @homeRoles.
  ///
  /// In en, this message translates to:
  /// **'Roles: {roles}'**
  String homeRoles(String roles);

  /// No description provided for @splashLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t restore your session.'**
  String get splashLoadError;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryButton;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationInvalidEmail;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {min} characters.'**
  String validationMinLength(String min);

  /// No description provided for @validationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Must be at most {max} characters.'**
  String validationMaxLength(String max);

  /// No description provided for @validationFailed.
  ///
  /// In en, this message translates to:
  /// **'Some fields need your attention.'**
  String get validationFailed;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authInvalidCredentials;

  /// No description provided for @authSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again.'**
  String get authSessionExpired;

  /// No description provided for @authInsufficientPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get authInsufficientPermission;

  /// No description provided for @authInsufficientRole.
  ///
  /// In en, this message translates to:
  /// **'Your role doesn\'t allow this action.'**
  String get authInsufficientRole;

  /// No description provided for @errorsNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection.'**
  String get errorsNetwork;

  /// No description provided for @errorsTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get errorsTooManyRequests;

  /// No description provided for @errorsNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorsNotFound;

  /// No description provided for @errorsInternal.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Try again.'**
  String get errorsInternal;

  /// No description provided for @errorsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorsUnknown;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'One Partner. Every Facility Solution.'**
  String get brandTagline;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @notYou.
  ///
  /// In en, this message translates to:
  /// **'Not you?'**
  String get notYou;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@company.com'**
  String get emailHint;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetTitle;

  /// No description provided for @resetEmailIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the email you sign in with. We\'ll send you a 6-digit code.'**
  String get resetEmailIntro;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// No description provided for @codeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get codeTitle;

  /// No description provided for @codeIntro.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. It may take a minute to arrive.'**
  String codeIntro(String email);

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get codeLabel;

  /// No description provided for @codeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter all 6 digits.'**
  String get codeIncomplete;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'New code in {seconds} s'**
  String resendIn(String seconds);

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'We sent a new code.'**
  String get codeResent;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'You\'ll use it to sign in from now on.'**
  String get newPasswordIntro;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get confirmPasswordLabel;

  /// No description provided for @ruleMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters'**
  String ruleMinLength(String min);

  /// No description provided for @ruleMatch.
  ///
  /// In en, this message translates to:
  /// **'Both passwords match'**
  String get ruleMatch;

  /// No description provided for @ruleMet.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ruleMet;

  /// No description provided for @ruleNotMet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get ruleNotMet;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'t match.'**
  String get passwordsDontMatch;

  /// No description provided for @savePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePasswordButton;

  /// No description provided for @resetDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get resetDoneTitle;

  /// No description provided for @resetDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your new password.'**
  String get resetDoneBody;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @errorsFeatureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Password reset isn\'t available in the app yet. Ask your supervisor or admin to reset your password.'**
  String get errorsFeatureUnavailable;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get tabAccounts;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabProfile;

  /// No description provided for @todayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTitle;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greeting(String name);

  /// No description provided for @noJobsToday.
  ///
  /// In en, this message translates to:
  /// **'No jobs today'**
  String get noJobsToday;

  /// No description provided for @noJobsTodayHint.
  ///
  /// In en, this message translates to:
  /// **'When a job is scheduled for you, it shows up here.'**
  String get noJobsTodayHint;

  /// No description provided for @someAccountsFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account couldn\'t load. Pull down to try again.} other{{count} accounts couldn\'t load. Pull down to try again.}}'**
  String someAccountsFailed(int count);

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// No description provided for @noAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccounts;

  /// No description provided for @noAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your manager to add you to a client account.'**
  String get noAccountsHint;

  /// No description provided for @clientStatusProspect.
  ///
  /// In en, this message translates to:
  /// **'Prospect'**
  String get clientStatusProspect;

  /// No description provided for @clientStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get clientStatusInactive;

  /// No description provided for @yourRole.
  ///
  /// In en, this message translates to:
  /// **'Your role: {role}'**
  String yourRole(String role);

  /// No description provided for @sectionWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get sectionWork;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @moduleJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get moduleJobs;

  /// No description provided for @moduleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get moduleCalendar;

  /// No description provided for @moduleComplaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get moduleComplaints;

  /// No description provided for @moduleTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get moduleTasks;

  /// No description provided for @moduleProposals.
  ///
  /// In en, this message translates to:
  /// **'Proposals'**
  String get moduleProposals;

  /// No description provided for @moduleContracts.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get moduleContracts;

  /// No description provided for @moduleScope.
  ///
  /// In en, this message translates to:
  /// **'Scope of work'**
  String get moduleScope;

  /// No description provided for @moduleTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get moduleTeam;

  /// No description provided for @moduleInfo.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get moduleInfo;

  /// No description provided for @moduleFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get moduleFiles;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get comingSoon;

  /// No description provided for @noModules.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to anything in this account yet.'**
  String get noModules;

  /// No description provided for @jobsNextDays.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get jobsNextDays;

  /// No description provided for @noJobsAhead.
  ///
  /// In en, this message translates to:
  /// **'No jobs in the next 7 days'**
  String get noJobsAhead;

  /// No description provided for @jobStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get jobStatusScheduled;

  /// No description provided for @jobStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get jobStatusInProgress;

  /// No description provided for @jobStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get jobStatusCompleted;

  /// No description provided for @jobStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get jobStatusCancelled;

  /// No description provided for @jobStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get jobStatusUnknown;

  /// No description provided for @jobWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get jobWhen;

  /// No description provided for @jobWhere.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get jobWhere;

  /// No description provided for @jobCrew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get jobCrew;

  /// No description provided for @jobChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get jobChecklist;

  /// No description provided for @jobInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get jobInstructions;

  /// No description provided for @noCrewAssigned.
  ///
  /// In en, this message translates to:
  /// **'No one assigned yet'**
  String get noCrewAssigned;

  /// No description provided for @checklistProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String checklistProgress(int done, int total);

  /// No description provided for @noChecklist.
  ///
  /// In en, this message translates to:
  /// **'No checklist'**
  String get noChecklist;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAccountManager.
  ///
  /// In en, this message translates to:
  /// **'Account manager'**
  String get roleAccountManager;

  /// No description provided for @roleSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get roleSupervisor;

  /// No description provided for @roleCrew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get roleCrew;

  /// No description provided for @roleClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get roleClient;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get profileTitle;

  /// No description provided for @sectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sectionSettings;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need your email and password to sign in again.'**
  String get signOutConfirmBody;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @sectionAdministration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get sectionAdministration;

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTitle;

  /// No description provided for @rolesTitle.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get rolesTitle;

  /// No description provided for @searchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, email or employee ID'**
  String get searchUsersHint;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get filterInactive;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users match'**
  String get noUsersFound;

  /// No description provided for @noUsersFoundHint.
  ///
  /// In en, this message translates to:
  /// **'Try another name or email.'**
  String get noUsersFoundHint;

  /// No description provided for @inactiveTag.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveTag;

  /// No description provided for @clientUserTag.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientUserTag;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit user'**
  String get editUser;

  /// No description provided for @newUserTitle.
  ///
  /// In en, this message translates to:
  /// **'New user'**
  String get newUserTitle;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @sectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get sectionContact;

  /// No description provided for @sectionEmployment.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get sectionEmployment;

  /// No description provided for @sectionEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get sectionEmergency;

  /// No description provided for @sectionRoles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get sectionRoles;

  /// No description provided for @sectionSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign-in'**
  String get sectionSignIn;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @employeeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeIdLabel;

  /// No description provided for @employmentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Employment type'**
  String get employmentTypeLabel;

  /// No description provided for @payRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay rate (per hour)'**
  String get payRateLabel;

  /// No description provided for @hireDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Hire date'**
  String get hireDateLabel;

  /// No description provided for @emergencyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get emergencyNameLabel;

  /// No description provided for @emergencyPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get emergencyPhoneLabel;

  /// No description provided for @initialPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get initialPasswordLabel;

  /// No description provided for @newPasswordOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'New password (optional)'**
  String get newPasswordOptionalLabel;

  /// No description provided for @passwordHelpCreate.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters. Share it with the person privately.'**
  String get passwordHelpCreate;

  /// No description provided for @passwordHelpEdit.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep the current password.'**
  String get passwordHelpEdit;

  /// No description provided for @employmentFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full-time'**
  String get employmentFullTime;

  /// No description provided for @employmentPartTime.
  ///
  /// In en, this message translates to:
  /// **'Part-time'**
  String get employmentPartTime;

  /// No description provided for @employmentContractor.
  ///
  /// In en, this message translates to:
  /// **'Contractor'**
  String get employmentContractor;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @chooseButton.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get chooseButton;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @invalidPayRate.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like 18.50.'**
  String get invalidPayRate;

  /// No description provided for @noRolesSelected.
  ///
  /// In en, this message translates to:
  /// **'No roles: this person can\'t do anything yet.'**
  String get noRolesSelected;

  /// No description provided for @deactivateUser.
  ///
  /// In en, this message translates to:
  /// **'Deactivate user'**
  String get deactivateUser;

  /// No description provided for @reactivateUser.
  ///
  /// In en, this message translates to:
  /// **'Reactivate user'**
  String get reactivateUser;

  /// No description provided for @deactivateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {name}?'**
  String deactivateConfirmTitle(String name);

  /// No description provided for @deactivateConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'They won\'t be able to sign in. Their history stays, and you can reactivate them later.'**
  String get deactivateConfirmBody;

  /// No description provided for @deactivateButton.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivateButton;

  /// No description provided for @reactivateButton.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivateButton;

  /// No description provided for @userInactiveNotice.
  ///
  /// In en, this message translates to:
  /// **'This user is deactivated and can\'t sign in.'**
  String get userInactiveNotice;

  /// No description provided for @readOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Only owners can change users and roles.'**
  String get readOnlyNotice;

  /// No description provided for @addRole.
  ///
  /// In en, this message translates to:
  /// **'Add role'**
  String get addRole;

  /// No description provided for @editRole.
  ///
  /// In en, this message translates to:
  /// **'Edit role'**
  String get editRole;

  /// No description provided for @roleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get roleNameLabel;

  /// No description provided for @roleNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters, numbers and _ (e.g. floor_lead)'**
  String get roleNameHelp;

  /// No description provided for @roleDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get roleDescriptionLabel;

  /// No description provided for @roleNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, numbers and _, starting with a letter.'**
  String get roleNameInvalid;

  /// No description provided for @builtInRole.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get builtInRole;

  /// No description provided for @roleUserCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No users} =1{1 user} other{{count} users}}'**
  String roleUserCount(int count);

  /// No description provided for @deleteRole.
  ///
  /// In en, this message translates to:
  /// **'Delete role'**
  String get deleteRole;

  /// No description provided for @deleteRoleConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteRoleConfirmTitle(String name);

  /// No description provided for @deleteRoleConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get deleteRoleConfirmBody;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @roleInUseHint.
  ///
  /// In en, this message translates to:
  /// **'Remove this role from its users before deleting it.'**
  String get roleInUseHint;

  /// No description provided for @usersEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'Another user already has this email.'**
  String get usersEmailTaken;

  /// No description provided for @rolesStillAssigned.
  ///
  /// In en, this message translates to:
  /// **'This role is still assigned to users.'**
  String get rolesStillAssigned;

  /// No description provided for @rolesSystemRole.
  ///
  /// In en, this message translates to:
  /// **'Built-in roles can\'t be renamed or deleted.'**
  String get rolesSystemRole;

  /// No description provided for @rolesSomeNotFound.
  ///
  /// In en, this message translates to:
  /// **'One of the selected roles no longer exists. Refresh and try again.'**
  String get rolesSomeNotFound;

  /// No description provided for @usersNotFound.
  ///
  /// In en, this message translates to:
  /// **'This user no longer exists.'**
  String get usersNotFound;

  /// No description provided for @errorsUniqueViolation.
  ///
  /// In en, this message translates to:
  /// **'That value is already in use.'**
  String get errorsUniqueViolation;

  /// No description provided for @jobsTodayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing scheduled today} =1{1 job today} other{{count} jobs today}}'**
  String jobsTodayCount(int count);

  /// No description provided for @yourJobs.
  ///
  /// In en, this message translates to:
  /// **'Your jobs'**
  String get yourJobs;

  /// No description provided for @statToDo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get statToDo;

  /// No description provided for @accountsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No accounts yet} =1{1 account} other{{count} accounts}}'**
  String accountsCount(int count);

  /// No description provided for @comingSoonLong.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonLong;

  /// No description provided for @openSection.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openSection;

  /// No description provided for @clientStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get clientStatusActive;

  /// No description provided for @newAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get newAccountTitle;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccount;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get sectionBilling;

  /// No description provided for @sectionPeopleInCharge.
  ///
  /// In en, this message translates to:
  /// **'People in charge'**
  String get sectionPeopleInCharge;

  /// No description provided for @legalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Legal name'**
  String get legalNameLabel;

  /// No description provided for @dbaLabel.
  ///
  /// In en, this message translates to:
  /// **'Trade name (DBA)'**
  String get dbaLabel;

  /// No description provided for @dbaHelp.
  ///
  /// In en, this message translates to:
  /// **'The name people use, if different from the legal name.'**
  String get dbaHelp;

  /// No description provided for @industryLabel.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industryLabel;

  /// No description provided for @serviceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get serviceTypeLabel;

  /// No description provided for @serviceTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Office cleaning'**
  String get serviceTypeHint;

  /// No description provided for @accountStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get accountStatusLabel;

  /// No description provided for @taxIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get taxIdLabel;

  /// No description provided for @billingAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get billingAddressLabel;

  /// No description provided for @billingCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get billingCityLabel;

  /// No description provided for @billingStateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get billingStateLabel;

  /// No description provided for @billingZipLabel.
  ///
  /// In en, this message translates to:
  /// **'ZIP code'**
  String get billingZipLabel;

  /// No description provided for @salespersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Salesperson'**
  String get salespersonLabel;

  /// No description provided for @assigneesReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Only owners and account managers can change who\'s in charge.'**
  String get assigneesReadOnly;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Only accounts that were never used can be deleted. This can\'t be undone.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @accountCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountCreatedTitle;

  /// No description provided for @accountCreatedNotMember.
  ///
  /// In en, this message translates to:
  /// **'To open it, ask an owner to add you to its team.'**
  String get accountCreatedNotMember;

  /// No description provided for @clientsHasRelatedRecords.
  ///
  /// In en, this message translates to:
  /// **'This account has history (proposals, contracts, locations, jobs or invoices), so it can\'t be deleted. Set its status to Inactive instead.'**
  String get clientsHasRelatedRecords;

  /// No description provided for @clientsAssigneeNotActive.
  ///
  /// In en, this message translates to:
  /// **'The account manager, supervisor and salesperson must be active users.'**
  String get clientsAssigneeNotActive;

  /// No description provided for @clientsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This account no longer exists.'**
  String get clientsNotFound;

  /// No description provided for @searchAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or tax ID'**
  String get searchAccountsHint;

  /// No description provided for @noAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts match'**
  String get noAccountsFound;

  /// No description provided for @noAccountsFoundHint.
  ///
  /// In en, this message translates to:
  /// **'Try another name or tax ID.'**
  String get noAccountsFoundHint;

  /// No description provided for @searchingLabel.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get searchingLabel;

  /// No description provided for @moduleJobsHint.
  ///
  /// In en, this message translates to:
  /// **'Schedule, crew and progress'**
  String get moduleJobsHint;

  /// No description provided for @moduleInfoHint.
  ///
  /// In en, this message translates to:
  /// **'Billing and people in charge'**
  String get moduleInfoHint;

  /// No description provided for @adminUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Staff and client sign-ins'**
  String get adminUsersHint;

  /// No description provided for @adminRolesHint.
  ///
  /// In en, this message translates to:
  /// **'Staff roles and who has them'**
  String get adminRolesHint;

  /// No description provided for @usersCannotDeactivateSelf.
  ///
  /// In en, this message translates to:
  /// **'You can\'t deactivate your own account.'**
  String get usersCannotDeactivateSelf;

  /// No description provided for @ownAccountNotice.
  ///
  /// In en, this message translates to:
  /// **'This is your account. You can\'t deactivate yourself; another owner can.'**
  String get ownAccountNotice;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @appearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceLabel;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @builtInRoleNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Built-in roles keep their name. You can change the description.'**
  String get builtInRoleNameHelp;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Update the password you sign in with'**
  String get changePasswordHint;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @changePasswordFootnote.
  ///
  /// In en, this message translates to:
  /// **'You\'ll stay signed in on this phone.'**
  String get changePasswordFootnote;

  /// No description provided for @authWrongCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Your current password is incorrect.'**
  String get authWrongCurrentPassword;

  /// No description provided for @passwordChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChangedTitle;

  /// No description provided for @passwordChangedBody.
  ///
  /// In en, this message translates to:
  /// **'Use your new password the next time you sign in.'**
  String get passwordChangedBody;

  /// No description provided for @profileEmailFootnote.
  ///
  /// In en, this message translates to:
  /// **'You sign in with {email}. To change it, ask an owner.'**
  String profileEmailFootnote(String email);

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Service catalog'**
  String get servicesTitle;

  /// No description provided for @adminServicesHint.
  ///
  /// In en, this message translates to:
  /// **'Services, categories and units'**
  String get adminServicesHint;

  /// No description provided for @newServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'New service'**
  String get newServiceTitle;

  /// No description provided for @editServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get editServiceTitle;

  /// No description provided for @searchServicesHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or category'**
  String get searchServicesHint;

  /// No description provided for @noServicesYet.
  ///
  /// In en, this message translates to:
  /// **'No services yet'**
  String get noServicesYet;

  /// No description provided for @noServicesYetHint.
  ///
  /// In en, this message translates to:
  /// **'Add the services you offer so proposals and scopes can use them.'**
  String get noServicesYetHint;

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services match'**
  String get noServicesFound;

  /// No description provided for @noServicesFoundHint.
  ///
  /// In en, this message translates to:
  /// **'Try another name, category or filter.'**
  String get noServicesFoundHint;

  /// No description provided for @perUnit.
  ///
  /// In en, this message translates to:
  /// **'per {unit}'**
  String perUnit(String unit);

  /// No description provided for @sectionService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get sectionService;

  /// No description provided for @sectionPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get sectionPricing;

  /// No description provided for @serviceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get serviceNameLabel;

  /// No description provided for @serviceCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get serviceCategoryLabel;

  /// No description provided for @unitOfMeasureLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit of measure'**
  String get unitOfMeasureLabel;

  /// No description provided for @defaultPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Default price per unit'**
  String get defaultPriceLabel;

  /// No description provided for @defaultPriceHelp.
  ///
  /// In en, this message translates to:
  /// **'Pre-fills the unit price on new proposals. Leave empty to price each time.'**
  String get defaultPriceHelp;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like 0.12 or 25.'**
  String get invalidPrice;

  /// No description provided for @serviceInactiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Inactive services stay on existing proposals and scopes, but can\'t be picked for new ones.'**
  String get serviceInactiveHelp;

  /// No description provided for @serviceCatalogNotFound.
  ///
  /// In en, this message translates to:
  /// **'This service no longer exists.'**
  String get serviceCatalogNotFound;

  /// No description provided for @serviceCatalogSomeNotFound.
  ///
  /// In en, this message translates to:
  /// **'One of the services is unknown or inactive. Refresh and try again.'**
  String get serviceCatalogSomeNotFound;

  /// No description provided for @searchCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategoriesHint;

  /// No description provided for @searchUnitsHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or abbreviation'**
  String get searchUnitsHint;

  /// No description provided for @noMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get noMatchesFound;

  /// No description provided for @noMatchesHint.
  ///
  /// In en, this message translates to:
  /// **'Try another search.'**
  String get noMatchesHint;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @noCategoriesYetHint.
  ///
  /// In en, this message translates to:
  /// **'Categories group your services, like Janitorial or Floor care.'**
  String get noCategoriesYetHint;

  /// No description provided for @noUnitsYet.
  ///
  /// In en, this message translates to:
  /// **'No units yet'**
  String get noUnitsYet;

  /// No description provided for @noUnitsYetHint.
  ///
  /// In en, this message translates to:
  /// **'Add how you price services, like Square foot, Hour or Visit.'**
  String get noUnitsYetHint;

  /// No description provided for @serviceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No services} =1{1 service} other{{count} services}}'**
  String serviceCount(int count);

  /// No description provided for @newCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategoryTitle;

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategoryTitle;

  /// No description provided for @newUnitTitle.
  ///
  /// In en, this message translates to:
  /// **'New unit'**
  String get newUnitTitle;

  /// No description provided for @editUnitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit unit'**
  String get editUnitTitle;

  /// No description provided for @catalogCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get catalogCategoryLabel;

  /// No description provided for @catalogUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit of measure'**
  String get catalogUnitLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Janitorial'**
  String get categoryNameHint;

  /// No description provided for @unitNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Square foot'**
  String get unitNameHint;

  /// No description provided for @categoryDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get categoryDescriptionLabel;

  /// No description provided for @abbreviationLabel.
  ///
  /// In en, this message translates to:
  /// **'Abbreviation'**
  String get abbreviationLabel;

  /// No description provided for @abbreviationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. sq ft'**
  String get abbreviationHint;

  /// No description provided for @abbreviationHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown next to prices: \$0.12 / sq ft. Leave empty to use the name.'**
  String get abbreviationHelp;

  /// No description provided for @categoryInactiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Inactive categories stay on existing services, but can\'t be picked for new ones.'**
  String get categoryInactiveHelp;

  /// No description provided for @unitInactiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Inactive units stay on existing services, but can\'t be picked for new ones.'**
  String get unitInactiveHelp;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @deleteUnit.
  ///
  /// In en, this message translates to:
  /// **'Delete unit'**
  String get deleteUnit;

  /// No description provided for @lookupInUse.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 service uses this, so it can\'t be deleted. Set it to Inactive instead.} other{{count} services use this, so it can\'t be deleted. Set it to Inactive instead.}}'**
  String lookupInUse(int count);

  /// No description provided for @lookupNameTaken.
  ///
  /// In en, this message translates to:
  /// **'Another one already has this name.'**
  String get lookupNameTaken;

  /// No description provided for @noUnitsToPick.
  ///
  /// In en, this message translates to:
  /// **'Add a unit first: Service catalog → + → Manage units.'**
  String get noUnitsToPick;

  /// No description provided for @serviceCatalogCategoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'This category was removed or set to inactive. Pick another.'**
  String get serviceCatalogCategoryNotFound;

  /// No description provided for @serviceCatalogUnitNotFound.
  ///
  /// In en, this message translates to:
  /// **'This unit was removed or set to inactive. Pick another.'**
  String get serviceCatalogUnitNotFound;

  /// No description provided for @serviceCategoriesNotFound.
  ///
  /// In en, this message translates to:
  /// **'This category no longer exists.'**
  String get serviceCategoriesNotFound;

  /// No description provided for @serviceCategoriesInUse.
  ///
  /// In en, this message translates to:
  /// **'Services still use this category, so it can\'t be deleted. Set it to Inactive instead.'**
  String get serviceCategoriesInUse;

  /// No description provided for @unitsOfMeasureNotFound.
  ///
  /// In en, this message translates to:
  /// **'This unit no longer exists.'**
  String get unitsOfMeasureNotFound;

  /// No description provided for @unitsOfMeasureInUse.
  ///
  /// In en, this message translates to:
  /// **'Services still use this unit, so it can\'t be deleted. Set it to Inactive instead.'**
  String get unitsOfMeasureInUse;

  /// No description provided for @noDefaultPrice.
  ///
  /// In en, this message translates to:
  /// **'No price'**
  String get noDefaultPrice;

  /// No description provided for @shownAs.
  ///
  /// In en, this message translates to:
  /// **'Shown as {abbreviation}'**
  String shownAs(String abbreviation);

  /// No description provided for @createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createTitle;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

  /// No description provided for @manageUnits.
  ///
  /// In en, this message translates to:
  /// **'Manage units'**
  String get manageUnits;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @unitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units of measure'**
  String get unitsTitle;

  /// No description provided for @activeTag.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeTag;

  /// No description provided for @moduleContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get moduleContacts;

  /// No description provided for @moduleContactsHint.
  ///
  /// In en, this message translates to:
  /// **'People at the client'**
  String get moduleContactsHint;

  /// No description provided for @noContactsYet.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get noContactsYet;

  /// No description provided for @noContactsYetHint.
  ///
  /// In en, this message translates to:
  /// **'Add the people you deal with at this account with +.'**
  String get noContactsYetHint;

  /// No description provided for @primaryContactTag.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primaryContactTag;

  /// No description provided for @billingContactTag.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billingContactTag;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactTitle;

  /// No description provided for @newContactTitle.
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get newContactTitle;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get editContact;

  /// No description provided for @deleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete contact'**
  String get deleteContact;

  /// No description provided for @deleteContactWithLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Their login stays: they can still sign in and see this account. This can\'t be undone.'**
  String get deleteContactWithLoginBody;

  /// No description provided for @contactHasLogin.
  ///
  /// In en, this message translates to:
  /// **'Has a login'**
  String get contactHasLogin;

  /// No description provided for @contactHasLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Signs in as a client of this account'**
  String get contactHasLoginHint;

  /// No description provided for @giveLogin.
  ///
  /// In en, this message translates to:
  /// **'Give a login'**
  String get giveLogin;

  /// No description provided for @signsInWith.
  ///
  /// In en, this message translates to:
  /// **'Will sign in with {email}'**
  String signsInWith(String email);

  /// No description provided for @giveLoginNeedsEmail.
  ///
  /// In en, this message translates to:
  /// **'Add an email to this contact first'**
  String get giveLoginNeedsEmail;

  /// No description provided for @giveLoginFootnote.
  ///
  /// In en, this message translates to:
  /// **'{name} will see this account in the app as a client.'**
  String giveLoginFootnote(String name);

  /// No description provided for @loginCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Login created'**
  String get loginCreatedTitle;

  /// No description provided for @loginCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'They can now sign in with {email} and the password you set. Share it with them privately.'**
  String loginCreatedBody(String email);

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @sectionPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get sectionPerson;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @jobTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitleLabel;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Facilities Manager'**
  String get jobTitleHint;

  /// No description provided for @contactNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Prefers calls in the morning'**
  String get contactNotesHint;

  /// No description provided for @contactRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role at the account'**
  String get contactRoleLabel;

  /// No description provided for @contactRoleHelp.
  ///
  /// In en, this message translates to:
  /// **'An account has one primary and one billing contact. Choosing one here takes it from whoever had it.'**
  String get contactRoleHelp;

  /// No description provided for @clientContactsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This contact no longer exists.'**
  String get clientContactsNotFound;

  /// No description provided for @clientContactsEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Add an email to this contact before giving them a login.'**
  String get clientContactsEmailRequired;

  /// No description provided for @clientContactsLoginExists.
  ///
  /// In en, this message translates to:
  /// **'This contact already has a login.'**
  String get clientContactsLoginExists;

  /// No description provided for @moduleLocations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get moduleLocations;

  /// No description provided for @moduleLocationsHint.
  ///
  /// In en, this message translates to:
  /// **'Sites, access and instructions'**
  String get moduleLocationsHint;

  /// No description provided for @searchLocationsHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, address or city'**
  String get searchLocationsHint;

  /// No description provided for @noLocationsYet.
  ///
  /// In en, this message translates to:
  /// **'No locations yet'**
  String get noLocationsYet;

  /// No description provided for @noLocationsYetHint.
  ///
  /// In en, this message translates to:
  /// **'Add the sites where the work happens with +.'**
  String get noLocationsYetHint;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationTitle;

  /// No description provided for @newLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'New location'**
  String get newLocationTitle;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit location'**
  String get editLocation;

  /// No description provided for @deleteLocation.
  ///
  /// In en, this message translates to:
  /// **'Delete location'**
  String get deleteLocation;

  /// No description provided for @locationNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tower A – Floor 3'**
  String get locationNameHint;

  /// No description provided for @sectionAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get sectionAddress;

  /// No description provided for @sectionSiteDetails.
  ///
  /// In en, this message translates to:
  /// **'Site details'**
  String get sectionSiteDetails;

  /// No description provided for @sectionUsedBy.
  ///
  /// In en, this message translates to:
  /// **'Used by'**
  String get sectionUsedBy;

  /// No description provided for @squareFootageLabel.
  ///
  /// In en, this message translates to:
  /// **'Square footage'**
  String get squareFootageLabel;

  /// No description provided for @squareFootageValue.
  ///
  /// In en, this message translates to:
  /// **'{value} sq ft'**
  String squareFootageValue(String value);

  /// No description provided for @floorCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get floorCountLabel;

  /// No description provided for @accessCodesLabel.
  ///
  /// In en, this message translates to:
  /// **'Access codes'**
  String get accessCodesLabel;

  /// No description provided for @accessCodesHelp.
  ///
  /// In en, this message translates to:
  /// **'Door or alarm codes. Only members of this account see them.'**
  String get accessCodesHelp;

  /// No description provided for @specialInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Special instructions'**
  String get specialInstructionsLabel;

  /// No description provided for @specialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Use the service entrance after 6 PM'**
  String get specialInstructionsHint;

  /// No description provided for @invalidSquareFootage.
  ///
  /// In en, this message translates to:
  /// **'Enter a number like 12000 or 850.5.'**
  String get invalidSquareFootage;

  /// No description provided for @invalidWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number.'**
  String get invalidWholeNumber;

  /// No description provided for @scopeOfWorkCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No scopes of work} =1{1 scope of work} other{{count} scopes of work}}'**
  String scopeOfWorkCount(int count);

  /// No description provided for @jobCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No jobs} =1{1 job} other{{count} jobs}}'**
  String jobCount(int count);

  /// No description provided for @locationInUse.
  ///
  /// In en, this message translates to:
  /// **'Scopes of work or jobs use this location, so it can\'t be deleted.'**
  String get locationInUse;

  /// No description provided for @locationsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This location no longer exists.'**
  String get locationsNotFound;

  /// No description provided for @streetAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get streetAddressLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
