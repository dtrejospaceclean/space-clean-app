import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/contacts_remote_data_source.dart';
import '../data/repositories/contacts_repository_impl.dart';
import '../domain/repositories/contacts_repository.dart';
import '../domain/usecases/contact_usecases.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>(
  (ref) => ContactsRepositoryImpl(
    ContactsRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getContactsProvider = Provider(
  (ref) => GetContacts(ref.watch(contactsRepositoryProvider)),
);
final saveContactProvider = Provider(
  (ref) => SaveContact(ref.watch(contactsRepositoryProvider)),
);
final deleteContactProvider = Provider(
  (ref) => DeleteContact(ref.watch(contactsRepositoryProvider)),
);
final createContactLoginProvider = Provider(
  (ref) => CreateContactLogin(ref.watch(contactsRepositoryProvider)),
);
