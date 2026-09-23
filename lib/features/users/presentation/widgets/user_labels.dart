import '../../../../core/l10n/role_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/managed_user.dart';

extension UserLabels on AppLocalizations {
  /// Localized employment type; unknown values are shown as stored.
  String employmentLabel(String type) => switch (type) {
    EmploymentTypes.fullTime => employmentFullTime,
    EmploymentTypes.partTime => employmentPartTime,
    EmploymentTypes.contractor => employmentContractor,
    _ => type,
  };

  /// "Supervisor, Crew", or the custom role's identifier as is.
  String rolesLabel(Iterable<String> names) => names.map(roleName).join(', ');
}
