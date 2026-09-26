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

/// Something the "+" beside the tab dock can open.
class _PlusOption {
  const _PlusOption(this.path, this.label, this.isAllowed);

  final String path;
  final String Function(AppLocalizations l10n) label;

  /// Gated by the global role, like the screen it opens.
  final bool Function(User user) isAllowed;
}

final _newAccount = _PlusOption(
  '${AccountsScreen.path}/new',
  (l10n) => l10n.newAccountTitle,
  AccountAdminPolicy.canCreate,
);
final _newService = _PlusOption(
  '${ServicesScreen.path}/new',
  (l10n) => l10n.newServiceTitle,
  ServiceCatalogPolicy.canManage,
);
final _newUser = _PlusOption(
  '${UsersScreen.path}/new',
  (l10n) => l10n.newUserTitle,
  UserAdminPolicy.canEdit,
);

/// What "+" offers on a page, keyed by the page's route pattern. Pages not
/// listed get [_everywhere]; [_noPlus] pages (forms) hide it.
final _byPage = <String, List<_PlusOption>>{
  AccountsScreen.path: [_newAccount],
  UsersScreen.path: [_newUser],
  ServicesScreen.path: [
    _newService,
    _PlusOption(
      CategoriesScreen.path,
      (l10n) => l10n.manageCategories,
      ServiceCatalogPolicy.canManage,
    ),
    _PlusOption(
      UnitsScreen.path,
      (l10n) => l10n.manageUnits,
      ServiceCatalogPolicy.canManage,
    ),
  ],
  CategoriesScreen.path: [
    _PlusOption(
      '${CategoriesScreen.path}/new',
      (l10n) => l10n.newCategoryTitle,
      ServiceCatalogPolicy.canManage,
    ),
  ],
  UnitsScreen.path: [
    _PlusOption(
      '${UnitsScreen.path}/new',
      (l10n) => l10n.newUnitTitle,
      ServiceCatalogPolicy.canManage,
    ),
  ],
};

/// Everything the user may create, from pages with no options of their own.
final _everywhere = [_newAccount, _newService, _newUser];

/// Forms and editors: nothing to add while filling one in.
bool _noPlus(String route) =>
    route.endsWith('/new') ||
    route.endsWith('/edit') ||
    route == '/me/password' ||
    route.startsWith('${ServicesScreen.path}/:') ||
    route.startsWith('${CategoriesScreen.path}/:') ||
    route.startsWith('${UnitsScreen.path}/:');

/// The route pattern of the page on top ("/me/services"). Pushed pages sit
/// in the list as imperative matches, so follow them down.
String _topRoute(RouteMatchList matches) => switch (matches.lastOrNull) {
  final ImperativeRouteMatch pushed => _topRoute(pushed.matches),
  _ => matches.fullPath,
};

/// Signed-in shell: Today, Accounts, Me, with the floating icon-only tab
/// dock. Each tab keeps its own stack. Beside the dock, "+" offers what fits
/// the current page (on the service catalog: a new service, categories,
/// units), limited to what the user may do; it hides when that's nothing.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int index) => navigationShell.goBranch(
    index,
    // Tapping the current tab returns to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  Future<void> _open(
    BuildContext context,
    List<_PlusOption> options, {
    required bool fromPage,
  }) async {
    final l10n = AppLocalizations.of(context);
    final path = options.length == 1
        ? options.single.path
        : await showAppChoice(
            context,
            title: l10n.createTitle,
            allowClear: false,
            options: {for (final o in options) o.path: o.label(l10n)},
          );
    if (path == null || path.isEmpty || !context.mounted) return;
    // A page's own options continue its stack, so back returns to it; the
    // general ones switch to the tab that owns the form.
    if (fromPage) {
      context.push(path);
    } else {
      context.go(path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => user,
      _ => null,
    };
    final router = GoRouter.of(context);

    return Scaffold(
      backgroundColor: context.colors.ground,
      body: navigationShell,
      bottomNavigationBar: ListenableBuilder(
        // Rebuilds on every navigation, so "+" follows the page.
        listenable: router.routerDelegate,
        builder: (context, _) {
          final route = _topRoute(router.routerDelegate.currentConfiguration);
          final page = _byPage[route];
          final options = user == null || _noPlus(route)
              ? const <_PlusOption>[]
              : (page ?? _everywhere).where((o) => o.isAllowed(user)).toList();
          return SpaceBottomBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _select,
            action: options.isEmpty
                ? null
                : BottomBarAction(
                    icon: Icons.add_rounded,
                    label: l10n.createTitle,
                    onPressed: () =>
                        _open(context, options, fromPage: page != null),
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
          );
        },
      ),
    );
  }
}
