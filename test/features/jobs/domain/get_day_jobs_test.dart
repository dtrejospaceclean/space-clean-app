import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/jobs/domain/usecases/job_usecases.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(id: 'c1', legalName: 'Tower Holdings LLC', dba: 'Tower');
const _clinic = Client(id: 'c2', legalName: 'Bayou Clinic');
const _mall = Client(id: 'c3', legalName: 'Galleria Mall');

void main() {
  GetDayJobs useCase(Map<String, Object> byClient) =>
      GetDayJobs(FakeJobsRepository(byClient));

  test('merges every account and sorts soonest first', () async {
    final day = await useCase({
      'c1': [job('a', 'c1', hour: 14)],
      'c2': [job('b', 'c2', hour: 7), job('c', 'c2', hour: 10)],
    })(GetDayJobsParams(clients: const [_tower, _clinic], day: testNow));

    expect(day.jobs.map((j) => j.job.id), ['b', 'c', 'a']);
    expect(day.jobs.first.client, _clinic);
    expect(day.failedClients, isEmpty);
  });

  test('skips accounts without jobs.view silently', () async {
    final day = await useCase({
      'c1': [job('a', 'c1')],
      'c2': const ServerFailure(
        'auth.insufficient_permission',
        statusCode: 403,
      ),
    })(GetDayJobsParams(clients: const [_tower, _clinic], day: testNow));

    expect(day.jobs, hasLength(1));
    expect(day.failedClients, isEmpty);
  });

  test('reports accounts that failed, keeping the rest', () async {
    final day = await useCase({
      'c1': [job('a', 'c1')],
      'c2': const NetworkFailure(),
      'c3': const ServerFailure('errors.internal', statusCode: 500),
    })(GetDayJobsParams(clients: const [_tower, _clinic, _mall], day: testNow));

    expect(day.jobs, hasLength(1));
    expect(day.failedClients, [_clinic, _mall]);
  });

  test('throws when every account failed', () async {
    await expectLater(
      useCase({'c1': const NetworkFailure()})(
        GetDayJobsParams(clients: const [_tower], day: testNow),
      ),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('no accounts means an empty day, not an error', () async {
    final day = await useCase({})(
      GetDayJobsParams(clients: const [], day: testNow),
    );

    expect(day.jobs, isEmpty);
  });
}
