import '../../../../core/network/api_exception.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../datasources/jobs_remote_data_source.dart';

class JobsRepositoryImpl implements JobsRepository {
  const JobsRepositoryImpl(this._remote);

  final JobsRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Job>> getJobs({
    required String clientId,
    required DateTime from,
    DateTime? to,
  }) => _guard(() => _remote.getJobs(clientId, from: from, to: to));

  @override
  Future<Job> getJob({required String clientId, required String jobId}) =>
      _guard(() => _remote.getJob(clientId, jobId));

  @override
  Future<Job> createJob({
    required String clientId,
    required JobDraft draft,
    List<CrewMember> crew = const [],
    List<String> checklist = const [],
  }) => _guard(
    () => _remote.createJob(clientId, draft, crew: crew, checklist: checklist),
  );

  @override
  Future<Job> updateJob({
    required String clientId,
    required String jobId,
    required JobDraft draft,
  }) => _guard(() => _remote.updateJob(clientId, jobId, draft));

  @override
  Future<Job> createFromEvent({
    required String clientId,
    required String eventId,
    List<CrewMember> crew = const [],
  }) => _guard(() => _remote.createFromEvent(clientId, eventId, crew: crew));

  @override
  Future<Job> setCrew({
    required String clientId,
    required String jobId,
    required List<CrewMember> crew,
  }) => _guard(() => _remote.setCrew(clientId, jobId, crew));

  @override
  Future<Job> setChecklist({
    required String clientId,
    required String jobId,
    required List<String> items,
  }) => _guard(() => _remote.setChecklist(clientId, jobId, items));

  @override
  Future<Job> setChecklistItemDone({
    required String clientId,
    required String jobId,
    required String itemId,
    required bool done,
  }) => _guard(
    () => _remote.setChecklistItemDone(clientId, jobId, itemId, done: done),
  );

  @override
  Future<Job> cancelJob({required String clientId, required String jobId}) =>
      _guard(() => _remote.cancelJob(clientId, jobId));

  @override
  Future<void> deleteJob({required String clientId, required String jobId}) =>
      _guard(() => _remote.deleteJob(clientId, jobId));
}
