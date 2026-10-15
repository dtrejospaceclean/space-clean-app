import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/profile_draft.dart';
import '../../../../core/domain/picked_photo.dart';
import '../../domain/repositories/profile_repository.dart';

/// `PATCH /auth/me`, `/auth/me/photo` and `POST /auth/change-password`.
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
    return _user(data);
  });

  // Dio sets the multipart Content-Type, boundary included.
  @override
  Future<User> setPhoto(PickedPhoto photo) => _guard(() async {
    final form = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photo.path),
    });
    return _user(await _api.put('/auth/me/photo', body: form));
  });

  @override
  Future<User> removePhoto() =>
      _guard(() async => _user(await _api.delete('/auth/me/photo')));

  static User _user(Object? data) =>
      UserModel.fromJson((data! as Map).cast<String, dynamic>());

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
