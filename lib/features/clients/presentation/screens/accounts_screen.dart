import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/client.dart';
import '../controllers/clients_providers.dart';

/// The client accounts the user belongs to (the server filters them), as a
/// two-column grid of tiles.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  static const path = '/accounts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final clients = ref.watch(myClientsProvider);
    Future<void> refresh() => ref.refresh(myClientsProvider.future);

    return SpacePage(
      title: l10n.accountsTitle,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: clients,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.apartment_rounded,
                title: l10n.noAccounts,
                hint: l10n.noAccountsHint,
              );
            }
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 0,
                  child: Text(
                    l10n.accountsCount(list.length),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                PageBox(
                  child: CardGrid(
                    children: [
                      for (final (i, client) in list.indexed)
                        TileCard(
                          icon: _AccountBadge(client: client, index: i),
                          title: client.displayName,
                          subtitle: switch (client.status) {
                            ClientStatus.prospect => l10n.clientStatusProspect,
                            ClientStatus.inactive => l10n.clientStatusInactive,
                            _ when client.displayName != client.legalName =>
                              client.legalName,
                            _ => null,
                          },
                          onTap: () => context.push('$path/${client.id}'),
                        ),
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

/// Initials alternating between the logo's navy and orange.
class _AccountBadge extends StatelessWidget {
  const _AccountBadge({required this.client, required this.index});

  final Client client;
  final int index;

  @override
  Widget build(BuildContext context) {
    final orange = index.isOdd;
    return InitialsAvatar(
      name: client.displayName,
      size: 48,
      background: orange ? SpaceColors.highlightSoft : SpaceColors.accentSoft,
      foreground: orange ? SpaceColors.highlightInk : SpaceColors.accent,
    );
  }
}
