import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/job.dart';
import '../models/job_model.dart';

/// Talks to `/clients/:clientId/jobs`. Throws `ApiException`.
class JobsRemoteDataSource {
  const JobsRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/jobs';

  static Job _one(Object? data, String clientId) => JobModel.fromJson(
    (data! as Map).cast<String, dynamic>(),
    clientId: clientId,
  );

  /// Every page.
  Future<List<Job>> getJobs(
    String clientId, {
    required DateTime from,
    DateTime? to,
  }) async {
    final items = await fetchAllPages(
      _api,
      _path(clientId),
      query: {
        'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );
    return [for (final j in items) JobModel.fromJson(j, clientId: clientId)];
  }

  Future<Job> getJob(String clientId, String jobId) async =>
      _one(await _api.get('${_path(clientId)}/$jobId'), clientId);

  Future<Job> createJob(
    String clientId,
    JobDraft draft, {
    List<CrewMember> crew = const [],
    List<String> checklist = const [],
  }) async => _one(
    await _api.post(
      _path(clientId),
      body: {
        ...JobModel.draftToJson(draft, create: true),
        if (crew.isNotEmpty) 'assignments': JobModel.crewToJson(crew),
        if (checklist.isNotEmpty)
          'checklist': JobModel.checklistToJson(checklist),
      },
    ),
    clientId,
  );

  Future<Job> updateJob(String clientId, String jobId, JobDraft draft) async =>
      _one(
        await _api.patch(
          '${_path(clientId)}/$jobId',
          body: JobModel.draftToJson(draft, create: false),
        ),
        clientId,
      );

  Future<Job> createFromEvent(
    String clientId,
    String eventId, {
    List<CrewMember> crew = const [],
  }) async => _one(
    await _api.post(
      '${_path(clientId)}/from-calendar-event',
      body: {
        'calendarEventId': eventId,
        if (crew.isNotEmpty) 'assignments': JobModel.crewToJson(crew),
      },
    ),
    clientId,
  );

  Future<Job> setCrew(
    String clientId,
    String jobId,
    List<CrewMember> crew,
  ) async => _one(
    await _api.put(
      '${_path(clientId)}/$jobId/assignments',
      body: {'assignments': JobModel.crewToJson(crew)},
    ),
    clientId,
  );

  Future<Job> setChecklist(
    String clientId,
    String jobId,
    List<String> items,
  ) async => _one(
    await _api.put(
      '${_path(clientId)}/$jobId/checklist',
      body: {'items': JobModel.checklistToJson(items)},
    ),
    clientId,
  );

  /// Takes no body; acts for the signed-in user.
  Future<Job> setChecklistItemDone(
    String clientId,
    String jobId,
    String itemId, {
    required bool done,
  }) async => _one(
    await _api.post(
      '${_path(clientId)}/$jobId/checklist/$itemId/'
      '${done ? 'complete' : 'reopen'}',
    ),
    clientId,
  );

  /// Takes no body.
  Future<Job> cancelJob(String clientId, String jobId) async =>
      _one(await _api.post('${_path(clientId)}/$jobId/cancel'), clientId);

  /// Returns no data.
  Future<void> deleteJob(String clientId, String jobId) =>
      _api.delete('${_path(clientId)}/$jobId');
}
