import '../../../../core/usecase/usecase.dart';
import '../entities/location.dart';
import '../repositories/locations_repository.dart';

class LocationQuery {
  const LocationQuery({required this.clientId, this.search = ''});

  final String clientId;
  final String search;
}

class GetLocations implements UseCase<List<Location>, LocationQuery> {
  const GetLocations(this._repository);

  final LocationsRepository _repository;

  @override
  Future<List<Location>> call(LocationQuery query) =>
      _repository.getLocations(query.clientId, search: query.search);
}

class LocationRef {
  const LocationRef({required this.clientId, required this.locationId});

  final String clientId;
  final String locationId;
}

class GetLocation implements UseCase<Location, LocationRef> {
  const GetLocation(this._repository);

  final LocationsRepository _repository;

  @override
  Future<Location> call(LocationRef params) =>
      _repository.getLocation(params.clientId, params.locationId);
}

class SaveLocationParams {
  const SaveLocationParams({
    required this.clientId,
    this.locationId,
    required this.draft,
  });

  final String clientId;

  /// Null to create a location.
  final String? locationId;
  final LocationDraft draft;
}

class SaveLocation implements UseCase<void, SaveLocationParams> {
  const SaveLocation(this._repository);

  final LocationsRepository _repository;

  @override
  Future<void> call(SaveLocationParams params) => switch (params.locationId) {
    null => _repository.createLocation(params.clientId, params.draft),
    final id => _repository.updateLocation(params.clientId, id, params.draft),
  };
}

class DeleteLocation implements UseCase<void, LocationRef> {
  const DeleteLocation(this._repository);

  final LocationsRepository _repository;

  @override
  Future<void> call(LocationRef params) =>
      _repository.deleteLocation(params.clientId, params.locationId);
}

class AddressSearch {
  const AddressSearch({
    required this.clientId,
    required this.query,
    required this.language,
  });

  final String clientId;
  final String query;

  /// `en` or `es`.
  final String language;
}

/// Suggests addresses for what's typed, trimmed. Under [minLength]
/// characters it answers nothing without calling the API.
class SuggestAddresses
    implements UseCase<List<AddressSuggestion>, AddressSearch> {
  const SuggestAddresses(this._repository);

  final LocationsRepository _repository;

  static const minLength = 3;

  /// Search can't be used for now (the month's allowance is spent, or the
  /// map service is down): the address is typed by hand. Saving still works.
  static const unavailableKeys = {'geo.limit_reached', 'geo.unavailable'};

  @override
  Future<List<AddressSuggestion>> call(AddressSearch p) async {
    final query = p.query.trim();
    if (query.length < minLength) return const [];
    return _repository.suggestAddresses(
      p.clientId,
      query,
      language: p.language,
    );
  }
}
