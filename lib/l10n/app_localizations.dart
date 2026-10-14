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
  /// **'We sent a 6-digit code to {email}. It may take a minute to arrive and works for 10 minutes.'**
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
  /// **'This isn\'t available in the app yet.'**
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

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread notification} other{{count} unread notifications}}'**
  String unreadNotifications(int count);

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

  /// No description provided for @reorderModules.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderModules;

  /// No description provided for @reorderModulesHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the handles to set the order. It\'s the same in every account.'**
  String get reorderModulesHint;

  /// No description provided for @noJobsAhead.
  ///
  /// In en, this message translates to:
  /// **'No upcoming jobs'**
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

  /// No description provided for @assigneesNoAccess.
  ///
  /// In en, this message translates to:
  /// **'For reference only. To give someone access to this account, add them in Team.'**
  String get assigneesNoAccess;

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
  /// **'This can\'t be undone. If the account has history, you\'ll see everything that would go with it before anything is deleted.'**
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

  /// No description provided for @purgeAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get purgeAccountTitle;

  /// No description provided for @purgeAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This deletes {name} and everything in it: proposals, contracts, scopes of work, calendar, locations, jobs, complaints, tasks, invoices, payments, contacts and team. Its client logins are turned off. This can\'t be undone. To keep the history, set the account to Inactive instead.'**
  String purgeAccountWarning(String name);

  /// No description provided for @purgeAccountConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Type the legal name to confirm'**
  String get purgeAccountConfirmLabel;

  /// No description provided for @purgeAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account and history'**
  String get purgeAccountButton;

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

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingLabel;

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

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseFromLibrary;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @photoAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Space Clean can\'t use the camera or your photos. Allow access in Settings and try again.'**
  String get photoAccessDenied;

  /// No description provided for @photoPickFailed.
  ///
  /// In en, this message translates to:
  /// **'That photo couldn\'t be opened. Try another one.'**
  String get photoPickFailed;

  /// No description provided for @usersPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'No photo was received. Try again.'**
  String get usersPhotoRequired;

  /// No description provided for @usersPhotoInvalidType.
  ///
  /// In en, this message translates to:
  /// **'Use a JPEG, PNG or WebP photo.'**
  String get usersPhotoInvalidType;

  /// No description provided for @usersPhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That photo is over 5 MB. Choose a smaller one.'**
  String get usersPhotoTooLarge;

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

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit phone number.'**
  String get invalidPhone;

  /// No description provided for @moduleTeamHint.
  ///
  /// In en, this message translates to:
  /// **'Who works here and what they can do'**
  String get moduleTeamHint;

  /// No description provided for @moduleTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get moduleTimeline;

  /// No description provided for @noTeamYet.
  ///
  /// In en, this message translates to:
  /// **'No one on this team yet'**
  String get noTeamYet;

  /// No description provided for @noTeamYetHint.
  ///
  /// In en, this message translates to:
  /// **'Add people with +.'**
  String get noTeamYetHint;

  /// No description provided for @customAccessTag.
  ///
  /// In en, this message translates to:
  /// **'Custom access'**
  String get customAccessTag;

  /// No description provided for @memberTitle.
  ///
  /// In en, this message translates to:
  /// **'Team member'**
  String get memberTitle;

  /// No description provided for @sectionAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get sectionAccess;

  /// No description provided for @editAccess.
  ///
  /// In en, this message translates to:
  /// **'Edit access'**
  String get editAccess;

  /// No description provided for @addMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to team'**
  String get addMemberTitle;

  /// No description provided for @memberUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get memberUserLabel;

  /// No description provided for @baseRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role on this account'**
  String get baseRoleLabel;

  /// No description provided for @baseRoleChangeHelp.
  ///
  /// In en, this message translates to:
  /// **'Changing the role resets access to that role\'s defaults.'**
  String get baseRoleChangeHelp;

  /// No description provided for @accessHelp.
  ///
  /// In en, this message translates to:
  /// **'Turning off View turns off the rest of that area.'**
  String get accessHelp;

  /// No description provided for @resetAccess.
  ///
  /// In en, this message translates to:
  /// **'Reset to the role\'s defaults'**
  String get resetAccess;

  /// No description provided for @addMemberHelp.
  ///
  /// In en, this message translates to:
  /// **'Access starts at the role\'s defaults. You can adjust it after adding them.'**
  String get addMemberHelp;

  /// No description provided for @noOneToAdd.
  ///
  /// In en, this message translates to:
  /// **'Everyone active is already on this team.'**
  String get noOneToAdd;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from team'**
  String get removeMember;

  /// No description provided for @removeMemberConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeMemberConfirmTitle(String name);

  /// No description provided for @removeMemberConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'They\'ll lose access to this account. Their user and history stay.'**
  String get removeMemberConfirmBody;

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @teamReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Only owners can change the team.'**
  String get teamReadOnly;

  /// No description provided for @accessView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get accessView;

  /// No description provided for @accessEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get accessEdit;

  /// No description provided for @accessAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get accessAssign;

  /// No description provided for @accessDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get accessDownload;

  /// No description provided for @accessUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get accessUpload;

  /// No description provided for @accessManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get accessManage;

  /// No description provided for @membersNotFound.
  ///
  /// In en, this message translates to:
  /// **'This person is no longer on this team.'**
  String get membersNotFound;

  /// No description provided for @membersUserNotActive.
  ///
  /// In en, this message translates to:
  /// **'This user is deactivated. Reactivate them before adding them.'**
  String get membersUserNotActive;

  /// No description provided for @languageAndAppearance.
  ///
  /// In en, this message translates to:
  /// **'Language and appearance'**
  String get languageAndAppearance;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @themeSystemHint.
  ///
  /// In en, this message translates to:
  /// **'Matches your phone\'s light or dark mode'**
  String get themeSystemHint;

  /// No description provided for @themeSystemSummary.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get themeSystemSummary;

  /// No description provided for @themeLightSummary.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get themeLightSummary;

  /// No description provided for @themeDarkSummary.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDarkSummary;

  /// No description provided for @moduleProposalsHint.
  ///
  /// In en, this message translates to:
  /// **'Pipeline, pricing and versions'**
  String get moduleProposalsHint;

  /// No description provided for @proposalStageLead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get proposalStageLead;

  /// No description provided for @proposalStageWalkthrough.
  ///
  /// In en, this message translates to:
  /// **'Walkthrough'**
  String get proposalStageWalkthrough;

  /// No description provided for @proposalStagePricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get proposalStagePricing;

  /// No description provided for @proposalStageProposal.
  ///
  /// In en, this message translates to:
  /// **'Proposal'**
  String get proposalStageProposal;

  /// No description provided for @proposalStageNegotiation.
  ///
  /// In en, this message translates to:
  /// **'Negotiation'**
  String get proposalStageNegotiation;

  /// No description provided for @proposalStageApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get proposalStageApproved;

  /// No description provided for @proposalStageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other stage'**
  String get proposalStageUnknown;

  /// No description provided for @noProposalsYet.
  ///
  /// In en, this message translates to:
  /// **'No proposals yet'**
  String get noProposalsYet;

  /// No description provided for @noProposalsYetHint.
  ///
  /// In en, this message translates to:
  /// **'Start one with +.'**
  String get noProposalsYetHint;

  /// No description provided for @newProposalTitle.
  ///
  /// In en, this message translates to:
  /// **'New proposal'**
  String get newProposalTitle;

  /// No description provided for @proposalTitle.
  ///
  /// In en, this message translates to:
  /// **'Proposal'**
  String get proposalTitle;

  /// No description provided for @editProposal.
  ///
  /// In en, this message translates to:
  /// **'Edit proposal'**
  String get editProposal;

  /// No description provided for @deleteProposal.
  ///
  /// In en, this message translates to:
  /// **'Delete proposal'**
  String get deleteProposal;

  /// No description provided for @deleteProposalConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this proposal?'**
  String get deleteProposalConfirmTitle;

  /// No description provided for @deleteProposalConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Every version and its line items will be deleted. This can\'t be undone.'**
  String get deleteProposalConfirmBody;

  /// No description provided for @newVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'New version'**
  String get newVersionTitle;

  /// No description provided for @approveProposalTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve proposal'**
  String get approveProposalTitle;

  /// No description provided for @approveButton.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveButton;

  /// No description provided for @proposalVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {number}'**
  String proposalVersion(int number);

  /// No description provided for @proposalNoLineItems.
  ///
  /// In en, this message translates to:
  /// **'No line items yet'**
  String get proposalNoLineItems;

  /// No description provided for @proposalMoreItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{description} and 1 more} other{{description} and {count} more}}'**
  String proposalMoreItems(int count, String description);

  /// No description provided for @proposalPreparedBy.
  ///
  /// In en, this message translates to:
  /// **'Prepared by {name}'**
  String proposalPreparedBy(String name);

  /// No description provided for @proposalApprovedBy.
  ///
  /// In en, this message translates to:
  /// **'Approved by {name} on {date}'**
  String proposalApprovedBy(String name, String date);

  /// No description provided for @proposalApprovedOn.
  ///
  /// In en, this message translates to:
  /// **'Approved on {date}'**
  String proposalApprovedOn(String date);

  /// No description provided for @pipelineStageLabel.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get pipelineStageLabel;

  /// No description provided for @validUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get validUntilLabel;

  /// No description provided for @agreedPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Agreed price'**
  String get agreedPriceLabel;

  /// No description provided for @agreedPriceHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional until the proposal is approved.'**
  String get agreedPriceHelp;

  /// No description provided for @lineItemsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Line items total'**
  String get lineItemsTotalLabel;

  /// No description provided for @versionNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Version note'**
  String get versionNoteLabel;

  /// No description provided for @versionNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Annual contract discount'**
  String get versionNoteHint;

  /// No description provided for @sectionLineItems.
  ///
  /// In en, this message translates to:
  /// **'Line items'**
  String get sectionLineItems;

  /// No description provided for @lineItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String lineItemTitle(int number);

  /// No description provided for @addLineItem.
  ///
  /// In en, this message translates to:
  /// **'Add line item'**
  String get addLineItem;

  /// No description provided for @addLineItemShort.
  ///
  /// In en, this message translates to:
  /// **'Line item'**
  String get addLineItemShort;

  /// No description provided for @lineItemsEmpty.
  ///
  /// In en, this message translates to:
  /// **'None yet. Tap + below to add one.'**
  String get lineItemsEmpty;

  /// No description provided for @removeLineItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeLineItem;

  /// No description provided for @lineItemServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'From the catalog'**
  String get lineItemServiceLabel;

  /// No description provided for @lineItemDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get lineItemDescriptionLabel;

  /// No description provided for @lineItemQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get lineItemQuantityLabel;

  /// No description provided for @lineItemQuantityUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity ({unit})'**
  String lineItemQuantityUnitLabel(String unit);

  /// No description provided for @lineItemUnitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get lineItemUnitPriceLabel;

  /// No description provided for @lineItemTotal.
  ///
  /// In en, this message translates to:
  /// **'Line total: {amount}'**
  String lineItemTotal(String amount);

  /// No description provided for @invalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a number like 12000 or 2.5.'**
  String get invalidQuantity;

  /// No description provided for @serviceNotInCatalog.
  ///
  /// In en, this message translates to:
  /// **'No longer in the catalog'**
  String get serviceNotInCatalog;

  /// No description provided for @sectionVersions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get sectionVersions;

  /// No description provided for @currentVersionTag.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentVersionTag;

  /// No description provided for @olderVersionNotice.
  ///
  /// In en, this message translates to:
  /// **'This is an earlier version, kept as history. Only the current version can change.'**
  String get olderVersionNotice;

  /// No description provided for @approvedProposalNote.
  ///
  /// In en, this message translates to:
  /// **'An approved proposal can\'t change.'**
  String get approvedProposalNote;

  /// No description provided for @newVersionHelp.
  ///
  /// In en, this message translates to:
  /// **'The current version stays in the history as it is.'**
  String get newVersionHelp;

  /// No description provided for @approveHelp.
  ///
  /// In en, this message translates to:
  /// **'Approving locks this version at the agreed price.'**
  String get approveHelp;

  /// No description provided for @proposalsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This proposal no longer exists.'**
  String get proposalsNotFound;

  /// No description provided for @proposalsNotCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Only the current version can change. Add a new version instead.'**
  String get proposalsNotCurrentVersion;

  /// No description provided for @proposalsAlreadyApproved.
  ///
  /// In en, this message translates to:
  /// **'This proposal is approved and can\'t change.'**
  String get proposalsAlreadyApproved;

  /// No description provided for @proposalsHasRelatedRecords.
  ///
  /// In en, this message translates to:
  /// **'A contract uses this proposal, so it can\'t be deleted.'**
  String get proposalsHasRelatedRecords;

  /// No description provided for @proposalsAgreedPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the agreed price to approve it.'**
  String get proposalsAgreedPriceRequired;

  /// No description provided for @noPriceYet.
  ///
  /// In en, this message translates to:
  /// **'No price yet'**
  String get noPriceYet;

  /// No description provided for @editLineItem.
  ///
  /// In en, this message translates to:
  /// **'Edit line item'**
  String get editLineItem;

  /// No description provided for @lineItemError.
  ///
  /// In en, this message translates to:
  /// **'Item {number}: {message}'**
  String lineItemError(int number, String message);

  /// No description provided for @searchProposalsHint.
  ///
  /// In en, this message translates to:
  /// **'Search services, notes or stage'**
  String get searchProposalsHint;

  /// No description provided for @searchTeamHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, email or role'**
  String get searchTeamHint;

  /// No description provided for @searchContactsHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, title, email or phone'**
  String get searchContactsHint;

  /// No description provided for @searchTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, assignee or status'**
  String get searchTasksHint;

  /// No description provided for @searchComplaintsHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, location or assignee'**
  String get searchComplaintsHint;

  /// No description provided for @searchInvoicesHint.
  ///
  /// In en, this message translates to:
  /// **'Search number, status or line items'**
  String get searchInvoicesHint;

  /// No description provided for @searchContractsHint.
  ///
  /// In en, this message translates to:
  /// **'Search dates, status or terms'**
  String get searchContractsHint;

  /// No description provided for @proposalValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String proposalValidUntil(String date);

  /// No description provided for @proposalExpiredOn.
  ///
  /// In en, this message translates to:
  /// **'Expired {date}'**
  String proposalExpiredOn(String date);

  /// No description provided for @moduleContractsHint.
  ///
  /// In en, this message translates to:
  /// **'Terms, signatures and renewals'**
  String get moduleContractsHint;

  /// No description provided for @noContractsYet.
  ///
  /// In en, this message translates to:
  /// **'No contracts yet'**
  String get noContractsYet;

  /// No description provided for @noContractsYetHint.
  ///
  /// In en, this message translates to:
  /// **'Start one with +, or from an approved proposal.'**
  String get noContractsYetHint;

  /// No description provided for @contractsFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get contractsFilterLabel;

  /// No description provided for @contractsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get contractsFilterAll;

  /// No description provided for @contractsFilterExpiring.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Expiring soon} other{Expiring soon ({count})}}'**
  String contractsFilterExpiring(int count);

  /// No description provided for @noContractsExpiring.
  ///
  /// In en, this message translates to:
  /// **'Nothing expiring soon'**
  String get noContractsExpiring;

  /// No description provided for @noContractsExpiringHint.
  ///
  /// In en, this message translates to:
  /// **'No active contract ends in the next 30 days.'**
  String get noContractsExpiringHint;

  /// No description provided for @contractFromProposal.
  ///
  /// In en, this message translates to:
  /// **'From proposal version {number}'**
  String contractFromProposal(int number);

  /// No description provided for @contractFrom.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String contractFrom(String date);

  /// No description provided for @contractStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get contractStatusDraft;

  /// No description provided for @contractStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get contractStatusActive;

  /// No description provided for @contractStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get contractStatusExpired;

  /// No description provided for @contractStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get contractStatusCancelled;

  /// No description provided for @contractStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other status'**
  String get contractStatusUnknown;

  /// No description provided for @contractExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get contractExpiringSoon;

  /// No description provided for @contractTitle.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contractTitle;

  /// No description provided for @newContractTitle.
  ///
  /// In en, this message translates to:
  /// **'New contract'**
  String get newContractTitle;

  /// No description provided for @editContract.
  ///
  /// In en, this message translates to:
  /// **'Edit contract'**
  String get editContract;

  /// No description provided for @deleteContract.
  ///
  /// In en, this message translates to:
  /// **'Delete contract'**
  String get deleteContract;

  /// No description provided for @keepContract.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepContract;

  /// No description provided for @deleteContractConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft?'**
  String get deleteContractConfirmTitle;

  /// No description provided for @deleteContractConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The draft contract will be deleted. This can\'t be undone.'**
  String get deleteContractConfirmBody;

  /// No description provided for @cancelContract.
  ///
  /// In en, this message translates to:
  /// **'Cancel contract'**
  String get cancelContract;

  /// No description provided for @cancelContractConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this contract?'**
  String get cancelContractConfirmTitle;

  /// No description provided for @cancelContractConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It stays in the account\'s history, but it can\'t be edited or signed again.'**
  String get cancelContractConfirmBody;

  /// No description provided for @cancelledContractNotice.
  ///
  /// In en, this message translates to:
  /// **'This contract is cancelled. It\'s kept as history and can\'t change.'**
  String get cancelledContractNotice;

  /// No description provided for @contractTermLength.
  ///
  /// In en, this message translates to:
  /// **'Term: {length}'**
  String contractTermLength(String length);

  /// No description provided for @yearsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String yearsCount(int count);

  /// No description provided for @monthsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String monthsCount(int count);

  /// No description provided for @contractScheduleSection.
  ///
  /// In en, this message translates to:
  /// **'Contract schedule & terms'**
  String get contractScheduleSection;

  /// No description provided for @contractExecutionSection.
  ///
  /// In en, this message translates to:
  /// **'Execution & documents'**
  String get contractExecutionSection;

  /// No description provided for @contractSignedMark.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get contractSignedMark;

  /// No description provided for @contractValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Contract value'**
  String get contractValueLabel;

  /// No description provided for @contractValueFromProposalHelp.
  ///
  /// In en, this message translates to:
  /// **'Starts from the proposal\'s agreed price.'**
  String get contractValueFromProposalHelp;

  /// No description provided for @contractProposalLabel.
  ///
  /// In en, this message translates to:
  /// **'Proposal'**
  String get contractProposalLabel;

  /// No description provided for @contractStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get contractStartLabel;

  /// No description provided for @contractExpirationLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiration date'**
  String get contractExpirationLabel;

  /// No description provided for @expirationBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'Pick a day on or after the start date.'**
  String get expirationBeforeStart;

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// No description provided for @sectionTerm.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get sectionTerm;

  /// No description provided for @paymentTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment terms'**
  String get paymentTermsLabel;

  /// No description provided for @paymentTermsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Net 30'**
  String get paymentTermsHint;

  /// No description provided for @autoRenewLabel.
  ///
  /// In en, this message translates to:
  /// **'Renews automatically'**
  String get autoRenewLabel;

  /// No description provided for @autoRenewOn.
  ///
  /// In en, this message translates to:
  /// **'Renews automatically'**
  String get autoRenewOn;

  /// No description provided for @autoRenewOff.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t renew automatically'**
  String get autoRenewOff;

  /// No description provided for @cancellationNoticeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation notice'**
  String get cancellationNoticeLabel;

  /// No description provided for @cancellationNoticeHelp.
  ///
  /// In en, this message translates to:
  /// **'Days of notice needed to cancel.'**
  String get cancellationNoticeHelp;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @contractDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Expires today} =1{Expires tomorrow} other{Expires in {count} days}}'**
  String contractDaysLeft(int count);

  /// No description provided for @signatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signatureLabel;

  /// No description provided for @signedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Signed on'**
  String get signedOnLabel;

  /// No description provided for @contractSignedBy.
  ///
  /// In en, this message translates to:
  /// **'Signed by {name} on {date}'**
  String contractSignedBy(String name, String date);

  /// No description provided for @contractSignedOn.
  ///
  /// In en, this message translates to:
  /// **'Signed on {date}'**
  String contractSignedOn(String date);

  /// No description provided for @contractNotSigned.
  ///
  /// In en, this message translates to:
  /// **'Not signed yet'**
  String get contractNotSigned;

  /// No description provided for @signContract.
  ///
  /// In en, this message translates to:
  /// **'Sign contract'**
  String get signContract;

  /// No description provided for @signContractHelp.
  ///
  /// In en, this message translates to:
  /// **'Signing records you as the signer and makes the contract active.'**
  String get signContractHelp;

  /// No description provided for @createContract.
  ///
  /// In en, this message translates to:
  /// **'Create contract'**
  String get createContract;

  /// No description provided for @contractsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This contract no longer exists.'**
  String get contractsNotFound;

  /// No description provided for @contractsValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the contract value.'**
  String get contractsValueRequired;

  /// No description provided for @contractsProposalNotApproved.
  ///
  /// In en, this message translates to:
  /// **'A contract can only come from an approved proposal.'**
  String get contractsProposalNotApproved;

  /// No description provided for @contractsAlreadySigned.
  ///
  /// In en, this message translates to:
  /// **'This contract is already signed.'**
  String get contractsAlreadySigned;

  /// No description provided for @contractsCancelled.
  ///
  /// In en, this message translates to:
  /// **'This contract is cancelled and can\'t change.'**
  String get contractsCancelled;

  /// No description provided for @contractsOnlyDraftsDeletable.
  ///
  /// In en, this message translates to:
  /// **'Only a draft contract can be deleted. Cancel it instead.'**
  String get contractsOnlyDraftsDeletable;

  /// No description provided for @contractsHasRelatedRecords.
  ///
  /// In en, this message translates to:
  /// **'Scopes of work or invoices use this contract, so it can\'t be deleted.'**
  String get contractsHasRelatedRecords;

  /// No description provided for @markExpired.
  ///
  /// In en, this message translates to:
  /// **'Mark expired'**
  String get markExpired;

  /// No description provided for @markExpiredConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark this contract expired?'**
  String get markExpiredConfirmTitle;

  /// No description provided for @markExpiredConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It stays in the account\'s history and can still be edited.'**
  String get markExpiredConfirmBody;

  /// No description provided for @contractEndedOn.
  ///
  /// In en, this message translates to:
  /// **'Ended {date}'**
  String contractEndedOn(String date);

  /// No description provided for @moduleScopeHint.
  ///
  /// In en, this message translates to:
  /// **'Areas, frequency and time windows'**
  String get moduleScopeHint;

  /// No description provided for @scopesOfOneContract.
  ///
  /// In en, this message translates to:
  /// **'Showing one contract\'s scopes.'**
  String get scopesOfOneContract;

  /// No description provided for @noScopesYet.
  ///
  /// In en, this message translates to:
  /// **'No scopes of work yet'**
  String get noScopesYet;

  /// No description provided for @noScopesYetHint.
  ///
  /// In en, this message translates to:
  /// **'Add one with + for each area of a location.'**
  String get noScopesYetHint;

  /// No description provided for @noTimeWindows.
  ///
  /// In en, this message translates to:
  /// **'No time windows'**
  String get noTimeWindows;

  /// No description provided for @scheduleAndMore.
  ///
  /// In en, this message translates to:
  /// **'{schedule} and {count} more'**
  String scheduleAndMore(String schedule, int count);

  /// No description provided for @scopeWholeSite.
  ///
  /// In en, this message translates to:
  /// **'Whole site'**
  String get scopeWholeSite;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @frequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get frequencyDaily;

  /// No description provided for @frequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frequencyWeekly;

  /// No description provided for @frequencyBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get frequencyBiweekly;

  /// No description provided for @frequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// No description provided for @frequencyQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get frequencyQuarterly;

  /// No description provided for @frequencyAnnual.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get frequencyAnnual;

  /// No description provided for @frequencyOneTime.
  ///
  /// In en, this message translates to:
  /// **'One time'**
  String get frequencyOneTime;

  /// No description provided for @frequencyUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other frequency'**
  String get frequencyUnknown;

  /// No description provided for @scopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scope of work'**
  String get scopeTitle;

  /// No description provided for @newScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'New scope of work'**
  String get newScopeTitle;

  /// No description provided for @editScope.
  ///
  /// In en, this message translates to:
  /// **'Edit scope'**
  String get editScope;

  /// No description provided for @deleteScope.
  ///
  /// In en, this message translates to:
  /// **'Delete scope'**
  String get deleteScope;

  /// No description provided for @deleteScopeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this scope?'**
  String get deleteScopeConfirmTitle;

  /// No description provided for @deleteScopeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The scope and its time windows will be deleted. This can\'t be undone.'**
  String get deleteScopeConfirmBody;

  /// No description provided for @scopeHasJobsNote.
  ///
  /// In en, this message translates to:
  /// **'This scope already produced jobs, so it can\'t be deleted. Pause its time windows instead.'**
  String get scopeHasJobsNote;

  /// No description provided for @scopeWorkSection.
  ///
  /// In en, this message translates to:
  /// **'Work details'**
  String get scopeWorkSection;

  /// No description provided for @contractTermLabel.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get contractTermLabel;

  /// No description provided for @sectionTimeWindows.
  ///
  /// In en, this message translates to:
  /// **'Time windows'**
  String get sectionTimeWindows;

  /// No description provided for @sectionSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get sectionSchedule;

  /// No description provided for @sectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get sectionDetails;

  /// No description provided for @sectionHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get sectionHours;

  /// No description provided for @timeWindowPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get timeWindowPaused;

  /// No description provided for @timeWindowsEmpty.
  ///
  /// In en, this message translates to:
  /// **'None yet. Tap + below to add one.'**
  String get timeWindowsEmpty;

  /// No description provided for @windowsNeedWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Pick the weekdays of each time window.'**
  String get windowsNeedWeekdays;

  /// No description provided for @addTimeWindow.
  ///
  /// In en, this message translates to:
  /// **'Add time window'**
  String get addTimeWindow;

  /// No description provided for @addTimeWindowShort.
  ///
  /// In en, this message translates to:
  /// **'Time window'**
  String get addTimeWindowShort;

  /// No description provided for @editTimeWindow.
  ///
  /// In en, this message translates to:
  /// **'Edit time window'**
  String get editTimeWindow;

  /// No description provided for @removeTimeWindow.
  ///
  /// In en, this message translates to:
  /// **'Remove time window'**
  String get removeTimeWindow;

  /// No description provided for @weekdaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get weekdaysLabel;

  /// No description provided for @pickWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day.'**
  String get pickWeekdays;

  /// No description provided for @startTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endTimeLabel;

  /// No description provided for @noEndTime.
  ///
  /// In en, this message translates to:
  /// **'No end time'**
  String get noEndTime;

  /// No description provided for @endBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'Pick a time after the start.'**
  String get endBeforeStart;

  /// No description provided for @timeWindowActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get timeWindowActiveLabel;

  /// No description provided for @timeWindowActiveHelp.
  ///
  /// In en, this message translates to:
  /// **'A paused window stays on the scope but makes no new work.'**
  String get timeWindowActiveHelp;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @areaNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get areaNameLabel;

  /// No description provided for @areaNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lobby'**
  String get areaNameHint;

  /// No description provided for @areaNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if it covers the whole site.'**
  String get areaNameHelp;

  /// No description provided for @scopeServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get scopeServiceLabel;

  /// No description provided for @frequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequencyLabel;

  /// No description provided for @estimatedDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated duration'**
  String get estimatedDurationLabel;

  /// No description provided for @estimatedDurationHelp.
  ///
  /// In en, this message translates to:
  /// **'In minutes.'**
  String get estimatedDurationHelp;

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min} other{{count} min}}'**
  String minutesCount(int count);

  /// No description provided for @instructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsLabel;

  /// No description provided for @instructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mop with neutral cleaner'**
  String get instructionsHint;

  /// No description provided for @exclusionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Not included'**
  String get exclusionsLabel;

  /// No description provided for @exclusionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Server room (4th floor)'**
  String get exclusionsHint;

  /// No description provided for @requiredSuppliesLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplies'**
  String get requiredSuppliesLabel;

  /// No description provided for @requiredSuppliesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Microfiber cloths'**
  String get requiredSuppliesHint;

  /// No description provided for @scopesNotFound.
  ///
  /// In en, this message translates to:
  /// **'This scope of work no longer exists.'**
  String get scopesNotFound;

  /// No description provided for @scopesDaysOfWeekRequired.
  ///
  /// In en, this message translates to:
  /// **'Weekly work needs the days of each time window.'**
  String get scopesDaysOfWeekRequired;

  /// No description provided for @scopesHasJobs.
  ///
  /// In en, this message translates to:
  /// **'This scope already produced jobs, so it can\'t be deleted. Pause its time windows instead.'**
  String get scopesHasJobs;

  /// No description provided for @scopeNeedsContract.
  ///
  /// In en, this message translates to:
  /// **'This account has no active or draft contract yet. Add one under Contracts first.'**
  String get scopeNeedsContract;

  /// No description provided for @scopeNeedsLocation.
  ///
  /// In en, this message translates to:
  /// **'This account has no locations yet. Add one under Locations first.'**
  String get scopeNeedsLocation;

  /// No description provided for @scopeNoServices.
  ///
  /// In en, this message translates to:
  /// **'The service catalog has no active services.'**
  String get scopeNoServices;

  /// No description provided for @moduleCalendarHint.
  ///
  /// In en, this message translates to:
  /// **'Visits by day, moves and one-offs'**
  String get moduleCalendarHint;

  /// No description provided for @eventStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get eventStatusScheduled;

  /// No description provided for @eventStatusRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get eventStatusRescheduled;

  /// No description provided for @eventStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get eventStatusCancelled;

  /// No description provided for @eventStatusConverted.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get eventStatusConverted;

  /// No description provided for @eventStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other status'**
  String get eventStatusUnknown;

  /// No description provided for @eventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no events} =1{1 event} other{{count} events}}'**
  String eventsCount(int count);

  /// No description provided for @goToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get goToToday;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @nothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get nothingScheduled;

  /// No description provided for @nothingScheduledHint.
  ///
  /// In en, this message translates to:
  /// **'Add a one-off visit with +. Visits from scopes of work appear on their own.'**
  String get nothingScheduledHint;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventTitle;

  /// No description provided for @newEventTitle.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get newEventTitle;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete event'**
  String get deleteEvent;

  /// No description provided for @keepEvent.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepEvent;

  /// No description provided for @deleteEventConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this event?'**
  String get deleteEventConfirmTitle;

  /// No description provided for @deleteEventConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from the calendar. This can\'t be undone.'**
  String get deleteEventConfirmBody;

  /// No description provided for @cancelEvent.
  ///
  /// In en, this message translates to:
  /// **'Cancel event'**
  String get cancelEvent;

  /// No description provided for @cancelEventConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this event?'**
  String get cancelEventConfirmTitle;

  /// No description provided for @cancelEventConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It stays on the calendar as cancelled and can\'t be changed again.'**
  String get cancelEventConfirmBody;

  /// No description provided for @eventCancelledNotice.
  ///
  /// In en, this message translates to:
  /// **'This event is cancelled and can\'t change.'**
  String get eventCancelledNotice;

  /// No description provided for @eventConvertedNotice.
  ///
  /// In en, this message translates to:
  /// **'This event became a job, so it\'s changed from the job now.'**
  String get eventConvertedNotice;

  /// No description provided for @eventFromScope.
  ///
  /// In en, this message translates to:
  /// **'From a scope of work'**
  String get eventFromScope;

  /// No description provided for @eventOneOff.
  ///
  /// In en, this message translates to:
  /// **'One-off'**
  String get eventOneOff;

  /// No description provided for @assignedToLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedToLabel;

  /// No description provided for @rescheduleEvent.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get rescheduleEvent;

  /// No description provided for @sectionMoves.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get sectionMoves;

  /// No description provided for @movedFrom.
  ///
  /// In en, this message translates to:
  /// **'From {when}'**
  String movedFrom(String when);

  /// No description provided for @movedTo.
  ///
  /// In en, this message translates to:
  /// **'to {when}'**
  String movedTo(String when);

  /// No description provided for @movedBy.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String movedBy(String name);

  /// No description provided for @eventTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitleLabel;

  /// No description provided for @eventTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Deep clean'**
  String get eventTitleHint;

  /// No description provided for @sectionWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get sectionWhen;

  /// No description provided for @eventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get eventDateLabel;

  /// No description provided for @eventMoveHelp.
  ///
  /// In en, this message translates to:
  /// **'{day} at {time}. To change the day or start, use Reschedule.'**
  String eventMoveHelp(String day, String time);

  /// No description provided for @eventNoScopes.
  ///
  /// In en, this message translates to:
  /// **'This account has no scopes of work yet.'**
  String get eventNoScopes;

  /// No description provided for @eventNoLocations.
  ///
  /// In en, this message translates to:
  /// **'This account has no locations yet. Add one under Locations first.'**
  String get eventNoLocations;

  /// No description provided for @eventNoMembers.
  ///
  /// In en, this message translates to:
  /// **'This account has no active team members yet.'**
  String get eventNoMembers;

  /// No description provided for @sectionNewTime.
  ///
  /// In en, this message translates to:
  /// **'New day and time'**
  String get sectionNewTime;

  /// No description provided for @rescheduleReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get rescheduleReasonLabel;

  /// No description provided for @rescheduleReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Client asked for Thursday'**
  String get rescheduleReasonHint;

  /// No description provided for @rescheduleHelp.
  ///
  /// In en, this message translates to:
  /// **'The current day and time stay in its history.'**
  String get rescheduleHelp;

  /// No description provided for @calendarNotFound.
  ///
  /// In en, this message translates to:
  /// **'This event no longer exists.'**
  String get calendarNotFound;

  /// No description provided for @calendarBadRange.
  ///
  /// In en, this message translates to:
  /// **'That range of days is too wide.'**
  String get calendarBadRange;

  /// No description provided for @calendarCancelled.
  ///
  /// In en, this message translates to:
  /// **'This event is cancelled and can\'t change.'**
  String get calendarCancelled;

  /// No description provided for @calendarAlreadyConverted.
  ///
  /// In en, this message translates to:
  /// **'This event already became a job.'**
  String get calendarAlreadyConverted;

  /// No description provided for @deleteGeneratedEventConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from the calendar and won\'t come back when the month is filled from its scope again. This can\'t be undone.'**
  String get deleteGeneratedEventConfirmBody;

  /// No description provided for @jobsPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Which jobs'**
  String get jobsPeriodLabel;

  /// No description provided for @jobsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get jobsUpcoming;

  /// No description provided for @jobsPast.
  ///
  /// In en, this message translates to:
  /// **'Past 30 days'**
  String get jobsPast;

  /// No description provided for @noJobsAheadHint.
  ///
  /// In en, this message translates to:
  /// **'Add one with +, or create one from a calendar event.'**
  String get noJobsAheadHint;

  /// No description provided for @noPastJobs.
  ///
  /// In en, this message translates to:
  /// **'No jobs in the past 30 days'**
  String get noPastJobs;

  /// No description provided for @newJobTitle.
  ///
  /// In en, this message translates to:
  /// **'New job'**
  String get newJobTitle;

  /// No description provided for @editJob.
  ///
  /// In en, this message translates to:
  /// **'Edit job'**
  String get editJob;

  /// No description provided for @deleteJob.
  ///
  /// In en, this message translates to:
  /// **'Delete job'**
  String get deleteJob;

  /// No description provided for @keepJob.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepJob;

  /// No description provided for @deleteJobConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this job?'**
  String get deleteJobConfirmTitle;

  /// No description provided for @deleteJobConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed with its crew and checklist. This can\'t be undone.'**
  String get deleteJobConfirmBody;

  /// No description provided for @cancelJob.
  ///
  /// In en, this message translates to:
  /// **'Cancel job'**
  String get cancelJob;

  /// No description provided for @cancelJobConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this job?'**
  String get cancelJobConfirmTitle;

  /// No description provided for @cancelJobConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It stays in the list as cancelled and can\'t be changed again.'**
  String get cancelJobConfirmBody;

  /// No description provided for @jobCancelledNotice.
  ///
  /// In en, this message translates to:
  /// **'This job was cancelled, so it can\'t change.'**
  String get jobCancelledNotice;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @noChecklistItems.
  ///
  /// In en, this message translates to:
  /// **'No checklist yet'**
  String get noChecklistItems;

  /// No description provided for @checkedInAt.
  ///
  /// In en, this message translates to:
  /// **'In {time}'**
  String checkedInAt(String time);

  /// No description provided for @checkedOutAt.
  ///
  /// In en, this message translates to:
  /// **'Out {time}'**
  String checkedOutAt(String time);

  /// No description provided for @jobTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get jobTypeLabel;

  /// No description provided for @jobTypeRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get jobTypeRecurring;

  /// No description provided for @jobTypeSpecial.
  ///
  /// In en, this message translates to:
  /// **'One-off'**
  String get jobTypeSpecial;

  /// No description provided for @doneAtBy.
  ///
  /// In en, this message translates to:
  /// **'{time} by {name}'**
  String doneAtBy(String time, String name);

  /// No description provided for @jobStartedLabel.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get jobStartedLabel;

  /// No description provided for @jobCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get jobCompletedLabel;

  /// No description provided for @qualityScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality score'**
  String get qualityScoreLabel;

  /// No description provided for @qualityScoreValue.
  ///
  /// In en, this message translates to:
  /// **'{score} of 5'**
  String qualityScoreValue(String score);

  /// No description provided for @clientSignoffLabel.
  ///
  /// In en, this message translates to:
  /// **'Client sign-off'**
  String get clientSignoffLabel;

  /// No description provided for @cleanerNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Crew notes'**
  String get cleanerNotesLabel;

  /// No description provided for @checklistItemDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get checklistItemDone;

  /// No description provided for @checklistItemOpen.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get checklistItemOpen;

  /// No description provided for @editCrewTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit crew'**
  String get editCrewTitle;

  /// No description provided for @editCrewHelp.
  ///
  /// In en, this message translates to:
  /// **'Active team members of this account. People who stay keep their check-in times.'**
  String get editCrewHelp;

  /// No description provided for @editChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit checklist'**
  String get editChecklistTitle;

  /// No description provided for @addChecklistItem.
  ///
  /// In en, this message translates to:
  /// **'Add checklist item'**
  String get addChecklistItem;

  /// No description provided for @addChecklistItemShort.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get addChecklistItemShort;

  /// No description provided for @checklistResetWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item is ticked. Saving a change clears the tick.} other{{count} items are ticked. Saving a change clears the ticks.}}'**
  String checklistResetWarning(int count);

  /// No description provided for @checklistFull.
  ///
  /// In en, this message translates to:
  /// **'A checklist holds up to {max} items.'**
  String checklistFull(int max);

  /// No description provided for @checklistEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No items yet. Add them with +.'**
  String get checklistEmptyHint;

  /// No description provided for @checklistItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String checklistItemLabel(int number);

  /// No description provided for @checklistEditHelp.
  ///
  /// In en, this message translates to:
  /// **'The crew ticks these off on site, in this order. Blank items are left out.'**
  String get checklistEditHelp;

  /// No description provided for @jobNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get jobNameLabel;

  /// No description provided for @jobNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Nightly clean'**
  String get jobNameHint;

  /// No description provided for @endsNextDay.
  ///
  /// In en, this message translates to:
  /// **'{time} (next day)'**
  String endsNextDay(String time);

  /// No description provided for @jobEndHelp.
  ///
  /// In en, this message translates to:
  /// **'An end before the start is on the next day.'**
  String get jobEndHelp;

  /// No description provided for @jobInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alarm code is at the front desk'**
  String get jobInstructionsHint;

  /// No description provided for @openJob.
  ///
  /// In en, this message translates to:
  /// **'Open job'**
  String get openJob;

  /// No description provided for @createJobFromEvent.
  ///
  /// In en, this message translates to:
  /// **'Create job'**
  String get createJobFromEvent;

  /// No description provided for @jobsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This job no longer exists.'**
  String get jobsNotFound;

  /// No description provided for @jobsNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'You\'re not on this job\'s crew.'**
  String get jobsNotAssigned;

  /// No description provided for @jobsAssigneeNotActive.
  ///
  /// In en, this message translates to:
  /// **'Someone picked for the crew is no longer active.'**
  String get jobsAssigneeNotActive;

  /// No description provided for @jobsLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'This event has no location. Add one before creating a job.'**
  String get jobsLocationRequired;

  /// No description provided for @jobsClosed.
  ///
  /// In en, this message translates to:
  /// **'This job is completed or cancelled, so it can\'t change.'**
  String get jobsClosed;

  /// No description provided for @jobsAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'This job is already completed.'**
  String get jobsAlreadyCompleted;

  /// No description provided for @jobsOnlyScheduledDeletable.
  ///
  /// In en, this message translates to:
  /// **'Only a job that hasn\'t started can be deleted.'**
  String get jobsOnlyScheduledDeletable;

  /// No description provided for @tickChecklistItem.
  ///
  /// In en, this message translates to:
  /// **'Tick off'**
  String get tickChecklistItem;

  /// No description provided for @reopenChecklistItem.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopenChecklistItem;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get checkOut;

  /// No description provided for @startJob.
  ///
  /// In en, this message translates to:
  /// **'Start job'**
  String get startJob;

  /// No description provided for @completeJob.
  ///
  /// In en, this message translates to:
  /// **'Complete job'**
  String get completeJob;

  /// No description provided for @completeJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete job'**
  String get completeJobTitle;

  /// No description provided for @youCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'You checked in at {time}.'**
  String youCheckedIn(String time);

  /// No description provided for @youCheckedInOut.
  ///
  /// In en, this message translates to:
  /// **'You checked in at {inTime} and out at {outTime}.'**
  String youCheckedInOut(String inTime, String outTime);

  /// No description provided for @checklistStillOpen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 checklist item isn\'t ticked yet.} other{{count} checklist items aren\'t ticked yet.}}'**
  String checklistStillOpen(int count);

  /// No description provided for @qualityScoreHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. 5 is the best. Tap the score again to clear it.'**
  String get qualityScoreHelp;

  /// No description provided for @cleanerNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Restroom faucet is leaking'**
  String get cleanerNotesHint;

  /// No description provided for @clientSignoffHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. María López'**
  String get clientSignoffHint;

  /// No description provided for @clientSignoffHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. The client\'s name, if they checked the work on site.'**
  String get clientSignoffHelp;

  /// No description provided for @jobsNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'Only a scheduled job can be started. It may have started already.'**
  String get jobsNotScheduled;

  /// No description provided for @jobsNotInProgress.
  ///
  /// In en, this message translates to:
  /// **'Only a job in progress can be completed. Start it first.'**
  String get jobsNotInProgress;

  /// No description provided for @jobsAlreadyCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'You already checked in to this job.'**
  String get jobsAlreadyCheckedIn;

  /// No description provided for @jobsNotCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Check in before checking out.'**
  String get jobsNotCheckedIn;

  /// No description provided for @jobsChecklistItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'That checklist item no longer exists.'**
  String get jobsChecklistItemNotFound;

  /// No description provided for @jobProgressCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completion'**
  String get jobProgressCompleted;

  /// No description provided for @jobProgressActive.
  ///
  /// In en, this message translates to:
  /// **'Active progress'**
  String get jobProgressActive;

  /// No description provided for @checklistProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done ({percent}%)'**
  String checklistProgressPercent(int done, int total, int percent);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, String minutes);

  /// No description provided for @jobsOnDay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing scheduled} =1{1 job scheduled} other{{count} jobs scheduled}}'**
  String jobsOnDay(int count);

  /// No description provided for @jobsFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter by status'**
  String get jobsFilter;

  /// No description provided for @jobsFilterOn.
  ///
  /// In en, this message translates to:
  /// **'Filtered: {status}'**
  String jobsFilterOn(String status);

  /// No description provided for @noJobsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No jobs this day'**
  String get noJobsOnDay;

  /// No description provided for @noJobsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No jobs with this status this day'**
  String get noJobsMatchFilter;

  /// No description provided for @dayHasJobs.
  ///
  /// In en, this message translates to:
  /// **'has jobs'**
  String get dayHasJobs;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @checklistCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} completed'**
  String checklistCompletedCount(int done, int total);

  /// No description provided for @percentDone.
  ///
  /// In en, this message translates to:
  /// **'{percent}% done'**
  String percentDone(int percent);

  /// No description provided for @reviewTasks.
  ///
  /// In en, this message translates to:
  /// **'Review tasks'**
  String get reviewTasks;

  /// No description provided for @copyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButton;

  /// No description provided for @copiedButton.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedButton;

  /// No description provided for @eventCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get eventCheckedIn;

  /// No description provided for @eventCheckedOut.
  ///
  /// In en, this message translates to:
  /// **'Checked out'**
  String get eventCheckedOut;

  /// No description provided for @eventWorkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Work completed'**
  String get eventWorkCompleted;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activityCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String activityCount(int count);

  /// No description provided for @moduleComplaintsHint.
  ///
  /// In en, this message translates to:
  /// **'Issues reported and how they were solved'**
  String get moduleComplaintsHint;

  /// No description provided for @complaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaintTitle;

  /// No description provided for @newComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'New complaint'**
  String get newComplaintTitle;

  /// No description provided for @editComplaint.
  ///
  /// In en, this message translates to:
  /// **'Edit complaint'**
  String get editComplaint;

  /// No description provided for @complaintStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get complaintStatusOpen;

  /// No description provided for @complaintStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get complaintStatusInProgress;

  /// No description provided for @complaintStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get complaintStatusResolved;

  /// No description provided for @complaintStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other status'**
  String get complaintStatusUnknown;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get priorityUnknown;

  /// No description provided for @complaintsFilterOpen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Open} other{Open ({count})}}'**
  String complaintsFilterOpen(int count);

  /// No description provided for @complaintsFilterResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get complaintsFilterResolved;

  /// No description provided for @noComplaintsYet.
  ///
  /// In en, this message translates to:
  /// **'No complaints'**
  String get noComplaintsYet;

  /// No description provided for @noComplaintsYetHint.
  ///
  /// In en, this message translates to:
  /// **'Complaints reported for this account show up here.'**
  String get noComplaintsYetHint;

  /// No description provided for @noOpenComplaints.
  ///
  /// In en, this message translates to:
  /// **'Nothing open'**
  String get noOpenComplaints;

  /// No description provided for @noOpenComplaintsHint.
  ///
  /// In en, this message translates to:
  /// **'Every complaint is resolved.'**
  String get noOpenComplaintsHint;

  /// No description provided for @noResolvedComplaints.
  ///
  /// In en, this message translates to:
  /// **'Nothing resolved yet'**
  String get noResolvedComplaints;

  /// No description provided for @complaintTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get complaintTitleLabel;

  /// No description provided for @complaintTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Restrooms out of paper'**
  String get complaintTitleHint;

  /// No description provided for @complaintDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get complaintDescriptionLabel;

  /// No description provided for @complaintDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What the client said, in detail'**
  String get complaintDescriptionHint;

  /// No description provided for @complaintAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Restrooms, floor 3'**
  String get complaintAreaHint;

  /// No description provided for @complaintJobLabel.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get complaintJobLabel;

  /// No description provided for @complaintNoJobs.
  ///
  /// In en, this message translates to:
  /// **'This account had no jobs in the last 30 days.'**
  String get complaintNoJobs;

  /// No description provided for @sectionWhere.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get sectionWhere;

  /// No description provided for @complaintReported.
  ///
  /// In en, this message translates to:
  /// **'Reported {date}'**
  String complaintReported(String date);

  /// No description provided for @complaintReportedBy.
  ///
  /// In en, this message translates to:
  /// **'Reported {date} by {name}'**
  String complaintReportedBy(String date, String name);

  /// No description provided for @complaintResolutionSection.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get complaintResolutionSection;

  /// No description provided for @resolvedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Resolved by'**
  String get resolvedByLabel;

  /// No description provided for @resolutionTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time to resolve'**
  String get resolutionTimeLabel;

  /// No description provided for @resolutionHoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String resolutionHoursValue(String hours);

  /// No description provided for @resolutionNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'What was done'**
  String get resolutionNotesLabel;

  /// No description provided for @resolveComplaint.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolveComplaint;

  /// No description provided for @resolveComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Resolve complaint'**
  String get resolveComplaintTitle;

  /// No description provided for @resolveComplaintHelp.
  ///
  /// In en, this message translates to:
  /// **'Say what was done, so the account\'s history shows how it was solved.'**
  String get resolveComplaintHelp;

  /// No description provided for @reopenComplaint.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopenComplaint;

  /// No description provided for @reopenComplaintConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reopen this complaint?'**
  String get reopenComplaintConfirmTitle;

  /// No description provided for @reopenComplaintConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It goes back to being worked on, so it can be edited and assigned again. The notes on what was done are kept.'**
  String get reopenComplaintConfirmBody;

  /// No description provided for @keepResolved.
  ///
  /// In en, this message translates to:
  /// **'Keep it resolved'**
  String get keepResolved;

  /// No description provided for @resolvedComplaintNotice.
  ///
  /// In en, this message translates to:
  /// **'Resolved complaints can\'t change. Reopen it to edit or reassign it.'**
  String get resolvedComplaintNotice;

  /// No description provided for @complaintsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This complaint no longer exists.'**
  String get complaintsNotFound;

  /// No description provided for @complaintsAlreadyResolved.
  ///
  /// In en, this message translates to:
  /// **'This complaint is resolved. Reopen it first to change it.'**
  String get complaintsAlreadyResolved;

  /// No description provided for @complaintsNotResolved.
  ///
  /// In en, this message translates to:
  /// **'Only a resolved complaint can be reopened.'**
  String get complaintsNotResolved;

  /// No description provided for @complaintsAssigneeNotActive.
  ///
  /// In en, this message translates to:
  /// **'The person assigned must be an active user.'**
  String get complaintsAssigneeNotActive;

  /// No description provided for @noJobComplaints.
  ///
  /// In en, this message translates to:
  /// **'No complaints about this job'**
  String get noJobComplaints;

  /// No description provided for @reportComplaint.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportComplaint;

  /// No description provided for @moduleTasksHint.
  ///
  /// In en, this message translates to:
  /// **'To-dos with a due date and an owner'**
  String get moduleTasksHint;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskTitle;

  /// No description provided for @newTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTaskTitle;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @taskStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskStatusPending;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get taskStatusInProgress;

  /// No description provided for @taskStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskStatusCompleted;

  /// No description provided for @taskStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get taskStatusCancelled;

  /// No description provided for @taskStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other status'**
  String get taskStatusUnknown;

  /// No description provided for @tasksFilterOpen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Open} other{Open ({count})}}'**
  String tasksFilterOpen(int count);

  /// No description provided for @tasksFilterDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tasksFilterDone;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasksYet;

  /// No description provided for @noTasksYetHint.
  ///
  /// In en, this message translates to:
  /// **'Add to-dos for this account with the \"+\".'**
  String get noTasksYetHint;

  /// No description provided for @noOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do'**
  String get noOpenTasks;

  /// No description provided for @noOpenTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Every task is done.'**
  String get noOpenTasksHint;

  /// No description provided for @noDoneTasks.
  ///
  /// In en, this message translates to:
  /// **'Nothing done yet'**
  String get noDoneTasks;

  /// No description provided for @taskDueIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Due today} =1{Due tomorrow} other{Due in {count} days}}'**
  String taskDueIn(int count);

  /// No description provided for @taskOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day overdue} other{{count} days overdue}}'**
  String taskOverdue(int count);

  /// No description provided for @taskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitleLabel;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Send the floor 3 quote'**
  String get taskTitleHint;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescriptionLabel;

  /// No description provided for @taskDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get taskDueDateLabel;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @startTask.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTask;

  /// No description provided for @completeTask.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeTask;

  /// No description provided for @cancelTask.
  ///
  /// In en, this message translates to:
  /// **'Cancel task'**
  String get cancelTask;

  /// No description provided for @cancelTaskConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this task?'**
  String get cancelTaskConfirmTitle;

  /// No description provided for @cancelTaskConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It stays in the list as cancelled, and can be reopened later.'**
  String get cancelTaskConfirmBody;

  /// No description provided for @keepTask.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepTask;

  /// No description provided for @reopenTask.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopenTask;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get deleteTaskConfirmTitle;

  /// No description provided for @deleteTaskConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s removed for good. To keep a record, cancel it instead.'**
  String get deleteTaskConfirmBody;

  /// No description provided for @closedTaskNotice.
  ///
  /// In en, this message translates to:
  /// **'This task is done with. Reopen it to change it.'**
  String get closedTaskNotice;

  /// No description provided for @tasksNotFound.
  ///
  /// In en, this message translates to:
  /// **'This task no longer exists.'**
  String get tasksNotFound;

  /// No description provided for @tasksAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'This task is completed. Reopen it first to change it.'**
  String get tasksAlreadyCompleted;

  /// No description provided for @tasksAlreadyOpen.
  ///
  /// In en, this message translates to:
  /// **'Only a completed or cancelled task can be reopened.'**
  String get tasksAlreadyOpen;

  /// No description provided for @tasksAssigneeNotActive.
  ///
  /// In en, this message translates to:
  /// **'The person assigned must be an active user.'**
  String get tasksAssigneeNotActive;

  /// No description provided for @otherJobsToday.
  ///
  /// In en, this message translates to:
  /// **'Other jobs today'**
  String get otherJobsToday;

  /// No description provided for @overdueTasks.
  ///
  /// In en, this message translates to:
  /// **'Overdue tasks'**
  String get overdueTasks;

  /// No description provided for @noJobsForYouToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing assigned to you today'**
  String get noJobsForYouToday;

  /// No description provided for @moduleInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get moduleInvoices;

  /// No description provided for @moduleInvoicesHint.
  ///
  /// In en, this message translates to:
  /// **'Billing, payments and what\'s overdue'**
  String get moduleInvoicesHint;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceTitle;

  /// No description provided for @newInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get newInvoiceTitle;

  /// No description provided for @editInvoice.
  ///
  /// In en, this message translates to:
  /// **'Edit invoice'**
  String get editInvoice;

  /// No description provided for @invoiceStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get invoiceStatusDraft;

  /// No description provided for @invoiceStatusIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get invoiceStatusIssued;

  /// No description provided for @invoiceStatusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partly paid'**
  String get invoiceStatusPartiallyPaid;

  /// No description provided for @invoiceStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoiceStatusPaid;

  /// No description provided for @invoiceStatusVoid.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get invoiceStatusVoid;

  /// No description provided for @invoiceStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other status'**
  String get invoiceStatusUnknown;

  /// No description provided for @invoiceStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get invoiceStatusOverdue;

  /// No description provided for @invoiceDaysOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day overdue} other{{count} days overdue}}'**
  String invoiceDaysOverdue(int count);

  /// No description provided for @invoicesFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Which invoices'**
  String get invoicesFilterLabel;

  /// No description provided for @invoicesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get invoicesFilterAll;

  /// No description provided for @invoicesFilterOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Overdue} other{Overdue ({count})}}'**
  String invoicesFilterOverdue(int count);

  /// No description provided for @noInvoicesYet.
  ///
  /// In en, this message translates to:
  /// **'No invoices'**
  String get noInvoicesYet;

  /// No description provided for @noInvoicesYetHint.
  ///
  /// In en, this message translates to:
  /// **'Bill this account with the \"+\".'**
  String get noInvoicesYetHint;

  /// No description provided for @noInvoicesOverdue.
  ///
  /// In en, this message translates to:
  /// **'Nothing overdue'**
  String get noInvoicesOverdue;

  /// No description provided for @noInvoicesOverdueHint.
  ///
  /// In en, this message translates to:
  /// **'Every issued invoice is paid or not due yet.'**
  String get noInvoicesOverdueHint;

  /// No description provided for @invoicesOfOneContract.
  ///
  /// In en, this message translates to:
  /// **'Showing one contract\'s invoices.'**
  String get invoicesOfOneContract;

  /// No description provided for @invoiceDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String invoiceDueOn(String date);

  /// No description provided for @invoiceBalanceOf.
  ///
  /// In en, this message translates to:
  /// **'{amount} due'**
  String invoiceBalanceOf(String amount);

  /// No description provided for @invoiceTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice total'**
  String get invoiceTotalLabel;

  /// No description provided for @invoiceBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance due'**
  String get invoiceBalanceLabel;

  /// No description provided for @invoicePaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoicePaidLabel;

  /// No description provided for @invoicePaidOf.
  ///
  /// In en, this message translates to:
  /// **'{paid} paid of {total}'**
  String invoicePaidOf(String paid, String total);

  /// No description provided for @invoicePaidInFull.
  ///
  /// In en, this message translates to:
  /// **'Paid in full'**
  String get invoicePaidInFull;

  /// No description provided for @invoiceIssueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get invoiceIssueDateLabel;

  /// No description provided for @invoiceDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get invoiceDueDateLabel;

  /// No description provided for @invoiceDueDateHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave the due date empty to use the contract\'s payment terms.'**
  String get invoiceDueDateHelp;

  /// No description provided for @invoiceDueBeforeIssue.
  ///
  /// In en, this message translates to:
  /// **'Pick a day on or after the issue date.'**
  String get invoiceDueBeforeIssue;

  /// No description provided for @invoiceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice number'**
  String get invoiceNumberLabel;

  /// No description provided for @invoiceNumberHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty to number it automatically.'**
  String get invoiceNumberHelp;

  /// No description provided for @invoiceNumberTaken.
  ///
  /// In en, this message translates to:
  /// **'That invoice number is already used.'**
  String get invoiceNumberTaken;

  /// No description provided for @invoiceContractLabel.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get invoiceContractLabel;

  /// No description provided for @invoiceNoContracts.
  ///
  /// In en, this message translates to:
  /// **'This account has no contracts.'**
  String get invoiceNoContracts;

  /// No description provided for @invoiceLineJobLabel.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get invoiceLineJobLabel;

  /// No description provided for @invoiceLineNoJobs.
  ///
  /// In en, this message translates to:
  /// **'This account had no jobs in the last 30 days.'**
  String get invoiceLineNoJobs;

  /// No description provided for @invoiceLineJob.
  ///
  /// In en, this message translates to:
  /// **'Job: {title}'**
  String invoiceLineJob(String title);

  /// No description provided for @sectionPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get sectionPayments;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsYet;

  /// No description provided for @paymentVoidedTag.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get paymentVoidedTag;

  /// No description provided for @issueInvoice.
  ///
  /// In en, this message translates to:
  /// **'Issue invoice'**
  String get issueInvoice;

  /// No description provided for @issueInvoiceConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue this invoice?'**
  String get issueInvoiceConfirmTitle;

  /// No description provided for @issueInvoiceConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Its lines and amounts can\'t change after this. To fix a mistake later, void it and make a new one.'**
  String get issueInvoiceConfirmBody;

  /// No description provided for @invoiceEmptyNotice.
  ///
  /// In en, this message translates to:
  /// **'Add line items to issue it.'**
  String get invoiceEmptyNotice;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @keepInvoice.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepInvoice;

  /// No description provided for @keepPayment.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepPayment;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get recordPayment;

  /// No description provided for @paymentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentAmountLabel;

  /// No description provided for @paymentAmountHelp.
  ///
  /// In en, this message translates to:
  /// **'Balance due: {amount}'**
  String paymentAmountHelp(String amount);

  /// No description provided for @paymentOverBalance.
  ///
  /// In en, this message translates to:
  /// **'That\'s more than the balance due ({amount}).'**
  String paymentOverBalance(String amount);

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero, like 250 or 99.50.'**
  String get invalidAmount;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get paymentMethodLabel;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get paymentMethodCheck;

  /// No description provided for @paymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentMethodBankTransfer;

  /// No description provided for @paymentMethodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get paymentMethodOther;

  /// No description provided for @paymentMethodUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other method'**
  String get paymentMethodUnknown;

  /// No description provided for @paymentMethodRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick how it was paid.'**
  String get paymentMethodRequired;

  /// No description provided for @paymentDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date received'**
  String get paymentDateLabel;

  /// No description provided for @paymentReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get paymentReferenceLabel;

  /// No description provided for @paymentReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Check number, authorization, transfer ID'**
  String get paymentReferenceHint;

  /// No description provided for @voidPayment.
  ///
  /// In en, this message translates to:
  /// **'Void payment'**
  String get voidPayment;

  /// No description provided for @voidPaymentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Void this payment?'**
  String get voidPaymentConfirmTitle;

  /// No description provided for @voidPaymentConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'For a bounced check or a refund. It stays on record but no longer counts, and the balance goes back up.'**
  String get voidPaymentConfirmBody;

  /// No description provided for @voidInvoice.
  ///
  /// In en, this message translates to:
  /// **'Void invoice'**
  String get voidInvoice;

  /// No description provided for @voidInvoiceConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Void this invoice?'**
  String get voidInvoiceConfirmTitle;

  /// No description provided for @voidInvoiceConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It stays in the account\'s history, but it can\'t take payments or change again. This can\'t be undone.'**
  String get voidInvoiceConfirmBody;

  /// No description provided for @deleteInvoice.
  ///
  /// In en, this message translates to:
  /// **'Delete invoice'**
  String get deleteInvoice;

  /// No description provided for @deleteInvoiceConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft?'**
  String get deleteInvoiceConfirmTitle;

  /// No description provided for @deleteInvoiceConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The draft invoice will be deleted. This can\'t be undone.'**
  String get deleteInvoiceConfirmBody;

  /// No description provided for @voidInvoiceNotice.
  ///
  /// In en, this message translates to:
  /// **'This invoice is void. It stays for the record.'**
  String get voidInvoiceNotice;

  /// No description provided for @invoiceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No invoices} =1{1 invoice} other{{count} invoices}}'**
  String invoiceCount(int count);

  /// No description provided for @invoicesNotFound.
  ///
  /// In en, this message translates to:
  /// **'This invoice no longer exists.'**
  String get invoicesNotFound;

  /// No description provided for @invoicesDueDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a due date: the contract\'s payment terms don\'t set one.'**
  String get invoicesDueDateRequired;

  /// No description provided for @invoicesDueBeforeIssue.
  ///
  /// In en, this message translates to:
  /// **'The due date can\'t be before the issue date.'**
  String get invoicesDueBeforeIssue;

  /// No description provided for @invoicesNotDraft.
  ///
  /// In en, this message translates to:
  /// **'Only a draft invoice can be changed or issued.'**
  String get invoicesNotDraft;

  /// No description provided for @invoicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'An invoice needs line items and a total above zero to be issued.'**
  String get invoicesEmpty;

  /// No description provided for @invoicesVoid.
  ///
  /// In en, this message translates to:
  /// **'This invoice is already void.'**
  String get invoicesVoid;

  /// No description provided for @invoicesHasPayments.
  ///
  /// In en, this message translates to:
  /// **'Void its payments first, then the invoice.'**
  String get invoicesHasPayments;

  /// No description provided for @invoicesOnlyDraftsDeletable.
  ///
  /// In en, this message translates to:
  /// **'Only a draft can be deleted. Void an issued invoice instead.'**
  String get invoicesOnlyDraftsDeletable;

  /// No description provided for @invoicesNotPayable.
  ///
  /// In en, this message translates to:
  /// **'Payments only go on an issued or partly paid invoice.'**
  String get invoicesNotPayable;

  /// No description provided for @invoicesOverpayment.
  ///
  /// In en, this message translates to:
  /// **'That\'s more than the balance due.'**
  String get invoicesOverpayment;

  /// No description provided for @invoicesPaymentNotFound.
  ///
  /// In en, this message translates to:
  /// **'That payment no longer exists.'**
  String get invoicesPaymentNotFound;

  /// No description provided for @invoicesPaymentAlreadyVoided.
  ///
  /// In en, this message translates to:
  /// **'That payment is already voided.'**
  String get invoicesPaymentAlreadyVoided;

  /// No description provided for @authInvalidPin.
  ///
  /// In en, this message translates to:
  /// **'That code is wrong or has expired. After 5 tries, send a new code.'**
  String get authInvalidPin;

  /// No description provided for @authInvalidResetToken.
  ///
  /// In en, this message translates to:
  /// **'This reset took too long or was already used. Send a new code to start again.'**
  String get authInvalidResetToken;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersionLabel;

  /// No description provided for @viewInvoicePdf.
  ///
  /// In en, this message translates to:
  /// **'View PDF'**
  String get viewInvoicePdf;

  /// No description provided for @invoicePdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice PDF'**
  String get invoicePdfTitle;

  /// No description provided for @sendInvoice.
  ///
  /// In en, this message translates to:
  /// **'Send by email'**
  String get sendInvoice;

  /// No description provided for @sendInvoiceButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendInvoiceButton;

  /// No description provided for @sendInvoiceTo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Send to 1 person} other{Send to {count} people}}'**
  String sendInvoiceTo(int count);

  /// No description provided for @sendInvoiceOtherEmails.
  ///
  /// In en, this message translates to:
  /// **'Other emails'**
  String get sendInvoiceOtherEmails;

  /// No description provided for @sendInvoiceAddEmail.
  ///
  /// In en, this message translates to:
  /// **'Add email'**
  String get sendInvoiceAddEmail;

  /// No description provided for @sendInvoiceHelp.
  ///
  /// In en, this message translates to:
  /// **'Everyone on the list sees the others\' addresses. The email and the attached PDF are in the language the app is in.'**
  String get sendInvoiceHelp;

  /// No description provided for @sendInvoiceNoRecipients.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one person, or add an email.'**
  String get sendInvoiceNoRecipients;

  /// No description provided for @sendInvoiceTooMany.
  ///
  /// In en, this message translates to:
  /// **'An invoice can go to up to {max} emails at once.'**
  String sendInvoiceTooMany(int max);

  /// No description provided for @invoiceSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to {emails}.'**
  String invoiceSentTo(String emails);

  /// No description provided for @invoicesNotSendable.
  ///
  /// In en, this message translates to:
  /// **'Only an issued invoice can be sent. Drafts and void invoices can\'t.'**
  String get invoicesNotSendable;

  /// No description provided for @invoicesNoRecipient.
  ///
  /// In en, this message translates to:
  /// **'This account has no billing or primary contact with an email. Add an email to send it.'**
  String get invoicesNoRecipient;

  /// No description provided for @mailSendFailed.
  ///
  /// In en, this message translates to:
  /// **'The email couldn\'t be sent. Try again in a moment.'**
  String get mailSendFailed;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsRowHint.
  ///
  /// In en, this message translates to:
  /// **'Work assigned to you and changes to your jobs'**
  String get notificationsRowHint;

  /// No description provided for @notificationsUnreadSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread} other{{count} unread}}'**
  String notificationsUnreadSummary(int count);

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noNotificationsYetHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see here when someone assigns you work or changes a job you\'re on.'**
  String get noNotificationsYetHint;

  /// No description provided for @notificationsLatestOnly.
  ///
  /// In en, this message translates to:
  /// **'Showing the latest 100.'**
  String get notificationsLatestOnly;

  /// No description provided for @notificationUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationUnread;

  /// No description provided for @notificationYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationYesterday;

  /// No description provided for @notifTaskAssigned.
  ///
  /// In en, this message translates to:
  /// **'{actor} assigned you a task'**
  String notifTaskAssigned(String actor);

  /// No description provided for @notifTaskAssignedNoActor.
  ///
  /// In en, this message translates to:
  /// **'You were assigned a task'**
  String get notifTaskAssignedNoActor;

  /// No description provided for @notifComplaintAssigned.
  ///
  /// In en, this message translates to:
  /// **'{actor} assigned you a complaint'**
  String notifComplaintAssigned(String actor);

  /// No description provided for @notifComplaintAssignedNoActor.
  ///
  /// In en, this message translates to:
  /// **'You were assigned a complaint'**
  String get notifComplaintAssignedNoActor;

  /// No description provided for @notifComplaintReported.
  ///
  /// In en, this message translates to:
  /// **'{actor} reported a complaint'**
  String notifComplaintReported(String actor);

  /// No description provided for @notifComplaintReportedNoActor.
  ///
  /// In en, this message translates to:
  /// **'A complaint was reported'**
  String get notifComplaintReportedNoActor;

  /// No description provided for @notifJobCrewAdded.
  ///
  /// In en, this message translates to:
  /// **'{actor} added you to a job'**
  String notifJobCrewAdded(String actor);

  /// No description provided for @notifJobCrewAddedNoActor.
  ///
  /// In en, this message translates to:
  /// **'You were added to a job'**
  String get notifJobCrewAddedNoActor;

  /// No description provided for @notifJobRescheduled.
  ///
  /// In en, this message translates to:
  /// **'{actor} moved a job you\'re on'**
  String notifJobRescheduled(String actor);

  /// No description provided for @notifJobRescheduledNoActor.
  ///
  /// In en, this message translates to:
  /// **'A job you\'re on was moved'**
  String get notifJobRescheduledNoActor;

  /// No description provided for @notifJobCancelled.
  ///
  /// In en, this message translates to:
  /// **'{actor} cancelled a job you\'re on'**
  String notifJobCancelled(String actor);

  /// No description provided for @notifJobCancelledNoActor.
  ///
  /// In en, this message translates to:
  /// **'A job you\'re on was cancelled'**
  String get notifJobCancelledNoActor;

  /// No description provided for @notifOther.
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get notifOther;
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
