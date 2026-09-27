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
}
