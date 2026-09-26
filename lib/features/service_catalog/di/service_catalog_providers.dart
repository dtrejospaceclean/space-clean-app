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
