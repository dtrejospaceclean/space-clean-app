import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_list.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../core/widgets/app/async_slivers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/client.dart';
import '../controllers/clients_providers.dart';

/// The client accounts the user belongs to (the server filters them).
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  static const path = '/accounts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final clients = ref.watch(myClientsProvider);
    Future<void> refresh() => ref.refresh(myClientsProvider.future);

    return AppPage(
      grouped: true,
      title: l10n.accountsTitle,
      topLevel: true,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: clients,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: useCupertino(context)
                    ? CupertinoIcons.building_2_fill
                    : Icons.apartment_outlined,
                title: l10n.noAccounts,
                hint: l10n.noAccountsHint,
              );
            }
            return SliverToBoxAdapter(
              child: AppListSection(
                children: [
                  for (final client in list)
                    AppListRow(
                      title: client.displayName,
                      subtitle: client.displayName == client.legalName
                          ? null
                          : client.legalName,
                      trailing: switch (client.status) {
                        ClientStatus.prospect => _StatusText(
                          l10n.clientStatusProspect,
                        ),
                        ClientStatus.inactive => _StatusText(
                          l10n.clientStatusInactive,
                        ),
                        _ => null,
                      },
                      onTap: () => context.push('$path/${client.id}'),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
  );
}
