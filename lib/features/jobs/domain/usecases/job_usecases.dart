import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../clients/domain/entities/client.dart';
import '../entities/job.dart';
import '../repositories/jobs_repository.dart';

/// Jobs from several accounts on one day, plus the accounts that failed.
class DayJobs {
  const DayJobs({required this.jobs, this.failedClients = const []});

  final List<AccountJob> jobs;
  final List<Client> failedClients;
}

class GetDayJobsParams {
  const GetDayJobsParams({required this.clients, required this.day});

  final List<Client> clients;

  /// Any time on the wanted (local) day.
  final DateTime day;
}

/// One day of work across all the user's accounts, soonest first. The API has
/// no cross-account endpoint, so this asks each account in parallel. Accounts
/// the user can't view jobs on are skipped silently; other failures are
/// reported so the screen can say which accounts are missing.
class GetDayJobs implements UseCase<DayJobs, GetDayJobsParams> {
  const GetDayJobs(this._repository);

  final JobsRepository _repository;

  @override
  Future<DayJobs> call(GetDayJobsParams params) async {
    final from = DateTime(params.day.year, params.day.month, params.day.day);
    final to = from.add(const Duration(days: 1));

    final results = await Future.wait([
      for (final client in params.clients)
        _repository
            .getJobs(clientId: client.id, from: from, to: to)
            .then<Object>((jobs) => jobs, onError: (Object e) => e),
    ]);

    final jobs = <AccountJob>[];
    final failed = <Client>[];
    Failure? onlyFailure;
    for (final (i, result) in results.indexed) {
      final client = params.clients[i];
      switch (result) {
        case final List<Job> list:
          jobs.addAll(list.map((job) => AccountJob(job: job, client: client)));
        case ServerFailure(statusCode: 403):
          break; // No jobs.view on this account.
        case final Failure failure:
          failed.add(client);
          onlyFailure = failure;
        default:
          throw result;
      }
    }
    // Nothing came back at all: surface the real error instead of "no jobs".
    if (jobs.isEmpty && failed.length == params.clients.length) {
      if (onlyFailure != null) throw onlyFailure;
    }
    jobs.sort((a, b) => a.job.scheduledStart.compareTo(b.job.scheduledStart));
    return DayJobs(jobs: jobs, failedClients: failed);
  }
}

/// The signed-in user's own jobs on one day (any time on it, local),
/// across all their accounts, soonest first.
class GetMyDayJobs implements UseCase<List<AccountJob>, DateTime> {
  const GetMyDayJobs(this._repository);

  final JobsRepository _repository;

  @override
  Future<List<AccountJob>> call(DateTime day) {
    final from = DateTime(day.year, day.month, day.day);
    return _repository.getMyJobs(
      from: from,
      to: from.add(const Duration(days: 1)),
    );
  }
}

/// Which of an account's jobs a list shows.
enum JobPeriod {
  /// From today on, soonest first.
  upcoming,

  /// The [JobQuery.pastDays] days before today, latest first.
  past,
}

class JobQuery {
  const JobQuery({
    required this.clientId,
    required this.period,
    required this.today,
  }) : withToday = false;

  /// The past [pastDays] days and all of today, latest first: what job
  /// pickers offer, since work is billed or complained about as soon as
  /// it's done.
  const JobQuery.recent({required this.clientId, required this.today})
    : period = JobPeriod.past,
      withToday = true;

  /// How far back [JobPeriod.past] reaches.
  static const pastDays = 30;

  final String clientId;
  final JobPeriod period;

  /// Whether [JobPeriod.past] also takes in today's jobs.
  final bool withToday;

  /// Any time on the current (local) day.
  final DateTime today;

  DateTime get _startOfToday => DateTime(today.year, today.month, today.day);

  @override
  bool operator ==(Object other) =>
      other is JobQuery &&
      other.clientId == clientId &&
      other.period == period &&
      other.withToday == withToday &&
      other._startOfToday == _startOfToday;

  @override
  int get hashCode => Object.hash(clientId, period, withToday, _startOfToday);
}

/// One account's jobs for a [JobPeriod]: upcoming soonest first, past
/// latest first.
class GetAccountJobs implements UseCase<List<Job>, JobQuery> {
  const GetAccountJobs(this._repository);

  final JobsRepository _repository;

  @override
  Future<List<Job>> call(JobQuery q) async {
    final today = q._startOfToday;
    final jobs = switch (q.period) {
      JobPeriod.upcoming => await _repository.getJobs(
        clientId: q.clientId,
        from: today,
      ),
      JobPeriod.past => await _repository.getJobs(
        clientId: q.clientId,
        from: DateTime(today.year, today.month, today.day - JobQuery.pastDays),
        // The API's `to` is inclusive.
        to: DateTime(
          today.year,
          today.month,
          today.day + (q.withToday ? 1 : 0),
        ).subtract(const Duration(milliseconds: 1)),
      ),
    };
    final sorted = [...jobs]
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
    return q.period == JobPeriod.past ? sorted.reversed.toList() : sorted;
  }
}

