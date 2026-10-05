import '../../../../core/network/api_exception.dart';
import '../../domain/entities/contract.dart';
import '../../domain/repositories/contracts_repository.dart';
import '../datasources/contracts_remote_data_source.dart';

class ContractsRepositoryImpl implements ContractsRepository {
  const ContractsRepositoryImpl(this._remote);

  final ContractsRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Contract>> getContracts(String clientId) =>
      _guard(() => _remote.getContracts(clientId));

  @override
  Future<Contract> getContract(String clientId, String contractId) =>
      _guard(() => _remote.getContract(clientId, contractId));

  @override
  Future<Contract> createContract(String clientId, ContractDraft draft) =>
      _guard(() => _remote.createContract(clientId, draft));

  @override
  Future<Contract> updateContract(
    String clientId,
    String contractId,
    ContractDraft draft,
  ) => _guard(() => _remote.updateContract(clientId, contractId, draft));

  @override
  Future<Contract> signContract(
    String clientId,
    String contractId, {
    DateTime? signedDate,
  }) => _guard(
    () => _remote.signContract(clientId, contractId, signedDate: signedDate),
  );

  @override
  Future<Contract> markExpired(String clientId, String contractId) =>
      _guard(() => _remote.markExpired(clientId, contractId));

  @override
  Future<Contract> cancelContract(String clientId, String contractId) =>
      _guard(() => _remote.cancelContract(clientId, contractId));

  @override
  Future<void> deleteContract(String clientId, String contractId) =>
      _guard(() => _remote.deleteContract(clientId, contractId));
}
