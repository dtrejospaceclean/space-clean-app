import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/clients_providers.dart';
import '../../domain/entities/client.dart';

/// The signed-in user's accounts. Refresh with `ref.invalidate`.
final myClientsProvider = FutureProvider<List<Client>>((ref) {
  // Reload when the session changes (sign-out, another user signs in).
  ref.watch(authControllerProvider.select((s) => s.value));
  return ref.watch(getMyClientsProvider)(const NoParams());
});

/// One account from the list, by id.
final clientByIdProvider = FutureProvider.family<Client?, String>((
  ref,
  clientId,
) async {
  final clients = await ref.watch(myClientsProvider.future);
  for (final client in clients) {
    if (client.id == clientId) return client;
  }
  return null;
});
