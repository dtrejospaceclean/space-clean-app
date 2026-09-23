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

class GetAccountJobsParams {
  const GetAccountJobsParams({
    required this.clientId,
    required this.from,
    required this.to,
  });

  final String clientId;
  final DateTime from;
  final DateTime to;
}

/// One account's jobs in a date range, soonest first.
class GetAccountJobs implements UseCase<List<Job>, GetAccountJobsParams> {
  const GetAccountJobs(this._repository);

  final JobsRepository _repository;

  @override
  Future<List<Job>> call(GetAccountJobsParams params) async {
    final jobs = await _repository.getJobs(
      clientId: params.clientId,
      from: params.from,
      to: params.to,
    );
    return [...jobs]
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }
}

class GetJobParams {
  const GetJobParams({required this.clientId, required this.jobId});

  final String clientId;
  final String jobId;
}

class GetJob implements UseCase<Job, GetJobParams> {
  const GetJob(this._repository);

  final JobsRepository _repository;

  @override
  Future<Job> call(GetJobParams params) =>
      _repository.getJob(clientId: params.clientId, jobId: params.jobId);
}
