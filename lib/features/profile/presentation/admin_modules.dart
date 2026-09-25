import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/domain/entities/user.dart';
import '../../users/domain/usecases/user_usecases.dart';
import '../../users/presentation/screens/roles_screen.dart';
import '../../users/presentation/screens/users_screen.dart';

/// One staff-wide tool under Me → Administration.
class AdminModule {
  const AdminModule({
    required this.icon,
    required this.label,
    required this.description,
    required this.path,
    required this.isVisibleTo,
  });

  final IconData icon;
  final String Function(AppLocalizations l10n) label;

  /// What's inside, in a few words.
  final String Function(AppLocalizations l10n) description;
  final String path;

  /// Gated by the global role (these tools aren't tied to an account).
  final bool Function(User user) isVisibleTo;
}

/// Every administration tool the app has built, in display order. To add
/// one, give it a route under `/me` and an entry here; the Me screen picks
/// it up for whoever may see it.
final adminModules = <AdminModule>[
  AdminModule(
    icon: Icons.group_outlined,
    label: (l10n) => l10n.usersTitle,
    description: (l10n) => l10n.adminUsersHint,
    path: UsersScreen.path,
    isVisibleTo: UserAdminPolicy.canView,
  ),
  AdminModule(
    icon: Icons.admin_panel_settings_outlined,
    label: (l10n) => l10n.rolesTitle,
    description: (l10n) => l10n.adminRolesHint,
    path: RolesScreen.path,
    isVisibleTo: UserAdminPolicy.canView,
  ),
];

/// The tools [user] may open, in display order.
List<AdminModule> visibleAdminModules(User user) =>
    adminModules.where((m) => m.isVisibleTo(user)).toList();
