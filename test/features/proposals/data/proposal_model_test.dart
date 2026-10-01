import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/proposals/data/models/proposal_model.dart';
import 'package:sp_cln_app/features/proposals/domain/entities/proposal.dart';

void main() {
  group('ProposalModel.fromJson', () {
    test('reads a version with its people, dates and line items', () {
      final p = ProposalModel.fromJson({
        'id': 'p1',
        'clientAccountId': 'c1',
        'proposalGroupId': 'g1',
        'pipelineStage': 'negotiation',
        'versionNumber': 2,
        'isCurrent': true,
        'versionNote': 'Annual discount',
        'agreedPrice': null,
        'validUntilDate': '2026-10-31T00:00:00.000Z',
        'preparedBy': {'id': 'u1', 'name': 'Carlos Medina'},
        'approvedBy': null,
        'lineItems': [
          {
            'id': 'i1',
            'serviceCatalogId': 's1',
            'description': 'Office cleaning',
            'quantity': '12000',
            'unitPrice': '0.12',
            'lineTotal': '1440',
          },
          {
            'id': 'i2',
            'serviceCatalogId': null,
            'description': 'Windows',
            'quantity': 4,
            'unitPrice': '150.5',
            'lineTotal': '602',
          },
        ],
      });

      expect(p.stage, ProposalStage.negotiation);
      expect(p.isOpen, isTrue);
      expect(p.validUntil, DateTime(2026, 10, 31));
      expect(p.preparedByName, 'Carlos Medina');
      expect(p.approvedByName, isNull);
      expect(p.lineItems[1].quantity, '4');
      expect(p.lineItemsTotal, '2042.00');
      expect(p.price, '2042.00');
    });

    test('an unknown stage is kept as unknown', () {
      final p = ProposalModel.fromJson({'id': 'p1', 'pipelineStage': 'won'});
      expect(p.stage, ProposalStage.unknown);
    });
  });

  group('ProposalDraftModel.toJson', () {
    final draft = ProposalDraft(
      stage: ProposalStage.pricing,
      agreedPrice: ' ',
      validUntil: DateTime(2026, 3, 1),
      versionNote: '',
      lineItems: const [
        LineItemDraft(
          serviceId: 's1',
          description: ' Office cleaning ',
          quantity: '12000',
          unitPrice: '0.12',
        ),
        LineItemDraft(description: 'Extra', quantity: '2.5', unitPrice: '10'),
      ],
    );

    test('a create leaves empty fields out and never sends totals', () {
      expect(ProposalDraftModel.toJson(draft, target: DraftTarget.create), {
        'pipelineStage': 'pricing',
        'validUntilDate': '2026-03-01',
        'lineItems': [
          {
            'serviceCatalogId': 's1',
            'description': 'Office cleaning',
            'quantity': 12000,
            'unitPrice': 0.12,
          },
          {'description': 'Extra', 'quantity': 2.5, 'unitPrice': 10},
        ],
      });
    });

    test('an update clears empty fields', () {
      final json = ProposalDraftModel.toJson(draft, target: DraftTarget.update);
      expect(json['agreedPrice'], isNull);
      expect(json.containsKey('agreedPrice'), isTrue);
      expect(json.containsKey('versionNote'), isTrue);
    });

    test('a new version leaves empty fields out', () {
      final json = ProposalDraftModel.toJson(
        draft,
        target: DraftTarget.version,
      );
      expect(json.containsKey('agreedPrice'), isFalse);
    });
  });

  test('money in cents', () {
    expect(toCents('1440'), 144000);
    expect(toCents('0.12'), 12);
    expect(toCents('4.5'), 450);
    expect(toCents('0.125'), 13);
    expect(toCents('x'), 0);
    expect(centsToDecimal(5), '0.05');
    expect(lineTotalCents('12000', '0.12'), 144000);
    expect(lineTotalCents('', '3'), 0);
  });
}
