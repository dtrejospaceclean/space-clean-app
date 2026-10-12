import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/network/api_client.dart';
import 'package:sp_cln_app/features/password_reset/data/datasources/password_reset_remote_data_source.dart';

/// Answers every request with [data] and records what was asked.
class _Answer implements HttpClientAdapter {
  _Answer([this.data]);

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

PasswordResetRemoteDataSource _remote(_Answer adapter) =>
    PasswordResetRemoteDataSource(
      ApiClient(
        Dio(BaseOptions(baseUrl: 'https://api.test'))
          ..httpClientAdapter = adapter,
      ),
    );

void main() {
  test('asks for a code by email', () async {
    final adapter = _Answer();
    await _remote(adapter).requestCode('ana@example.com');

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/auth/forgot-password');
    expect(request.data, {'email': 'ana@example.com'});
  });

  test('trades the code for a token', () async {
    final adapter = _Answer({
      'resetToken': 'abc123',
      'expiresAt': '2026-10-12T21:15:00.000Z',
    });
    final token = await _remote(adapter)
        .verifyCode(email: 'ana@example.com', code: '482913');

    final request = adapter.requests.single;
    expect(request.path, '/auth/verify-pin');
    expect(request.data, {'email': 'ana@example.com', 'pin': '482913'});
    expect(token.token, 'abc123');
    expect(token.expiresAt.toUtc(), DateTime.utc(2026, 10, 12, 21, 15));
  });

  test('sets the password with the token', () async {
    final adapter = _Answer();
    await _remote(adapter)
        .resetPassword(resetToken: 'abc123', newPassword: 'a-long-new-secret');

    final request = adapter.requests.single;
    expect(request.path, '/auth/reset-password');
    expect(request.data, {
      'resetToken': 'abc123',
      'newPassword': 'a-long-new-secret',
    });
  });
}
