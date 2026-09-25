import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/clients_remote_data_source.dart';
import '../data/repositories/clients_repository_impl.dart';
import '../domain/repositories/clients_repository.dart';
import '../domain/usecases/get_my_clients.dart';
import '../domain/usecases/manage_clients.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>(
  (ref) => ClientsRepositoryImpl(
    ClientsRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getMyClientsProvider = Provider<GetMyClients>(
  (ref) => GetMyClients(ref.watch(clientsRepositoryProvider)),
);
final searchMyClientsProvider = Provider(
  (ref) => SearchMyClients(ref.watch(clientsRepositoryProvider)),
);
final getClientProvider = Provider(
  (ref) => GetClient(ref.watch(clientsRepositoryProvider)),
);
final createClientProvider = Provider(
  (ref) => CreateClient(ref.watch(clientsRepositoryProvider)),
);
final updateClientProvider = Provider(
  (ref) => UpdateClient(ref.watch(clientsRepositoryProvider)),
);
final deleteClientProvider = Provider(
  (ref) => DeleteClient(ref.watch(clientsRepositoryProvider)),
);
