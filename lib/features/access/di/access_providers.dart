import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/repositories/access_repository_impl.dart';
import '../domain/repositories/access_repository.dart';
import '../domain/usecases/get_account_access.dart';

final accessRepositoryProvider = Provider<AccessRepository>(
  (ref) => AccessRepositoryImpl(ref.watch(apiClientProvider)),
);

final getAccountAccessProvider = Provider<GetAccountAccess>(
  (ref) => GetAccountAccess(ref.watch(accessRepositoryProvider)),
);
