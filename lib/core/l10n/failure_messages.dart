import '../../l10n/app_localizations.dart';
import '../error/failures.dart';

/// Maps API translation keys (`auth.invalid_credentials`, `validation.is_email`…)
/// to localized text. Add cases here as features start surfacing new keys.
extension FailureMessages on AppLocalizations {
  String failureMessage(Failure failure) => messageForKey(failure.messageKey);

  String messageForKey(String key) => switch (key) {
    'auth.invalid_credentials' => authInvalidCredentials,
    'auth.missing_token' ||
    'auth.invalid_access_token' ||
    'auth.invalid_refresh_token' => authSessionExpired,
    'auth.insufficient_permission' => authInsufficientPermission,
    'auth.insufficient_role' => authInsufficientRole,
    'validation.failed' => validationFailed,
    NetworkFailure.key => errorsNetwork,
    UnavailableFailure.key => errorsFeatureUnavailable,
    'users.email_taken' => usersEmailTaken,
    'users.not_found' => usersNotFound,
    'roles.still_assigned' => rolesStillAssigned,
    'roles.system_role_not_renamable' ||
    'roles.system_role_not_deletable' => rolesSystemRole,
    'roles.some_not_found' => rolesSomeNotFound,
    'errors.unique_violation' => errorsUniqueViolation,
    'errors.too_many_requests' => errorsTooManyRequests,
    'errors.not_found' => errorsNotFound,
    'errors.internal' => errorsInternal,
    _ => errorsUnknown,
  };

  /// Falls back to the server's English message for rules without a translation.
  String fieldError(FieldError error) {
    final firstParam = '${error.params['constraint1'] ?? ''}';
    return switch (error.key) {
      'validation.is_not_empty' => validationRequired,
      'validation.is_email' => validationInvalidEmail,
      'validation.min_length' => validationMinLength(firstParam),
      'validation.max_length' => validationMaxLength(firstParam),
      _ when error.fallbackMessage.isNotEmpty => error.fallbackMessage,
      _ => errorsUnknown,
    };
  }
}
