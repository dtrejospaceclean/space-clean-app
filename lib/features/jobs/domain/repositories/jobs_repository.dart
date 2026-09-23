import '../entities/job.dart';

/// Every method throws a `Failure` on error. For crew the server returns only
/// the jobs they're assigned to.
abstract interface class JobsRepository {
  /// Jobs of one account scheduled within [from]–[to].
  Future<List<Job>> getJobs({
    required String clientId,
    required DateTime from,
    required DateTime to,
  });

  Future<Job> getJob({required String clientId, required String jobId});
}
