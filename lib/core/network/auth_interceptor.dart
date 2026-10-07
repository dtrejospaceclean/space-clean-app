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

  Future<_Refresh>? _refreshing;

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
    // Signed out meanwhile: nothing to refresh, and nothing to end.
    if (current == null) return handler.next(err);
    final sentHeader = options.headers['Authorization'];
    final _Refresh result = sentHeader != 'Bearer ${current.accessToken}'
        ? _Refreshed(current)
        : await _refresh();

    switch (result) {
      case _Refreshed():
        try {
          options.extra[_retriedKey] = true;
          // A FormData body is spent once sent; replay a fresh copy.
          if (options.data case final FormData form) {
            options.data = form.clone();
          }
          handler.resolve(await _dio.fetch<Object?>(options));
        } on DioException catch (e) {
          // Refused even with fresh tokens: they're no good either.
          if (e.response?.statusCode == 401) {
            await _tokenStorage.expireSession();
          }
          handler.next(e);
        }
      case _Rejected():
        // The session ended in [_doRefresh]; the router goes to sign-in.
        handler.next(err);
      case _Unreachable(:final error):
        // The session is kept. Report why the refresh failed (offline, server
        // down) rather than the 401, which would read "session expired".
        handler.next(
          DioException(
            requestOptions: options,
            response: error.response,
            type: error.type,
            error: error.error,
          ),
        );
    }
  }

  Future<_Refresh> _refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<_Refresh> _doRefresh() async {
    final current = await _tokenStorage.read();
    if (current == null) return const _Rejected();
    try {
      final response = await _refreshDio.post<Object?>(
        '/auth/refresh',
        data: {'refreshToken': current.refreshToken},
      );
      final data = unwrapEnvelope(response.data) as Map;
      final tokens = AuthTokens.fromJson(data.cast<String, dynamic>());
      await _tokenStorage.save(tokens);
      return _Refreshed(tokens);
    } on DioException catch (e) {
      // Offline, a timeout, the server down or busy: try again later with
      // the same session. Any other refusal means the refresh token is dead.
      final status = e.response?.statusCode;
      final temporary =
          status == null || status >= 500 || status == 408 || status == 429;
      if (temporary) return _Unreachable(e);
      await _tokenStorage.expireSession();
      return const _Rejected();
    }
  }
}

sealed class _Refresh {
  const _Refresh();
}

final class _Refreshed extends _Refresh {
  const _Refreshed(this.tokens);
  final AuthTokens tokens;
}

/// The session is over: the server refused the refresh token (and it was
/// ended), or there was none left.
final class _Rejected extends _Refresh {
  const _Rejected();
}

/// The refresh didn't get an answer about the token.
final class _Unreachable extends _Refresh {
  const _Unreachable(this.error);
  final DioException error;
}
