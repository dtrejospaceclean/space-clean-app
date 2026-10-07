import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/users_providers.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/usecases/user_usecases.dart';
import '../controllers/users_providers.dart';
import '../widgets/user_labels.dart';
import 'users_screen.dart';
import '../../../../core/widgets/us_phone.dart';

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
    final auth = ref.read(authControllerProvider).value;
    if (auth is! Authenticated) return;
    try {
      await ref.read(setUserActiveProvider)(
        SetUserActiveParams(
          id: user.id,
          active: !user.isActive,
          actor: auth.user,
        ),
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
    final theme = Theme.of(context);
    final user = ref.watch(userProvider(userId));
    final canEdit = ref.watch(canEditUsersProvider);
    final me = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => user,
      _ => null,
    };
    // Your own account can't be deactivated from here.
    final isMe = me != null && !UserAdminPolicy.canDeactivate(me, userId);
    Future<void> refresh() => ref.refresh(userProvider(userId).future);

    String? orNull(String? v) => v == null || v.isEmpty ? null : v;

    return SpacePage(
      onRefresh: refresh,
      actions: [
        if (canEdit && user.hasValue)
          CircleButton.dark(
            icon: Icons.edit_outlined,
            tooltip: l10n.editUser,
            onPressed: () => context.push('${UsersScreen.path}/$userId/edit'),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: user,
          onRetry: refresh,
          builder: (user) => SliverMainAxisGroup(
            slivers: [
              PageBox(
                top: 12,
                child: SpaceCard(
                  child: Row(
                    children: [
                      InitialsAvatar(
                        name: user.name,
                        photoUrl: user.photoUrl,
                        size: 56,
                        background: user.isActive
                            ? context.colors.accent
                            : context.colors.sunken,
                        foreground: user.isActive
                            ? context.colors.onAccent
                            : context.colors.inkMuted,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: theme.textTheme.titleLarge),
                            Text(user.email, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (!user.isActive)
                                  StatusPill(
                                    label: l10n.inactiveTag,
                                    color: context.colors.inkMuted,
                                    background: context.colors.sunken,
                                  ),
                                for (final role in user.roles)
                                  StatusPill(
                                    label: l10n.roleName(role.name),
                                    color: context.colors.accent,
                                    background: context.colors.accentSoft,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!user.isActive || !canEdit)
                PageBox(
                  top: SpaceSpace.gap,
                  child: Notice(
                    tone: NoticeTone.info,
                    message: !user.isActive
                        ? l10n.userInactiveNotice
                        : l10n.readOnlyNotice,
                  ),
                ),
              if (user.roles.isEmpty)
                PageBox(
                  top: SpaceSpace.gap,
                  child: Notice(message: l10n.noRolesSelected),
                ),
              PageBox(
                top: 12,
                child: SectionHeader(title: l10n.sectionEmployment),
              ),
              PageBox(
                top: 0,
                child: CardGrid(
                  children: [
                    StatCard(
                      label: l10n.payRateLabel,
                      value: orNull(user.payRate) == null
                          ? '—'
                          : '\$${user.payRate}',
                    ),
                    StatCard(
                      label: l10n.employmentTypeLabel,
                      value: switch (orNull(user.employmentType)) {
                        final t? => l10n.employmentLabel(t),
                        null => '—',
                      },
                    ),
                    StatCard(
                      label: l10n.hireDateLabel,
                      value: user.hireDate == null
                          ? '—'
                          : context.formatDayLong(user.hireDate!),
                    ),
                    StatCard(
                      label: l10n.employeeIdLabel,
                      value: orNull(user.employeeId) ?? '—',
                    ),
                  ],
                ),
              ),
              PageBox(
                top: 12,
                child: SectionHeader(title: l10n.sectionContact),
              ),
              PageBox(
                top: 0,
                child: ListCard(
                  children: [
                    ListRow(
                      leading: const IconBadge(icon: Icons.email_outlined),
                      title: user.email,
                    ),
                    ListRow(
                      leading: const IconBadge(icon: Icons.phone_outlined),
                      title:
                          orNull(UsPhone.format(user.phoneNumber)) ??
                          l10n.notSet,
                    ),
                    ListRow(
                      leading: IconBadge(
                        icon: Icons.contact_emergency_outlined,
                        color: context.colors.highlightInk,
                        background: context.colors.highlightSoft,
                      ),
                      title: orNull(user.emergencyContactName) ?? l10n.notSet,
                      subtitle: [
                        l10n.sectionEmergency,
                        ?orNull(UsPhone.format(user.emergencyContactPhone)),
                      ].join(' · '),
                    ),
                  ],
                ),
              ),
              if (canEdit && isMe)
                PageBox(
                  top: 24,
                  child: Notice(
                    tone: NoticeTone.info,
                    message: l10n.ownAccountNotice,
                  ),
                )
              else if (canEdit)
                PageBox(
                  top: 24,
                  child: SecondaryButton(
                    label: user.isActive
                        ? l10n.deactivateUser
                        : l10n.reactivateUser,
                    icon: user.isActive
                        ? Icons.person_off_outlined
                        : Icons.person_outline_rounded,
                    destructive: user.isActive,
                    onPressed: () => _toggleActive(context, ref, user),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
