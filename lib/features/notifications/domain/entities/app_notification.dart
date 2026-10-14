/// What a notification is about, which decides where tapping it goes.
enum NotificationEntity {
  task('task'),
  complaint('complaint'),
  job('job'),

  /// Something newer than this app: shown, but tapping opens nothing.
  unknown('');

  const NotificationEntity(this.wire);

  final String wire;

  static NotificationEntity fromWire(String? value) => values.firstWhere(
    (e) => e.wire == value && e != unknown,
    orElse: () => unknown,
  );
}

/// The kinds of notification the API sends; [type] is one of these keys.
abstract final class NotificationTypes {
  static const taskAssigned = 'notifications.task_assigned';
  static const complaintAssigned = 'notifications.complaint_assigned';
  static const complaintReported = 'notifications.complaint_reported';
  static const jobCrewAdded = 'notifications.job_crew_added';
  static const jobRescheduled = 'notifications.job_rescheduled';
  static const jobCancelled = 'notifications.job_cancelled';
}

/// Something that happened to the signed-in user (`/me/notifications`).
/// The server sends a translation key and its params, never display text,
/// so the app words it in its own language.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.createdAt,
    this.params = const {},
    this.clientId,
    this.accountName,
    this.entity = NotificationEntity.unknown,
    this.entityId,
    this.isRead = false,
  });

  final String id;

  /// A [NotificationTypes] key, or one this app doesn't know yet.
  final String type;
  final Map<String, Object?> params;

  /// The account it happened in; null for something outside one.
  final String? clientId;
  final String? accountName;
  final NotificationEntity entity;
  final String? entityId;
  final bool isRead;
  final DateTime createdAt;

  /// A text param, or null when missing or blank.
  String? text(String name) => switch (params[name]) {
    final String s when s.trim().isNotEmpty => s,
    _ => null,
  };

  /// A date param (ISO), in local time.
  DateTime? date(String name) => switch (text(name)) {
    final s? => DateTime.tryParse(s)?.toLocal(),
    _ => null,
  };

  /// Who did it; null when it wasn't a person (or they're unknown).
  String? get actorName => text('actorName');

  /// Whether tapping it can open what it's about.
  bool get canOpen =>
      clientId != null &&
      entityId != null &&
      entity != NotificationEntity.unknown;
}

/// The latest notifications, newest first. [hasMore] when older ones exist
/// beyond them.
class NotificationPage {
  const NotificationPage({required this.items, this.hasMore = false});

  final List<AppNotification> items;
  final bool hasMore;

  int get unread => items.where((n) => !n.isRead).length;
}
