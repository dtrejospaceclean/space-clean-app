import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../models/job_model.dart';

/// Reads `/clients/:clientId/jobs`.
class JobsRepositoryImpl implements JobsRepository {
  const JobsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Job>> getJobs({
    required String clientId,
    required DateTime from,
    required DateTime to,
  }) => _guard(() async {
    final items = await fetchAllPages(
      _api,
      '/clients/$clientId/jobs',
      query: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      },
    );
    return [for (final j in items) JobModel.fromJson(j, clientId: clientId)];
  });

  @override
  Future<Job> getJob({required String clientId, required String jobId}) =>
      _guard(() async {
        final data = await _api.get('/clients/$clientId/jobs/$jobId') as Map;
        return JobModel.fromJson(
          data.cast<String, dynamic>(),
          clientId: clientId,
        );
      });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }
}
