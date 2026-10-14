import '../../../../core/network/api_client.dart';
import '../../domain/entities/app_notification.dart';
import '../models/notification_model.dart';

/// Talks to `/me/notifications`. Throws `ApiException`.
class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._api);

  final ApiClient _api;

  static const _path = '/me/notifications';

  /// The API's largest page: older ones beyond it aren't worth a scroll.
  static const pageSize = 100;

  Future<int> unreadCount() async =>
      switch (await _api.get('$_path/unread-count')) {
        {'count': final num count} => count.toInt(),
        _ => 0,
      };

  Future<NotificationPage> getNotifications() async {
    final data =
        await _api.get(_path, query: {'page': 1, 'pageSize': pageSize}) as Map;
    return NotificationPage(
      items: [
        for (final item in data['items'] as List)
          NotificationModel.fromJson((item as Map).cast<String, dynamic>()),
      ],
      hasMore: switch (data['meta']) {
        {'hasNextPage': true} => true,
        _ => false,
      },
    );
  }

  Future<AppNotification> markRead(String id) async =>
      NotificationModel.fromJson(
        (await _api.post('$_path/$id/read') as Map).cast<String, dynamic>(),
      );

  Future<int> markAllRead() async =>
      switch (await _api.post('$_path/read-all')) {
        {'count': final num count} => count.toInt(),
        _ => 0,
      };
}
