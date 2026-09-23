import '../../domain/entities/client.dart';

abstract final class ClientModel {
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
  );
}
