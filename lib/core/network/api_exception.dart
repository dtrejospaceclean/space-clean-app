import 'package:dio/dio.dart';

import '../error/failures.dart';

/// One failed validation rule on one field, as sent in the envelope's `errors`.
class ApiFieldError {
  const ApiFieldError({
    required this.key,
    required this.message,
    this.params = const {},
  });

  factory ApiFieldError.fromJson(Map<String, dynamic> json) => ApiFieldError(
    key: json['key'] as String? ?? 'validation.failed',
    message: json['message'] as String? ?? '',
    params: (json['params'] as Map?)?.cast<String, dynamic>() ?? const {},
  );

  /// Translation key, e.g. `validation.min_length`.
  final String key;

  /// English default from the server. Only a fallback.
  final String message;

  /// Rule arguments in order: `constraint1`, `constraint2`, …
  final Map<String, dynamic> params;
}

/// A failed API call. [key] is a translation key, never display text.
class ApiException implements Exception {
  const ApiException({
    required this.key,
    required this.statusCode,
    this.fieldErrors = const {},
  });

  factory ApiException.fromDioException(DioException error) {
    final response = error.response;
    if (response == null) {
      return const ApiException(key: NetworkFailure.key, statusCode: 0);
    }
    final body = response.data;
    if (body is! Map) {
      return ApiException(
        key: _fallbackKey(response.statusCode),
        statusCode: response.statusCode ?? 0,
      );
    }
    final rawErrors = body['errors'];
    return ApiException(
      key: body['message'] as String? ?? _fallbackKey(response.statusCode),
      statusCode: body['statusCode'] as int? ?? response.statusCode ?? 0,
      fieldErrors: rawErrors is Map
          ? {
              for (final MapEntry(:key, :value) in rawErrors.entries)
                key as String: [
                  for (final e in value as List)
                    ApiFieldError.fromJson((e as Map).cast<String, dynamic>()),
                ],
            }
          : const {},
    );
  }

  final String key;
  final int statusCode;

  /// Keyed by field path as sent in the request body, e.g. `lineItems.0.quantity`.
  final Map<String, List<ApiFieldError>> fieldErrors;

  /// Converts this transport error into a domain [Failure].
  Failure toFailure() => switch (this) {
    ApiException(statusCode: 0) => const NetworkFailure(),
    ApiException(statusCode: 401) => UnauthorizedFailure(key),
    ApiException(:final fieldErrors) when fieldErrors.isNotEmpty =>
      ValidationFailure(key, {
        for (final MapEntry(:key, :value) in fieldErrors.entries)
          key: [
            for (final e in value)
              FieldError(
                key: e.key,
                fallbackMessage: e.message,
                params: e.params,
              ),
          ],
      }),
    _ => ServerFailure(key, statusCode: statusCode),
  };

  static String _fallbackKey(int? status) => switch (status) {
    404 => 'errors.not_found',
    429 => 'errors.too_many_requests',
    final s? when s >= 500 => 'errors.internal',
    _ => 'errors.unknown',
  };

  @override
  String toString() => 'ApiException($statusCode, $key)';
}
