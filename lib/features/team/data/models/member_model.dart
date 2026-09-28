import '../../domain/entities/member.dart';

abstract final class MemberModel {
  static Member fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map? ?? const {};
    return Member(
      userId: json['userId'] as String,
      clientId: json['clientAccountId'] as String? ?? '',
      name: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
      isActive: user['isActive'] as bool? ?? true,
      baseRole: json['baseRole'] as String? ?? '',
      permissions: _granted(json['permissions']),
      overrides: {
        for (final MapEntry(:key, :value)
            in (json['overrides'] as Map? ?? const {}).entries)
          if (value is bool) key as String: value,
      },
    );
  }

  /// The keys of a `{ "jobs.view": true }` map whose value is `true`.
  static Set<String> _granted(Object? flags) => {
    for (final MapEntry(:key, :value) in (flags as Map? ?? const {}).entries)
      if (value == true) key as String,
  };
}

abstract final class PermissionCatalogModel {
  /// `GET /permissions`: `{ permissions: [...], defaultsByRole: { role: {…} } }`.
  static PermissionCatalog fromJson(Map<String, dynamic> json) =>
      PermissionCatalog(
        permissions: [
          for (final p in json['permissions'] as List? ?? const []) p as String,
        ],
        defaultsByRole: {
          for (final MapEntry(:key, :value)
              in (json['defaultsByRole'] as Map? ?? const {}).entries)
            key as String: MemberModel._granted(value),
        },
      );
}
