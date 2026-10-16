import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/locations_remote_data_source.dart';
import '../data/repositories/locations_repository_impl.dart';
import '../domain/repositories/locations_repository.dart';
import '../domain/usecases/location_usecases.dart';

final locationsRepositoryProvider = Provider<LocationsRepository>(
  (ref) => LocationsRepositoryImpl(
    LocationsRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getLocationsProvider = Provider(
  (ref) => GetLocations(ref.watch(locationsRepositoryProvider)),
);
final getLocationProvider = Provider(
  (ref) => GetLocation(ref.watch(locationsRepositoryProvider)),
);
final saveLocationProvider = Provider(
  (ref) => SaveLocation(ref.watch(locationsRepositoryProvider)),
);
final deleteLocationProvider = Provider(
  (ref) => DeleteLocation(ref.watch(locationsRepositoryProvider)),
);
final suggestAddressesProvider = Provider(
  (ref) => SuggestAddresses(ref.watch(locationsRepositoryProvider)),
);
