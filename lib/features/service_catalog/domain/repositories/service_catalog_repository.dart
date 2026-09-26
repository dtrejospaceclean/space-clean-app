import '../entities/service_item.dart';

/// Every method throws a `Failure`. Any signed-in user reads the catalog;
/// writes need the global `owner` or `account_manager` role.
abstract interface class ServiceCatalogRepository {
  Future<List<ServiceItem>> getServices(CatalogQuery query);

  Future<ServiceItem> getService(String id);

  Future<ServiceItem> createService(ServiceDraft draft);

  Future<ServiceItem> updateService(String id, ServiceDraft draft);

  Future<List<ServiceCategory>> getCategories(CatalogQuery query);

  Future<ServiceCategory> getCategory(String id);

  /// [id] null creates one. [LookupDraft.detail] is the description.
  Future<ServiceCategory> saveCategory(String? id, LookupDraft draft);

  /// Throws `ServerFailure` `service_categories.in_use` while services use it.
  Future<void> deleteCategory(String id);

  Future<List<UnitOfMeasure>> getUnits(CatalogQuery query);

  Future<UnitOfMeasure> getUnit(String id);

  /// [id] null creates one. [LookupDraft.detail] is the abbreviation.
  Future<UnitOfMeasure> saveUnit(String? id, LookupDraft draft);

  /// Throws `ServerFailure` `units_of_measure.in_use` while services use it.
  Future<void> deleteUnit(String id);
}
