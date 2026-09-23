import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_list.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../core/widgets/app/async_slivers.dart';
import '../../../../core/widgets/threshold/threshold_notice.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/users_providers.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/usecases/user_usecases.dart';
import '../controllers/users_providers.dart';
import '../widgets/user_labels.dart';
import 'users_screen.dart';

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    ManagedUser user,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (user.isActive) {
      final confirmed = await showAdaptiveDialog<bool>(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: Text(l10n.deactivateConfirmTitle(user.name)),
          content: Text(l10n.deactivateConfirmBody),
          actions: [
            adaptiveAction(
              context,
              label: l10n.cancelButton,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            adaptiveAction(
              context,
              label: l10n.deactivateButton,
              destructive: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      await ref.read(setUserActiveProvider)(
        SetUserActiveParams(id: user.id, active: !user.isActive),
      );
      ref
        ..invalidate(userProvider(user.id))
        ..invalidate(usersProvider);
    } on Failure catch (f) {
      if (context.mounted) {
        await showAdaptiveDialog<void>(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            content: Text(l10n.failureMessage(f)),
            actions: [
              adaptiveAction(
                context,
                label: l10n.doneButton,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cupertino = useCupertino(context);
    final user = ref.watch(userProvider(userId));
    final canEdit = ref.watch(canEditUsersProvider);
    Future<void> refresh() => ref.refresh(userProvider(userId).future);

    String? orNull(String? v) => v == null || v.isEmpty ? null : v;

    return AppPage(
      title: user.value?.name ?? l10n.usersTitle,
      grouped: true,
      onRefresh: refresh,
      actions: [
        if (canEdit && user.hasValue)
          IconButton(
            tooltip: l10n.editUser,
            icon: Icon(cupertino ? CupertinoIcons.pencil : Icons.edit_outlined),
            onPressed: () => context.push('${UsersScreen.path}/$userId/edit'),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: user,
          onRetry: refresh,
          builder: (user) => SliverList.list(
            children: [
              if (!user.isActive || !canEdit)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ThresholdNotice(
                    tone: NoticeTone.info,
                    message: !user.isActive
                        ? l10n.userInactiveNotice
                        : l10n.readOnlyNotice,
                  ),
                ),
              AppListSection(
                title: l10n.sectionContact,
                children: [
                  AppListRow(
                    leading: cupertino
                        ? CupertinoIcons.mail
                        : Icons.email_outlined,
                    title: user.email,
                  ),
                  AppListRow(
                    leading: cupertino
                        ? CupertinoIcons.phone
                        : Icons.phone_outlined,
                    title: orNull(user.phoneNumber) ?? l10n.notSet,
                  ),
                ],
              ),
              AppListSection(
                title: l10n.sectionRoles,
                children: [
                  AppListRow(
                    leading: cupertino
                        ? CupertinoIcons.person_badge_plus
                        : Icons.badge_outlined,
                    title: user.roles.isEmpty
                        ? l10n.noRolesSelected
                        : l10n.rolesLabel(user.roles.map((r) => r.name)),
                  ),
                ],
              ),
              AppListSection(
                title: l10n.sectionEmployment,
                children: [
                  AppListRow(
                    title: l10n.employeeIdLabel,
                    trailing: Text(orNull(user.employeeId) ?? l10n.notSet),
                  ),
                  AppListRow(
                    title: l10n.employmentTypeLabel,
                    trailing: Text(switch (orNull(user.employmentType)) {
                      final t? => l10n.employmentLabel(t),
                      null => l10n.notSet,
                    }),
                  ),
                  AppListRow(
                    title: l10n.payRateLabel,
                    trailing: Text(
                      orNull(user.payRate) == null
                          ? l10n.notSet
                          : '\$${user.payRate}',
                    ),
                  ),
                  AppListRow(
                    title: l10n.hireDateLabel,
                    trailing: Text(
                      user.hireDate == null
                          ? l10n.notSet
                          : context.formatDayLong(user.hireDate!),
                    ),
                  ),
                ],
              ),
              AppListSection(
                title: l10n.sectionEmergency,
                children: [
                  AppListRow(
                    leading: cupertino
                        ? CupertinoIcons.heart
                        : Icons.contact_emergency_outlined,
                    title: orNull(user.emergencyContactName) ?? l10n.notSet,
                    subtitle: orNull(user.emergencyContactPhone),
                  ),
                ],
              ),
              if (canEdit)
                AppListSection(
                  children: [
                    AppListRow(
                      leading: user.isActive
                          ? (cupertino
                                ? CupertinoIcons.person_crop_circle_badge_xmark
                                : Icons.person_off_outlined)
                          : (cupertino
                                ? CupertinoIcons
                                      .person_crop_circle_badge_checkmark
                                : Icons.person_outline),
                      title: user.isActive
                          ? l10n.deactivateUser
                          : l10n.reactivateUser,
                      destructive: user.isActive,
                      onTap: () => _toggleActive(context, ref, user),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
