import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/repositories/service_catalog_repository.dart';
import '../models/service_models.dart';

/// `/service-catalog`.
class ServiceCatalogRepositoryImpl implements ServiceCatalogRepository {
  const ServiceCatalogRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<ServiceItem>> getServices(ServiceQuery query) => _guard(() async {
    final items = await fetchAllPages(
      _api,
      '/service-catalog',
      query: {
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        if (query.isActive case final active?) 'isActive': '$active',
      },
    );
    return items.map(ServiceItemModel.fromJson).toList();
  });

  @override
  Future<ServiceItem> getService(String id) => _guard(
    () async =>
        ServiceItemModel.fromJson(_map(await _api.get('/service-catalog/$id'))),
  );

  @override
  Future<ServiceItem> createService(ServiceDraft draft) => _guard(
    () async => ServiceItemModel.fromJson(
      _map(
        await _api.post(
          '/service-catalog',
          body: ServiceDraftModel.toJson(draft),
        ),
      ),
    ),
  );

  @override
  Future<ServiceItem> updateService(String id, ServiceDraft draft) => _guard(
    () async => ServiceItemModel.fromJson(
      _map(
        await _api.patch(
          '/service-catalog/$id',
          body: ServiceDraftModel.toJson(draft),
        ),
      ),
    ),
  );

  static Map<String, dynamic> _map(Object? data) =>
      (data! as Map).cast<String, dynamic>();

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }
}
