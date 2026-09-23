import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_client.dart';

/// Attaches the bearer token and, on an expired/missing access token, refreshes
/// once and replays the request. Concurrent 401s share a single refresh call.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._dio,
    required this._refreshDio,
    required this._tokenStorage,
  });

  final Dio _dio;

  /// Has no interceptors, so a failing refresh can't recurse.
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;

  Future<AuthTokens?>? _refreshing;

  static const _retriedKey = 'authRetried';
  static const _refreshableKeys = {
    'auth.invalid_access_token',
    'auth.missing_token',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[ApiClient.skipAuth] != true) {
      final tokens = await _tokenStorage.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final body = err.response?.data;
    final key = body is Map ? body['message'] : null;
    final canRefresh =
        err.response?.statusCode == 401 &&
        _refreshableKeys.contains(key) &&
        options.extra[ApiClient.skipAuth] != true &&
        options.extra[_retriedKey] != true;
    if (!canRefresh) return handler.next(err);

    // Another request may already have refreshed while this one was in flight.
    final current = await _tokenStorage.read();
    final sentHeader = options.headers['Authorization'];
    final alreadyRefreshed =
        current != null && sentHeader != 'Bearer ${current.accessToken}';
    final tokens = alreadyRefreshed ? current : await _refresh();
    if (tokens == null) return handler.next(err);

    try {
      options.extra[_retriedKey] = true;
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<AuthTokens?> _refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<AuthTokens?> _doRefresh() async {
    final current = await _tokenStorage.read();
    if (current == null) return null;
    try {
      final response = await _refreshDio.post<Object?>(
        '/auth/refresh',
        data: {'refreshToken': current.refreshToken},
      );
      final data = unwrapEnvelope(response.data) as Map;
      final tokens = AuthTokens.fromJson(data.cast<String, dynamic>());
      await _tokenStorage.save(tokens);
      return tokens;
    } on DioException catch (e) {
      // A network failure leaves the session alone; only a rejected refresh ends it.
      if (e.response?.statusCode == 401) {
        await _tokenStorage.expireSession();
      }
      return null;
    }
  }
}
