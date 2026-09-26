import '../../domain/entities/user.dart';

/// JSON mapping for the user returned by `GET /auth/me`.
abstract final class UserModel {
  static User fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
    userType: json['userType'] == 'external'
        ? UserType.external
        : UserType.internal,
    isActive: json['isActive'] as bool? ?? true,
    roles: [
      for (final r in json['roles'] as List? ?? const [])
        Role(id: r['id'] as String, name: r['name'] as String),
    ],
    phoneNumber: json['phoneNumber'] as String?,
    emergencyContactName: json['emergencyContactName'] as String?,
    emergencyContactPhone: json['emergencyContactPhone'] as String?,
  );
}
