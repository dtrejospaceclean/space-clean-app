import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/network/api_client.dart';
import 'package:sp_cln_app/core/network/api_exception.dart';
import 'package:sp_cln_app/core/network/auth_interceptor.dart';
import 'package:sp_cln_app/core/storage/token_storage.dart';

typedef Reply = (int status, Map<String, Object?> body);

/// Answers every request from [handler] and records what was sent.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final Future<Reply> Function(RequestOptions options) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = await handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Reply ok(Object? data) => (
  200,
  {
    'success': true,
    'message': 'ok',
    'data': data,
    'errors': null,
    'statusCode': 200,
  },
);

Reply fail(int status, String key) => (
  status,
  {
    'success': false,
    'message': key,
    'data': null,
    'errors': null,
    'statusCode': status,
  },
);

void main() {
  late TokenStorage tokenStorage;
  late FakeAdapter adapter;
  late ApiClient api;
  late int sessionExpiredCalls;
  late int refreshCalls;

  void setUpClient(Future<Reply> Function(RequestOptions options) handler) {
    refreshCalls = 0;
    adapter = FakeAdapter((options) {
      if (options.path == '/auth/refresh') refreshCalls++;
      return handler(options);
    });
    final options = BaseOptions(baseUrl: 'http://api.test');
    final dio = Dio(options)..httpClientAdapter = adapter;
    final refreshDio = Dio(options)..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        refreshDio: refreshDio,
        tokenStorage: tokenStorage,
      ),
    );
    api = ApiClient(dio);
  }

  String? bearer(RequestOptions options) =>
      options.headers['Authorization'] as String?;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tokenStorage = TokenStorage(const FlutterSecureStorage());
    await tokenStorage.save(
      const AuthTokens(accessToken: 'old-access', refreshToken: 'old-refresh'),
    );
    sessionExpiredCalls = 0;
    tokenStorage.sessionExpired.listen((_) => sessionExpiredCalls++);
  });

  /// `/auth/me` accepts only the new access token; refresh issues it.
  Future<Reply> backend(RequestOptions options) async => switch (options.path) {
    '/auth/refresh' => ok({
      'accessToken': 'new-access',
      'refreshToken': 'new-refresh',
    }),
    _ when bearer(options) == 'Bearer new-access' => ok({'id': 'u1'}),
    _ => fail(401, 'auth.invalid_access_token'),
  };

  test('refreshes an expired access token and replays the request', () async {
    setUpClient(backend);

    final data = await api.get('/auth/me');

    expect(data, {'id': 'u1'});
    expect(refreshCalls, 1);
    expect(bearer(adapter.requests.last), 'Bearer new-access');
    expect((await tokenStorage.read())!.refreshToken, 'new-refresh');
  });

  test('concurrent 401s share one refresh', () async {
    setUpClient(backend);

    await Future.wait([api.get('/auth/me'), api.get('/a'), api.get('/b')]);

    expect(refreshCalls, 1);
  });

  test('a rejected refresh clears the session', () async {
    setUpClient(
      (options) async => options.path == '/auth/refresh'
          ? fail(401, 'auth.invalid_refresh_token')
          : fail(401, 'auth.invalid_access_token'),
    );

    await expectLater(
      api.get('/auth/me'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
    await Future<void>.delayed(
      Duration.zero,
    ); // let the broadcast stream deliver
    expect(sessionExpiredCalls, 1);
    expect(await tokenStorage.read(), isNull);
  });

  test('a network failure during refresh keeps the session', () async {
    setUpClient((options) async {
      if (options.path == '/auth/refresh') {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        );
      }
      return fail(401, 'auth.invalid_access_token');
    });

    await expectLater(api.get('/auth/me'), throwsA(isA<ApiException>()));
    expect(sessionExpiredCalls, 0);
    expect(await tokenStorage.read(), isNotNull);
  });

  test('public requests skip the token and never refresh', () async {
    setUpClient((_) async => fail(401, 'auth.invalid_credentials'));

    await expectLater(
      api.post('/auth/login', body: {}, authenticated: false),
      throwsA(
        isA<ApiException>().having(
          (e) => e.key,
          'key',
          'auth.invalid_credentials',
        ),
      ),
    );
    expect(bearer(adapter.requests.single), isNull);
    expect(refreshCalls, 0);
  });
}
