import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/contacts_providers.dart';
import '../../domain/entities/contact.dart';
import '../../domain/usecases/contact_usecases.dart';

/// An account's contacts, primary first. Refresh with `ref.invalidate`
/// after any save or delete.
final contactsProvider = FutureProvider.autoDispose
    .family<List<Contact>, String>(
      (ref, clientId) => ref.watch(getContactsProvider)(clientId),
    );

/// One contact, read from its account's list: `(clientId, contactId)`.
final contactProvider = FutureProvider.autoDispose
    .family<Contact, (String, String)>((ref, key) async {
      final (clientId, contactId) = key;
      final contacts = await ref.watch(contactsProvider(clientId).future);
      for (final contact in contacts) {
        if (contact.id == contactId) return contact;
      }
      throw const ServerFailure('client_contacts.not_found', statusCode: 404);
    });

/// Whether the signed-in user may give contacts a login (owners).
final canCreateContactLoginProvider = Provider<bool>(
  (ref) => switch (ref.watch(authControllerProvider).value) {
    Authenticated(:final user) => ContactLoginPolicy.canCreate(user),
    _ => false,
  },
);
