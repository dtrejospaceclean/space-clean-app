/// Domain-level errors thrown by repositories. Pure Dart: no HTTP or Flutter types.
///
/// [messageKey] is a translation key (the API's `message`, e.g. `auth.invalid_credentials`),
/// resolved to text in the presentation layer.
sealed class Failure implements Exception {
  const Failure(this.messageKey);

  final String messageKey;

  @override
  String toString() => '$runtimeType($messageKey)';
}

/// The server was unreachable or didn't answer.
final class NetworkFailure extends Failure {
  const NetworkFailure() : super(key);

  static const key = 'errors.network';
}

/// Missing, expired or rejected credentials (HTTP 401).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.messageKey);
}

/// Input rejected by the server, with errors per field path (HTTP 400 with `errors`).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.messageKey, this.fieldErrors);

  final Map<String, List<FieldError>> fieldErrors;
}

/// The backend doesn't offer this capability yet.
final class UnavailableFailure extends Failure {
  const UnavailableFailure() : super(key);

  static const key = 'errors.feature_unavailable';
}

/// A rule the app enforces itself before calling the server (the API
/// doesn't check it). [messageKey] is an app key, e.g.
/// `users.cannot_deactivate_self`.
final class RuleFailure extends Failure {
  const RuleFailure(super.messageKey);
}

/// Any other error response: forbidden, not found, conflict, server error…
final class ServerFailure extends Failure {
  const ServerFailure(super.messageKey, {required this.statusCode});

  final int statusCode;
}

/// One failed validation rule on one field.
class FieldError {
  const FieldError({
    required this.key,
    required this.fallbackMessage,
    this.params = const {},
  });

  /// Translation key, e.g. `validation.min_length`.
  final String key;

  /// English text from the server, for rules without a translation.
  final String fallbackMessage;

  /// Rule arguments in order: `constraint1`, `constraint2`, …
  final Map<String, Object?> params;
}
