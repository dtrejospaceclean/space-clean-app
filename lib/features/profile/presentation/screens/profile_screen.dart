import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../jobs/presentation/screens/today_screen.dart';
import '../../../notifications/presentation/controllers/notifications_providers.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../settings/presentation/controllers/language_controller.dart';
import '../../../settings/presentation/controllers/theme_mode_controller.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../admin_modules.dart';
import '../widgets/profile_photo_button.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

/// The signed-in user, administration, settings, and sign-out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const path = '/me';

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          adaptiveAction(
            context,
            label: l10n.cancelButton,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.signOutButton,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => user,
      _ => null,
    };
    if (user == null) return SizedBox.shrink();
    final unread = ref.watch(unreadNotificationsProvider).value ?? 0;

    return SpacePage(
      // Opened from Today's avatar rather than a tab, so back returns there.
      onBack: () => context.go(TodayScreen.path),
      title: l10n.profileTitle,
      actions: [
        CircleButton.dark(
          icon: Icons.edit_outlined,
          tooltip: l10n.editProfile,
          onPressed: () => context.push(EditProfileScreen.path),
        ),
      ],
      slivers: [
        PageBox(
          top: 8,
          child: SpaceCard(
            child: Row(
              children: [
                ProfilePhotoButton(user: user),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: theme.textTheme.titleLarge),
                      Text(user.email, style: theme.textTheme.bodyMedium),
                      if (user.roles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final role in user.roles)
                              StatusPill(
                                label: l10n.roleName(role.name),
                                color: context.colors.accent,
                                background: context.colors.accentSoft,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        PageBox(
          top: 12,
          child: ListCard(
            children: [
              ListRow(
                leading: unread > 0
                    ? const IconBadge.strong(
                        icon: Icons.notifications_active_outlined,
                      )
                    : const IconBadge(icon: Icons.notifications_none_rounded),
                title: l10n.notificationsTitle,
                subtitle: unread > 0
                    ? l10n.notificationsUnreadSummary(unread)
                    : l10n.notificationsRowHint,
                onTap: () => context.push(NotificationsScreen.path),
              ),
            ],
          ),
        ),
        PageBox(top: 12, child: SectionHeader(title: l10n.sectionSignIn)),
        PageBox(
          top: 0,
          child: ListCard(
            children: [
              ListRow(
                leading: const IconBadge(icon: Icons.lock_outline_rounded),
                title: l10n.changePasswordTitle,
                subtitle: l10n.changePasswordHint,
                onTap: () => context.push(ChangePasswordScreen.path),
              ),
            ],
          ),
        ),
        if (visibleAdminModules(user) case final modules
            when modules.isNotEmpty) ...[
          PageBox(
            top: 12,
            child: SectionHeader(title: l10n.sectionAdministration),
          ),
          PageBox(
            top: 0,
            child: ListCard(
              children: [
                for (final module in modules)
                  ListRow(
                    leading: IconBadge.strong(icon: module.icon),
                    title: module.label(l10n),
                    subtitle: module.description(l10n),
                    onTap: () => context.push(module.path),
                  ),
              ],
            ),
          ),
        ],
        PageBox(top: 12, child: SectionHeader(title: l10n.sectionSettings)),
        PageBox(
          top: 0,
          child: ListCard(
            children: [
              ListRow(
                leading: const IconBadge(icon: Icons.tune_rounded),
                title: l10n.languageAndAppearance,
                // What's in effect now: "English · System theme".
                subtitle: [
                  languageEndonyms[currentLanguage(context, ref)]!,
                  l10n.themeSummary(ref.watch(themeModeControllerProvider)),
                ].join(' · '),
                onTap: () => context.push(SettingsScreen.path),
              ),
            ],
          ),
        ),
        PageBox(
          top: 24,
          child: SecondaryButton(
            label: l10n.signOutButton,
            icon: Icons.logout_rounded,
            destructive: true,
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ),
      ],
    );
  }
}
