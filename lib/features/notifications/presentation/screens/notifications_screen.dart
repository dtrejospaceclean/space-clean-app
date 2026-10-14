import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/domain/priority.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/priority_label.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../clients/presentation/screens/accounts_screen.dart';
import '../../../complaints/presentation/screens/complaints_screen.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../../jobs/presentation/screens/account_jobs_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../../di/notifications_providers.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notifications_providers.dart';

/// The signed-in user's notifications, newest first, unread ones marked.
/// Tapping one marks it read and opens what it's about in its account
/// (the Accounts tab, so its links and actions all work there). Opened
/// from Me.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  static const path = '/me/notifications';

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _markingAll = false;
  Failure? _failure;

  Future<void> _markAllRead() async {
    setState(() {
      _markingAll = true;
      _failure = null;
    });
    try {
      await ref.read(markAllNotificationsReadProvider)(const NoParams());
      if (mounted) invalidateNotifications(ref);
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  void _open(AppNotification n) {
    if (!n.isRead) {
      // Opening shouldn't wait on it: a failure leaves it unread, which the
      // next load shows.
      ref
          .read(markNotificationReadProvider)(n.id)
          .then((_) {}, onError: (_) {})
          .whenComplete(() {
            if (mounted) invalidateNotifications(ref);
          });
    }
    if (notificationPath(n) case final path?) context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notifications = ref.watch(notificationsProvider);
    final hasUnread = (notifications.value?.unread ?? 0) > 0;
    final failure = _failure;
    Future<void> refresh() {
      ref.invalidate(unreadNotificationsProvider);
      return ref.refresh(notificationsProvider.future);
    }

    return SpacePage(
      title: l10n.notificationsTitle,
      onRefresh: refresh,
      actions: [
        if (hasUnread)
          CircleButton.dark(
            icon: Icons.done_all_rounded,
            tooltip: l10n.markAllRead,
            busy: _markingAll,
            onPressed: _markingAll ? null : _markAllRead,
          ),
      ],
      slivers: [
        if (failure != null)
          PageBox(top: 4, child: Notice(message: l10n.failureMessage(failure))),
        AsyncSlivers(
          value: notifications,
          onRetry: refresh,
          builder: (page) {
            if (page.items.isEmpty) {
              return MessageSliver(
                icon: Icons.notifications_none_rounded,
                title: l10n.noNotificationsYet,
                hint: l10n.noNotificationsYetHint,
              );
            }
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: ListCard(
                    children: [
                      for (final n in page.items)
                        NotificationRow(
                          notification: n,
                          onTap: n.canOpen ? () => _open(n) : null,
                        ),
                    ],
                  ),
                ),
                if (page.hasMore)
                  PageBox(
                    top: 8,
                    child: Text(
                      l10n.notificationsLatestOnly,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Where tapping [n] goes: its task, complaint or job, in its account's
/// stack. Null when the app can't open it.
String? notificationPath(AppNotification n) => n.canOpen
    ? entityPath(clientId: n.clientId!, entity: n.entity, entityId: n.entityId!)
    : null;

/// A task, complaint or job's page in its account's stack; null for
/// something this app doesn't know.
String? entityPath({
  required String clientId,
  required NotificationEntity entity,
  required String entityId,
}) {
  final account = '${AccountsScreen.path}/$clientId';
  return switch (entity) {
    NotificationEntity.task => '$account/${TasksScreen.route}/$entityId',
    NotificationEntity.complaint =>
      '$account/${ComplaintsScreen.route}/$entityId',
    NotificationEntity.job => '$account/${AccountJobsScreen.route}/$entityId',
    NotificationEntity.unknown => null,
  };
}

/// What happened, worded in the app's language from the API's key: "Carlos
/// Medina assigned you a task", or without a person, "You were assigned a
/// task".
String notificationHeadline(AppLocalizations l10n, AppNotification n) {
  final actor = n.actorName;
  return switch (n.type) {
    NotificationTypes.taskAssigned =>
      actor != null
          ? l10n.notifTaskAssigned(actor)
          : l10n.notifTaskAssignedNoActor,
    NotificationTypes.complaintAssigned =>
      actor != null
          ? l10n.notifComplaintAssigned(actor)
          : l10n.notifComplaintAssignedNoActor,
    NotificationTypes.complaintReported =>
      actor != null
          ? l10n.notifComplaintReported(actor)
          : l10n.notifComplaintReportedNoActor,
    NotificationTypes.jobCrewAdded =>
      actor != null
          ? l10n.notifJobCrewAdded(actor)
          : l10n.notifJobCrewAddedNoActor,
    NotificationTypes.jobRescheduled =>
      actor != null
          ? l10n.notifJobRescheduled(actor)
          : l10n.notifJobRescheduledNoActor,
    NotificationTypes.jobCancelled =>
      actor != null
          ? l10n.notifJobCancelled(actor)
          : l10n.notifJobCancelledNoActor,
    _ => l10n.notifOther,
  };
}

/// A notification as a list row: what happened, then what it's about (and
/// when, for a job), the account and when it came. Unread ones get a
/// solid badge and a dot.
class NotificationRow extends ConsumerWidget {
  const NotificationRow({super.key, required this.notification, this.onTap});

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final n = notification;
    final now = ref.watch(clockProvider)();
    final icon = switch (n.entity) {
      NotificationEntity.task => Icons.task_alt_rounded,
      NotificationEntity.complaint => Icons.report_outlined,
      NotificationEntity.job => Icons.cleaning_services_outlined,
      NotificationEntity.unknown => Icons.notifications_none_rounded,
    };
    final start = n.date('start');
    final details = [
      ?(n.text('taskTitle') ?? n.text('complaintTitle') ?? n.text('jobTitle')),
      if (start != null)
        '${context.formatDate(start)}, ${context.formatTime(start)}',
      ?n.accountName,
      _when(context, l10n, n.createdAt, now),
    ];
    return ListRow(
      leading: n.isRead ? IconBadge(icon: icon) : IconBadge.strong(icon: icon),
      title: notificationHeadline(l10n, n),
      subtitle: details.join(' · '),
      tag: n.type == NotificationTypes.complaintReported
          ? switch (n.text('priority')) {
              final p? => PriorityLabel(priority: Priority.fromWire(p)),
              null => null,
            }
          : null,
      trailing: n.isRead ? null : const _UnreadDot(),
      onTap: onTap,
    );
  }

  /// "2:15 PM" today, "Yesterday", else the date.
  static String _when(
    BuildContext context,
    AppLocalizations l10n,
    DateTime at,
    DateTime now,
  ) {
    final day = DateTime(at.year, at.month, at.day);
    final today = DateTime(now.year, now.month, now.day);
    return switch (today.difference(day).inDays) {
      0 => context.formatTime(at),
      1 => l10n.notificationYesterday,
      _ => context.formatDate(at),
    };
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).notificationUnread,
    child: Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: context.colors.primary,
        shape: BoxShape.circle,
      ),
    ),
  );
}
