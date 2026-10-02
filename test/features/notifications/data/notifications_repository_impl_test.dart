import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/notifications/data/repositories/notifications_repository_impl.dart';

void main() {
  test('counts a placeholder 3 until the API has notifications', () async {
    expect(await const NotificationsRepositoryImpl().unreadCount(), 3);
  });
}
