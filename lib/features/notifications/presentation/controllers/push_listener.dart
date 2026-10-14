import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/notifications_providers.dart';
import '../../domain/entities/push_message.dart';
import '../../domain/usecases/push_usecases.dart';
import '../screens/notifications_screen.dart';
import 'notifications_providers.dart';

/// Push notifications for the app's lifetime, around everything the router
/// shows. Once signed in it registers this phone (again when the language
/// or token changes, so pushes come worded in the app's language); on
/// sign-out it drops the token. Our pushes (`source: 'spclean'`) refresh
/// the unread count, show as a notification while the app is open, and on
/// a tap open what they're about, as the inbox does. Others (Stream Chat,
/// later) are left alone.
class PushListener extends ConsumerStatefulWidget {
  const PushListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushListener> createState() => _PushListenerState();
}

class _PushListenerState extends ConsumerState<PushListener> {
  final _subscriptions = <StreamSubscription<Object?>>[];

  /// Who this phone is registered for, and in which language.
  String? _userId;
  String? _language;

  /// A push tapped before the session was back (it launched the app).
  PushMessage? _pending;

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      ref.read(watchReceivedPushesProvider)().listen(_received),
      ref.read(watchOpenedPushesProvider)().listen(_opened),
      ref.read(watchPushTokenRefreshProvider)().listen((_) => _enable()),
    ]);
    ref.listenManual(
      authControllerProvider,
      (_, next) => _signedIn(switch (next.value) {
        Authenticated(:final user) => user.id,
        _ => null,
      }),
      fireImmediately: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userId != null && _language != _currentLanguage) _enable();
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  String get _currentLanguage =>
      Localizations.localeOf(context).languageCode == 'es' ? 'es' : 'en';

  void _signedIn(String? userId) {
    if (userId == _userId) return;
    final wasSignedIn = _userId != null;
    _userId = userId;
    _language = null;
    if (userId == null) {
      // Logout already told the server; an expired session can't.
      if (wasSignedIn) ref.read(disablePushProvider)(false);
      return;
    }
    // After this frame: the first build may not have Localizations yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _enable();
      if (_pending case final message?) {
        _pending = null;
        _open(message);
      }
    });
  }

  Future<void> _enable() async {
    if (_userId == null || !mounted) return;
    final language = _currentLanguage;
    _language = language;
    try {
      await ref.read(enablePushProvider)(
        EnablePushParams(
          language: language,
          channelName: AppLocalizations.of(context).pushChannelName,
        ),
      );
    } catch (error) {
      // No pushes this time; the inbox still has everything. The next
      // start tries again.
      _language = null;
      debugPrint('Push registration failed: $error');
    }
  }

  void _received(PushMessage message) {
    if (message.source != PushSource.spclean || !mounted) return;
    invalidateNotifications(ref);
    ref.read(showPushProvider)(message);
  }

  void _opened(PushMessage message) {
    if (message.source != PushSource.spclean || !mounted) return;
    if (_userId == null) {
      _pending = message;
      return;
    }
    _open(message);
  }

  void _open(PushMessage message) {
    if (message.notificationId case final id?) {
      ref
          .read(markNotificationReadProvider)(id)
          .then((_) {}, onError: (_) {})
          .whenComplete(() {
            if (mounted) invalidateNotifications(ref);
          });
    }
    final path = switch (message) {
      PushMessage(:final clientId?, :final entityId?, :final entity) =>
        entityPath(clientId: clientId, entity: entity, entityId: entityId),
      _ => null,
    };
    ref.read(appRouterProvider).go(path ?? NotificationsScreen.path);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
