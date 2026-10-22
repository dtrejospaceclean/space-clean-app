import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/chat_remote_data_source.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/usecases/chat_usecases.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) =>
      ChatRepositoryImpl(ChatRemoteDataSource(ref.watch(apiClientProvider))),
);

final getChatCredentialsProvider = Provider(
  (ref) => GetChatCredentials(ref.watch(chatRepositoryProvider)),
);
final openChatChannelProvider = Provider(
  (ref) => OpenChatChannel(ref.watch(chatRepositoryProvider)),
);
final getChatContactsProvider = Provider(
  (ref) => GetChatContacts(ref.watch(chatRepositoryProvider)),
);

/// Makes the chat service's client for an API key. The chat screens are
/// Stream's own widgets, so they talk to it directly.
final chatClientFactoryProvider = Provider<StreamChatClient Function(String)>(
  (ref) =>
      (apiKey) => StreamChatClient(apiKey, logLevel: Level.WARNING),
);

/// The push provider set up in the Stream dashboard (Chat → Push
/// Notifications → Firebase), which chat pushes to this phone go through.
const chatPushProviderName = 'firebase';
