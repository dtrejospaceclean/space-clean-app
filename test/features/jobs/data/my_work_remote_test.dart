import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/network/api_client.dart';
import 'package:sp_cln_app/features/jobs/data/datasources/jobs_remote_data_source.dart';
import 'package:sp_cln_app/features/tasks/data/datasources/tasks_remote_data_source.dart';

/// Answers every request with one page of [items] and records what was
/// asked.
class _OnePage implements HttpClientAdapter {
  _OnePage(this.items);

  final List<Map<String, Object?>> items;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'message': 'ok',
        'data': {
          'items': items,
          'meta': {'hasNextPage': false},
        },
        'statusCode': 200,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient _api(_OnePage adapter) => ApiClient(
  Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter,
);

void main() {
  test(
    'the user\'s own jobs come from one request, each with its account',
    () async {
      final adapter = _OnePage([
        {
          'id': 'j1',
          'title': 'Nightly clean',
          'status': 'scheduled',
          'scheduledStart': '2026-09-23T23:00:00.000Z',
          'clientAccountId': 'c1',
          'clientAccount': {
            'id': 'c1',
            'legalName': 'Tower Holdings LLC',
            'dba': 'Tower',
          },
          'assignments': [],
          'checklistItems': [],
        },
      ]);

      final jobs = await JobsRemoteDataSource(_api(adapter)).getMyJobs(
        from: DateTime.utc(2026, 9, 23),
        to: DateTime.utc(2026, 9, 24),
      );

      final request = adapter.requests.single;
      expect(request.path, '/me/jobs');
      expect(request.queryParameters['from'], '2026-09-23T00:00:00.000Z');
      expect(request.queryParameters['to'], '2026-09-24T00:00:00.000Z');
      final mine = jobs.single;
      expect(mine.job.id, 'j1');
      expect(mine.job.clientId, 'c1');
      expect(mine.client.displayName, 'Tower');
    },
  );

  test('the user\'s overdue tasks name their account', () async {
    final adapter = _OnePage([
      {
        'id': 't1',
        'clientAccountId': 'c2',
        'title': 'Send the quote',
        'priority': 'high',
        'status': 'pending',
        'dueDate': '2026-09-20T00:00:00.000Z',
        'isOverdue': true,
        'daysUntilDue': -3,
        // No trade name: the legal name stands in.
        'clientAccount': {'id': 'c2', 'legalName': 'Bayou Clinic', 'dba': null},
      },
    ]);

    final tasks = await TasksRemoteDataSource(_api(adapter))
        .getMyOverdueTasks();

    final request = adapter.requests.single;
    expect(request.path, '/me/tasks');
    expect(request.queryParameters['overdue'], 'true');
    expect(tasks.single.accountName, 'Bayou Clinic');
    expect(tasks.single.clientId, 'c2');
    expect(tasks.single.isOverdue, isTrue);
  });
}
