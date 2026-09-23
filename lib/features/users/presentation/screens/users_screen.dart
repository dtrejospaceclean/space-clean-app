import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_list.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../core/widgets/app/async_slivers.dart';
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

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => ref.read(userQueryProvider.notifier).search(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cupertino = useCupertino(context);
    final users = ref.watch(usersProvider);
    final query = ref.watch(userQueryProvider);
    final canEdit = ref.watch(canEditUsersProvider);
    Future<void> refresh() => ref.refresh(usersProvider.future);

    final statusOptions = <bool?, String>{
      true: l10n.filterActive,
      false: l10n.filterInactive,
      null: l10n.filterAll,
    };

    return AppPage(
      title: l10n.usersTitle,
      grouped: true,
      onRefresh: refresh,
      actions: [
        if (canEdit)
          IconButton(
            tooltip: l10n.addUser,
            icon: Icon(cupertino ? CupertinoIcons.add : Icons.person_add_alt),
            onPressed: () => context.push('${UsersScreen.path}/new'),
          ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (cupertino)
                  CupertinoSearchTextField(
                    controller: _search,
                    placeholder: l10n.searchUsersHint,
                    onChanged: _onSearch,
                  )
                else
                  SearchBar(
                    controller: _search,
                    hintText: l10n.searchUsersHint,
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: _onSearch,
                  ),
                const SizedBox(height: 12),
                if (cupertino)
                  CupertinoSlidingSegmentedControl<int>(
                    groupValue: statusOptions.keys.toList().indexOf(
                      query.isActive,
                    ),
                    onValueChanged: (i) => ref
                        .read(userQueryProvider.notifier)
                        .status(statusOptions.keys.elementAt(i!)),
                    children: {
                      for (final (i, label) in statusOptions.values.indexed)
                        i: Text(label),
                    },
                  )
                else
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    selected: {
                      statusOptions.keys.toList().indexOf(query.isActive),
                    },
                    onSelectionChanged: (s) => ref
                        .read(userQueryProvider.notifier)
                        .status(statusOptions.keys.elementAt(s.single)),
                    segments: [
                      for (final (i, label) in statusOptions.values.indexed)
                        ButtonSegment(value: i, label: Text(label)),
                    ],
                  ),
              ],
            ),
          ),
        ),
        AsyncSlivers(
          value: users,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: cupertino ? CupertinoIcons.person_2 : Icons.group_off,
                title: l10n.noUsersFound,
                hint: l10n.noUsersFoundHint,
              );
            }
            return SliverToBoxAdapter(
              child: AppListSection(
                children: [
                  for (final user in list)
                    AppListRow(
                      title: user.name,
                      subtitle: [
                        user.email,
                        if (user.roles.isNotEmpty)
                          l10n.rolesLabel(user.roles.map((r) => r.name)),
                      ].join(' · '),
                      trailing: !user.isActive
                          ? Text(l10n.inactiveTag)
                          : user.userType == UserType.external
                          ? Text(l10n.clientUserTag)
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
