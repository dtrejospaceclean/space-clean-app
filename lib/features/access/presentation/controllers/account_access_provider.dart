import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/access_providers.dart';
import '../../domain/entities/account_access.dart';
import '../../domain/usecases/get_account_access.dart';

/// The signed-in user's permissions on one account. Screens build their
/// actions from this instead of calling endpoints that would return 403.
final accountAccessProvider = FutureProvider.family<AccountAccess, String>((
  ref,
  clientId,
) {
  final auth = ref.watch(authControllerProvider).value;
  if (auth is! Authenticated) return AccountAccess.none(clientId);
  return ref.watch(getAccountAccessProvider)(
    AccountAccessParams(clientId: clientId, user: auth.user),
  );
});
