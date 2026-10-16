import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/location.dart';
import '../models/location_model.dart';

/// Talks to `/clients/:clientId/locations`. Throws `ApiException`.
class LocationsRemoteDataSource {
  const LocationsRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/locations';

  Future<List<Location>> getLocations(
    String clientId, {
    String search = '',
  }) async => (await fetchAllPages(
    _api,
    _path(clientId),
    query: {if (search.isNotEmpty) 'search': search},
  )).map(LocationModel.fromJson).toList();

  Future<Location> getLocation(String clientId, String locationId) async =>
      LocationModel.fromJson(
        ((await _api.get('${_path(clientId)}/$locationId'))! as Map)
            .cast<String, dynamic>(),
      );

  Future<void> createLocation(String clientId, LocationDraft draft) async =>
      _api.post(
        _path(clientId),
        body: LocationDraftModel.toJson(draft, create: true),
      );

  Future<void> updateLocation(
    String clientId,
    String locationId,
    LocationDraft draft,
  ) async => _api.patch(
    '${_path(clientId)}/$locationId',
    body: LocationDraftModel.toJson(draft, create: false),
  );

  Future<void> deleteLocation(String clientId, String locationId) async =>
      _api.delete('${_path(clientId)}/$locationId');

  Future<List<AddressSuggestion>> suggestAddresses(
    String clientId,
    String query, {
    required String language,
  }) async {
    final data = await _api.get(
      '${_path(clientId)}/address-suggestions',
      query: {'q': query, 'language': language},
    );
    return [
      for (final row in data as List? ?? const [])
        LocationModel.suggestionFromJson((row as Map).cast<String, dynamic>()),
    ];
  }
}
