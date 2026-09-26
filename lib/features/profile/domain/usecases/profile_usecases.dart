import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/profile_draft.dart';
import '../repositories/profile_repository.dart';

class UpdateMyProfile implements UseCase<User, ProfileDraft> {
  const UpdateMyProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<User> call(ProfileDraft params) => _repository.updateProfile(params);
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
