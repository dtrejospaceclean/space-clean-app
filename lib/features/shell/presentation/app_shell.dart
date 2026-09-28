import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/domain/entities/account_access.dart';
import '../../access/presentation/controllers/account_access_provider.dart';
import '../../auth/domain/entities/user.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../clients/domain/usecases/manage_clients.dart';
import '../../clients/presentation/screens/accounts_screen.dart';
import '../../contacts/presentation/screens/contacts_screen.dart';
import '../../locations/presentation/screens/locations_screen.dart';
import '../../service_catalog/domain/usecases/service_catalog_usecases.dart';
import '../../service_catalog/presentation/screens/services_screen.dart';
import '../../users/domain/usecases/user_usecases.dart';
import '../../users/presentation/screens/users_screen.dart';

/// Something the "+" beside the tab dock can open.
class _PlusOption {
  const _PlusOption(this.path, this.label, this.isAllowed) : permission = null;

  /// Inside an account: [path] may contain `:clientId`, filled from the page.
  const _PlusOption.inAccount(this.path, this.label, String this.permission)
    : isAllowed = null;

  final String path;
  final String Function(AppLocalizations l10n) label;

  /// Gated by the global role, like the screen it opens...
  final bool Function(User user)? isAllowed;

  /// ...or by a permission on the account the page belongs to.
  final String? permission;

  /// [path] with the page's parameters (`:clientId`) filled in.
  String pathFor(Map<String, String> params) => params.entries.fold(
    path,
    (path, p) => path.replaceAll(':${p.key}', p.value),
  );

  bool allows(User user, AccountAccess? access) => switch (permission) {
    null => isAllowed!(user),
    final permission => access?.can(permission) ?? false,
  };
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
  '${AccountsScreen.path}/:clientId/${ContactsScreen.route}': [
    _PlusOption.inAccount(
      '${AccountsScreen.path}/:clientId/${ContactsScreen.route}/new',
      (l10n) => l10n.newContactTitle,
      Permissions.infoEdit,
    ),
  ],
  '${AccountsScreen.path}/:clientId/${LocationsScreen.route}': [
    _PlusOption.inAccount(
      '${AccountsScreen.path}/:clientId/${LocationsScreen.route}/new',
      (l10n) => l10n.newLocationTitle,
      Permissions.infoEdit,
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
    route.endsWith('/login') ||
    route.startsWith('${ServicesScreen.path}/:') ||
    route.startsWith('${CategoriesScreen.path}/:') ||
    route.startsWith('${UnitsScreen.path}/:');

/// The matches of the page on top: its route pattern ("/me/services") and
/// path parameters. Pushed pages sit in the list as imperative matches, so
/// follow them down.
RouteMatchList _top(RouteMatchList matches) => switch (matches.lastOrNull) {
  final ImperativeRouteMatch pushed => _top(pushed.matches),
  _ => matches,
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
    required Map<String, String> params,
    required bool fromPage,
  }) async {
    final l10n = AppLocalizations.of(context);
    final path = options.length == 1
        ? options.single.pathFor(params)
        : await showAppChoice(
            context,
            // The options name themselves ("New service", "Manage units").
            allowClear: false,
            options: {
              for (final o in options) o.pathFor(params): o.label(l10n),
            },
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
        builder: (context, _) => Consumer(
          builder: (context, ref, _) {
            final top = _top(router.routerDelegate.currentConfiguration);
            final route = top.fullPath;
            final page = _byPage[route];
            // Pages inside an account gate "+" by the user's permissions there.
            final access = switch (top.pathParameters['clientId']) {
              final clientId? =>
                ref.watch(accountAccessProvider(clientId)).value,
              null => null,
            };
            final options = user == null || _noPlus(route)
                ? const <_PlusOption>[]
                : (page ?? _everywhere)
                      .where((o) => o.allows(user, access))
                      .toList();
            return SpaceBottomBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _select,
              action: options.isEmpty
                  ? null
                  : BottomBarAction(
                      icon: Icons.add_rounded,
                      label: l10n.createTitle,
                      onPressed: () => _open(
                        context,
                        options,
                        params: top.pathParameters,
                        fromPage: page != null,
                      ),
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
      ),
    );
  }
}
