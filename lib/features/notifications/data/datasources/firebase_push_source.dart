import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/push_message.dart';

/// Firebase Cloud Messaging, plus local notifications to show a push that
/// arrives while the app is open (the OS shows them only when it isn't).
class FirebasePushSource {
  FirebasePushSource({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? local,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _local = local ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;

  /// The server sends ours on this channel (`android.notification.channelId`).
  static const channelId = 'spclean_default';

  /// The status bar icon (the mark's silhouette), tinted brand orange in
  /// the shade, with the colored mark beside the text.
  static const _icon = 'ic_notification';
  static const _largeIcon = 'ic_notification_large';
  static const _color = Color(0xFFD14702);

  final _localTaps = StreamController<PushMessage>.broadcast();
  Future<void>? _ready;
  String _channelName = '';

  Future<void> _init() => _ready ??= () async {
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (_decode(response.payload) case final message?) {
          _localTaps.add(message);
        }
      },
    );
  }();

  Future<void> prepareChannel(String name) async {
    await _init();
    _channelName = name;
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            channelId,
            name,
            importance: Importance.high,
          ),
        );
  }

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional => true,
      _ => false,
    };
  }

  Future<String?> token() => _messaging.getToken();

  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  Stream<PushMessage> get received => FirebaseMessaging.onMessage.map(_message);

  Stream<PushMessage> get opened => _merge([
    FirebaseMessaging.onMessageOpenedApp.map(_message),
    _localTaps.stream,
  ]);

  Future<PushMessage?> launchMessage() async {
    if (await _messaging.getInitialMessage() case final remote?) {
      return _message(remote);
    }
    // A push shown while the app was open, tapped after it closed.
    await _init();
    final details = await _local.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return _decode(details?.notificationResponse?.payload);
    }
    return null;
  }

  Future<void> show(PushMessage message) async {
    await _init();
    await _local.show(
      id: (message.notificationId ?? '${DateTime.now()}').hashCode,
      title: message.title,
      body: message.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: _icon,
          color: _color,
          largeIcon: const DrawableResourceAndroidBitmap(_largeIcon),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> forgetToken() => _messaging.deleteToken();

  static PushMessage _message(RemoteMessage remote) => PushMessage.fromData(
    remote.data,
    title: remote.notification?.title,
    body: remote.notification?.body,
  );

  static PushMessage? _decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    return switch (jsonDecode(payload)) {
      final Map<String, dynamic> data => PushMessage.fromData(data),
      _ => null,
    };
  }
}

/// Merges broadcast streams (no extra package for one call).
Stream<T> _merge<T>(List<Stream<T>> streams) {
  final subscriptions = <StreamSubscription<T>>[];
  late final StreamController<T> controller;
  controller = StreamController<T>.broadcast(
    onListen: () {
      for (final stream in streams) {
        subscriptions.add(stream.listen(controller.add));
      }
    },
    onCancel: () async {
      for (final s in subscriptions) {
        await s.cancel();
      }
      subscriptions.clear();
    },
  );
  return controller.stream;
}
