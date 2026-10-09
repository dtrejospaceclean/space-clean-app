import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../di/contacts_providers.dart';
import '../../domain/entities/contact.dart';
import '../../domain/usecases/contact_usecases.dart';
import '../controllers/contacts_providers.dart';
import '../../../../core/widgets/us_phone.dart';

/// One contact: a head card (name, title, tags, Edit), then capitals-titled
/// cards for how to reach them and whether they can sign in. Editing and deleting need `info.edit`; giving them a
/// login is for global owners.
class ContactScreen extends ConsumerWidget {
  const ContactScreen({
    super.key,
    required this.clientId,
    required this.contactId,
  });

  final String clientId;
  final String contactId;

  Future<void> _delete(BuildContext context, WidgetRef ref, Contact c) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.deleteRoleConfirmTitle(c.fullName)),
        // Deleting the contact leaves their login and membership in place.
        content: Text(
          c.hasLogin
              ? l10n.deleteContactWithLoginBody
              : l10n.deleteRoleConfirmBody,
        ),
        actions: [
          adaptiveAction(
            context,
            label: l10n.cancelButton,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.deleteButton,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(deleteContactProvider)(
        ContactRef(clientId: clientId, contactId: c.id),
      );
      if (!context.mounted) return;
      // Leave before the list reloads, so this page doesn't flash "not
      // found" on its way out.
      context.pop();
      ref.invalidate(contactsProvider(clientId));
    } on Failure catch (f) {
      if (context.mounted) {
        await showAdaptiveDialog<void>(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            content: Text(l10n.failureMessage(f)),
            actions: [
              adaptiveAction(
                context,
                label: l10n.doneButton,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final contact = ref.watch(contactProvider((clientId, contactId)));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.infoEdit) ??
        false;
    final canGiveLogin = ref.watch(canCreateContactLoginProvider);
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(contactsProvider(clientId).future);

    String? orNull(String? v) => v == null || v.trim().isEmpty ? null : v;

    return SpacePage(
      title: l10n.contactTitle,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: contact,
          onRetry: refresh,
          builder: (c) {
            final Widget? signIn = switch (c) {
              Contact(hasLogin: true) => ListRow(
                title: l10n.contactHasLogin,
                subtitle: l10n.contactHasLoginHint,
              ),
              // A login is made from the contact's email.
              _ when !canGiveLogin => null,
              Contact(:final email?) when email.trim().isNotEmpty => ListRow(
                title: l10n.giveLogin,
                subtitle: l10n.signsInWith(email),
                onTap: () => context.push('$here/login'),
              ),
              _ => ListRow(
                title: l10n.giveLogin,
                subtitle: l10n.giveLoginNeedsEmail,
                muted: true,
              ),
            };
            // Beside the name it would squeeze it at large text sizes, so
            // it moves under the tags there.
            final large = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
            final edit = canEdit
                ? PillButton(
                    label: l10n.editButton,
                    icon: Icons.edit_outlined,
                    tooltip: l10n.editContact,
                    onPressed: () => context.push('$here/edit'),
                  )
                : null;

            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: SpaceCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InitialsAvatar(name: c.fullName, size: 64),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.fullName,
                                style: theme.textTheme.titleLarge,
                              ),
                              if (orNull(c.title) case final title?) ...[
                                const SizedBox(height: 2),
                                Text(
                                  title.toUpperCase(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                              if (c.isPrimary || c.isBillingContact) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final (on, label) in [
                                      (c.isPrimary, l10n.primaryContactTag),
                                      (
                                        c.isBillingContact,
                                        l10n.billingContactTag,
                                      ),
                                    ])
                                      if (on)
                                        StatusPill(
                                          label: label,
                                          color: context.colors.accent,
                                          background: context.colors.accentSoft,
                                        ),
                                  ],
                                ),
                              ],
                              if (edit != null && large) ...[
                                const SizedBox(height: 10),
                                edit,
                              ],
                            ],
                          ),
                        ),
                        if (edit != null && !large) ...[
                          const SizedBox(width: 8),
                          edit,
                        ],
                      ],
                    ),
                  ),
                ),
                PageBox(top: 16, child: CapsHeader(l10n.sectionContact)),
                PageBox(
                  top: 0,
                  child: FactCard(
                    rows: [
                      [(l10n.emailLabel, orNull(c.email))],
                      [(l10n.phoneLabel, orNull(UsPhone.format(c.phone)))],
                      if (orNull(c.notes) case final notes?)
                        [(l10n.notesLabel, notes)],
                    ],
                  ),
                ),
                if (signIn != null) ...[
                  PageBox(top: 16, child: CapsHeader(l10n.sectionSignIn)),
                  PageBox(top: 0, child: ListCard(children: [signIn])),
                ],
                if (canEdit)
                  PageBox(
                    top: 20,
                    child: Center(
                      child: LinkButton(
                        label: l10n.deleteContact,
                        icon: Icons.delete_outline_rounded,
                        destructive: true,
                        onPressed: () => _delete(context, ref, c),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
