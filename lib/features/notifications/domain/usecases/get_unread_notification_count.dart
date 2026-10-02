import '../../../../core/usecase/usecase.dart';
import '../repositories/notifications_repository.dart';

class GetUnreadNotificationCount implements UseCase<int, NoParams> {
  const GetUnreadNotificationCount(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<int> call(NoParams params) => _repository.unreadCount();
}
