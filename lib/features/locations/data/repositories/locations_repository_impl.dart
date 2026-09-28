import '../../../../core/network/api_exception.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/locations_repository.dart';
import '../datasources/locations_remote_data_source.dart';

class LocationsRepositoryImpl implements LocationsRepository {
  const LocationsRepositoryImpl(this._remote);

  final LocationsRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Location>> getLocations(String clientId, {String search = ''}) =>
      _guard(() => _remote.getLocations(clientId, search: search));

  @override
  Future<Location> getLocation(String clientId, String locationId) =>
      _guard(() => _remote.getLocation(clientId, locationId));

  @override
  Future<void> createLocation(String clientId, LocationDraft draft) =>
      _guard(() => _remote.createLocation(clientId, draft));

  @override
  Future<void> updateLocation(
    String clientId,
    String locationId,
    LocationDraft draft,
  ) => _guard(() => _remote.updateLocation(clientId, locationId, draft));

  @override
  Future<void> deleteLocation(String clientId, String locationId) =>
      _guard(() => _remote.deleteLocation(clientId, locationId));
}
