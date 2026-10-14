import '../../../../core/network/api_exception.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<int> unreadCount() => _guard(_remote.unreadCount);

  @override
  Future<NotificationPage> getNotifications() =>
      _guard(_remote.getNotifications);

  @override
  Future<AppNotification> markRead(String id) =>
      _guard(() => _remote.markRead(id));

  @override
  Future<int> markAllRead() => _guard(_remote.markAllRead);
}
