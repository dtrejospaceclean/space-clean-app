import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/repositories/service_catalog_repository.dart';
import '../models/service_models.dart';

/// `/service-catalog`, `/service-categories` and `/units-of-measure`.
class ServiceCatalogRepositoryImpl implements ServiceCatalogRepository {
  const ServiceCatalogRepositoryImpl(this._api);

  final ApiClient _api;

  static const _services = '/service-catalog';
  static const _categories = '/service-categories';
  static const _units = '/units-of-measure';

  @override
  Future<List<ServiceItem>> getServices(CatalogQuery query) =>
      _list(_services, query, ServiceItemModel.fromJson);

  @override
  Future<ServiceItem> getService(String id) =>
      _one('$_services/$id', ServiceItemModel.fromJson);

  @override
  Future<ServiceItem> createService(ServiceDraft draft) => _guard(
    () async => ServiceItemModel.fromJson(
      _map(await _api.post(_services, body: ServiceDraftModel.toJson(draft))),
    ),
  );

  @override
  Future<ServiceItem> updateService(String id, ServiceDraft draft) => _guard(
    () async => ServiceItemModel.fromJson(
      _map(
        await _api.patch(
          '$_services/$id',
          body: ServiceDraftModel.toJson(draft),
        ),
      ),
    ),
  );

  @override
  Future<List<ServiceCategory>> getCategories(CatalogQuery query) =>
      _list(_categories, query, ServiceCategoryModel.fromJson);

  @override
  Future<ServiceCategory> getCategory(String id) =>
      _one('$_categories/$id', ServiceCategoryModel.fromJson);

  @override
  Future<ServiceCategory> saveCategory(String? id, LookupDraft draft) => _save(
    _categories,
    id,
    ServiceCategoryModel.toJson(draft),
    ServiceCategoryModel.fromJson,
  );

  @override
  Future<void> deleteCategory(String id) =>
      _guard(() => _api.delete('$_categories/$id'));

  @override
  Future<List<UnitOfMeasure>> getUnits(CatalogQuery query) =>
      _list(_units, query, UnitOfMeasureModel.fromJson);

  @override
  Future<UnitOfMeasure> getUnit(String id) =>
      _one('$_units/$id', UnitOfMeasureModel.fromJson);

  @override
  Future<UnitOfMeasure> saveUnit(String? id, LookupDraft draft) => _save(
    _units,
    id,
    UnitOfMeasureModel.toJson(draft),
    UnitOfMeasureModel.fromJson,
  );

  @override
  Future<void> deleteUnit(String id) =>
      _guard(() => _api.delete('$_units/$id'));

  Future<List<T>> _list<T>(
    String path,
    CatalogQuery query,
    T Function(Map<String, dynamic>) fromJson,
  ) => _guard(() async {
    final items = await fetchAllPages(
      _api,
      path,
      query: {
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        if (query.isActive case final active?) 'isActive': '$active',
        'categoryId': ?query.categoryId,
      },
    );
    return items.map(fromJson).toList();
  });

  Future<T> _one<T>(String path, T Function(Map<String, dynamic>) fromJson) =>
      _guard(() async => fromJson(_map(await _api.get(path))));

  Future<T> _save<T>(
    String path,
    String? id,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) => _guard(
    () async => fromJson(
      _map(
        id == null
            ? await _api.post(path, body: body)
            : await _api.patch('$path/$id', body: body),
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
