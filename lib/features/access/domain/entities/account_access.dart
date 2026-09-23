/// Per-account permission names (`<module>.<action>`), as the API defines them.
abstract final class Permissions {
  static const infoView = 'info.view';
  static const infoEdit = 'info.edit';
  static const proposalView = 'proposal.view';
  static const contractView = 'contract.view';
  static const scopeView = 'scope.view';
  static const jobsView = 'jobs.view';
  static const jobsEdit = 'jobs.edit';
  static const jobsAssign = 'jobs.assign';
  static const complaintsView = 'complaints.view';
  static const calendarView = 'calendar.view';
  static const tasksView = 'tasks.view';
  static const filesView = 'files.view';
  static const teamView = 'team.view';

  /// Each base role's default permissions, as documented for the API
  /// (`GET /permissions` serves the same map, but only to owners and account
  /// managers). Used when a member can't read their own membership.
  static const roleDefaults = <String, Set<String>>{
    'supervisor': {
      'info.view',
      'scope.view',
      'jobs.view',
      'jobs.edit',
      'jobs.assign',
      'complaints.view',
      'complaints.edit',
      'calendar.view',
      'tasks.view',
      'tasks.edit',
      'files.view',
      'files.upload',
      'team.view',
    },
    'crew': {
      'jobs.view',
      'tasks.view',
      'calendar.view',
      'files.view',
      'files.upload',
    },
    'client': {
      'info.view',
      'contract.view',
      'contract.download',
      'jobs.view',
      'complaints.view',
      'calendar.view',
      'files.view',
      'files.download',
    },
  };
}

/// What the signed-in user may do inside one client account.
class AccountAccess {
  const AccountAccess({
    required this.clientId,
    this.baseRole,
    this.permissions = const {},
    this.everything = false,
    this.estimated = false,
  });

  /// A global owner bypasses membership and may do everything.
  const AccountAccess.owner(this.clientId)
    : baseRole = 'owner',
      permissions = const {},
      everything = true,
      estimated = false;

  /// Not a member: nothing is allowed.
  const AccountAccess.none(this.clientId)
    : baseRole = null,
      permissions = const {},
      everything = false,
      estimated = false;

  final String clientId;

  /// The member's base role on this account (`supervisor`, `crew`…).
  final String? baseRole;

  /// Effective permissions: role defaults plus per-account overrides.
  final Set<String> permissions;
  final bool everything;

  /// True when built from role defaults because the membership itself
  /// couldn't be read; per-account overrides are then unknown.
  final bool estimated;

  bool can(String permission) => everything || permissions.contains(permission);
}
