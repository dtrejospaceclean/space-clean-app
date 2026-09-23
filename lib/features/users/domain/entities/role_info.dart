/// A role as administered: global roles gate staff-wide actions.
class RoleInfo {
  const RoleInfo({
    required this.id,
    required this.name,
    this.description,
    this.userCount = 0,
  });

  final String id;

  /// Lowercase identifier, e.g. `account_manager`.
  final String name;
  final String? description;
  final int userCount;

  /// The five base roles can't be renamed or deleted.
  bool get isSystem => systemRoles.contains(name);

  /// Roles still held by someone can't be deleted.
  bool get isDeletable => !isSystem && userCount == 0;

  static const systemRoles = {
    'owner',
    'account_manager',
    'supervisor',
    'crew',
    'client',
  };

  /// Allowed shape for a role name (the server enforces the same rule).
  static final namePattern = RegExp(r'^[a-z][a-z0-9_]*$');
}
