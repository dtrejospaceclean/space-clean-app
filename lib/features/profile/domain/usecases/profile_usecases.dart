import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/profile_draft.dart';
import '../../../../core/domain/picked_photo.dart';
import '../repositories/profile_repository.dart';

class UpdateMyProfile implements UseCase<User, ProfileDraft> {
  const UpdateMyProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<User> call(ProfileDraft params) => _repository.updateProfile(params);
}

/// Throws `RuleFailure` `users.photo_too_large` without uploading when the
/// file is over the server's limit.
class SetMyPhoto implements UseCase<User, PickedPhoto> {
  const SetMyPhoto(this._repository);

  final ProfileRepository _repository;

  static const tooLargeKey = 'users.photo_too_large';

  @override
  Future<User> call(PickedPhoto params) async {
    if (params.isTooLarge) throw const RuleFailure(tooLargeKey);
    return _repository.setPhoto(params);
  }
}

class RemoveMyPhoto implements UseCase<User, NoParams> {
  const RemoveMyPhoto(this._repository);

  final ProfileRepository _repository;

  @override
  Future<User> call(NoParams params) => _repository.removePhoto();
}

class ChangePasswordParams {
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}

/// Tokens already issued keep working, so the session stays signed in.
class ChangePassword implements UseCase<void, ChangePasswordParams> {
  const ChangePassword(this._repository);

  final ProfileRepository _repository;

  @override
  Future<void> call(ChangePasswordParams params) => _repository.changePassword(
    currentPassword: params.currentPassword,
    newPassword: params.newPassword,
  );
}
