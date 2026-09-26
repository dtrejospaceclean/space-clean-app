/// What a user may change about themselves (`PATCH /auth/me`). Email, roles,
/// pay and status stay with the owners, through user administration.
class ProfileDraft {
  const ProfileDraft({
    required this.name,
    this.phoneNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  final String name;

  /// Empty or null clears the field.
  final String? phoneNumber;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
}
