import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../settings/presentation/widgets/language_toggle.dart';
import '../../../settings/presentation/widgets/theme_mode_toggle.dart';
import '../../../users/domain/usecases/user_usecases.dart';
import '../admin_modules.dart';
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

    return SpacePage(
      title: l10n.profileTitle,
      actions: [
        if (UserAdminPolicy.canEdit(user))
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
                InitialsAvatar(
                  name: user.name,
                  size: 56,
                  background: context.colors.accent,
                  foreground: context.colors.onAccent,
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
          child: SpaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, (icon, label, control)) in [
                  (
                    Icons.language_rounded,
                    l10n.languageLabel,
                    const LanguageToggle(),
                  ),
                  (
                    Icons.contrast_rounded,
                    l10n.appearanceLabel,
                    const ThemeModeToggle(),
                  ),
                ].indexed) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Divider(),
                    ),
                  Row(
                    children: [
                      IconBadge(icon: icon, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(label, style: theme.textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  control,
                ],
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
