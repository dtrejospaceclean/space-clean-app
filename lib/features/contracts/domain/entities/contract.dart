/// Where a contract stands. "Expiring soon" isn't one: it's worked out from
/// the expiration date ([Contract.isExpiringSoon]).
enum ContractStatus {
  draft('draft'),
  active('active'),
  expired('expired'),
  cancelled('cancelled'),

  /// A status this app doesn't know yet.
  unknown('');

  const ContractStatus(this.wire);

  /// The API's name for it.
  final String wire;

  static ContractStatus fromWire(String? value) => values.firstWhere(
    (s) => s != unknown && s.wire == value,
    orElse: () => unknown,
  );
}

/// An agreement with a client account, usually from an approved proposal.
/// Signing activates it; a cancelled contract is read-only.
class Contract {
  const Contract({
    required this.id,
    required this.clientId,
    required this.contractValue,
    required this.startDate,
    required this.status,
    this.proposalId,
    this.proposalVersion,
    this.expirationDate,
    this.paymentTerms,
    this.autoRenew = false,
    this.cancellationNoticeDays,
    this.signedByName,
    this.signedDate,
    this.scopeOfWorkCount = 0,
    this.invoiceCount = 0,
    this.daysUntilExpiration,
    this.isExpiringSoon = false,
  });

  final String id;
  final String clientId;

  /// The approved proposal version it came from, if any. Fixed once the
  /// contract exists.
  final String? proposalId;
  final int? proposalVersion;

  /// A decimal string ("2400").
  final String contractValue;

  /// Calendar days (no time).
  final DateTime startDate;
  final DateTime? expirationDate;

  /// e.g. "Net 30".
  final String? paymentTerms;
  final ContractStatus status;
  final bool autoRenew;
  final int? cancellationNoticeDays;
  final String? signedByName;

  /// A calendar day; null until signed.
  final DateTime? signedDate;
  final int scopeOfWorkCount;
  final int invoiceCount;

  /// Days from today to [expirationDate] (negative once past); null without
  /// one. Worked out by the server.
  final int? daysUntilExpiration;

  /// Active and within 30 days of its expiration date.
  final bool isExpiringSoon;

  bool get isSigned => signedDate != null;
  bool get isCancelled => status == ContractStatus.cancelled;

  /// Anything but a cancelled contract can still change.
  bool get isEditable => !isCancelled;

  /// Signing records who and when, once, and activates it.
  bool get canSign => !isSigned && !isCancelled;

  /// Any active contract can be closed out as expired by hand; the server
  /// never does it on its own.
  bool get canMarkExpired => status == ContractStatus.active;

  /// Only a draft nothing was built on can be deleted; the rest is history.
  bool get canDelete =>
      status == ContractStatus.draft &&
      scopeOfWorkCount == 0 &&
      invoiceCount == 0;

  /// How long it runs, start to expiration, in the largest whole unit:
  /// years or months when the end falls on the start's day of the month
  /// (Jan 15 – Jul 15 is 6 months), days otherwise. Null without an end
  /// after the start.
  ContractTerm? get term {
    final end = expirationDate;
    if (end == null) return null;
    final months =
        (end.year - startDate.year) * 12 + end.month - startDate.month;
    if (end.day == startDate.day && months > 0) {
      return months % 12 == 0
          ? ContractTerm(months ~/ 12, TermUnit.years)
          : ContractTerm(months, TermUnit.months);
    }
    // In UTC, so a daylight-saving change doesn't lose a day.
    final days = DateTime.utc(end.year, end.month, end.day)
        .difference(
          DateTime.utc(startDate.year, startDate.month, startDate.day),
        )
        .inDays;
    return days > 0 ? ContractTerm(days, TermUnit.days) : null;
  }
}

enum TermUnit { days, months, years }

/// A contract's length: [count] of [unit].
class ContractTerm {
  const ContractTerm(this.count, this.unit);

  final int count;
  final TermUnit unit;

  @override
  bool operator ==(Object other) =>
      other is ContractTerm && other.count == count && other.unit == unit;

  @override
  int get hashCode => Object.hash(count, unit);

  @override
  String toString() => '$count ${unit.name}';
}

/// The editable fields of a contract, as typed. Empty optional fields clear
/// them on an edit.
class ContractDraft {
  const ContractDraft({
    required this.startDate,
    this.proposalId,
    this.contractValue,
    this.expirationDate,
    this.paymentTerms,
    this.autoRenew = false,
    this.cancellationNoticeDays,
  });

  /// Only on a create. With it, an empty [contractValue] takes the
  /// proposal's agreed price.
  final String? proposalId;

  /// As typed, up to two decimals.
  final String? contractValue;
  final DateTime startDate;
  final DateTime? expirationDate;
  final String? paymentTerms;
  final bool autoRenew;

  /// As typed: a whole number of days.
  final String? cancellationNoticeDays;
}
