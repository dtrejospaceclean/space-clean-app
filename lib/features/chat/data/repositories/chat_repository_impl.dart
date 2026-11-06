import '../../../../core/network/api_exception.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._remote);

  final ChatRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<ChatCredentials> credentials() => _guard(_remote.credentials);

  @override
  Future<ChatChannelRef> openChannel(ChatTarget target) =>
      _guard(() => _remote.openChannel(target));

  @override
  Future<List<ChatContact>> contacts() => _guard(_remote.contacts);
}
