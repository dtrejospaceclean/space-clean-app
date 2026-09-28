import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/team_remote_data_source.dart';
import '../data/repositories/team_repository_impl.dart';
import '../domain/repositories/team_repository.dart';
import '../domain/usecases/team_usecases.dart';

final teamRepositoryProvider = Provider<TeamRepository>(
  (ref) =>
      TeamRepositoryImpl(TeamRemoteDataSource(ref.watch(apiClientProvider))),
);

final getMembersProvider = Provider(
  (ref) => GetMembers(ref.watch(teamRepositoryProvider)),
);
final getPermissionCatalogProvider = Provider(
  (ref) => GetPermissionCatalog(ref.watch(teamRepositoryProvider)),
);
final addMemberProvider = Provider(
  (ref) => AddMember(ref.watch(teamRepositoryProvider)),
);
final updateMemberAccessProvider = Provider(
  (ref) => UpdateMemberAccess(ref.watch(teamRepositoryProvider)),
);
final removeMemberProvider = Provider(
  (ref) => RemoveMember(ref.watch(teamRepositoryProvider)),
);
