import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/service_item.dart';
import '../repositories/service_catalog_repository.dart';

/// Who maintains the catalog. Everyone else only meets it in pickers.
abstract final class ServiceCatalogPolicy {
  static bool canManage(User user) =>
      user.hasAnyRole(const [GlobalRole.owner, GlobalRole.accountManager]);
}

/// By name (the API orders by category first).
class GetServices implements UseCase<List<ServiceItem>, CatalogQuery> {
  const GetServices(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<List<ServiceItem>> call(CatalogQuery query) async {
    final services = await _repository.getServices(query);
    return [...services]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}

class GetService implements UseCase<ServiceItem, String> {
  const GetService(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<ServiceItem> call(String id) => _repository.getService(id);
}

class SaveParams<T> {
  const SaveParams({this.id, required this.draft});

  /// Null creates a new entry.
  final String? id;
  final T draft;
}

class SaveService implements UseCase<ServiceItem, SaveParams<ServiceDraft>> {
  const SaveService(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<ServiceItem> call(SaveParams<ServiceDraft> params) =>
      switch (params.id) {
        final id? => _repository.updateService(id, params.draft),
        null => _repository.createService(params.draft),
      };
}

/// By name.
class GetCategories implements UseCase<List<ServiceCategory>, CatalogQuery> {
  const GetCategories(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<List<ServiceCategory>> call(CatalogQuery query) =>
      _repository.getCategories(query);
}

class GetCategory implements UseCase<ServiceCategory, String> {
  const GetCategory(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<ServiceCategory> call(String id) => _repository.getCategory(id);
}

class SaveCategory
    implements UseCase<ServiceCategory, SaveParams<LookupDraft>> {
  const SaveCategory(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<ServiceCategory> call(SaveParams<LookupDraft> params) =>
      _repository.saveCategory(params.id, params.draft);
}

class DeleteCategory implements UseCase<void, String> {
  const DeleteCategory(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<void> call(String id) => _repository.deleteCategory(id);
}

/// By name.
class GetUnits implements UseCase<List<UnitOfMeasure>, CatalogQuery> {
  const GetUnits(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<List<UnitOfMeasure>> call(CatalogQuery query) =>
      _repository.getUnits(query);
}

class GetUnit implements UseCase<UnitOfMeasure, String> {
  const GetUnit(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<UnitOfMeasure> call(String id) => _repository.getUnit(id);
}

class SaveUnit implements UseCase<UnitOfMeasure, SaveParams<LookupDraft>> {
  const SaveUnit(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<UnitOfMeasure> call(SaveParams<LookupDraft> params) =>
      _repository.saveUnit(params.id, params.draft);
}

class DeleteUnit implements UseCase<void, String> {
  const DeleteUnit(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<void> call(String id) => _repository.deleteUnit(id);
}
