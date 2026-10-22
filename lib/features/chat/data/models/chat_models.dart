import '../../domain/entities/chat.dart';

abstract final class ChatModels {
  static ChatCredentials credentials(Map<String, dynamic> json) =>
      ChatCredentials(
        apiKey: json['apiKey'] as String,
        userId: json['userId'] as String,
        token: json['token'] as String,
        expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
      );

  /// `{ cid, type, id }`; the cid alone is enough.
  static ChatChannelRef channel(Map<String, dynamic> json) {
    final cid = json['cid'] as String? ?? '';
    final colon = cid.indexOf(':');
    return ChatChannelRef(
      type: json['type'] as String? ?? cid.substring(0, colon),
      id: json['id'] as String? ?? cid.substring(colon + 1),
    );
  }

  static ChatContact contact(Map<String, dynamic> json) => ChatContact(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    photoUrl: json['photoUrl'] as String?,
  );
}
