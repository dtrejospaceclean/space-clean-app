import '../entities/chat.dart';

/// The server's side of chat: credentials for the chat service, the
/// conversations the user may open and who they may message. The messages
/// themselves go straight to the chat service. Throws a `Failure`; a 503
/// `chat.unavailable` means chat isn't set up on the server.
abstract interface class ChatRepository {
  Future<ChatCredentials> credentials();

  Future<ChatChannelRef> openChannel(ChatTarget target);

  Future<List<ChatContact>> contacts();
}
