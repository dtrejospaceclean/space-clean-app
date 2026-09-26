import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user.dart';
import '../controllers/users_providers.dart';
import '../widgets/user_labels.dart';

/// Everyone who can sign in: staff and clients' own people. Search, filter by
/// status, open a user; owners can add one.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  static const path = '/me/users';

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  late final _search = TextEditingController(
    text: ref.read(userQueryProvider).search,
  );
  Timer? _debounce;

  /// Typed text waiting out the debounce, not yet searched.
  bool _pending = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    setState(() => _pending = true);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(userQueryProvider.notifier).search(text);
      setState(() => _pending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final users = ref.watch(usersProvider);
    final query = ref.watch(userQueryProvider);
    Future<void> refresh() => ref.refresh(usersProvider.future);

    return SpacePage(
      title: l10n.usersTitle,
      onRefresh: refresh,
      slivers: [
        PageBox(
          top: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchField(
                controller: _search,
                hint: l10n.searchUsersHint,
                onChanged: _onSearch,
                // From the first keystroke until the results are in.
                busy: _pending || users.isLoading,
              ),
              const SizedBox(height: 12),
              PillToggle<bool?>(
                options: {
                  true: l10n.filterActive,
                  false: l10n.filterInactive,
                  null: l10n.filterAll,
                },
                selected: query.isActive,
                onChanged: (v) =>
                    ref.read(userQueryProvider.notifier).status(v),
              ),
            ],
          ),
        ),
        AsyncSlivers(
          value: users,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.group_off_outlined,
                title: l10n.noUsersFound,
                hint: l10n.noUsersFoundHint,
              );
            }
            return PageBox(
              child: ListCard(
                children: [
                  for (final user in list)
                    ListRow(
                      leading: InitialsAvatar(name: user.name),
                      title: user.name,
                      subtitle: [
                        user.email,
                        if (user.roles.isNotEmpty)
                          l10n.rolesLabel(user.roles.map((r) => r.name)),
                      ].join(' · '),
                      trailing: !user.isActive
                          ? StatusPill(
                              label: l10n.inactiveTag,
                              color: context.colors.inkMuted,
                              background: context.colors.sunken,
                            )
                          : user.userType == UserType.external
                          ? StatusPill(
                              label: l10n.clientUserTag,
                              color: context.colors.accent,
                              background: context.colors.accentSoft,
                            )
                          : null,
                      onTap: () =>
                          context.push('${UsersScreen.path}/${user.id}'),
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
