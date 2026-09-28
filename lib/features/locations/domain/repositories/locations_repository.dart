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
}
