import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/password_reset_repository_impl.dart';
import '../domain/repositories/password_reset_repository.dart';
import '../domain/usecases/password_reset_usecases.dart';

final passwordResetRepositoryProvider = Provider<PasswordResetRepository>(
  (ref) => const PasswordResetRepositoryImpl(),
);

final requestResetCodeProvider = Provider<RequestResetCode>(
  (ref) => RequestResetCode(ref.watch(passwordResetRepositoryProvider)),
);

final verifyResetCodeProvider = Provider<VerifyResetCode>(
  (ref) => VerifyResetCode(ref.watch(passwordResetRepositoryProvider)),
);

final resetPasswordProvider = Provider<ResetPassword>(
  (ref) => ResetPassword(ref.watch(passwordResetRepositoryProvider)),
);
