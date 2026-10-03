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

/// One account's jobs from today through the next 7 days.
final accountJobsProvider = FutureProvider.autoDispose
    .family<List<Job>, String>((ref, clientId) {
      final now = ref.watch(clockProvider)();
      final from = DateTime(now.year, now.month, now.day);
      return ref.watch(getAccountJobsProvider)(
        GetAccountJobsParams(
          clientId: clientId,
          from: from,
          to: from.add(const Duration(days: 8)),
        ),
      );
    });

final jobProvider =
    FutureProvider.family<Job, ({String clientId, String jobId})>(
      (ref, key) => ref.watch(getJobProvider)(
        GetJobParams(clientId: key.clientId, jobId: key.jobId),
      ),
    );
