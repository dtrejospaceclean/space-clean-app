import '../../../../core/usecase/usecase.dart';
import '../entities/contract.dart';
import '../repositories/contracts_repository.dart';

class GetContracts implements UseCase<List<Contract>, String> {
  const GetContracts(this._repository);

  final ContractsRepository _repository;

  /// [clientId]'s contracts.
  @override
  Future<List<Contract>> call(String clientId) =>
      _repository.getContracts(clientId);
}

class ContractRef {
  const ContractRef({required this.clientId, required this.contractId});

  final String clientId;
  final String contractId;
}

class GetContract implements UseCase<Contract, ContractRef> {
  const GetContract(this._repository);

  final ContractsRepository _repository;

  @override
  Future<Contract> call(ContractRef params) =>
      _repository.getContract(params.clientId, params.contractId);
}

class SaveContractParams {
  const SaveContractParams({
    required this.clientId,
    required this.draft,
    this.contractId,
  });

  final String clientId;

  /// The contract edited; null to create.
  final String? contractId;
  final ContractDraft draft;
}

/// Creates a draft or edits a contract; returns the saved contract.
class SaveContract implements UseCase<Contract, SaveContractParams> {
  const SaveContract(this._repository);

  final ContractsRepository _repository;

  @override
  Future<Contract> call(SaveContractParams p) => switch (p.contractId) {
    null => _repository.createContract(p.clientId, p.draft),
    final id => _repository.updateContract(p.clientId, id, p.draft),
  };
}

class SignContractParams {
  const SignContractParams({
    required this.clientId,
    required this.contractId,
    this.signedDate,
  });

  final String clientId;
  final String contractId;

  /// Null for today.
  final DateTime? signedDate;
}

class SignContract implements UseCase<Contract, SignContractParams> {
  const SignContract(this._repository);

  final ContractsRepository _repository;

  @override
  Future<Contract> call(SignContractParams p) => _repository.signContract(
    p.clientId,
    p.contractId,
    signedDate: p.signedDate,
  );
}

class MarkContractExpired implements UseCase<Contract, ContractRef> {
  const MarkContractExpired(this._repository);

  final ContractsRepository _repository;

  @override
  Future<Contract> call(ContractRef params) =>
      _repository.markExpired(params.clientId, params.contractId);
}

class CancelContract implements UseCase<Contract, ContractRef> {
  const CancelContract(this._repository);

  final ContractsRepository _repository;

  @override
  Future<Contract> call(ContractRef params) =>
      _repository.cancelContract(params.clientId, params.contractId);
}

class DeleteContract implements UseCase<void, ContractRef> {
  const DeleteContract(this._repository);

  final ContractsRepository _repository;

  @override
  Future<void> call(ContractRef params) =>
      _repository.deleteContract(params.clientId, params.contractId);
}
