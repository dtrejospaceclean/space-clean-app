import '../../domain/entities/contract.dart';

abstract final class ContractModel {
  /// A decimal column: a string from the API, tolerated as a number.
  static String? _decimal(Object? value) => switch (value) {
    final String s => s,
    final num n => '$n',
    _ => null,
  };

  /// A date-only column: keep the calendar day, ignore the UTC time.
  static DateTime? _day(Object? value) => switch (value) {
    final String s when s.length >= 10 => DateTime.tryParse(s.substring(0, 10)),
    _ => null,
  };

  static Contract fromJson(Map<String, dynamic> json) => Contract(
    id: json['id'] as String,
    clientId: json['clientAccountId'] as String? ?? '',
    proposalId: json['proposalId'] as String?,
    proposalVersion: switch (json['proposal']) {
      {'versionNumber': final num n} => n.toInt(),
      _ => null,
    },
    contractValue: _decimal(json['contractValue']) ?? '0',
    startDate: _day(json['startDate']) ?? DateTime(1970),
    expirationDate: _day(json['expirationDate']),
    paymentTerms: json['paymentTerms'] as String?,
    status: ContractStatus.fromWire(json['status'] as String?),
    autoRenew: json['autoRenew'] as bool? ?? false,
    cancellationNoticeDays: (json['cancellationNoticeDays'] as num?)?.toInt(),
    signedByName: switch (json['signedBy']) {
      {'name': final String name} => name,
      _ => null,
    },
    signedDate: _day(json['signedDate']),
    scopeOfWorkCount: (json['scopeOfWorkCount'] as num?)?.toInt() ?? 0,
    invoiceCount: (json['invoiceCount'] as num?)?.toInt() ?? 0,
    daysUntilExpiration: (json['daysUntilExpiration'] as num?)?.toInt(),
    isExpiringSoon: json['isExpiringSoon'] as bool? ?? false,
  );
}

abstract final class ContractDraftModel {
  static String ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Body for a create or an update (`PATCH`). Money and days go as
  /// numbers. An update sends empty optional fields as null so they're
  /// cleared, but never `proposalId` (fixed) or a null value (required by
  /// the table); a create leaves empty fields out, so the value can come
  /// from the proposal and the status starts as draft.
  static Map<String, dynamic> toJson(ContractDraft d, {required bool create}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final optional = <String, dynamic>{
      'expirationDate': switch (d.expirationDate) {
        final DateTime date => ymd(date),
        null => null,
      },
      'paymentTerms': text(d.paymentTerms),
      'cancellationNoticeDays': int.tryParse(
        text(d.cancellationNoticeDays) ?? '',
      ),
    };
    if (create) optional.removeWhere((_, v) => v == null);
    return {
      if (create) 'proposalId': ?text(d.proposalId),
      'contractValue': ?num.tryParse(text(d.contractValue) ?? ''),
      'startDate': ymd(d.startDate),
      ...optional,
      'autoRenew': d.autoRenew,
    };
  }
}
