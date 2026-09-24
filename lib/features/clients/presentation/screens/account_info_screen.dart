import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../di/clients_providers.dart';
import '../../domain/entities/client.dart';
import '../controllers/clients_providers.dart';
import '../widgets/client_labels.dart';
import 'accounts_screen.dart';

/// An account's details: names, status, billing and the people in charge.
/// Editing needs `info.edit`; deleting is for global owners.
class AccountInfoScreen extends ConsumerWidget {
  const AccountInfoScreen({super.key, required this.clientId});

  final String clientId;

  Future<void> _delete(BuildContext context, WidgetRef ref, Client c) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.deleteRoleConfirmTitle(c.displayName)),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          adaptiveAction(
            context,
            label: l10n.cancelButton,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.deleteButton,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(deleteClientProvider)(c.id);
      ref.invalidate(myClientsProvider);
      if (context.mounted) context.go(AccountsScreen.path);
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
    final client = ref.watch(clientDetailProvider(clientId));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.infoEdit) ??
        false;
    final canDelete = ref.watch(canDeleteAccountsProvider);
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() =>
        ref.refresh(clientDetailProvider(clientId).future);

    String? orNull(String? v) => v == null || v.trim().isEmpty ? null : v;

    return SpacePage(
      title: l10n.moduleInfo,
      onRefresh: refresh,
      actions: [
        if (canEdit && client.hasValue)
          CircleButton.dark(
            icon: Icons.edit_outlined,
            tooltip: l10n.editAccount,
            onPressed: () => context.push('$here/edit'),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: client,
          onRetry: refresh,
          builder: (c) {
            final billing = [
              orNull(c.billingAddress),
              [
                orNull(c.billingCity),
                orNull(c.billingState),
                orNull(c.billingZip),
              ].nonNulls.join(', '),
            ].map(orNull).nonNulls.join('\n');
            ListRow person(String role, ClientAssignee? who) => ListRow(
              leading: const IconBadge(icon: Icons.person_outline_rounded),
              title: who?.name ?? l10n.notSet,
              subtitle: role,
            );

            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: SpaceCard(
                    child: Row(
                      children: [
                        InitialsAvatar(
                          name: c.displayName,
                          size: 56,
                          background: SpaceColors.accentSoft,
                          foreground: SpaceColors.accent,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.displayName,
                                style: theme.textTheme.titleLarge,
                              ),
                              if (c.displayName != c.legalName)
                                Text(
                                  c.legalName,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              const SizedBox(height: 8),
                              StatusPill(
                                label: l10n.clientStatusLabel(c.status),
                                color: c.status == ClientStatus.active
                                    ? SpaceColors.accent
                                    : SpaceColors.inkMuted,
                                background: c.status == ClientStatus.active
                                    ? SpaceColors.accentSoft
                                    : SpaceColors.sunken,
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
                  child: SectionHeader(title: l10n.sectionGeneral),
                ),
                PageBox(
                  top: 0,
                  child: CardGrid(
                    children: [
                      StatCard(
                        label: l10n.industryLabel,
                        value: orNull(c.industry) ?? '—',
                      ),
                      StatCard(
                        label: l10n.serviceTypeLabel,
                        value: orNull(c.serviceType) ?? '—',
                      ),
                    ],
                  ),
                ),
                PageBox(
                  top: 12,
                  child: SectionHeader(title: l10n.sectionBilling),
                ),
                PageBox(
                  top: 0,
                  child: ListCard(
                    children: [
                      ListRow(
                        leading: const IconBadge(icon: Icons.badge_outlined),
                        title: orNull(c.taxId) ?? l10n.notSet,
                        subtitle: l10n.taxIdLabel,
                      ),
                      ListRow(
                        leading: const IconBadge(
                          icon: Icons.location_on_outlined,
                        ),
                        title: orNull(billing) ?? l10n.notSet,
                        subtitle: l10n.billingAddressLabel,
                      ),
                    ],
                  ),
                ),
                PageBox(
                  top: 12,
                  child: SectionHeader(title: l10n.sectionPeopleInCharge),
                ),
                PageBox(
                  top: 0,
                  child: ListCard(
                    children: [
                      person(l10n.roleAccountManager, c.accountManager),
                      person(l10n.roleSupervisor, c.supervisor),
                      person(l10n.salespersonLabel, c.salesperson),
                    ],
                  ),
                ),
                if (canDelete)
                  PageBox(
                    top: 24,
                    child: SecondaryButton(
                      label: l10n.deleteAccount,
                      icon: Icons.delete_outline_rounded,
                      destructive: true,
                      onPressed: () => _delete(context, ref, c),
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
