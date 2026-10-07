import '../entities/job.dart';

/// Every method throws a `Failure` on error. For crew the server returns only
/// the jobs they're assigned to.
abstract interface class JobsRepository {
  /// Jobs of one account scheduled from [from] (up to [to], when given),
  /// soonest first. Needs `jobs.view`.
  Future<List<Job>> getJobs({
    required String clientId,
    required DateTime from,
    DateTime? to,
  });

  /// Needs `jobs.view`.
  Future<Job> getJob({required String clientId, required String jobId});

  /// With its first [crew] and [checklist]. Needs `jobs.edit`.
  Future<Job> createJob({
    required String clientId,
    required JobDraft draft,
    List<CrewMember> crew = const [],
    List<String> checklist = const [],
  });

  /// Refused once completed or cancelled. Needs `jobs.edit`.
  Future<Job> updateJob({
    required String clientId,
    required String jobId,
    required JobDraft draft,
  });

  /// Turns a calendar event into a job on its day and time, and marks the
  /// event converted. Needs `jobs.edit`.
  Future<Job> createFromEvent({
    required String clientId,
    required String eventId,
    List<CrewMember> crew = const [],
  });

  /// Replaces the crew; people who stay keep their check-in times. Needs
  /// `jobs.assign`.
  Future<Job> setCrew({
    required String clientId,
    required String jobId,
    required List<CrewMember> crew,
  });

  /// Replaces every item, all unticked. Needs `jobs.edit`.
  Future<Job> setChecklist({
    required String clientId,
    required String jobId,
    required List<String> items,
  });

  /// Ticks item [itemId] as done for the signed-in user, or reopens it.
  /// Needs `jobs.view`; crew only on their own jobs.
  Future<Job> setChecklistItemDone({
    required String clientId,
    required String jobId,
    required String itemId,
    required bool done,
  });

  /// Refused once completed. Needs `jobs.edit`.
  Future<Job> cancelJob({required String clientId, required String jobId});

  /// Only while it never started. Needs `jobs.edit`.
  Future<void> deleteJob({required String clientId, required String jobId});
}
