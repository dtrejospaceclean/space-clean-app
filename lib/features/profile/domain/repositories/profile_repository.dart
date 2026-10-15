import '../../../auth/domain/entities/user.dart';
import '../entities/profile_draft.dart';
import '../../../../core/domain/picked_photo.dart';

/// The signed-in user's own record. Every method throws a `Failure` on error.
abstract interface class ProfileRepository {
  /// Returns the saved user.
  Future<User> updateProfile(ProfileDraft draft);

  /// Sets or replaces the user's own photo. Returns the saved user, with
  /// the new `photoUrl`.
  Future<User> setPhoto(PickedPhoto photo);

  /// Returns the saved user, with no `photoUrl`.
  Future<User> removePhoto();

  /// Throws `ServerFailure` `auth.wrong_current_password` when
  /// [currentPassword] is wrong.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
