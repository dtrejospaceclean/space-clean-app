/// Per-account permission names (`<module>.<action>`), as the API defines them.
abstract final class Permissions {
  static const infoView = 'info.view';
  static const infoEdit = 'info.edit';
  static const proposalView = 'proposal.view';
  static const proposalEdit = 'proposal.edit';
  static const contractView = 'contract.view';
  static const contractEdit = 'contract.edit';
  static const scopeView = 'scope.view';
  static const scopeEdit = 'scope.edit';
  static const jobsView = 'jobs.view';
  static const jobsEdit = 'jobs.edit';
  static const jobsAssign = 'jobs.assign';
  static const complaintsView = 'complaints.view';
  static const calendarView = 'calendar.view';
  static const tasksView = 'tasks.view';
  static const filesView = 'files.view';
  static const teamView = 'team.view';
}

/// What the signed-in user may do inside one client account.
class AccountAccess {
  const AccountAccess({
    required this.clientId,
    this.baseRole,
    this.permissions = const {},
    this.everything = false,
  });

  /// A global owner bypasses membership and may do everything.
  const AccountAccess.owner(this.clientId)
    : baseRole = 'owner',
      permissions = const {},
      everything = true;

  /// Not a member: nothing is allowed.
  const AccountAccess.none(this.clientId)
    : baseRole = null,
      permissions = const {},
      everything = false;

  final String clientId;

  /// The member's base role on this account (`supervisor`, `crew`…).
  final String? baseRole;

  /// Effective permissions: role defaults plus per-account overrides.
  final Set<String> permissions;
  final bool everything;

  bool can(String permission) => everything || permissions.contains(permission);
}
