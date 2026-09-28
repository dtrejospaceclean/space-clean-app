/// Someone who works on a client account: their base role there and what
/// they may do.
class Member {
  const Member({
    required this.userId,
    required this.clientId,
    required this.name,
    required this.email,
    required this.baseRole,
    this.isActive = true,
    this.permissions = const {},
    this.overrides = const {},
  });

  final String userId;
  final String clientId;
  final String name;
  final String email;

  /// Their user can sign in (deactivated users stay members).
  final bool isActive;

  /// One of the five system roles; it seeds [permissions].
  final String baseRole;

  /// In effect: the role's defaults with [overrides] applied.
  final Set<String> permissions;

  /// Only where this member differs from their role's defaults.
  final Map<String, bool> overrides;

  bool get hasCustomAccess => overrides.isNotEmpty;
}

/// Every per-account permission and what each base role gets by default,
/// from `GET /permissions`.
class PermissionCatalog {
  const PermissionCatalog({
    required this.permissions,
    required this.defaultsByRole,
  });

  /// `<module>.<action>` names, in the API's order.
  final List<String> permissions;
  final Map<String, Set<String>> defaultsByRole;

  /// The base roles a member can have, in the API's order.
  Iterable<String> get roles => defaultsByRole.keys;

  Set<String> defaultsFor(String role) => defaultsByRole[role] ?? const {};

  /// The permissions grouped by module ("jobs" → jobs.view, jobs.edit…),
  /// both in the API's order.
  Map<String, List<String>> get byModule {
    final modules = <String, List<String>>{};
    for (final p in permissions) {
      modules.putIfAbsent(p.split('.').first, () => []).add(p);
    }
    return modules;
  }

  /// [granted] with [permission] flipped. Turning on an action also turns
  /// on its area's `view`; turning off `view` turns off the whole area,
  /// since the rest is useless without it.
  Set<String> toggled(Set<String> granted, String permission) {
    final module = permission.split('.').first;
    final view = '$module.view';
    if (granted.contains(permission)) {
      return permission == view
          ? granted.where((p) => p.split('.').first != module).toSet()
          : ({...granted}..remove(permission));
    }
    return {...granted, permission, if (permissions.contains(view)) view};
  }

  /// The override map that turns [role]'s defaults into [wanted]: only the
  /// permissions that differ.
  Map<String, bool> overridesFor(String role, Set<String> wanted) {
    final defaults = defaultsFor(role);
    return {
      for (final p in permissions)
        if (wanted.contains(p) != defaults.contains(p)) p: wanted.contains(p),
    };
  }
}
