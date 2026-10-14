import '../../../../core/usecase/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications implements UseCase<NotificationPage, NoParams> {
  const GetNotifications(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<NotificationPage> call(NoParams params) =>
      _repository.getNotifications();
}

/// Takes the notification's id.
class MarkNotificationRead implements UseCase<AppNotification, String> {
  const MarkNotificationRead(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<AppNotification> call(String id) => _repository.markRead(id);
}

class MarkAllNotificationsRead implements UseCase<int, NoParams> {
  const MarkAllNotificationsRead(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<int> call(NoParams params) => _repository.markAllRead();
}
