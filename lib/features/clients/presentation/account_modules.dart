import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../access/domain/entities/account_access.dart';
import '../../calendar/presentation/screens/calendar_screen.dart';
import '../../complaints/presentation/screens/complaints_screen.dart';
import '../../contacts/presentation/screens/contacts_screen.dart';
import '../../contracts/presentation/screens/contracts_screen.dart';
import '../../invoices/presentation/screens/invoices_screen.dart';
import '../../jobs/presentation/screens/account_jobs_screen.dart';
import '../../locations/presentation/screens/locations_screen.dart';
import '../../proposals/presentation/screens/proposals_screen.dart';
import '../../scopes/presentation/screens/scopes_screen.dart';
import '../../tasks/presentation/screens/tasks_screen.dart';
import '../../team/presentation/screens/team_screen.dart';

/// How an account's modules are ordered until the user sets their own
/// order: the work first, then the account's own records.
enum AccountSection { work, account }

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

/// Every module the app has built, in default order within each section.
/// To add one, give it a route under `/accounts/:clientId` and an entry
/// here; the account screen picks it up, permission-filtered. A user who
/// reordered the list sees a new module at the end of it.
final accountModules = <AccountModule>[
  AccountModule(
    section: AccountSection.work,
    permission: Permissions.jobsView,
    icon: Icons.cleaning_services_outlined,
    label: (l10n) => l10n.moduleJobs,
    description: (l10n) => l10n.moduleJobsHint,
    route: AccountJobsScreen.route,
  ),
  AccountModule(
    section: AccountSection.work,
    permission: Permissions.proposalView,
    icon: Icons.request_quote_outlined,
    label: (l10n) => l10n.moduleProposals,
    description: (l10n) => l10n.moduleProposalsHint,
    route: ProposalsScreen.route,
  ),
  AccountModule(
    section: AccountSection.work,
    permission: Permissions.contractView,
    icon: Icons.history_edu_outlined,
    label: (l10n) => l10n.moduleContracts,
    description: (l10n) => l10n.moduleContractsHint,
    route: ContractsScreen.route,
  ),
  AccountModule(
    section: AccountSection.work,
    permission: Permissions.invoiceView,
    icon: Icons.receipt_long_outlined,
    label: (l10n) => l10n.moduleInvoices,
    description: (l10n) => l10n.moduleInvoicesHint,
    route: InvoicesScreen.route,
  ),
  AccountModule(
    section: AccountSection.work,
    permission: Permissions.scopeView,
    icon: Icons.checklist_rtl_rounded,
    label: (l10n) => l10n.moduleScope,
    description: (l10n) => l10n.moduleScopeHint,
    route: ScopesScreen.route,
  ),
  AccountModule(
    section: AccountSection.work,
    permission: Permissions.calendarView,
    icon: Icons.calendar_month_outlined,
    label: (l10n) => l10n.moduleCalendar,
    description: (l10n) => l10n.moduleCalendarHint,
    route: CalendarScreen.route,
  ),
  AccountModule(
    section: AccountSection.work,
    permission: Permissions.complaintsView,
    icon: Icons.report_outlined,
    label: (l10n) => l10n.moduleComplaints,
    description: (l10n) => l10n.moduleComplaintsHint,
    route: ComplaintsScreen.route,
  ),
  AccountModule(
    section: AccountSection.work,
    permission: Permissions.tasksView,
    icon: Icons.task_alt_rounded,
    label: (l10n) => l10n.moduleTasks,
    description: (l10n) => l10n.moduleTasksHint,
    route: TasksScreen.route,
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

/// Every module's route in the order the user set ([saved], routes from
/// [ModuleOrderController]), defaulting to section order. Saved routes that
/// no longer exist are dropped; modules the user never ordered come last.
List<String> fullOrder(List<String> saved) {
  final known = {for (final m in accountModules) m.route};
  final defaults = [
    for (final section in AccountSection.values)
      for (final m in accountModules)
        if (m.section == section) m.route,
  ];
  final ordered = [
    for (final route in saved)
      if (known.contains(route)) route,
  ];
  return [
    ...ordered,
    for (final route in defaults)
      if (!ordered.contains(route)) route,
  ];
}

/// The modules [access] allows, in the user's order ([saved]).
List<AccountModule> orderedModules(AccountAccess access, List<String> saved) {
  final byRoute = {for (final m in accountModules) m.route: m};
  return [
    for (final route in fullOrder(saved))
      if (byRoute[route]! case final m when access.can(m.permission)) m,
  ];
}

/// The full order after the user rearranged the modules they can see into
/// [visible]: those take the places they held, in their new order, and
/// modules hidden from them in this account keep their own places.
List<String> reorderVisible(List<String> saved, List<String> visible) {
  final shown = visible.toSet();
  final next = visible.iterator;
  return [
    for (final route in fullOrder(saved))
      if (shown.contains(route)) (next..moveNext()).current else route,
  ];
}
