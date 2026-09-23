import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/adaptive.dart';
import '../../../l10n/app_localizations.dart';

/// Signed-in shell: Today, Accounts, Me. A Material navigation bar on
/// Android, a Cupertino tab bar on iOS. Each tab keeps its own stack.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int index) => navigationShell.goBranch(
    index,
    // Tapping the current tab returns to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cupertino = useCupertino(context);
    final tabs = [
      (
        cupertino ? CupertinoIcons.sun_max : Icons.today_outlined,
        cupertino ? CupertinoIcons.sun_max_fill : Icons.today,
        l10n.tabToday,
      ),
      (
        cupertino ? CupertinoIcons.building_2_fill : Icons.apartment_outlined,
        cupertino ? CupertinoIcons.building_2_fill : Icons.apartment,
        l10n.tabAccounts,
      ),
      (
        cupertino ? CupertinoIcons.person_crop_circle : Icons.person_outline,
        cupertino ? CupertinoIcons.person_crop_circle_fill : Icons.person,
        l10n.tabProfile,
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: cupertino
          ? CupertinoTabBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _select,
              iconSize: 26,
              items: [
                for (final (icon, activeIcon, label) in tabs)
                  BottomNavigationBarItem(
                    icon: Icon(icon),
                    activeIcon: Icon(activeIcon),
                    label: label,
                  ),
              ],
            )
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _select,
              destinations: [
                for (final (icon, activeIcon, label) in tabs)
                  NavigationDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(activeIcon),
                    label: label,
                  ),
              ],
            ),
    );
  }
}
