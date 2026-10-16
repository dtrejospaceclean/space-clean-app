import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/proposals_remote_data_source.dart';
import '../data/repositories/proposals_repository_impl.dart';
import '../domain/repositories/proposals_repository.dart';
import '../domain/usecases/proposal_usecases.dart';

final proposalsRepositoryProvider = Provider<ProposalsRepository>(
  (ref) => ProposalsRepositoryImpl(
    ProposalsRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getProposalsProvider = Provider(
  (ref) => GetProposals(ref.watch(proposalsRepositoryProvider)),
);
final getProposalProvider = Provider(
  (ref) => GetProposal(ref.watch(proposalsRepositoryProvider)),
);
final getProposalVersionsProvider = Provider(
  (ref) => GetProposalVersions(ref.watch(proposalsRepositoryProvider)),
);
final saveProposalProvider = Provider(
  (ref) => SaveProposal(ref.watch(proposalsRepositoryProvider)),
);
final approveProposalProvider = Provider(
  (ref) => ApproveProposal(ref.watch(proposalsRepositoryProvider)),
);
final deleteProposalProvider = Provider(
  (ref) => DeleteProposal(ref.watch(proposalsRepositoryProvider)),
);
final getProposalPdfProvider = Provider(
  (ref) => GetProposalPdf(ref.watch(proposalsRepositoryProvider)),
);
final sendProposalProvider = Provider(
  (ref) => SendProposal(ref.watch(proposalsRepositoryProvider)),
);
