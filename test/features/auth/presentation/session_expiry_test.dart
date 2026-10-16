import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_cln_app/app.dart';
import 'package:sp_cln_app/core/di/network_providers.dart';
import 'package:sp_cln_app/core/network/auth_interceptor.dart';
import 'package:sp_cln_app/core/refresh/live_data.dart';
import 'package:sp_cln_app/core/storage/preferences.dart';
import 'package:sp_cln_app/features/auth/presentation/screens/login_screen.dart';
import 'package:sp_cln_app/features/jobs/presentation/controllers/jobs_providers.dart';

import '../../../helpers/test_app.dart';

typedef Reply = (int status, Object? body);

/// Answers from [handler] in place of the network.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

  Reply Function(RequestOptions options) handler;
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    final (status, body) = handler(options);
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

Reply _ok(Object? data) =>
    (200, {'success': true, 'message': 'ok', 'data': data, 'statusCode': 200});

Reply _fail(int status, String key) => (
  status,
  {'success': false, 'message': key, 'data': null, 'statusCode': status},
);

const _me = {
  'id': 'u1',
  'email': 'ana@example.com',
  'name': 'Ana Pérez',
  'userType': 'internal',
  'isActive': true,
  'roles': [
    {'id': 'r1', 'name': 'owner'},
  ],
};

/// A signed-in user whose tokens are then refused: everything below the
/// HTTP layer is the real app (interceptor, token storage, repositories).
Future<_Adapter> _pumpSignedIn(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  FlutterSecureStorage.setMockInitialValues({
    'auth.accessToken': 'access',
    'auth.refreshToken': 'refresh',
  });
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final adapter = _Adapter(
    (o) => switch (o.path) {
      '/auth/me' => _ok(_me),
      '/clients' => _ok({
        'items': <Object>[],
        'meta': {'page': 1, 'pageSize': 20, 'total': 0, 'totalPages': 0},
      }),
      _ => _ok(<Object>[]),
    },
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(() => testNow),
        liveRefreshIntervalProvider.overrideWithValue(null),
        dioProvider.overrideWith((ref) {
          final options = BaseOptions(baseUrl: 'http://api.test');
          final dio = Dio(options)..httpClientAdapter = adapter;
          dio.interceptors.add(
            AuthInterceptor(
              dio: dio,
              refreshDio: Dio(options)..httpClientAdapter = adapter,
              tokenStorage: ref.watch(tokenStorageProvider),
            ),
          );
          return dio;
        }),
      ],
      retry: (_, _) => null,
      observers: const [LiveDataObserver()],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

Reply Function(RequestOptions) _refused(Reply refresh) =>
    (o) => o.path == '/auth/refresh'
    ? refresh
    : _fail(401, 'auth.invalid_access_token');

/// Opens Me → Users, which loads from the server.
Future<void> _openUsers(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Me'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Users'));
  await tester.pumpAndSettle();
}

void _expectSignIn() {
  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.text('Your session expired. Sign in again.'), findsOneWidget);
}

void main() {
  testWidgets('a refused refresh mid-session goes back to sign-in', (
    tester,
  ) async {
    final adapter = await _pumpSignedIn(tester);
    adapter.handler = _refused(_fail(401, 'auth.invalid_refresh_token'));

    await _openUsers(tester);

    expect(adapter.paths, contains('/auth/refresh'));
    _expectSignIn();
  });

  testWidgets('a refresh refused any other way goes back to sign-in', (
    tester,
  ) async {
    final adapter = await _pumpSignedIn(tester);
    adapter.handler = _refused(_fail(400, 'validation.failed'));

    await _openUsers(tester);

    _expectSignIn();
  });

  testWidgets('coming back to a dead session goes to sign-in', (tester) async {
    final adapter = await _pumpSignedIn(tester);
    adapter.handler = _refused(_fail(401, 'auth.invalid_refresh_token'));

    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();

    _expectSignIn();
  });

  testWidgets('a server that is down keeps the session and says so', (
    tester,
  ) async {
    final adapter = await _pumpSignedIn(tester);
    adapter.handler = _refused(_fail(503, 'common.service_unavailable'));

    await _openUsers(tester);

    // Still signed in, on Users, without claiming the session expired.
    expect(find.text('Your session expired. Sign in again.'), findsNothing);
    expect(find.text('Users'), findsWidgets);
  });
}
