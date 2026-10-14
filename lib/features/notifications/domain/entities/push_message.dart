import 'app_notification.dart';

/// Who sent a push. One Firebase project carries ours and, later, Stream
/// Chat's, so every handler routes by this first.
enum PushSource {
  /// Ours: `data.source == 'spclean'`, about a row in the inbox.
  spclean,

  /// Stream Chat's (`data.sender == 'stream.chat'`); not handled yet.
  streamChat,

  other;

  static PushSource of(Map<String, Object?> data) => switch (data) {
    {'source': 'spclean'} => spclean,
    {'sender': 'stream.chat'} => streamChat,
    _ => other,
  };
}

/// A push as it reached the phone: the server's words for it (already in
/// the device's language) and what it's about.
class PushMessage {
  const PushMessage({
    required this.source,
    this.notificationId,
    this.clientId,
    this.entity = NotificationEntity.unknown,
    this.entityId,
    this.title,
    this.body,
  });

  /// From a push's `data` (all strings) and its visible text.
  factory PushMessage.fromData(
    Map<String, Object?> data, {
    String? title,
    String? body,
  }) {
    String? text(String key) => switch (data[key]) {
      final String s when s.isNotEmpty => s,
      _ => null,
    };
    return PushMessage(
      source: PushSource.of(data),
      notificationId: text('notificationId'),
      clientId: text('clientId'),
      entity: NotificationEntity.fromWire(text('entityType')),
      entityId: text('entityId'),
      title: title,
      body: body,
    );
  }

  final PushSource source;

  /// The inbox row it announces.
  final String? notificationId;
  final String? clientId;
  final NotificationEntity entity;
  final String? entityId;
  final String? title;
  final String? body;

  /// The `data` it was built from, to carry it through a tap.
  Map<String, String> get data => {
    if (source == PushSource.spclean) 'source': 'spclean',
    'notificationId': ?notificationId,
    'clientId': ?clientId,
    if (entity != NotificationEntity.unknown) 'entityType': entity.wire,
    'entityId': ?entityId,
  };
}
