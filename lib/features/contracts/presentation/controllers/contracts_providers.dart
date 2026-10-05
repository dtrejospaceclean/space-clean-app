import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/contracts_providers.dart';
import '../../domain/entities/contract.dart';
import '../../domain/usecases/contract_usecases.dart';

/// An account's contracts, latest start first.
final contractsProvider = FutureProvider.autoDispose
    .family<List<Contract>, String>(
      (ref, clientId) => ref.watch(getContractsProvider)(clientId),
    );

/// One contract: `(clientId, contractId)`.
final contractProvider = FutureProvider.autoDispose
    .family<Contract, (String, String)>(
      (ref, key) => ref.watch(getContractProvider)(
        ContractRef(clientId: key.$1, contractId: key.$2),
      ),
    );

/// Drops an account's cached contracts after any write.
void invalidateContracts(WidgetRef ref, String clientId) => ref
  ..invalidate(contractsProvider(clientId))
  ..invalidate(contractProvider);
