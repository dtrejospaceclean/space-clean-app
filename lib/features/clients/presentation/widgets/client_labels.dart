import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/client.dart';

extension ClientLabels on AppLocalizations {
  String clientStatusLabel(ClientStatus status) => switch (status) {
    ClientStatus.prospect => clientStatusProspect,
    ClientStatus.active => clientStatusActive,
    ClientStatus.inactive => clientStatusInactive,
    ClientStatus.unknown => notSet,
  };
}
