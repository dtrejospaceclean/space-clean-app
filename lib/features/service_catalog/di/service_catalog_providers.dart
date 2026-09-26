import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/repositories/service_catalog_repository_impl.dart';
import '../domain/repositories/service_catalog_repository.dart';
import '../domain/usecases/service_catalog_usecases.dart';

final serviceCatalogRepositoryProvider = Provider<ServiceCatalogRepository>(
  (ref) => ServiceCatalogRepositoryImpl(ref.watch(apiClientProvider)),
);

final getServicesProvider = Provider(
  (ref) => GetServices(ref.watch(serviceCatalogRepositoryProvider)),
);
final getServiceProvider = Provider(
  (ref) => GetService(ref.watch(serviceCatalogRepositoryProvider)),
);
final saveServiceProvider = Provider(
  (ref) => SaveService(ref.watch(serviceCatalogRepositoryProvider)),
);
final getCategoriesProvider = Provider(
  (ref) => GetCategories(ref.watch(serviceCatalogRepositoryProvider)),
);
final getCategoryProvider = Provider(
  (ref) => GetCategory(ref.watch(serviceCatalogRepositoryProvider)),
);
final saveCategoryProvider = Provider(
  (ref) => SaveCategory(ref.watch(serviceCatalogRepositoryProvider)),
);
final deleteCategoryProvider = Provider(
  (ref) => DeleteCategory(ref.watch(serviceCatalogRepositoryProvider)),
);
final getUnitsProvider = Provider(
  (ref) => GetUnits(ref.watch(serviceCatalogRepositoryProvider)),
);
final getUnitProvider = Provider(
  (ref) => GetUnit(ref.watch(serviceCatalogRepositoryProvider)),
);
final saveUnitProvider = Provider(
  (ref) => SaveUnit(ref.watch(serviceCatalogRepositoryProvider)),
);
final deleteUnitProvider = Provider(
  (ref) => DeleteUnit(ref.watch(serviceCatalogRepositoryProvider)),
);
