import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../clients/presentation/controllers/clients_providers.dart';
import '../../di/jobs_providers.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';

/// Injectable clock, so tests can pin "today".
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Today's work across every account the user belongs to.
final todayJobsProvider = FutureProvider.autoDispose<DayJobs>((ref) async {
  final clients = await ref.watch(myClientsProvider.future);
  return ref.watch(getDayJobsProvider)(
    GetDayJobsParams(clients: clients, day: ref.watch(clockProvider)()),
  );
});

/// The user's own jobs today, from `GET /me/jobs`: one request.
final myDayJobsProvider = FutureProvider.autoDispose<List<AccountJob>>(
  (ref) => ref.watch(getMyDayJobsProvider)(ref.watch(clockProvider)()),
);

/// One account's upcoming or past jobs.
final accountJobsProvider = FutureProvider.autoDispose
    .family<List<Job>, JobQuery>(
      (ref, query) => ref.watch(getAccountJobsProvider)(query),
    );

/// One job: `(clientId, jobId)`.
final jobProvider = FutureProvider.autoDispose.family<Job, (String, String)>(
  (ref, key) =>
      ref.watch(getJobProvider)(JobRef(clientId: key.$1, jobId: key.$2)),
);

/// Drops cached jobs after any write.
void invalidateJobs(WidgetRef ref) => ref
  ..invalidate(todayJobsProvider)
  ..invalidate(myDayJobsProvider)
  ..invalidate(accountJobsProvider)
  ..invalidate(jobProvider);
