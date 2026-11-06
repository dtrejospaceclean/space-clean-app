import '../../../../core/network/api_client.dart';
import '../../domain/entities/chat.dart';
import '../models/chat_models.dart';

/// Talks to the server's chat endpoints. Throws `ApiException`.
class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._api);

  final ApiClient _api;

  Future<ChatCredentials> credentials() async => ChatModels.credentials(
    await _api.post('/me/chat/token') as Map<String, dynamic>,
  );

  Future<ChatChannelRef> openChannel(ChatTarget target) async {
    final data = switch (target) {
      AccountChat(:final clientId) => await _api.post(
        '/clients/$clientId/chat',
      ),
      JobChat(:final clientId, :final jobId) => await _api.post(
        '/clients/$clientId/jobs/$jobId/chat',
      ),
      ComplaintChat(:final clientId, :final complaintId) => await _api.post(
        '/clients/$clientId/complaints/$complaintId/chat',
      ),
      DirectChat(:final userId) => await _api.post(
        '/me/chat/direct',
        body: {'userId': userId},
      ),
    };
    return ChatModels.channel(data as Map<String, dynamic>);
  }

  Future<List<ChatContact>> contacts() async => [
    for (final row in await _api.get('/me/chat/contacts') as List<dynamic>)
      ChatModels.contact(row as Map<String, dynamic>),
  ];
}
