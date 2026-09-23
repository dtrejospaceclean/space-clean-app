import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_list.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../settings/presentation/widgets/language_selector.dart';
import '../../../users/presentation/controllers/users_providers.dart';
import '../../../users/presentation/screens/roles_screen.dart';
import '../../../users/presentation/screens/users_screen.dart';

/// The signed-in user, settings, and sign-out.
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
    final cupertino = useCupertino(context);
    final user = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => user,
      _ => null,
    };
    if (user == null) return const SizedBox.shrink();

    return AppPage(
      grouped: true,
      title: l10n.profileTitle,
      topLevel: true,
      slivers: [
        SliverList.list(
          children: [
            AppListSection(
              children: [
                AppListRow(
                  leading: cupertino
                      ? CupertinoIcons.person_crop_circle
                      : Icons.account_circle_outlined,
                  title: user.name,
                  subtitle: user.email,
                ),
                if (user.roles.isNotEmpty)
                  AppListRow(
                    leading: cupertino
                        ? CupertinoIcons.person_badge_plus
                        : Icons.badge_outlined,
                    title: user.roles
                        .map((r) => l10n.roleName(r.name))
                        .join(', '),
                  ),
              ],
            ),
            if (ref.watch(canViewUsersProvider))
              AppListSection(
                title: l10n.sectionAdministration,
                children: [
                  AppListRow(
                    leading: cupertino
                        ? CupertinoIcons.person_2
                        : Icons.group_outlined,
                    title: l10n.usersTitle,
                    onTap: () => context.push(UsersScreen.path),
                  ),
                  AppListRow(
                    leading: cupertino
                        ? CupertinoIcons.person_badge_plus
                        : Icons.admin_panel_settings_outlined,
                    title: l10n.rolesTitle,
                    onTap: () => context.push(RolesScreen.path),
                  ),
                ],
              ),
            AppListSection(
              title: l10n.sectionSettings,
              children: [
                AppListRow(
                  leading: cupertino ? CupertinoIcons.globe : Icons.language,
                  title: l10n.languageLabel,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: LanguageSelector(),
                ),
              ],
            ),
            AppListSection(
              children: [
                AppListRow(
                  leading: cupertino
                      ? CupertinoIcons.square_arrow_right
                      : Icons.logout,
                  title: l10n.signOutButton,
                  destructive: true,
                  onTap: () => _confirmSignOut(context, ref),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
