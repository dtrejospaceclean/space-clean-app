import '../../l10n/app_localizations.dart';

extension RoleNames on AppLocalizations {
  /// Localized name of a global or per-account base role.
  String roleName(String role) => switch (role) {
    'owner' => roleOwner,
    'account_manager' => roleAccountManager,
    'supervisor' => roleSupervisor,
    'crew' => roleCrew,
    'client' => roleClient,
    _ => role,
  };
}
