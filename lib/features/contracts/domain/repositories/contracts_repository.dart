import '../entities/contract.dart';

/// Every method throws a `Failure` on error.
abstract interface class ContractsRepository {
  /// An account's contracts, latest start first. Needs `contract.view`.
  Future<List<Contract>> getContracts(String clientId);

  /// Needs `contract.view`.
  Future<Contract> getContract(String clientId, String contractId);

  /// A new draft. Needs `contract.edit`; with a proposal, it must be
  /// approved (`contracts.proposal_not_approved`); without one the value is
  /// required (`contracts.contract_value_required`).
  Future<Contract> createContract(String clientId, ContractDraft draft);

  /// Needs `contract.edit`; refused once cancelled (`contracts.cancelled`).
  Future<Contract> updateContract(
    String clientId,
    String contractId,
    ContractDraft draft,
  );

  /// Records the signature (by the signed-in user, on [signedDate] or
  /// today) and activates the contract. Needs `contract.edit`; once only
  /// (`contracts.already_signed`).
  Future<Contract> signContract(
    String clientId,
    String contractId, {
    DateTime? signedDate,
  });

  /// Needs `contract.edit`. The contract stays, read-only.
  Future<Contract> cancelContract(String clientId, String contractId);

  /// Needs `contract.edit`; only an untouched draft
  /// (`contracts.only_drafts_deletable`, `contracts.has_related_records`).
  Future<void> deleteContract(String clientId, String contractId);
}
