import '../../domain/entities/app_notification.dart';

abstract final class NotificationModel {
  static AppNotification fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    type: json['type'] as String? ?? '',
    params: switch (json['params']) {
      final Map<Object?, Object?> map => map.cast<String, Object?>(),
      _ => const {},
    },
    clientId: json['clientId'] as String?,
    accountName: json['accountName'] as String?,
    entity: NotificationEntity.fromWire(json['entityType'] as String?),
    entityId: json['entityId'] as String?,
    isRead: json['isRead'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}
