import '../../../../core/usecase/usecase.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

/// Signs the user in to the chat service. Also keeps their name and photo
/// there current, so it runs on every sign-in and app start.
class GetChatCredentials implements UseCase<ChatCredentials, NoParams> {
  const GetChatCredentials(this._repository);

  final ChatRepository _repository;

  @override
  Future<ChatCredentials> call(NoParams params) => _repository.credentials();
}

class OpenChatChannel implements UseCase<ChatChannelRef, ChatTarget> {
  const OpenChatChannel(this._repository);

  final ChatRepository _repository;

  @override
  Future<ChatChannelRef> call(ChatTarget target) =>
      _repository.openChannel(target);
}

class GetChatContacts implements UseCase<List<ChatContact>, NoParams> {
  const GetChatContacts(this._repository);

  final ChatRepository _repository;

  @override
  Future<List<ChatContact>> call(NoParams params) => _repository.contacts();
}
