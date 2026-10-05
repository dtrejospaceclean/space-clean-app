import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/contracts_remote_data_source.dart';
import '../data/repositories/contracts_repository_impl.dart';
import '../domain/repositories/contracts_repository.dart';
import '../domain/usecases/contract_usecases.dart';

final contractsRepositoryProvider = Provider<ContractsRepository>(
  (ref) => ContractsRepositoryImpl(
    ContractsRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getContractsProvider = Provider(
  (ref) => GetContracts(ref.watch(contractsRepositoryProvider)),
);
final getContractProvider = Provider(
  (ref) => GetContract(ref.watch(contractsRepositoryProvider)),
);
final saveContractProvider = Provider(
  (ref) => SaveContract(ref.watch(contractsRepositoryProvider)),
);
final signContractProvider = Provider(
  (ref) => SignContract(ref.watch(contractsRepositoryProvider)),
);
final markContractExpiredProvider = Provider(
  (ref) => MarkContractExpired(ref.watch(contractsRepositoryProvider)),
);
final cancelContractProvider = Provider(
  (ref) => CancelContract(ref.watch(contractsRepositoryProvider)),
);
final deleteContractProvider = Provider(
  (ref) => DeleteContract(ref.watch(contractsRepositoryProvider)),
);
