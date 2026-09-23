import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/clients_remote_data_source.dart';
import '../data/repositories/clients_repository_impl.dart';
import '../domain/repositories/clients_repository.dart';
import '../domain/usecases/get_my_clients.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>(
  (ref) => ClientsRepositoryImpl(
    ClientsRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getMyClientsProvider = Provider<GetMyClients>(
  (ref) => GetMyClients(ref.watch(clientsRepositoryProvider)),
);
