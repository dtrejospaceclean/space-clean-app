import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/jobs_remote_data_source.dart';
import '../data/repositories/jobs_repository_impl.dart';
import '../domain/repositories/jobs_repository.dart';
import '../domain/usecases/job_usecases.dart';

final jobsRepositoryProvider = Provider<JobsRepository>(
  (ref) =>
      JobsRepositoryImpl(JobsRemoteDataSource(ref.watch(apiClientProvider))),
);

final getMyDayJobsProvider = Provider(
  (ref) => GetMyDayJobs(ref.watch(jobsRepositoryProvider)),
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
final saveJobProvider = Provider(
  (ref) => SaveJob(ref.watch(jobsRepositoryProvider)),
);
final convertEventToJobProvider = Provider(
  (ref) => ConvertEventToJob(ref.watch(jobsRepositoryProvider)),
);
final setJobCrewProvider = Provider(
  (ref) => SetJobCrew(ref.watch(jobsRepositoryProvider)),
);
final setJobChecklistProvider = Provider(
  (ref) => SetJobChecklist(ref.watch(jobsRepositoryProvider)),
);
final tickChecklistItemProvider = Provider(
  (ref) => TickChecklistItem(ref.watch(jobsRepositoryProvider)),
);
final checkInProvider = Provider(
  (ref) => CheckIn(ref.watch(jobsRepositoryProvider)),
);
final checkOutProvider = Provider(
  (ref) => CheckOut(ref.watch(jobsRepositoryProvider)),
);
final startJobProvider = Provider(
  (ref) => StartJob(ref.watch(jobsRepositoryProvider)),
);
final completeJobProvider = Provider(
  (ref) => CompleteJob(ref.watch(jobsRepositoryProvider)),
);
final cancelJobProvider = Provider(
  (ref) => CancelJob(ref.watch(jobsRepositoryProvider)),
);
final deleteJobProvider = Provider(
  (ref) => DeleteJob(ref.watch(jobsRepositoryProvider)),
);
