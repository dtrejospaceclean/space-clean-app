import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final storage = TokenStorage(const FlutterSecureStorage());
  ref.onDispose(storage.dispose);
  return storage;
});

BaseOptions _baseOptions([String baseUrl = AppConfig.apiBaseUrl]) =>
    BaseOptions(
      baseUrl: baseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    );

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions());
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      refreshDio: Dio(_baseOptions()),
      tokenStorage: ref.watch(tokenStorageProvider),
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);

/// The WhatsApp bot's service. It takes our access token (owners only) and
/// refreshes it through our own API, but answers without our envelope, so
/// it has no [ApiClient].
final botDioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions(AppConfig.botBaseUrl));
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      refreshDio: Dio(_baseOptions()),
      tokenStorage: ref.watch(tokenStorageProvider),
      endsSessionOnRefusedReplay: false,
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});
