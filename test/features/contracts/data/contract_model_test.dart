import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/contracts/data/models/contract_model.dart';
import 'package:sp_cln_app/features/contracts/domain/entities/contract.dart';

void main() {
  group('ContractModel.fromJson', () {
    test('reads a signed contract with its proposal and derived fields', () {
      final c = ContractModel.fromJson({
        'id': 'k1',
        'clientAccountId': 'c1',
        'proposalId': 'p1',
        'contractValue': '2400',
        'startDate': '2026-03-01T00:00:00.000Z',
        'expirationDate': '2027-02-28T00:00:00.000Z',
        'paymentTerms': 'Net 30',
        'status': 'active',
        'autoRenew': true,
        'cancellationNoticeDays': 30,
        'signedByUserId': 'u1',
        'signedDate': '2026-02-20T00:00:00.000Z',
        'signedBy': {'id': 'u1', 'name': 'Carlos Medina', 'email': 'c@x.com'},
        'proposal': {'id': 'p1', 'versionNumber': 2, 'agreedPrice': '2400'},
        'scopeOfWorkCount': 3,
        'invoiceCount': 0,
        'daysUntilExpiration': 155,
        'isExpiringSoon': false,
      });

      expect(c.status, ContractStatus.active);
      expect(c.contractValue, '2400');
      // Date-only columns keep their calendar day in any time zone.
      expect(c.startDate, DateTime(2026, 3, 1));
      expect(c.expirationDate, DateTime(2027, 2, 28));
      expect(c.signedDate, DateTime(2026, 2, 20));
      expect(c.signedByName, 'Carlos Medina');
      expect(c.proposalVersion, 2);
      expect(c.autoRenew, isTrue);
      expect(c.cancellationNoticeDays, 30);
      expect(c.daysUntilExpiration, 155);
      expect(c.isSigned, isTrue);
      expect(c.canSign, isFalse);
      // Scopes were built on it, and it isn't a draft.
      expect(c.canDelete, isFalse);
    });

    test('reads a bare draft and an unknown status', () {
      final draft = ContractModel.fromJson({
        'id': 'k2',
        'clientAccountId': 'c1',
        'proposalId': null,
        'contractValue': 1200.5,
        'startDate': '2026-10-01T00:00:00.000Z',
        'expirationDate': null,
        'status': 'draft',
        'signedBy': null,
        'proposal': null,
      });
      expect(draft.contractValue, '1200.5');
      expect(draft.expirationDate, isNull);
      expect(draft.proposalVersion, isNull);
      expect(draft.canSign, isTrue);
      expect(draft.canDelete, isTrue);

      final odd = ContractModel.fromJson({
        'id': 'k3',
        'contractValue': '1',
        'startDate': '2026-10-01',
        'status': 'archived',
      });
      expect(odd.status, ContractStatus.unknown);
    });
  });

  group('ContractDraftModel.toJson', () {
    final draft = ContractDraft(
      proposalId: 'p1',
      contractValue: ' 2400.50 ',
      startDate: DateTime(2026, 10, 1),
      paymentTerms: '  ',
      cancellationNoticeDays: '',
    );

    test('a create leaves empty fields out and sends numbers', () {
      expect(ContractDraftModel.toJson(draft, create: true), {
        'proposalId': 'p1',
        'contractValue': 2400.5,
        'startDate': '2026-10-01',
        'autoRenew': false,
      });
    });

    test('an update clears empty fields and never sends the proposal', () {
      expect(ContractDraftModel.toJson(draft, create: false), {
        'contractValue': 2400.5,
        'startDate': '2026-10-01',
        'expirationDate': null,
        'paymentTerms': null,
        'cancellationNoticeDays': null,
        'autoRenew': false,
      });
      final full = ContractDraft(
        contractValue: '2400',
        startDate: DateTime(2026, 10, 1),
        expirationDate: DateTime(2027, 9, 30),
        paymentTerms: 'Net 15',
        autoRenew: true,
        cancellationNoticeDays: '30',
      );
      expect(ContractDraftModel.toJson(full, create: false), {
        'contractValue': 2400,
        'startDate': '2026-10-01',
        'expirationDate': '2027-09-30',
        'paymentTerms': 'Net 15',
        'cancellationNoticeDays': 30,
        'autoRenew': true,
      });
    });
  });
}
