import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Thin wrapper over [Dio] that unwraps the `{ success, message, data, errors, statusCode }`
/// envelope and turns every failure into an [ApiException].
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// Set on requests that must not carry the access token or trigger a refresh.
  static const skipAuth = 'skipAuth';

  Future<Object?> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query));

  /// A file rather than an envelope (e.g. a PDF). A refusal still comes as
  /// the usual JSON error, so it throws like any other call; a success that
  /// isn't the [expectedType] is refused as an unknown error.
  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? query,
    required String expectedType,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        queryParameters: query,
        options: Options(responseType: ResponseType.bytes),
      );
      final type = response.headers.value(Headers.contentTypeHeader) ?? '';
      if (!type.startsWith(expectedType)) {
        throw ApiException(
          key: 'errors.unknown',
          statusCode: response.statusCode ?? 0,
        );
      }
      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Object?> post(
    String path, {
    Object? body,
    bool authenticated = true,
  }) => _send(
    () => _dio.post<Object?>(
      path,
      data: body,
      options: Options(extra: {skipAuth: !authenticated}),
    ),
  );

  Future<Object?> patch(String path, {Object? body}) =>
      _send(() => _dio.patch<Object?>(path, data: body));

  Future<Object?> put(String path, {Object? body}) =>
      _send(() => _dio.put<Object?>(path, data: body));

  Future<Object?> delete(String path) =>
      _send(() => _dio.delete<Object?>(path));

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    try {
      final response = await request();
      return unwrapEnvelope(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

/// Returns the envelope's `data`. Dio already rejected statuses >= 400.
Object? unwrapEnvelope(Object? body) {
  if (body is Map && body.containsKey('success')) return body['data'];
  return body;
}
