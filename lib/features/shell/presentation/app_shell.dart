import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/entities/user.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../clients/domain/usecases/manage_clients.dart';
import '../../clients/presentation/screens/accounts_screen.dart';
import '../../service_catalog/domain/usecases/service_catalog_usecases.dart';
import '../../service_catalog/presentation/screens/services_screen.dart';
import '../../users/domain/usecases/user_usecases.dart';
import '../../users/presentation/screens/users_screen.dart';

/// Something the "+" beside the tab dock can start.
class _CreateOption {
  const _CreateOption(this.path, this.label, this.isAllowed);

  /// The form's route; opening it switches to the tab that owns it.
  final String path;
  final String Function(AppLocalizations l10n) label;

  /// Gated by the global role, like the screens' own "+" buttons.
  final bool Function(User user) isAllowed;
}

final _createOptions = <_CreateOption>[
  _CreateOption(
    '${AccountsScreen.path}/new',
    (l10n) => l10n.newAccountTitle,
    AccountAdminPolicy.canCreate,
  ),
  _CreateOption(
    '${ServicesScreen.path}/new',
    (l10n) => l10n.newServiceTitle,
    ServiceCatalogPolicy.canManage,
  ),
  _CreateOption(
    '${UsersScreen.path}/new',
    (l10n) => l10n.newUserTitle,
    UserAdminPolicy.canEdit,
  ),
];

/// Signed-in shell: Today, Accounts, Me, with the floating icon-only tab
/// dock. Each tab keeps its own stack. Beside the dock, a "+" opens what the
/// user may create; it's hidden for people who can't create anything.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int index) => navigationShell.goBranch(
    index,
    // Tapping the current tab returns to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  Future<void> _create(
    BuildContext context,
    List<_CreateOption> options,
  ) async {
    final l10n = AppLocalizations.of(context);
    final path = options.length == 1
        ? options.single.path
        : await showAppChoice(
            context,
            title: l10n.createTitle,
            allowClear: false,
            options: {for (final o in options) o.path: o.label(l10n)},
          );
    if (path != null && path.isNotEmpty && context.mounted) context.go(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final creatable = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) =>
        _createOptions.where((o) => o.isAllowed(user)).toList(),
      _ => const <_CreateOption>[],
    };

    return Scaffold(
      backgroundColor: context.colors.ground,
      body: navigationShell,
      bottomNavigationBar: SpaceBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _select,
        action: creatable.isEmpty
            ? null
            : BottomBarAction(
                icon: Icons.add_rounded,
                label: l10n.createTitle,
                onPressed: () => _create(context, creatable),
              ),
        items: [
          BottomBarItem(
            icon: Icons.today_outlined,
            activeIcon: Icons.today_rounded,
            label: l10n.tabToday,
          ),
          BottomBarItem(
            icon: Icons.apartment_outlined,
            activeIcon: Icons.apartment_rounded,
            label: l10n.tabAccounts,
          ),
          BottomBarItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
