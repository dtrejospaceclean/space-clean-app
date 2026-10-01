import '../../domain/entities/proposal.dart';

abstract final class ProposalModel {
  /// A decimal column: a string from the API, tolerated as a number.
  static String? _decimal(Object? value) => switch (value) {
    final String s => s,
    final num n => '$n',
    _ => null,
  };

  static DateTime? _timestamp(Object? value) => switch (value) {
    final String s => DateTime.tryParse(s)?.toLocal(),
    _ => null,
  };

  static String? _name(Object? user) => switch (user) {
    {'name': final String name} => name,
    _ => null,
  };

  static Proposal fromJson(Map<String, dynamic> json) => Proposal(
    id: json['id'] as String,
    clientId: json['clientAccountId'] as String? ?? '',
    groupId: json['proposalGroupId'] as String? ?? '',
    stage: ProposalStage.fromWire(json['pipelineStage'] as String?),
    versionNumber: (json['versionNumber'] as num?)?.toInt() ?? 1,
    isCurrent: json['isCurrent'] as bool? ?? true,
    versionNote: json['versionNote'] as String?,
    agreedPrice: _decimal(json['agreedPrice']),
    validUntil: switch (json['validUntilDate']) {
      // A date-only column: keep the calendar day, ignore the UTC time.
      final String s when s.length >= 10 => DateTime.tryParse(
        s.substring(0, 10),
      ),
      _ => null,
    },
    preparedByName: _name(json['preparedBy']),
    approvedByName: _name(json['approvedBy']),
    approvedDate: _timestamp(json['approvedDate']),
    createdAt: _timestamp(json['createdAt']),
    lineItems: [
      for (final item in (json['lineItems'] as List? ?? const []))
        _lineItem((item as Map).cast<String, dynamic>()),
    ],
  );

  static ProposalLineItem _lineItem(Map<String, dynamic> json) =>
      ProposalLineItem(
        id: json['id'] as String? ?? '',
        serviceId: json['serviceCatalogId'] as String?,
        description: json['description'] as String? ?? '',
        quantity: _decimal(json['quantity']) ?? '0',
        unitPrice: _decimal(json['unitPrice']) ?? '0',
        lineTotal: _decimal(json['lineTotal']) ?? '0',
      );
}

enum DraftTarget { create, update, version }

abstract final class ProposalDraftModel {
  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Body for a create, an update (`PATCH`) or a new version. Money and
  /// quantities go as numbers; `lineTotal` is never sent (the server
  /// computes it). An update sends empty optional fields as null so they're
  /// cleared; a create or a new version leaves them out (a new version
  /// would otherwise fall back to the previous version's values anyway).
  static Map<String, dynamic> toJson(
    ProposalDraft d, {
    required DraftTarget target,
  }) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final optional = <String, dynamic>{
      'agreedPrice': num.tryParse(text(d.agreedPrice) ?? ''),
      'validUntilDate': switch (d.validUntil) {
        final DateTime date => _ymd(date),
        null => null,
      },
      'versionNote': text(d.versionNote),
    };
    if (target != DraftTarget.update) {
      optional.removeWhere((_, v) => v == null);
    }
    return {
      'pipelineStage': d.stage.wire,
      ...optional,
      'lineItems': [
        for (final item in d.lineItems)
          {
            'serviceCatalogId': ?text(item.serviceId),
            'description': item.description.trim(),
            'quantity': num.tryParse(item.quantity.trim()) ?? 0,
            'unitPrice': num.tryParse(item.unitPrice.trim()) ?? 0,
          },
      ],
    };
  }
}
