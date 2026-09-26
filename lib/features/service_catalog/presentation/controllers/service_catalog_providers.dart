import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/service_catalog_providers.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/usecases/service_catalog_usecases.dart';

/// Whether the signed-in user may add and edit catalog entries.
final canManageServicesProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider).value;
  return auth is Authenticated && ServiceCatalogPolicy.canManage(auth.user);
});

/// The catalog screen's tabs.
enum CatalogTab { services, categories, units }

final catalogTabProvider = NotifierProvider<CatalogTabController, CatalogTab>(
  CatalogTabController.new,
);

class CatalogTabController extends Notifier<CatalogTab> {
  @override
  CatalogTab build() => CatalogTab.services;

  void select(CatalogTab tab) => state = tab;
}

/// Each tab's search and filters, kept while switching tabs.
final catalogQueryProvider =
    NotifierProvider.family<CatalogQueryController, CatalogQuery, CatalogTab>(
      CatalogQueryController.new,
    );

class CatalogQueryController extends Notifier<CatalogQuery> {
  CatalogQueryController(this.tab);

  final CatalogTab tab;

  @override
  CatalogQuery build() => const CatalogQuery();

  void search(String text) => state = state.copyWith(search: text);

  void status(bool? isActive) =>
      state = state.copyWith(isActive: () => isActive);

  void category(String? id) => state = state.copyWith(categoryId: () => id);
}

final servicesProvider = FutureProvider<List<ServiceItem>>(
  (ref) => ref.watch(getServicesProvider)(
    ref.watch(catalogQueryProvider(CatalogTab.services)),
  ),
);

final serviceProvider = FutureProvider.family<ServiceItem, String>(
  (ref, id) => ref.watch(getServiceProvider)(id),
);

final categoriesProvider = FutureProvider<List<ServiceCategory>>(
  (ref) => ref.watch(getCategoriesProvider)(
    ref.watch(catalogQueryProvider(CatalogTab.categories)),
  ),
);

final categoryProvider = FutureProvider.family<ServiceCategory, String>(
  (ref, id) => ref.watch(getCategoryProvider)(id),
);

final unitsProvider = FutureProvider<List<UnitOfMeasure>>(
  (ref) => ref.watch(getUnitsProvider)(
    ref.watch(catalogQueryProvider(CatalogTab.units)),
  ),
);

final unitProvider = FutureProvider.family<UnitOfMeasure, String>(
  (ref, id) => ref.watch(getUnitProvider)(id),
);

/// Every active category, for pickers and the services filter.
final activeCategoriesProvider = FutureProvider<List<ServiceCategory>>(
  (ref) => ref.watch(getCategoriesProvider)(const CatalogQuery()),
);

/// Every active unit, for the service form's picker.
final activeUnitsProvider = FutureProvider<List<UnitOfMeasure>>(
  (ref) => ref.watch(getUnitsProvider)(const CatalogQuery()),
);

/// Drops every cached catalog list after a save or delete, since counts and
/// names show across tabs and pickers.
void invalidateCatalog(WidgetRef ref) => ref
  ..invalidate(servicesProvider)
  ..invalidate(serviceProvider)
  ..invalidate(categoriesProvider)
  ..invalidate(categoryProvider)
  ..invalidate(unitsProvider)
  ..invalidate(unitProvider)
  ..invalidate(activeCategoriesProvider)
  ..invalidate(activeUnitsProvider);
