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

/// An account's details: an overview card (names, status, billing facts)
/// and the people in charge. Editing needs `info.edit` (the overview's Edit
/// pill); deleting is for global owners (the link at the bottom).
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
      slivers: [
        AsyncSlivers(
          value: client,
          skeleton: SkeletonLayout.detail,
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

            // Beside the name it would squeeze it at large text sizes, so
            // it moves under the status there.
            final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
            final edit = PillButton(
              label: l10n.editButton,
              icon: Icons.edit_outlined,
              tooltip: l10n.editAccount,
              onPressed: () => context.push('$here/edit'),
            );

            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: SpaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InitialsAvatar(name: c.displayName, size: 64),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.displayName,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  if (c.displayName != c.legalName) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      c.legalName.toUpperCase(),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(letterSpacing: 0.6),
                                    ),
                                  ],
                                  if (status case (final fg, final bg)) ...[
                                    const SizedBox(height: 10),
                                    StatusPill(
                                      label: l10n.clientStatusLabel(c.status),
                                      color: fg,
                                      background: bg,
                                    ),
                                  ],
                                  if (canEdit && largeText) ...[
                                    const SizedBox(height: 10),
                                    edit,
                                  ],
                                ],
                              ),
                            ),
                            if (canEdit && !largeText) ...[
                              const SizedBox(width: 8),
                              edit,
                            ],
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Divider(),
                        ),
                        _FactGrid(
                          facts: [
                            (l10n.taxIdLabel, orNull(c.taxId)),
                            (l10n.industryLabel, orNull(c.industry)),
                            (l10n.serviceTypeLabel, orNull(c.serviceType)),
                            (l10n.billingAddressLabel, orNull(address)),
                          ],
                        ),
                      ],
                    ),
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
                        ListRow(
                          // Missing people say so, muted, instead of posing
                          // as data.
                          title: orNull(who?.name) ?? l10n.notSet,
                          muted: orNull(who?.name) == null,
                          subtitle: role,
                        ),
                    ],
                  ),
                ),
                if (canDelete)
                  PageBox(
                    top: 20,
                    child: Center(
                      child: LinkButton(
                        label: l10n.deleteAccount,
                        icon: Icons.delete_outline_rounded,
                        destructive: true,
                        onPressed: _deleting ? null : () => _delete(c),
                      ),
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

/// Facts two to a row, each its value over a muted label. One column at
/// large text sizes (150% and up), so long values such as an address don't
/// wrap word by word.
class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.facts});

  /// Label and value; a null value isn't set.
  final List<(String, String?)> facts;

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.textScalerOf(context).scale(1) >= 1.5 ? 1 : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < facts.length; i += columns) ...[
          if (i > 0) const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = i; j < i + columns; j++) ...[
                if (j > i) const SizedBox(width: 16),
                Expanded(
                  child: j < facts.length
                      ? _Fact(facts[j].$1, facts[j].$2)
                      : const SizedBox(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// A value over its label. A missing value says "Not set", muted, instead
/// of posing as data.
class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value ?? AppLocalizations.of(context).notSet,
            style: theme.textTheme.titleMedium?.copyWith(
              color: value == null ? context.colors.inkMuted : null,
              fontWeight: value == null ? FontWeight.w500 : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
