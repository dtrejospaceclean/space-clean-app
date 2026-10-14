import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/push_message.dart';
import '../repositories/push_repository.dart';

class EnablePushParams {
  const EnablePushParams({required this.language, required this.channelName});

  /// `en` or `es`: the server words pushes in it.
  final String language;

  /// The Android channel's name in Settings.
  final String channelName;
}

/// After sign-in (and when the token or language changes): asks to show
/// notifications and tells the server to push to this phone. Returns the
/// token, or null when notifications are refused or unavailable. Throws a
/// `Failure` when the server can't be told.
class EnablePush implements UseCase<String?, EnablePushParams> {
  const EnablePush(this._repository);

  final PushRepository _repository;

  @override
  Future<String?> call(EnablePushParams params) async {
    await _repository.prepareChannel(params.channelName);
    if (!await _repository.requestPermission()) return null;
    final token = await _repository.token();
    if (token == null) return null;
    await _repository.registerDevice(token: token, language: params.language);
    return token;
  }
}

/// On sign-out: stops this phone's pushes. [tellServer] while the session
/// still works (logging out); either way the token is dropped, so pushes
/// still addressed to it fail and the server forgets it. Never throws.
class DisablePush implements UseCase<void, bool> {
  const DisablePush(this._repository);

  final PushRepository _repository;

  @override
  Future<void> call(bool tellServer) async {
    try {
      if (tellServer) {
        if (await _repository.token() case final token?) {
          await _repository.unregisterDevice(token);
        }
      }
    } on Failure {
      // Dropping the token below stops the pushes anyway.
    }
    try {
      await _repository.forgetToken();
    } catch (_) {
      // Nothing to drop.
    }
  }
}

/// Stream use cases, so they don't fit the `Future`-based `UseCase`.
class WatchReceivedPushes {
  const WatchReceivedPushes(this._repository);

  final PushRepository _repository;

  Stream<PushMessage> call() => _repository.received;
}

/// Taps on pushes, starting with the one that launched the app.
class WatchOpenedPushes {
  const WatchOpenedPushes(this._repository);

  final PushRepository _repository;

  Stream<PushMessage> call() async* {
    if (await _repository.launchMessage() case final message?) yield message;
    yield* _repository.opened;
  }
}

class WatchPushTokenRefresh {
  const WatchPushTokenRefresh(this._repository);

  final PushRepository _repository;

  Stream<String> call() => _repository.tokenRefreshes;
}

class ShowPush implements UseCase<void, PushMessage> {
  const ShowPush(this._repository);

  final PushRepository _repository;

  @override
  Future<void> call(PushMessage message) => _repository.show(message);
}
