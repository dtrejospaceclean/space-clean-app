import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/search/text_search.dart';
import '../../../../core/widgets/us_phone.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../domain/entities/contact.dart';
import '../controllers/contacts_providers.dart';

/// "Facilities Manager · Primary · Billing": what a contact is to the account.
String contactSummary(AppLocalizations l10n, Contact c) => [
  if (c.title case final title? when title.trim().isNotEmpty) title,
  if (c.isPrimary) l10n.primaryContactTag,
  if (c.isBillingContact) l10n.billingContactTag,
].join(' · ');

/// Whether [query] appears in [c]'s name, title, email or phone (typed
/// with or without the mask), or matches Primary or Billing.
bool matchesContact(AppLocalizations l10n, Contact c, String query) =>
    matchesSearch(query, [
      c.fullName,
      contactSummary(l10n, c),
      c.email,
      c.phone,
      if (c.phone case final phone?) UsPhone.format(phone),
    ]);

/// The people at one client account, primary first, with a search. New
/// ones come from the dock's "+" (`info.edit`).
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'contacts';

  final String clientId;

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _search = TextEditingController();

  /// The API can't search contacts, but the whole list is already here.
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clientId = widget.clientId;
    final contacts = ref.watch(contactsProvider(clientId));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.infoEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(contactsProvider(clientId).future);

    return SpacePage(
      title: l10n.moduleContacts,
      onRefresh: refresh,
      slivers: [
        PageBox(
          top: 4,
          child: SearchField(
            controller: _search,
            hint: l10n.searchContactsHint,
            onChanged: (text) => setState(() => _query = text),
          ),
        ),
        AsyncSlivers(
          value: contacts,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.contacts_outlined,
                title: l10n.noContactsYet,
                hint: canEdit ? l10n.noContactsYetHint : null,
              );
            }
            final found = list
                .where((c) => matchesContact(l10n, c, _query))
                .toList();
            if (found.isEmpty) {
              return MessageSliver(
                icon: Icons.contacts_outlined,
                title: l10n.noMatchesFound,
                hint: l10n.noMatchesHint,
              );
            }
            return PageBox(
              child: ListCard(
                children: [
                  for (final contact in found)
                    ListRow(
                      leading: InitialsAvatar(name: contact.fullName),
                      title: contact.fullName,
                      subtitle: contactSummary(l10n, contact),
                      onTap: () => context.push('$here/${contact.id}'),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
