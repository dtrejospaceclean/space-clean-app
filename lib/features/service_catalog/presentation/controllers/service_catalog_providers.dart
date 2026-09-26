import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/service_catalog_providers.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/usecases/service_catalog_usecases.dart';

/// Whether the signed-in user may add and edit services.
final canManageServicesProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider).value;
  return auth is Authenticated && ServiceCatalogPolicy.canManage(auth.user);
});

/// The list's search and status filter.
final serviceQueryProvider =
    NotifierProvider<ServiceQueryController, ServiceQuery>(
      ServiceQueryController.new,
    );

class ServiceQueryController extends Notifier<ServiceQuery> {
  @override
  ServiceQuery build() => const ServiceQuery();

  void search(String text) => state = state.copyWith(search: text);

  void status(bool? isActive) =>
      state = state.copyWith(isActive: () => isActive);
}

final servicesProvider = FutureProvider<List<ServiceItem>>(
  (ref) => ref.watch(getServicesProvider)(ref.watch(serviceQueryProvider)),
);

final serviceProvider = FutureProvider.family<ServiceItem, String>(
  (ref, id) => ref.watch(getServiceProvider)(id),
);
