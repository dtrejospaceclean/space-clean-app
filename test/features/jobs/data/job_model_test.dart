import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/jobs/data/models/job_model.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';

void main() {
  test('maps the API job, including crew and checklist progress', () {
    final job = JobModel.fromJson({
      'id': 'j1',
      'title': 'Nightly clean',
      'status': 'in_progress',
      'scheduledStart': '2026-09-23T12:00:00.000Z',
      'scheduledEnd': null,
      'location': {
        'name': 'Tower A',
        'address': '1 Main St',
        'city': 'Houston',
      },
      'assignments': [
        {
          'userId': 'u1',
          'user': {'id': 'u1', 'name': 'Ana Pérez'},
          'roleOnJob': 'lead',
        },
      ],
      'checklistItems': [
        {'id': 'i1', 'isCompleted': true},
        {'id': 'i2', 'isCompleted': false},
      ],
    }, clientId: 'c1');

    expect(job.clientId, 'c1');
    expect(job.status, JobStatus.inProgress);
    expect(job.scheduledStart.isUtc, isFalse);
    expect(job.scheduledStart.toUtc(), DateTime.utc(2026, 9, 23, 12));
    expect(job.scheduledEnd, isNull);
    expect(job.location?.city, 'Houston');
    expect(job.assignees.single.name, 'Ana Pérez');
    expect((job.checklistDone, job.checklistTotal), (1, 2));
  });

  test('unknown statuses do not crash the list', () {
    final job = JobModel.fromJson({
      'id': 'j1',
      'title': 'x',
      'status': 'paused',
      'scheduledStart': '2026-09-23T12:00:00.000Z',
    }, clientId: 'c1');

    expect(job.status, JobStatus.unknown);
  });
}