class JobRef {
  const JobRef({required this.clientId, required this.jobId});

  final String clientId;
  final String jobId;
}

class GetJob implements UseCase<Job, JobRef> {
  const GetJob(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(JobRef p) =>
      _repository.getJob(clientId: p.clientId, jobId: p.jobId);
}

class SaveJobParams {
  const SaveJobParams({
    required this.clientId,
    required this.draft,
    this.jobId,
  });

  final String clientId;

  /// The job edited; null to create.
  final String? jobId;
  final JobDraft draft;
}

class SaveJob implements UseCase<Job, SaveJobParams> {
  const SaveJob(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(SaveJobParams p) => switch (p.jobId) {
    null => _repository.createJob(clientId: p.clientId, draft: p.draft),
    final id => _repository.updateJob(
      clientId: p.clientId,
      jobId: id,
      draft: p.draft,
    ),
  };
}

class ConvertEventParams {
  const ConvertEventParams({
    required this.clientId,
    required this.eventId,
    this.assignedToId,
  });

  final String clientId;
  final String eventId;

  /// The event's assignee, who becomes the job's first crew member.
  final String? assignedToId;
}

/// "Create job" on a calendar event.
class ConvertEventToJob implements UseCase<Job, ConvertEventParams> {
  const ConvertEventToJob(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(ConvertEventParams p) => _repository.createFromEvent(
    clientId: p.clientId,
    eventId: p.eventId,
    crew: [if (p.assignedToId case final id?) CrewMember(userId: id)],
  );
}

class SetCrewParams {
  const SetCrewParams({
    required this.clientId,
    required this.jobId,
    required this.crew,
  });

  final String clientId;
  final String jobId;
  final List<CrewMember> crew;
}

class SetJobCrew implements UseCase<Job, SetCrewParams> {
  const SetJobCrew(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(SetCrewParams p) =>
      _repository.setCrew(clientId: p.clientId, jobId: p.jobId, crew: p.crew);
}

class SetChecklistParams {
  const SetChecklistParams({
    required this.clientId,
    required this.jobId,
    required this.items,
  });

  final String clientId;
  final String jobId;
  final List<String> items;
}

/// Saves the items in order, trimmed; blank ones are dropped.
class SetJobChecklist implements UseCase<Job, SetChecklistParams> {
  const SetJobChecklist(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(SetChecklistParams p) => _repository.setChecklist(
    clientId: p.clientId,
    jobId: p.jobId,
    items: [
      for (final item in p.items)
        if (item.trim() case final text when text.isNotEmpty) text,
    ],
  );
}

class TickChecklistItemParams {
  const TickChecklistItemParams({
    required this.clientId,
    required this.jobId,
    required this.itemId,
    required this.done,
  });

  final String clientId;
  final String jobId;
  final String itemId;

  /// True ticks it off; false reopens it.
  final bool done;
}

/// Ticks a checklist item off, or reopens it, as the signed-in user.
class TickChecklistItem implements UseCase<Job, TickChecklistItemParams> {
  const TickChecklistItem(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(TickChecklistItemParams p) =>
      _repository.setChecklistItemDone(
        clientId: p.clientId,
        jobId: p.jobId,
        itemId: p.itemId,
        done: p.done,
      );
}

class CheckIn implements UseCase<Job, JobRef> {
  const CheckIn(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(JobRef p) =>
      _repository.checkIn(clientId: p.clientId, jobId: p.jobId);
}

class CheckOut implements UseCase<Job, JobRef> {
  const CheckOut(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(JobRef p) =>
      _repository.checkOut(clientId: p.clientId, jobId: p.jobId);
}

class StartJob implements UseCase<Job, JobRef> {
  const StartJob(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(JobRef p) =>
      _repository.startJob(clientId: p.clientId, jobId: p.jobId);
}

class CompleteJobParams {
  const CompleteJobParams({
    required this.clientId,
    required this.jobId,
    required this.completion,
  });

  final String clientId;
  final String jobId;
  final JobCompletion completion;
}

class CompleteJob implements UseCase<Job, CompleteJobParams> {
  const CompleteJob(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(CompleteJobParams p) => _repository.completeJob(
    clientId: p.clientId,
    jobId: p.jobId,
    completion: p.completion,
  );
}

class CancelJob implements UseCase<Job, JobRef> {
  const CancelJob(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(JobRef p) =>
      _repository.cancelJob(clientId: p.clientId, jobId: p.jobId);
}

class DeleteJob implements UseCase<void, JobRef> {
  const DeleteJob(this._repository);

  final JobsRepository _repository;

  @override
  Future<void> call(JobRef p) =>
      _repository.deleteJob(clientId: p.clientId, jobId: p.jobId);
}
