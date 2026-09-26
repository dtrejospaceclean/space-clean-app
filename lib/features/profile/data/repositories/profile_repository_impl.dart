import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/profile_draft.dart';
import '../../domain/repositories/profile_repository.dart';

/// `PATCH /auth/me` and `POST /auth/change-password`.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<User> updateProfile(ProfileDraft draft) => _guard(() async {
    String? optional(String? value) =>
        (value ?? '').trim().isEmpty ? null : value!.trim();
    final data = await _api.patch(
      '/auth/me',
      body: {
        'name': draft.name.trim(),
        'phoneNumber': optional(draft.phoneNumber),
        'emergencyContactName': optional(draft.emergencyContactName),
        'emergencyContactPhone': optional(draft.emergencyContactPhone),
      },
    );
    return UserModel.fromJson((data! as Map).cast<String, dynamic>());
  });

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _guard(
    () => _api.post(
      '/auth/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    ),
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }
}
