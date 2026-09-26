import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/service_item.dart';
import '../repositories/service_catalog_repository.dart';

/// Who maintains the catalog. Everyone else only meets it in pickers.
abstract final class ServiceCatalogPolicy {
  static bool canManage(User user) =>
      user.hasAnyRole(const [GlobalRole.owner, GlobalRole.accountManager]);
}

/// In the API's order: by category (uncategorized last), then name.
class GetServices implements UseCase<List<ServiceItem>, ServiceQuery> {
  const GetServices(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<List<ServiceItem>> call(ServiceQuery query) =>
      _repository.getServices(query);
}

class GetService implements UseCase<ServiceItem, String> {
  const GetService(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<ServiceItem> call(String id) => _repository.getService(id);
}

class SaveServiceParams {
  const SaveServiceParams({this.id, required this.draft});

  /// Null creates a new service.
  final String? id;
  final ServiceDraft draft;
}

class SaveService implements UseCase<ServiceItem, SaveServiceParams> {
  const SaveService(this._repository);

  final ServiceCatalogRepository _repository;

  @override
  Future<ServiceItem> call(SaveServiceParams params) => switch (params.id) {
    final id? => _repository.updateService(id, params.draft),
    null => _repository.createService(params.draft),
  };
}
