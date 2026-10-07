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
    'auth.wrong_current_password' => authWrongCurrentPassword,
    'validation.failed' => validationFailed,
    NetworkFailure.key => errorsNetwork,
    UnavailableFailure.key => errorsFeatureUnavailable,
    'users.email_taken' => usersEmailTaken,
    'users.not_found' => usersNotFound,
    'users.cannot_deactivate_self' => usersCannotDeactivateSelf,
    'users.photo_required' => usersPhotoRequired,
    'users.photo_invalid_type' => usersPhotoInvalidType,
    'users.photo_too_large' => usersPhotoTooLarge,
    'roles.still_assigned' => rolesStillAssigned,
    'roles.system_role_not_renamable' ||
    'roles.system_role_not_deletable' => rolesSystemRole,
    'roles.some_not_found' => rolesSomeNotFound,
    'clients.not_found' => clientsNotFound,
    'clients.assignee_not_active' => clientsAssigneeNotActive,
    'clients.has_related_records' => clientsHasRelatedRecords,
    'client_contacts.not_found' => clientContactsNotFound,
    'locations.not_found' => locationsNotFound,
    'members.not_found' => membersNotFound,
    'proposals.not_found' => proposalsNotFound,
    'proposals.not_current_version' => proposalsNotCurrentVersion,
    'proposals.already_approved' => proposalsAlreadyApproved,
    'proposals.has_related_records' => proposalsHasRelatedRecords,
    'proposals.agreed_price_required' => proposalsAgreedPriceRequired,
    'contracts.not_found' => contractsNotFound,
    'contracts.contract_value_required' => contractsValueRequired,
    'contracts.proposal_not_approved' => contractsProposalNotApproved,
    'contracts.already_signed' => contractsAlreadySigned,
    'contracts.cancelled' => contractsCancelled,
    'contracts.only_drafts_deletable' => contractsOnlyDraftsDeletable,
    'contracts.has_related_records' => contractsHasRelatedRecords,
    'scopes.not_found' => scopesNotFound,
    'scopes.days_of_week_required' => scopesDaysOfWeekRequired,
    'scopes.has_jobs' => scopesHasJobs,
    'calendar.not_found' => calendarNotFound,
    'calendar.invalid_range' || 'calendar.range_too_wide' => calendarBadRange,
    'calendar.cancelled' => calendarCancelled,
    'calendar.already_converted' => calendarAlreadyConverted,
    'jobs.not_found' => jobsNotFound,
    'jobs.not_assigned' => jobsNotAssigned,
    'jobs.assignee_not_active' => jobsAssigneeNotActive,
    'jobs.location_required' => jobsLocationRequired,
    'jobs.closed' => jobsClosed,
    'jobs.already_completed' => jobsAlreadyCompleted,
    'jobs.only_scheduled_deletable' => jobsOnlyScheduledDeletable,
    'members.user_not_active' => membersUserNotActive,
    'locations.has_related_records' => locationInUse,
    'client_contacts.email_required' => clientContactsEmailRequired,
    'client_contacts.login_exists' => clientContactsLoginExists,
    'service_catalog.not_found' => serviceCatalogNotFound,
    'service_catalog.some_not_found' => serviceCatalogSomeNotFound,
    'service_catalog.category_not_found' => serviceCatalogCategoryNotFound,
    'service_catalog.unit_not_found' => serviceCatalogUnitNotFound,
    'service_categories.not_found' => serviceCategoriesNotFound,
    'service_categories.in_use' => serviceCategoriesInUse,
    'units_of_measure.not_found' => unitsOfMeasureNotFound,
    'units_of_measure.in_use' => unitsOfMeasureInUse,
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
