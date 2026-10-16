import '../entities/location.dart';

/// Every method throws a `Failure` on error.
abstract interface class LocationsRepository {
  /// An account's locations by name. A non-empty [search] matches the name,
  /// address or city. Needs `info.view`.
  Future<List<Location>> getLocations(String clientId, {String search = ''});

  /// One location with its usage counts. Needs `info.view`.
  Future<Location> getLocation(String clientId, String locationId);

  /// Needs `info.edit`.
  Future<void> createLocation(String clientId, LocationDraft draft);

  /// Needs `info.edit`.
  Future<void> updateLocation(
    String clientId,
    String locationId,
    LocationDraft draft,
  );

  /// Needs `info.edit`, and only while no scope of work or job uses it
  /// (`locations.has_related_records` otherwise).
  Future<void> deleteLocation(String clientId, String locationId);

  /// Up to 5 US street addresses matching [query] (3 characters or more),
  /// worded in [language] (`en`, `es`). Needs `info.edit`. Every call counts
  /// toward a monthly allowance; once it's spent, or when the map service is
  /// down, it throws `geo.limit_reached` / `geo.unavailable`.
  Future<List<AddressSuggestion>> suggestAddresses(
    String clientId,
    String query, {
    required String language,
  });
}
