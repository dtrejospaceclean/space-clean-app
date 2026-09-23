import '../../../auth/domain/entities/user.dart';

/// A user as the administration screens see it: the account plus the staff
/// record (employment, pay, emergency contact).
class ManagedUser {
  const ManagedUser({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    required this.isActive,
    this.roles = const [],
    this.employeeId,
    this.phoneNumber,
    this.employmentType,
    this.payRate,
    this.hireDate,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  final String id;
  final String email;
  final String name;
  final UserType userType;

  /// Users are never deleted; they are deactivated.
  final bool isActive;
  final List<Role> roles;
  final String? employeeId;
  final String? phoneNumber;

  /// Free text on the server; the app offers [EmploymentTypes].
  final String? employmentType;

  /// Decimal as the API sends it (`"18.5"`); never parsed to a double.
  final String? payRate;
  final DateTime? hireDate;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
}

/// Values the app offers for `employmentType`. The server accepts any text,
/// so an existing user may carry something else, which is kept as is.
abstract final class EmploymentTypes {
  static const fullTime = 'full_time';
  static const partTime = 'part_time';
  static const contractor = 'contractor';

  static const all = [fullTime, partTime, contractor];
}

/// Filters for the user list. `null` means "any".
class UserQuery {
  const UserQuery({this.search = '', this.isActive = true, this.roleId});

  final String search;
  final bool? isActive;
  final String? roleId;

  UserQuery copyWith({
    String? search,
    bool? Function()? isActive,
    String? Function()? roleId,
  }) => UserQuery(
    search: search ?? this.search,
    isActive: isActive == null ? this.isActive : isActive(),
    roleId: roleId == null ? this.roleId : roleId(),
  );

  @override
  bool operator ==(Object other) =>
      other is UserQuery &&
      other.search == search &&
      other.isActive == isActive &&
      other.roleId == roleId;

  @override
  int get hashCode => Object.hash(search, isActive, roleId);
}

/// The editable fields of a user. On update only non-null fields are sent,
/// except the `clear*` flags, which send null to empty an optional field.
class UserDraft {
  const UserDraft({
    this.email,
    this.password,
    this.name,
    this.employeeId,
    this.phoneNumber,
    this.employmentType,
    this.payRate,
    this.hireDate,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.roleIds,
    this.cleared = const {},
  });

  final String? email;
  final String? password;
  final String? name;
  final String? employeeId;
  final String? phoneNumber;
  final String? employmentType;

  /// Decimal text as typed, e.g. `"18.50"`.
  final String? payRate;
  final DateTime? hireDate;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  /// Create only; on edit, roles go through their own endpoint.
  final List<String>? roleIds;

  /// Optional fields the user emptied, sent as null to clear them.
  final Set<String> cleared;
}
