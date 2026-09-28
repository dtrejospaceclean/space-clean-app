import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/client.dart';
import '../controllers/clients_providers.dart';

/// The client accounts the user belongs to (the server filters them), as one
/// list with a search box. Owners and account managers can add one.
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  static const path = '/accounts';

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  late final TextEditingController _search;
  Timer? _debounce;

  /// Typed text waiting out the debounce, not yet searched.
  bool _pending = false;

  @override
  void initState() {
    super.initState();
    // Eager: the box may never be shown, but dispose() still needs it.
    _search = TextEditingController(text: ref.read(accountSearchProvider));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  /// Searches once typing pauses, not on every keystroke.
  void _onSearch(String text) {
    _debounce?.cancel();
    setState(() => _pending = true);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(accountSearchProvider.notifier).search(text);
      setState(() => _pending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clients = ref.watch(accountsListProvider);
    final searching = ref.watch(accountSearchProvider).isNotEmpty;
    // Nothing to search until the user has at least one account.
    final hasAccounts = ref.watch(myClientsProvider).value?.isNotEmpty ?? false;
    Future<void> refresh() async {
      ref.invalidate(myClientsProvider);
      await ref.read(accountsListProvider.future);
    }

    return SpacePage(
      // A tab's home: nothing to go back to.
      showBack: false,
      title: l10n.accountsTitle,
      onRefresh: refresh,
      slivers: [
        if (hasAccounts)
          PageBox(
            top: 4,
            child: SearchField(
              controller: _search,
              hint: l10n.searchAccountsHint,
              onChanged: _onSearch,
              // From the first keystroke until the results are in.
              busy: _pending || clients.isLoading,
            ),
          ),
        AsyncSlivers(
          value: clients,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return searching
                  ? MessageSliver(
                      icon: Icons.search_off_rounded,
                      title: l10n.noAccountsFound,
                      hint: l10n.noAccountsFoundHint,
                    )
                  : MessageSliver(
                      icon: Icons.apartment_rounded,
                      title: l10n.noAccounts,
                      hint: l10n.noAccountsHint,
                    );
            }
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 12,
                  child: Text(
                    l10n.accountsCount(list.length),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                PageBox(
                  top: 8,
                  child: ListCard(
                    children: [
                      for (final (i, client) in list.indexed)
                        ListRow(
                          leading: _AccountBadge(client: client, index: i),
                          title: client.displayName,
                          subtitle: client.displayName != client.legalName
                              ? client.legalName
                              : null,
                          trailing: _StatusTag(status: client.status),
                          onTap: () => context.push(
                            '${AccountsScreen.path}/${client.id}',
                          ),
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

/// Flags accounts that aren't active yet or anymore; active ones stay quiet.
class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

  final ClientStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (status) {
      ClientStatus.prospect => StatusPill(
        label: l10n.clientStatusProspect,
        color: context.colors.highlightInk,
        background: context.colors.highlightSoft,
      ),
      ClientStatus.inactive => StatusPill(
        label: l10n.clientStatusInactive,
        color: context.colors.inkMuted,
        background: context.colors.sunken,
      ),
      _ => const SizedBox.shrink(),
    };
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
      size: 44,
      background: orange
          ? context.colors.highlightSoft
          : context.colors.accentSoft,
      foreground: orange ? context.colors.highlightInk : context.colors.accent,
    );
  }
}
