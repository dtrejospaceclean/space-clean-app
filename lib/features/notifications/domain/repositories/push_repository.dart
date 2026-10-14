import '../entities/push_message.dart';

/// Push notifications on this phone (Firebase Cloud Messaging) and the
/// server's record of which phones a user has (`/me/devices`). Server calls
/// throw a `Failure`.
abstract interface class PushRepository {
  /// Asks to show notifications (Android 13+ and iOS ask once); whether
  /// they're allowed.
  Future<bool> requestPermission();

  /// Creates the Android channel pushes arrive on, named [channelName] in
  /// Settings. Safe to repeat; it renames the channel.
  Future<void> prepareChannel(String channelName);

  /// This install's push token; null when there isn't one.
  Future<String?> token();

  /// New tokens, when Firebase replaces this install's.
  Stream<String> get tokenRefreshes;

  /// Pushes that arrive while the app is open (the OS shows none then).
  Stream<PushMessage> get received;

  /// Pushes the user tapped while the app was running or in the background.
  Stream<PushMessage> get opened;

  /// The push the user tapped to launch the app, if that's how it started.
  Future<PushMessage?> launchMessage();

  /// Shows [message] the way the OS would while the app is closed.
  Future<void> show(PushMessage message);

  /// Sends [token]'s pushes to the signed-in user, worded in [language]
  /// (`en`/`es`). Repeating it updates the language.
  Future<void> registerDevice({
    required String token,
    required String language,
  });

  /// Stops the signed-in user's pushes to [token].
  Future<void> unregisterDevice(String token);

  /// Drops this install's token, so nothing sent to it arrives any more.
  Future<void> forgetToken();
}
