import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/jobs/data/models/job_model.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';

void main() {
  test('maps the API job, including crew and checklist progress', () {
    final job = JobModel.fromJson({
      'id': 'j1',
      'title': 'Nightly clean',
      'status': 'in_progress',
      'jobType': 'recurring',
      'scheduledStart': '2026-09-23T12:00:00.000Z',
      'scheduledEnd': null,
      'locationId': 'l1',
      'location': {
        'id': 'l1',
        'name': 'Tower A',
        'address': '1 Main St',
        'city': 'Houston',
      },
      'scopeOfWorkId': 's1',
      'scopeOfWork': {'id': 's1', 'areaName': 'Lobby', 'frequency': 'daily'},
      'actualStartTime': '2026-09-23T12:05:00.000Z',
      'startedBy': {'id': 'u1', 'name': 'Ana Pérez'},
      'qualityScore': '4.5',
      'assignments': [
        {
          'userId': 'u1',
          'user': {'id': 'u1', 'name': 'Ana Pérez'},
          'roleOnJob': 'lead',
          'checkInTime': '2026-09-23T11:58:00.000Z',
          'checkOutTime': null,
        },
      ],
      'checklistItems': [
        {
          'id': 'i1',
          'description': 'Empty trash',
          'isCompleted': true,
          'completedBy': {'id': 'u1', 'name': 'Ana Pérez'},
          'completedAt': '2026-09-23T12:30:00.000Z',
        },
        {'id': 'i2', 'description': 'Mop floors', 'isCompleted': false},
      ],
    }, clientId: 'c1');

    expect(job.clientId, 'c1');
    expect(job.status, JobStatus.inProgress);
    expect(job.jobType, JobType.recurring);
    expect(job.scheduledStart.isUtc, isFalse);
    expect(job.scheduledStart.toUtc(), DateTime.utc(2026, 9, 23, 12));
    expect(job.scheduledEnd, isNull);
    expect((job.locationId, job.location?.city), ('l1', 'Houston'));
    expect((job.scopeId, job.scopeArea), ('s1', 'Lobby'));
    expect(job.actualStart?.toUtc(), DateTime.utc(2026, 9, 23, 12, 5));
    expect(job.startedByName, 'Ana Pérez');
    expect(job.qualityScore, 4.5);
    final ana = job.assignees.single;
    expect((ana.name, ana.roleOnJob), ('Ana Pérez', 'lead'));
    expect(ana.checkInTime?.toUtc(), DateTime.utc(2026, 9, 23, 11, 58));
    expect(ana.checkOutTime, isNull);
    expect((job.checklistDone, job.checklistTotal), (1, 2));
    expect(job.checklist.first.completedByName, 'Ana Pérez');
    expect(job.checklist.last.description, 'Mop floors');
  });

  test('unknown statuses and types do not crash the list', () {
    final job = JobModel.fromJson({
      'id': 'j1',
      'title': 'x',
      'status': 'paused',
      'jobType': 'emergency',
      'scheduledStart': '2026-09-23T12:00:00.000Z',
    }, clientId: 'c1');

    expect(job.status, JobStatus.unknown);
    expect(job.jobType, JobType.unknown);
    expect(job.isOpen, isFalse);
  });

  group('draftToJson', () {
    final draft = JobDraft(
      title: '  Nightly clean ',
      locationId: 'l1',
      scheduledStart: DateTime.utc(2026, 9, 23, 22),
      scheduledEnd: DateTime.utc(2026, 9, 24, 2),
      instructions: ' ',
    );

    test('a create leaves empty fields out and sends UTC times', () {
      expect(JobModel.draftToJson(draft, create: true), {
        'title': 'Nightly clean',
        'locationId': 'l1',
        'scheduledStart': '2026-09-23T22:00:00.000Z',
        'scheduledEnd': '2026-09-24T02:00:00.000Z',
      });
    });

    test('an update sends empty fields as null to clear them', () {
      expect(JobModel.draftToJson(draft, create: false), {
        'title': 'Nightly clean',
        'locationId': 'l1',
        'scheduledStart': '2026-09-23T22:00:00.000Z',
        'scheduledEnd': '2026-09-24T02:00:00.000Z',
        'scopeOfWorkId': null,
        'instructions': null,
      });
    });
  });

  test('a completion leaves empty fields out', () {
    expect(
      JobModel.completionToJson(
        const JobCompletion(
          qualityScore: 4.5,
          cleanerNotes: '  ',
          clientSignoffName: ' María López ',
        ),
      ),
      {'qualityScore': 4.5, 'clientSignoffName': 'María López'},
    );
    expect(JobModel.completionToJson(const JobCompletion()), isEmpty);
  });

  test('crew sends a role only when there is one; checklist keeps order', () {
    expect(
      JobModel.crewToJson(const [
        CrewMember(userId: 'u1', roleOnJob: 'lead'),
        CrewMember(userId: 'u2', roleOnJob: ' '),
      ]),
      [
        {'userId': 'u1', 'roleOnJob': 'lead'},
        {'userId': 'u2'},
      ],
    );
    expect(JobModel.checklistToJson(['Trash', 'Floors']), [
      {'description': 'Trash', 'sortOrder': 0},
      {'description': 'Floors', 'sortOrder': 1},
    ]);
  });
}
