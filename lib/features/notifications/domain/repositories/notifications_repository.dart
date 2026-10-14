import '../entities/app_notification.dart';

/// The signed-in user's notifications (`/me/notifications`). Throws a
/// `Failure` on error.
abstract interface class NotificationsRepository {
  /// How many of the signed-in user's notifications are unread.
  Future<int> unreadCount();

  /// The latest ones, newest first.
  Future<NotificationPage> getNotifications();

  /// Marks one read; reading it again keeps it read.
  Future<AppNotification> markRead(String id);

  /// Marks every one read; returns how many were unread.
  Future<int> markAllRead();
}
