import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/proposals/domain/entities/proposal.dart';
import 'package:sp_cln_app/features/proposals/presentation/screens/proposals_screen.dart';
import 'package:sp_cln_app/l10n/app_localizations.dart';

void main() {
  const p = Proposal(
    id: 'p1',
    clientId: 'c1',
    groupId: 'g1',
    stage: ProposalStage.negotiation,
    versionNumber: 1,
    isCurrent: true,
    preparedByName: 'Carlos Medina',
  );

  test('ignores case and accents, in Spanish', () {
    final es = lookupAppLocalizations(const Locale('es'));
    expect(matchesProposal(es, p, 'NEGOCIACION'), isTrue);
    expect(matchesProposal(es, p, 'negociación carlos'), isTrue);
    expect(matchesProposal(es, p, 'aprobada'), isFalse);
    expect(matchesProposal(es, p, '   '), isTrue);
  });
}
