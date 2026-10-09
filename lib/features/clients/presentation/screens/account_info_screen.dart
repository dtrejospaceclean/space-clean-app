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
import 'purge_account_screen.dart';

/// An account's details: names, status, billing and the people in charge.
/// Editing needs `info.edit`; deleting (the header's trash button) is for
/// global owners.
class AccountInfoScreen extends ConsumerStatefulWidget {
  const AccountInfoScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends ConsumerState<AccountInfoScreen> {
  bool _deleting = false;

  String get clientId => widget.clientId;

  /// Deletes an unused account. One with history goes straight to the purge
  /// page, which asks for the legal name.
  Future<void> _delete(Client c) async {
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
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await ref.read(deleteClientProvider)(c.id);
      ref.invalidate(myClientsProvider);
      if (mounted) context.go(AccountsScreen.path);
    } on Failure catch (f) {
      if (!mounted) return;
      if (f.messageKey == 'clients.has_related_records') {
        final here = GoRouterState.of(context).matchedLocation;
        context.push('$here/${PurgeAccountScreen.route}');
        return;
      }
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
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        if (client.value case final c? when canDelete)
          CircleButton.light(
            icon: Icons.delete_outline_rounded,
            tooltip: l10n.deleteAccount,
            busy: _deleting,
            onPressed: () => _delete(c),
          ),
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
            // "1980 Post Oak Blvd" / "Houston, TX 77056".
            final region = [
              orNull(c.billingState),
              orNull(c.billingZip),
            ].nonNulls.join(' ');
            final address = [
              orNull(c.billingAddress),
              [orNull(c.billingCity), orNull(region)].nonNulls.join(', '),
            ].map(orNull).nonNulls.join('\n');

            /// A fact: its value as the title, what it is underneath.
            /// Missing values say so, muted, instead of posing as data.
            ListRow fact(IconData icon, String label, String? value) => ListRow(
              leading: IconBadge(icon: icon),
              title: orNull(value) ?? l10n.notSet,
              subtitle: label,
              muted: orNull(value) == null,
            );

            final status = switch (c.status) {
              ClientStatus.active => (
                context.colors.accent,
                context.colors.accentSoft,
              ),
              // Same tones as the Accounts list.
              ClientStatus.prospect => (
                context.colors.highlightInk,
                context.colors.highlightSoft,
              ),
              ClientStatus.inactive => (
                context.colors.inkMuted,
                context.colors.sunken,
              ),
              ClientStatus.unknown => null,
            };

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
                          background: context.colors.accentSoft,
                          foreground: context.colors.accent,
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
                              if (status case (final fg, final bg)) ...[
                                const SizedBox(height: 8),
                                StatusPill(
                                  label: l10n.clientStatusLabel(c.status),
                                  color: fg,
                                  background: bg,
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
                  child: SectionHeader(title: l10n.sectionGeneral),
                ),
                PageBox(
                  top: 0,
                  child: ListCard(
                    children: [
                      fact(
                        Icons.domain_rounded,
                        l10n.industryLabel,
                        c.industry,
                      ),
                      fact(
                        Icons.cleaning_services_outlined,
                        l10n.serviceTypeLabel,
                        c.serviceType,
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
                      fact(Icons.badge_outlined, l10n.taxIdLabel, c.taxId),
                      fact(
                        Icons.location_on_outlined,
                        l10n.billingAddressLabel,
                        address,
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
                      for (final (role, who) in [
                        (l10n.roleAccountManager, c.accountManager),
                        (l10n.roleSupervisor, c.supervisor),
                        (l10n.salespersonLabel, c.salesperson),
                      ])
                        fact(Icons.person_outline_rounded, role, who?.name),
                    ],
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
