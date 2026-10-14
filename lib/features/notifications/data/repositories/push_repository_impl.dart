import 'dart:io';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/push_message.dart';
import '../../domain/repositories/push_repository.dart';
import '../datasources/devices_remote_data_source.dart';
import '../datasources/firebase_push_source.dart';

class PushRepositoryImpl implements PushRepository {
  const PushRepositoryImpl(this._push, this._devices);

  final FirebasePushSource _push;
  final DevicesRemoteDataSource _devices;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<bool> requestPermission() => _push.requestPermission();

  @override
  Future<void> prepareChannel(String channelName) =>
      _push.prepareChannel(channelName);

  @override
  Future<String?> token() => _push.token();

  @override
  Stream<String> get tokenRefreshes => _push.tokenRefreshes;

  @override
  Stream<PushMessage> get received => _push.received;

  @override
  Stream<PushMessage> get opened => _push.opened;

  @override
  Future<PushMessage?> launchMessage() => _push.launchMessage();

  @override
  Future<void> show(PushMessage message) => _push.show(message);

  @override
  Future<void> registerDevice({
    required String token,
    required String language,
  }) => _guard(
    () => _devices.register(
      token: token,
      platform: Platform.isIOS ? 'ios' : 'android',
      language: language,
    ),
  );

  @override
  Future<void> unregisterDevice(String token) =>
      _guard(() => _devices.unregister(token));

  @override
  Future<void> forgetToken() => _push.forgetToken();
}

/// When Firebase couldn't start: no token, nothing arrives, nothing to tell
/// the server. The inbox still works.
class DisabledPushRepository implements PushRepository {
  const DisabledPushRepository();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> prepareChannel(String channelName) async {}

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Stream<PushMessage> get received => const Stream.empty();

  @override
  Stream<PushMessage> get opened => const Stream.empty();

  @override
  Future<PushMessage?> launchMessage() async => null;

  @override
  Future<void> show(PushMessage message) async {}

  @override
  Future<void> registerDevice({
    required String token,
    required String language,
  }) async {}

  @override
  Future<void> unregisterDevice(String token) async {}

  @override
  Future<void> forgetToken() async {}
}
