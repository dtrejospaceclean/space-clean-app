/// Throws a `Failure` on error.
abstract interface class NotificationsRepository {
  /// How many of the signed-in user's notifications are unread.
  Future<int> unreadCount();
}
