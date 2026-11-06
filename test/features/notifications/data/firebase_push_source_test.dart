import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/notifications/data/datasources/firebase_push_source.dart';

class _FakeMessaging extends Fake implements FirebaseMessaging {
  _FakeMessaging({required this.apnsAfter});

  /// How many times APNs has no token yet; null means it never answers.
  final int? apnsAfter;
  int apnsAsks = 0;
  int tokenAsks = 0;

  @override
  Future<String?> getAPNSToken() async {
    apnsAsks++;
    final after = apnsAfter;
    return after != null && apnsAsks > after ? 'apns' : null;
  }

  @override
  Future<String?> getToken({
    String? serviceWorkerScriptPath,
    String? vapidKey,
  }) async {
    tokenAsks++;
    return 'fcm';
  }
}

void main() {
  FirebasePushSource source(FirebaseMessaging messaging) => FirebasePushSource(
    messaging: messaging,
    apnsTimeout: const Duration(milliseconds: 200),
  );

  group('on iOS', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('waits for APNs before asking for the token', () async {
      final messaging = _FakeMessaging(apnsAfter: 2);

      expect(await source(messaging).token(), 'fcm');
      expect(messaging.apnsAsks, 3);
      expect(messaging.tokenAsks, 1);
    });

    test('has no token when APNs never answers', () async {
      final messaging = _FakeMessaging(apnsAfter: null);

      expect(await source(messaging).token(), isNull);
      expect(messaging.tokenAsks, 0);
    });
  });

  test('on Android, asks for the token without APNs', () async {
    final messaging = _FakeMessaging(apnsAfter: null);

    expect(await source(messaging).token(), 'fcm');
    expect(messaging.apnsAsks, 0);
  });
}
