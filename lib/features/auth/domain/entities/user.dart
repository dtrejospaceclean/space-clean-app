/// Global (staff-wide) roles. Per-client-account permissions are a separate layer.
abstract final class GlobalRole {
  static const owner = 'owner';
  static const accountManager = 'account_manager';
  static const supervisor = 'supervisor';
  static const crew = 'crew';
  static const client = 'client';
}

class Role {
  const Role({required this.id, required this.name});

  final String id;
  final String name;
}

enum UserType { internal, external }

/// The signed-in user.
class User {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    required this.isActive,
    required this.roles,
    this.phoneNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String name;

  /// `internal` is staff, `external` is a client's own person.
  final UserType userType;
  final bool isActive;
  final List<Role> roles;

  // Details the user edits on their own profile.
  final String? phoneNumber;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  /// Public CDN link to the profile photo; `null` shows initials. A new
  /// photo gets a new URL, so caching by URL is safe.
  final String? photoUrl;

  bool hasRole(String role) => roles.any((r) => r.name == role);

  bool hasAnyRole(Iterable<String> names) => names.any(hasRole);
}
