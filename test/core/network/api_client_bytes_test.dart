import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/network/api_client.dart';
import 'package:sp_cln_app/core/network/api_exception.dart';
import 'package:sp_cln_app/core/network/auth_interceptor.dart';
import 'package:sp_cln_app/core/storage/token_storage.dart';

/// A reply: status, content type and body.
typedef Reply = (int, String, List<int>);

Reply pdf(String text) => (200, 'application/pdf', utf8.encode(text));

Reply json(int status, String key) => (
  status,
  Headers.jsonContentType,
  utf8.encode(
    jsonEncode({
      'success': status < 400,
      'message': key,
      'data': status < 400
          ? {'accessToken': 'new-access', 'refreshToken': 'new-refresh'}
          : null,
      'errors': null,
      'statusCode': status,
    }),
  ),
);

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

  final Reply Function(RequestOptions options) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, type, body) = handler(options);
    return ResponseBody.fromBytes(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [type],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late TokenStorage tokens;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tokens = TokenStorage(const FlutterSecureStorage());
    await tokens.save(
      const AuthTokens(accessToken: 'old-access', refreshToken: 'old-refresh'),
    );
  });

  (ApiClient, _Adapter) client(Reply Function(RequestOptions) handler) {
    final adapter = _Adapter(handler);
    final options = BaseOptions(baseUrl: 'http://api.test');
    final dio = Dio(options)..httpClientAdapter = adapter;
    final refreshDio = Dio(options)..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(dio: dio, refreshDio: refreshDio, tokenStorage: tokens),
    );
    return (ApiClient(dio), adapter);
  }

  test('a file comes back as its bytes', () async {
    final (api, adapter) = client((_) => pdf('%PDF-1.7'));

    final bytes = await api.getBytes(
      '/clients/c1/invoices/i1/pdf',
      query: {'language': 'en'},
      expectedType: 'application/pdf',
    );

    expect(utf8.decode(bytes), '%PDF-1.7');
    expect(adapter.requests.single.queryParameters, {'language': 'en'});
  });

  test('a refusal reads its JSON key, though it came as bytes', () async {
    final (api, _) = client((_) => json(404, 'invoices.not_found'));

    await expectLater(
      api.getBytes('/x/pdf', expectedType: 'application/pdf'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.key, 'key', 'invoices.not_found')
            .having((e) => e.statusCode, 'statusCode', 404),
      ),
    );
  });

  test('an expired token is refreshed and the file fetched again', () async {
    final (api, adapter) = client(
      (options) => switch (options.path) {
        '/auth/refresh' => json(200, 'auth.tokens_refreshed'),
        _ when options.headers['Authorization'] == 'Bearer new-access' => pdf(
          '%PDF fresh',
        ),
        _ => json(401, 'auth.invalid_access_token'),
      },
    );

    final bytes = await api.getBytes('/x/pdf', expectedType: 'application/pdf');

    expect(utf8.decode(bytes), '%PDF fresh');
    expect(adapter.requests.where((r) => r.path == '/auth/refresh').length, 1);
  });

  test('something other than the expected file is refused', () async {
    final (api, _) = client((_) => (200, 'text/html', utf8.encode('<html>')));

    await expectLater(
      api.getBytes('/x/pdf', expectedType: 'application/pdf'),
      throwsA(isA<ApiException>()),
    );
  });
}
