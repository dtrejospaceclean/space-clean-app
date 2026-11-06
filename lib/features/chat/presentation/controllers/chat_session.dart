import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../notifications/di/notifications_providers.dart';
import '../../di/chat_providers.dart';

/// Where the signed-in user's chat connection is.
sealed class ChatSession {
  const ChatSession();
}

/// Signed out, or chat isn't set up on the server (`chat.unavailable`):
/// the app shows no chat at all.
final class ChatOff extends ChatSession {
  const ChatOff();
}

final class ChatConnecting extends ChatSession {
  const ChatConnecting();
}

final class ChatReady extends ChatSession {
  const ChatReady(this.client);

  final StreamChatClient client;
}

/// It couldn't connect (offline, server error); [ChatSessionController.retry]
/// tries again.
final class ChatFailed extends ChatSession {
  const ChatFailed(this.failure);

  final Failure? failure;
}

/// Connects the signed-in user to the chat service, and disconnects them
/// on sign-out. Chat pushes to this phone are registered with the chat
/// service once connected (and when the push token changes), and dropped
/// before disconnecting, while the chat token still works.
class ChatSessionController extends Notifier<ChatSession> {
  StreamChatClient? _client;
  String? _userId;
  String? _pushToken;
  StreamSubscription<String>? _tokenRefreshes;

  @override
  ChatSession build() {
    ref.listen(
      authControllerProvider,
      (_, next) => _signedIn(switch (next.value) {
        Authenticated(:final user) => user.id,
        _ => null,
      }),
      fireImmediately: true,
    );
    ref.onDispose(() {
      _tokenRefreshes?.cancel();
      _close(_client);
    });
    return const ChatOff();
  }

  /// Tries to connect again after a failure.
  Future<void> retry() async {
    if (_userId case final userId? when state is ChatFailed) {
      await _connect(userId);
    }
  }

  void _signedIn(String? userId) {
    if (userId == _userId) return;
    final previous = _client;
    _userId = userId;
    _client = null;
    // Not during build: the listener fires before it returns.
    scheduleMicrotask(() async {
      if (previous != null) {
        state = const ChatOff();
        await _close(previous);
      }
      if (userId != null && _userId == userId) await _connect(userId);
    });
  }

  Future<void> _connect(String userId) async {
    state = const ChatConnecting();
    StreamChatClient? client;
    try {
      final getCredentials = ref.read(getChatCredentialsProvider);
      final credentials = await getCredentials(const NoParams());
      if (_userId != userId) return;
      client = ref.read(chatClientFactoryProvider)(credentials.apiKey);
      // The first token is the one just fetched; the client asks again
      // when it runs out.
      String? first = credentials.token;
      await client.connectUserWithProvider(User(id: credentials.userId), (
        _,
      ) async {
        if (first case final token?) {
          first = null;
          return token;
        }
        return (await getCredentials(const NoParams())).token;
      });
      if (_userId != userId) {
        await client.dispose();
        return;
      }
      _client = client;
      state = ChatReady(client);
      unawaited(_registerPush(client));
    } on Failure catch (f) {
      await client?.dispose();
      if (_userId != userId) return;
      state = f.messageKey == chatUnavailableKey
          ? const ChatOff()
          : ChatFailed(f);
    } catch (error) {
      debugPrint('Chat failed to connect: $error');
      await client?.dispose();
      if (_userId == userId) state = const ChatFailed(null);
    }
  }

  Future<void> _registerPush(StreamChatClient client) async {
    if (!ref.read(pushEnabledProvider)) return;
    Future<void> add(String token) async {
      try {
        await client.addDevice(
          token,
          PushProvider.firebase,
          pushProviderName: chatPushProviderName,
        );
        _pushToken = token;
      } catch (error) {
        // Chat still works; its messages just don't push to this phone.
        debugPrint('Chat push registration failed: $error');
      }
    }

    if (await ref.read(getPushTokenProvider)(const NoParams())
        case final token?) {
      await add(token);
    }
    await _tokenRefreshes?.cancel();
    _tokenRefreshes = ref.read(watchPushTokenRefreshProvider)().listen((token) {
      if (_client == client) add(token);
    });
  }

  Future<void> _close(StreamChatClient? client) async {
    await _tokenRefreshes?.cancel();
    _tokenRefreshes = null;
    if (client == null) return;
    final token = _pushToken;
    _pushToken = null;
    try {
      if (token != null) {
        await client.removeDevice(token).timeout(const Duration(seconds: 3));
      }
    } catch (_) {
      // The phone's push token is dropped on sign-out anyway.
    }
    try {
      await client.disconnectUser(flushChatPersistence: true);
      await client.dispose();
    } catch (_) {
      // Already closed.
    }
  }
}

/// The server's answer when chat isn't configured.
const chatUnavailableKey = 'chat.unavailable';

final chatSessionProvider =
    NotifierProvider<ChatSessionController, ChatSession>(
      ChatSessionController.new,
    );

/// The connected chat client; null while there's none.
final chatClientProvider = Provider<StreamChatClient?>(
  (ref) => switch (ref.watch(chatSessionProvider)) {
    ChatReady(:final client) => client,
    _ => null,
  },
);

/// Unread chat messages across the user's conversations; 0 without chat.
final chatUnreadProvider = StreamProvider<int>((ref) {
  final client = ref.watch(chatClientProvider);
  if (client == null) return Stream.value(0);
  return client.state.totalUnreadCountStream;
});

/// The conversation on screen (its channel id), so a push about it isn't
/// shown while the user is reading it.
class OpenChatChannelController extends Notifier<String?> {
  @override
  String? build() => null;

  void opened(String channelId) => state = channelId;

  void closed(String channelId) {
    if (state == channelId) state = null;
  }
}

final openChatChannelIdProvider =
    NotifierProvider<OpenChatChannelController, String?>(
      OpenChatChannelController.new,
    );
