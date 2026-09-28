import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/contacts/data/models/contact_model.dart';
import 'package:sp_cln_app/features/contacts/domain/entities/contact.dart';

void main() {
  test('reads a contact and whether it has a login', () {
    final contact = ContactModel.fromJson({
      'id': 'k1',
      'clientAccountId': 'c1',
      'userId': 'u9',
      'firstName': 'Laura',
      'lastName': 'Gómez',
      'title': 'Facilities Manager',
      'email': 'laura@torrenorte.com',
      'phone': null,
      'isPrimary': true,
      'isBillingContact': false,
      'notes': null,
    });

    expect(contact.fullName, 'Laura Gómez');
    expect(contact.clientId, 'c1');
    expect(contact.isPrimary, isTrue);
    expect(contact.phone, isNull);
    expect(contact.hasLogin, isTrue);
  });

  const draft = ContactDraft(
    firstName: ' Laura ',
    lastName: 'Gómez',
    title: '  ',
    email: 'laura@torrenorte.com ',
    isBillingContact: true,
  );

  test('a new contact sends only the fields that were filled in', () {
    expect(ContactDraftModel.toJson(draft, create: true), {
      'firstName': 'Laura',
      'lastName': 'Gómez',
      'email': 'laura@torrenorte.com',
      'isPrimary': false,
      'isBillingContact': true,
    });
  });

  test('an update clears the optional fields left empty', () {
    expect(ContactDraftModel.toJson(draft, create: false), {
      'firstName': 'Laura',
      'lastName': 'Gómez',
      'title': null,
      'email': 'laura@torrenorte.com',
      'phone': null,
      'notes': null,
      'isPrimary': false,
      'isBillingContact': true,
    });
  });
}
