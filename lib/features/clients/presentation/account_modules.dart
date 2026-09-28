import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../access/domain/entities/account_access.dart';
import '../../contacts/presentation/screens/contacts_screen.dart';
import '../../locations/presentation/screens/locations_screen.dart';
import '../../team/presentation/screens/team_screen.dart';

/// The groups an account's modules are listed under, in screen order.
enum AccountSection {
  work,
  account;

  String label(AppLocalizations l10n) => switch (this) {
    work => l10n.sectionWork,
    account => l10n.sectionAccount,
  };
}

/// One thing a member can open inside an account.
class AccountModule {
  const AccountModule({
    required this.section,
    required this.permission,
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
  });

  final AccountSection section;

  /// Shown only to members whose effective permissions include it.
  final String permission;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;

  /// What's inside, in a few words.
  final String Function(AppLocalizations l10n) description;

  /// Path segment under `/accounts/:clientId`.
  final String route;
}

/// Every module the app has built, in display order within each section.
/// To add one, give it a route under `/accounts/:clientId` and an entry
/// here; the account screen picks it up, grouped and permission-filtered.
final accountModules = <AccountModule>[
  AccountModule(
    section: AccountSection.work,
    permission: Permissions.jobsView,
    icon: Icons.cleaning_services_outlined,
    label: (l10n) => l10n.moduleJobs,
    description: (l10n) => l10n.moduleJobsHint,
    route: 'jobs',
  ),
  AccountModule(
    section: AccountSection.account,
    permission: Permissions.infoView,
    icon: Icons.info_outline_rounded,
    label: (l10n) => l10n.moduleInfo,
    description: (l10n) => l10n.moduleInfoHint,
    route: 'info',
  ),
  AccountModule(
    section: AccountSection.account,
    permission: Permissions.infoView,
    icon: Icons.contacts_outlined,
    label: (l10n) => l10n.moduleContacts,
    description: (l10n) => l10n.moduleContactsHint,
    route: ContactsScreen.route,
  ),
  AccountModule(
    section: AccountSection.account,
    permission: Permissions.infoView,
    icon: Icons.location_on_outlined,
    label: (l10n) => l10n.moduleLocations,
    description: (l10n) => l10n.moduleLocationsHint,
    route: LocationsScreen.route,
  ),
  AccountModule(
    section: AccountSection.account,
    permission: Permissions.teamView,
    icon: Icons.groups_outlined,
    label: (l10n) => l10n.moduleTeam,
    description: (l10n) => l10n.moduleTeamHint,
    route: TeamScreen.route,
  ),
];

/// The modules [access] allows, grouped by section in screen order. Empty
/// sections are left out.
Map<AccountSection, List<AccountModule>> visibleModules(AccountAccess access) =>
    {
      for (final section in AccountSection.values)
        if (accountModules.where(
              (m) => m.section == section && access.can(m.permission),
            )
            case final modules when modules.isNotEmpty)
          section: modules.toList(),
    };
