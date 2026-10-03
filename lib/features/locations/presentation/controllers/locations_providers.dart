import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/locations_providers.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/location_usecases.dart';

/// Each account's location search, as last applied (already debounced).
final locationSearchProvider =
    NotifierProvider.family<LocationSearchController, String, String>(
      LocationSearchController.new,
    );

class LocationSearchController extends Notifier<String> {
  LocationSearchController(this.clientId);

  final String clientId;

  @override
  String build() => '';

  void search(String text) => state = text.trim();
}

/// An account's locations by name, filtered by its search.
final locationsProvider = FutureProvider.autoDispose
    .family<List<Location>, String>(
      (ref, clientId) => ref.watch(getLocationsProvider)(
        LocationQuery(
          clientId: clientId,
          search: ref.watch(locationSearchProvider(clientId)),
        ),
      ),
    );

/// One location with its usage counts: `(clientId, locationId)`.
final locationProvider = FutureProvider.autoDispose
    .family<Location, (String, String)>(
      (ref, key) => ref.watch(getLocationProvider)(
        LocationRef(clientId: key.$1, locationId: key.$2),
      ),
    );

/// Drops an account's cached locations after a save or delete.
void invalidateLocations(WidgetRef ref, String clientId) => ref
  ..invalidate(locationsProvider(clientId))
  ..invalidate(locationProvider);
