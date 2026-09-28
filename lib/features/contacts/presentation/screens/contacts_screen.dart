import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
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

/// The people at one client account, primary first. New ones come from
/// the dock's "+" (`info.edit`).
class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'contacts';

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
            return PageBox(
              top: 4,
              child: ListCard(
                children: [
                  for (final contact in list)
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
