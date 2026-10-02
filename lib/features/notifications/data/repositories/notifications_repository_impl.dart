import '../../domain/repositories/notifications_repository.dart';

/// The backend has no notification endpoints yet. Until it does, this
/// returns a fixed placeholder so the avatar's badge can be seen; replace
/// it with a remote data source once the API contract is defined (don't
/// guess it).
class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl();

  /// TODO(notifications): placeholder until the backend has the feature.
  static const placeholderUnread = 3;

  @override
  Future<int> unreadCount() async => placeholderUnread;
}
