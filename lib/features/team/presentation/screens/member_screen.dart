import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/team_providers.dart';
import '../../domain/entities/member.dart';
import '../../domain/usecases/team_usecases.dart';
import '../controllers/team_providers.dart';
import '../widgets/access_list.dart';

/// One member of an account's team: their role there and every area they
/// can open. Owners change their access or remove them.
class MemberScreen extends ConsumerWidget {
  const MemberScreen({super.key, required this.clientId, required this.userId});

  final String clientId;
  final String userId;

  Future<void> _remove(BuildContext context, WidgetRef ref, Member m) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.removeMemberConfirmTitle(m.name)),
        content: Text(l10n.removeMemberConfirmBody),
        actions: [
          adaptiveAction(
            context,
            label: l10n.cancelButton,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.removeButton,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(removeMemberProvider)(
        MemberRef(clientId: clientId, userId: m.userId),
      );
      if (!context.mounted) return;
      // Leave before the list reloads, so this page doesn't flash "not
      // found" on its way out.
      context.pop();
      ref.invalidate(membersProvider(clientId));
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
    final value = bothLoaded(
      ref.watch(memberProvider((clientId, userId))),
      ref.watch(permissionCatalogProvider),
    );
    final canManage = ref.watch(canManageTeamProvider);
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => Future.wait([
      ref.refresh(membersProvider(clientId).future),
      ref.refresh(permissionCatalogProvider.future),
    ]);

    return SpacePage(
      title: l10n.memberTitle,
      onRefresh: refresh,
      actions: [
        if (canManage && value.hasValue)
          CircleButton.dark(
            icon: Icons.edit_outlined,
            tooltip: l10n.editAccess,
            onPressed: () => context.push('$here/edit'),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: value,
          skeleton: SkeletonLayout.detail,
          onRetry: refresh,
          builder: (loaded) {
            final (m, catalog) = loaded;
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: SpaceCard(
                    child: Row(
                      children: [
                        InitialsAvatar(
                          name: m.name,
                          size: 56,
                          background: context.colors.accentSoft,
                          foreground: context.colors.accent,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name, style: theme.textTheme.titleLarge),
                              Text(m.email, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  StatusPill(
                                    label: l10n.roleName(m.baseRole),
                                    color: context.colors.accent,
                                    background: context.colors.accentSoft,
                                  ),
                                  if (m.hasCustomAccess)
                                    StatusPill(
                                      label: l10n.customAccessTag,
                                      color: context.colors.highlightInk,
                                      background: context.colors.highlightSoft,
                                    ),
                                  if (!m.isActive)
                                    StatusPill(
                                      label: l10n.inactiveTag,
                                      color: context.colors.inkMuted,
                                      background: context.colors.sunken,
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
                PageBox(
                  top: 12,
                  child: SectionHeader(title: l10n.sectionAccess),
                ),
                PageBox(
                  top: 0,
                  child: SpaceCard(
                    child: AccessList(catalog: catalog, granted: m.permissions),
                  ),
                ),
                PageBox(
                  top: 24,
                  child: canManage
                      ? SecondaryButton(
                          label: l10n.removeMember,
                          icon: Icons.person_remove_outlined,
                          destructive: true,
                          onPressed: () => _remove(context, ref, m),
                        )
                      : Text(
                          l10n.teamReadOnly,
                          style: theme.textTheme.bodySmall,
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
