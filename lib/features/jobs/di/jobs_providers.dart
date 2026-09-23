import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/repositories/jobs_repository_impl.dart';
import '../domain/repositories/jobs_repository.dart';
import '../domain/usecases/job_usecases.dart';

final jobsRepositoryProvider = Provider<JobsRepository>(
  (ref) => JobsRepositoryImpl(ref.watch(apiClientProvider)),
);

final getDayJobsProvider = Provider<GetDayJobs>(
  (ref) => GetDayJobs(ref.watch(jobsRepositoryProvider)),
);

final getAccountJobsProvider = Provider<GetAccountJobs>(
  (ref) => GetAccountJobs(ref.watch(jobsRepositoryProvider)),
);

final getJobProvider = Provider<GetJob>(
  (ref) => GetJob(ref.watch(jobsRepositoryProvider)),
);
