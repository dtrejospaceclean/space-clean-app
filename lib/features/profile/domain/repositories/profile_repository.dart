import '../../../auth/domain/entities/user.dart';
import '../entities/profile_draft.dart';

/// The signed-in user's own record. Every method throws a `Failure` on error.
abstract interface class ProfileRepository {
  /// Returns the saved user.
  Future<User> updateProfile(ProfileDraft draft);

  /// Throws `ServerFailure` `auth.wrong_current_password` when
  /// [currentPassword] is wrong.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
