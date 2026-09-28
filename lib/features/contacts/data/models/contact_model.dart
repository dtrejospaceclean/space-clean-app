import '../../domain/entities/contact.dart';

abstract final class ContactModel {
  static Contact fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'] as String,
    clientId: json['clientAccountId'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    title: json['title'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    isPrimary: json['isPrimary'] as bool? ?? false,
    isBillingContact: json['isBillingContact'] as bool? ?? false,
    notes: json['notes'] as String?,
    userId: json['userId'] as String?,
  );
}

abstract final class ContactDraftModel {
  /// Body for `POST …/contacts` / `PATCH …/contacts/:id`. An update sends
  /// empty optional fields as null so they're cleared; a create leaves them
  /// out.
  static Map<String, dynamic> toJson(ContactDraft d, {required bool create}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final optional = {
      'title': text(d.title),
      'email': text(d.email),
      'phone': text(d.phone),
      'notes': text(d.notes),
    };
    if (create) optional.removeWhere((_, v) => v == null);
    return {
      'firstName': d.firstName.trim(),
      'lastName': d.lastName.trim(),
      ...optional,
      'isPrimary': d.isPrimary,
      'isBillingContact': d.isBillingContact,
    };
  }
}
