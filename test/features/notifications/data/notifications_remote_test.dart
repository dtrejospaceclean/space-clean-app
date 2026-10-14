import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/network/api_client.dart';
import 'package:sp_cln_app/features/notifications/data/datasources/devices_remote_data_source.dart';
import 'package:sp_cln_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:sp_cln_app/features/notifications/domain/entities/app_notification.dart';

/// Answers every request with [data] and records what was asked.
class _Answer implements HttpClientAdapter {
  _Answer(this.data);

  final Object? data;
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
        'data': data,
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

NotificationsRemoteDataSource _remote(_Answer adapter) =>
    NotificationsRemoteDataSource(
      ApiClient(
        Dio(BaseOptions(baseUrl: 'https://api.test'))
          ..httpClientAdapter = adapter,
      ),
    );

const _crewAdded = {
  'id': 'n1',
  'type': 'notifications.job_crew_added',
  'params': {
    'jobTitle': 'Night clean',
    'start': '2026-10-14T13:00:00.000Z',
    'actorName': 'Carlos Medina',
  },
  'clientId': 'c1',
  'accountName': 'Torre Norte',
  'entityType': 'job',
  'entityId': 'j1',
  'isRead': false,
  'readAt': null,
  'createdAt': '2026-10-13T18:42:10.123Z',
};

void main() {
  test('reads the latest page and whether older ones exist', () async {
    final adapter = _Answer({
      'items': [_crewAdded],
      'meta': {'page': 1, 'pageSize': 100, 'hasNextPage': true},
    });
    final page = await _remote(adapter).getNotifications();

    final request = adapter.requests.single;
    expect(request.path, '/me/notifications');
    expect(request.queryParameters, {'page': 1, 'pageSize': 100});
    expect(page.hasMore, isTrue);
    final n = page.items.single;
    expect(n.type, NotificationTypes.jobCrewAdded);
    expect(n.entity, NotificationEntity.job);
    expect(n.actorName, 'Carlos Medina');
    expect(n.text('jobTitle'), 'Night clean');
    expect(n.date('start'), DateTime.utc(2026, 10, 14, 13).toLocal());
    expect(n.canOpen, isTrue);
    expect(page.unread, 1);
  });

  test('something newer than the app is kept but opens nothing', () async {
    final adapter = _Answer({
      'items': [
        {
          ..._crewAdded,
          'type': 'notifications.something_new',
          'entityType': 'invoice',
          'params': {'actorName': null},
        },
      ],
      'meta': {'hasNextPage': false},
    });
    final n = (await _remote(adapter).getNotifications()).items.single;

    expect(n.entity, NotificationEntity.unknown);
    expect(n.canOpen, isFalse);
    expect(n.actorName, isNull);
  });

  test('counts the unread ones', () async {
    final adapter = _Answer({'count': 3});
    expect(await _remote(adapter).unreadCount(), 3);
    expect(adapter.requests.single.path, '/me/notifications/unread-count');
  });

  test('marks one read, or all of them', () async {
    final one = _Answer({..._crewAdded, 'isRead': true});
    expect((await _remote(one).markRead('n1')).isRead, isTrue);
    expect(one.requests.single.method, 'POST');
    expect(one.requests.single.path, '/me/notifications/n1/read');

    final all = _Answer({'count': 7});
    expect(await _remote(all).markAllRead(), 7);
    expect(all.requests.single.path, '/me/notifications/read-all');
  });

  test('registers this phone and stops its pushes', () async {
    final adapter = _Answer({'count': 1});
    final devices = DevicesRemoteDataSource(
      ApiClient(
        Dio(BaseOptions(baseUrl: 'https://api.test'))
          ..httpClientAdapter = adapter,
      ),
    );

    await devices.register(token: 'abc:1', platform: 'android', language: 'es');
    await devices.unregister('abc:1');

    final [post, delete] = adapter.requests;
    expect(post.method, 'POST');
    expect(post.path, '/me/devices');
    expect(post.data, {
      'token': 'abc:1',
      'platform': 'android',
      'language': 'es',
    });
    expect(delete.method, 'DELETE');
    expect(delete.path, '/me/devices/abc%3A1');
  });
}
