import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../settings/presentation/widgets/language_toggle.dart';
import '../../../users/presentation/controllers/users_providers.dart';
import '../../../users/presentation/screens/roles_screen.dart';
import '../../../users/presentation/screens/users_screen.dart';

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
    if (user == null) return const SizedBox.shrink();

    return SpacePage(
      title: l10n.profileTitle,
      slivers: [
        PageBox(
          top: 8,
          child: SpaceCard(
            child: Row(
              children: [
                InitialsAvatar(
                  name: user.name,
                  size: 56,
                  background: SpaceColors.accent,
                  foreground: SpaceColors.onAccent,
                ),
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
                                color: SpaceColors.accent,
                                background: SpaceColors.accentSoft,
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
        if (ref.watch(canViewUsersProvider)) ...[
          PageBox(
            top: 12,
            child: SectionHeader(title: l10n.sectionAdministration),
          ),
          PageBox(
            top: 0,
            child: CardGrid(
              children: [
                TileCard(
                  icon: const IconBadge.strong(icon: Icons.group_outlined),
                  title: l10n.usersTitle,
                  subtitle: l10n.openSection,
                  onTap: () => context.push(UsersScreen.path),
                ),
                TileCard(
                  icon: const IconBadge(
                    icon: Icons.admin_panel_settings_outlined,
                  ),
                  title: l10n.rolesTitle,
                  subtitle: l10n.openSection,
                  onTap: () => context.push(RolesScreen.path),
                ),
              ],
            ),
          ),
        ],
        PageBox(top: 12, child: SectionHeader(title: l10n.sectionSettings)),
        PageBox(
          top: 0,
          child: SpaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBadge(icon: Icons.language_rounded, size: 36),
                    const SizedBox(width: 12),
                    Text(
                      l10n.languageLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const LanguageToggle(),
              ],
            ),
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
