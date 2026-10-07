import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';
import 'package:sp_cln_app/features/jobs/domain/usecases/job_usecases.dart';

import '../../../helpers/test_app.dart';

void main() {
  final repo = FakeJobsRepository({
    'c1': [
      job('old', 'c1', day: 10),
      job('last-week', 'c1', day: 16),
      job('yesterday', 'c1', day: 22),
      job('late', 'c1', hour: 18),
      job('early', 'c1', hour: 7),
      job('next-week', 'c1', day: 30),
    ],
  });

  List<String> ids(List<Job> jobs) => [for (final j in jobs) j.id];

  test('upcoming is from the start of today on, soonest first', () async {
    final jobs = await GetAccountJobs(repo)(
      JobQuery(clientId: 'c1', period: JobPeriod.upcoming, today: testNow),
    );
    expect(ids(jobs), ['early', 'late', 'next-week']);
  });

  test('past is the 30 days before today, latest first', () async {
    final jobs = await GetAccountJobs(repo)(
      JobQuery(clientId: 'c1', period: JobPeriod.past, today: testNow),
    );
    expect(ids(jobs), ['yesterday', 'last-week', 'old']);
  });

  test('queries on the same day are the same list', () {
    expect(
      JobQuery(clientId: 'c1', period: JobPeriod.past, today: testNow),
      JobQuery(
        clientId: 'c1',
        period: JobPeriod.past,
        today: testNow.add(const Duration(hours: 3)),
      ),
    );
  });

  test('a checklist is saved trimmed, without blank items', () async {
    final repo = FakeJobsRepository({
      'c1': [job('j1', 'c1')],
    });
    await SetJobChecklist(repo)(
      const SetChecklistParams(
        clientId: 'c1',
        jobId: 'j1',
        items: [' Trash ', '', '  ', 'Floors'],
      ),
    );
    expect(repo.checklists.single, ['Trash', 'Floors']);
  });

  test("an event's assignee becomes the job's crew", () async {
    final repo = FakeJobsRepository();
    await ConvertEventToJob(repo)(
      const ConvertEventParams(
        clientId: 'c1',
        eventId: 'e1',
        assignedToId: 'u1',
      ),
    );
    await ConvertEventToJob(repo)(
      const ConvertEventParams(clientId: 'c1', eventId: 'e2'),
    );
    expect(repo.crews.first.single.userId, 'u1');
    expect(repo.crews.last, isEmpty);
  });

  test('only open jobs change, and only scheduled ones are deleted', () {
    expect(job('a', 'c1').isOpen, isTrue);
    expect(job('a', 'c1').canDelete, isTrue);
    final started = job('b', 'c1', status: JobStatus.inProgress);
    expect(
      (started.isOpen, started.canDelete, started.canCancel),
      (true, false, true),
    );
    for (final status in [JobStatus.completed, JobStatus.cancelled]) {
      final closed = job('c', 'c1', status: status);
      expect(
        (closed.isOpen, closed.canDelete, closed.canCancel),
        (false, false, false),
      );
    }
  });
}
