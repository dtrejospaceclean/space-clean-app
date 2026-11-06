/// What the app needs to sign in to the chat service (Stream) as the
/// signed-in user: `POST /me/chat/token`. The token lasts a day; the chat
/// client asks for a new one when it runs out.
class ChatCredentials {
  const ChatCredentials({
    required this.apiKey,
    required this.userId,
    required this.token,
    this.expiresAt,
  });

  final String apiKey;

  /// Our user id, which is also the chat user's id.
  final String userId;
  final String token;
  final DateTime? expiresAt;
}

/// A conversation to open. The server creates it if it's missing and adds
/// the user to it, after checking they may see what it's about.
sealed class ChatTarget {
  const ChatTarget();
}

/// The account's channel: everyone on its team, the client's people too.
final class AccountChat extends ChatTarget {
  const AccountChat(this.clientId);

  final String clientId;
}

/// A job's thread: its crew and whoever opens it (`jobs.view`).
final class JobChat extends ChatTarget {
  const JobChat({required this.clientId, required this.jobId});

  final String clientId;
  final String jobId;
}

/// A complaint's thread (`complaints.view`).
final class ComplaintChat extends ChatTarget {
  const ComplaintChat({required this.clientId, required this.complaintId});

  final String clientId;
  final String complaintId;
}

/// A one-to-one conversation with [userId].
final class DirectChat extends ChatTarget {
  const DirectChat(this.userId);

  final String userId;
}

/// A channel on the chat service, as `type:id` (its cid).
class ChatChannelRef {
  const ChatChannelRef({required this.type, required this.id});

  final String type;
  final String id;

  String get cid => '$type:$id';
}

/// Someone the user may start a direct conversation with: people who share
/// an account with them (everyone, for owners and account managers).
class ChatContact {
  const ChatContact({required this.id, required this.name, this.photoUrl});

  final String id;
  final String name;
  final String? photoUrl;
}

/// What a channel is about, from the custom data the server gives it.
enum ChatChannelKind {
  account,
  job,
  complaint,
  direct,
  unknown;

  static ChatChannelKind fromWire(Object? value) => switch (value) {
    'account' => account,
    'job' => job,
    'complaint' => complaint,
    'direct' => direct,
    _ => unknown,
  };
}

/// A channel's custom data: what it's about and in which account.
class ChatChannelInfo {
  const ChatChannelInfo({
    this.kind = ChatChannelKind.unknown,
    this.clientId,
    this.jobId,
    this.complaintId,
  });

  factory ChatChannelInfo.fromData(Map<String, Object?> data) {
    String? text(String key) => switch (data[key]) {
      final String s when s.isNotEmpty => s,
      _ => null,
    };
    return ChatChannelInfo(
      kind: ChatChannelKind.fromWire(data['kind']),
      clientId: text('clientId'),
      jobId: text('jobId'),
      complaintId: text('complaintId'),
    );
  }

  final ChatChannelKind kind;

  /// The account it belongs to; null for direct conversations.
  final String? clientId;
  final String? jobId;
  final String? complaintId;
}

/// A chat message turned into a task or a complaint, which keeps its id
/// (`externalMessageId`) so the record links back to the conversation.
class ChatMessageRef {
  const ChatMessageRef({
    required this.id,
    required this.text,
    this.authorName,
    this.jobId,
  });

  final String id;
  final String text;
  final String? authorName;

  /// The job the conversation is about, for a complaint.
  final String? jobId;

  /// Longest title tasks and complaints take.
  static const maxTitle = 200;

  /// The message's first line, cut to fit a title.
  String get suggestedTitle {
    final firstLine = text.trim().split('\n').first.trim();
    if (firstLine.length <= maxTitle) return firstLine;
    return '${firstLine.substring(0, maxTitle - 1).trimRight()}…';
  }
}
