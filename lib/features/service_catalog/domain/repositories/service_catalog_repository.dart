import '../entities/service_item.dart';

/// Every method throws a `Failure`. Any signed-in user reads the catalog;
/// writes need the global `owner` or `account_manager` role.
abstract interface class ServiceCatalogRepository {
  Future<List<ServiceItem>> getServices(ServiceQuery query);

  Future<ServiceItem> getService(String id);

  Future<ServiceItem> createService(ServiceDraft draft);

  Future<ServiceItem> updateService(String id, ServiceDraft draft);
}
