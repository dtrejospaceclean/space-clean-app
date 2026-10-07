import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/profile_usecases.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(apiClientProvider)),
);

final updateMyProfileProvider = Provider<UpdateMyProfile>(
  (ref) => UpdateMyProfile(ref.watch(profileRepositoryProvider)),
);

final changePasswordProvider = Provider<ChangePassword>(
  (ref) => ChangePassword(ref.watch(profileRepositoryProvider)),
);

final setMyPhotoProvider = Provider<SetMyPhoto>(
  (ref) => SetMyPhoto(ref.watch(profileRepositoryProvider)),
);

final removeMyPhotoProvider = Provider<RemoveMyPhoto>(
  (ref) => RemoveMyPhoto(ref.watch(profileRepositoryProvider)),
);
