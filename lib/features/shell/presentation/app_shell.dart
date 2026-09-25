import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../l10n/app_localizations.dart';

/// Signed-in shell: Today, Accounts, Me, with the custom white tab bar.
/// Each tab keeps its own stack.
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
    return Scaffold(
      backgroundColor: context.colors.ground,
      body: navigationShell,
      bottomNavigationBar: SpaceBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _select,
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
