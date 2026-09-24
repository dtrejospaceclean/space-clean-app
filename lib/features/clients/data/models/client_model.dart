import '../../domain/entities/client.dart';

abstract final class ClientModel {
  /// A list row (`GET /clients`) or a single account (`GET /clients/:id`).
  static Client fromJson(Map<String, dynamic> json) => Client(
    id: json['id'] as String,
    legalName: json['legalName'] as String? ?? '',
    dba: json['dba'] as String?,
    status: switch (json['status']) {
      'prospect' => ClientStatus.prospect,
      'active' => ClientStatus.active,
      'inactive' => ClientStatus.inactive,
      _ => ClientStatus.unknown,
    },
    locationCount: (json['locationCount'] as num?)?.toInt(),
    contactCount: switch (json['contacts']) {
      final List contacts => contacts.length,
      _ => (json['contactCount'] as num?)?.toInt(),
    },
    industry: json['industry'] as String?,
    serviceType: json['serviceType'] as String?,
    taxId: json['taxId'] as String?,
    billingAddress: json['billingAddress'] as String?,
    billingCity: json['billingCity'] as String?,
    billingState: json['billingState'] as String?,
    billingZip: json['billingZip'] as String?,
    accountManager: _assignee(json['accountManager']),
    supervisor: _assignee(json['supervisor']),
    salesperson: _assignee(json['salesperson']),
  );

  static ClientAssignee? _assignee(Object? json) => switch (json) {
    {'id': final String id} && final Map m => ClientAssignee(
      id: id,
      name: m['name'] as String? ?? '',
      email: m['email'] as String?,
    ),
    _ => null,
  };
}

abstract final class ClientDraftModel {
  /// Body for `POST /clients` / `PATCH /clients/:id`. Only fields the server
  /// accepts; unknown ones would fail the whole request.
  static Map<String, dynamic> toJson(ClientDraft d, {required bool create}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final body = <String, dynamic>{
      'legalName': ?text(d.legalName),
      'dba': ?text(d.dba),
      'industry': ?text(d.industry),
      'status': ?switch (d.status) {
        ClientStatus.prospect => 'prospect',
        ClientStatus.active => 'active',
        ClientStatus.inactive => 'inactive',
        ClientStatus.unknown || null => null,
      },
      'serviceType': ?text(d.serviceType),
      'taxId': ?text(d.taxId),
      'billingAddress': ?text(d.billingAddress),
      'billingCity': ?text(d.billingCity),
      'billingState': ?text(d.billingState),
      'billingZip': ?text(d.billingZip),
      'accountManagerUserId': ?d.accountManagerUserId,
      'supervisorUserId': ?d.supervisorUserId,
      'salespersonUserId': ?d.salespersonUserId,
    };
    if (!create) {
      for (final field in d.cleared) {
        body.putIfAbsent(field, () => null);
      }
    }
    return body;
  }
}
