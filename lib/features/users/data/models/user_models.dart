import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/entities/role_info.dart';

abstract final class ManagedUserModel {
  static ManagedUser fromJson(Map<String, dynamic> json) => ManagedUser(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    name: json['name'] as String? ?? '',
    userType: json['userType'] == 'external'
        ? UserType.external
        : UserType.internal,
    isActive: json['isActive'] as bool? ?? true,
    roles: [
      for (final r in json['roles'] as List? ?? const [])
        Role(id: r['id'] as String, name: r['name'] as String),
    ],
    employeeId: json['employeeId'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    employmentType: json['employmentType'] as String?,
    payRate: switch (json['payRate']) {
      final String s => s,
      final num n => n.toString(),
      _ => null,
    },
    hireDate: switch (json['hireDate']) {
      // A date-only column: keep the calendar day, ignore the UTC time.
      final String s => DateTime.tryParse(s.substring(0, 10)),
      _ => null,
    },
    emergencyContactName: json['emergencyContactName'] as String?,
    emergencyContactPhone: json['emergencyContactPhone'] as String?,
    photoUrl: json['photoUrl'] as String?,
  );
}

abstract final class UserDraftModel {
  /// Body for `POST /users` / `PATCH /users/:id`. Only fields the server
  /// accepts; unknown ones would fail the whole request.
  static Map<String, dynamic> toJson(UserDraft d, {required bool create}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final body = <String, dynamic>{
      'email': ?text(d.email),
      'password': ?d.password,
      'name': ?text(d.name),
      'employeeId': ?text(d.employeeId),
      'phoneNumber': ?text(d.phoneNumber),
      'employmentType': ?text(d.employmentType),
      // The API takes decimals as numbers on input.
      'payRate': ?switch (text(d.payRate)) {
        final String s => num.tryParse(s),
        null => null,
      },
      'hireDate': ?switch (d.hireDate) {
        final DateTime date => _ymd(date),
        null => null,
      },
      'emergencyContactName': ?text(d.emergencyContactName),
      'emergencyContactPhone': ?text(d.emergencyContactPhone),
      if (create && d.roleIds != null) 'roleIds': d.roleIds,
    };
    if (!create) {
      for (final field in d.cleared) {
        body.putIfAbsent(field, () => null);
      }
    }
    return body;
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

abstract final class RoleInfoModel {
  static RoleInfo fromJson(Map<String, dynamic> json) => RoleInfo(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    userCount: (json['userCount'] as num?)?.toInt() ?? 0,
  );
}
