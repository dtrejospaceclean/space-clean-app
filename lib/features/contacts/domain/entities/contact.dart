/// A person at a client account (the client's own people, not staff).
class Contact {
  const Contact({
    required this.id,
    required this.clientId,
    required this.firstName,
    required this.lastName,
    this.title,
    this.email,
    this.phone,
    this.isPrimary = false,
    this.isBillingContact = false,
    this.notes,
    this.userId,
  });

  final String id;
  final String clientId;
  final String firstName;
  final String lastName;

  /// Their job title at the client, e.g. "Facilities Manager".
  final String? title;
  final String? email;
  final String? phone;

  /// The main person to talk to. At most one per account.
  final bool isPrimary;

  /// Who receives invoices. At most one per account.
  final bool isBillingContact;
  final String? notes;

  /// Set once the contact has been given a login.
  final String? userId;

  String get fullName => '$firstName $lastName'.trim();

  bool get hasLogin => userId != null;
}

/// The editable fields of a contact. Empty optional fields are cleared.
class ContactDraft {
  const ContactDraft({
    required this.firstName,
    required this.lastName,
    this.title,
    this.email,
    this.phone,
    this.isPrimary = false,
    this.isBillingContact = false,
    this.notes,
  });

  final String firstName;
  final String lastName;
  final String? title;
  final String? email;
  final String? phone;

  /// Setting either flag clears it on the account's other contacts.
  final bool isPrimary;
  final bool isBillingContact;
  final String? notes;
}

/// The sign-in created for a contact.
class ContactLogin {
  const ContactLogin({required this.userId, required this.email});

  final String userId;
  final String email;
}
