import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/search/text_search.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/chat_providers.dart';
import '../../domain/entities/chat.dart';
import 'chat_list_screen.dart';

/// Who the user may message directly (`GET /me/chat/contacts`). Picking
/// someone opens the conversation with them, starting it if it's new.
final chatContactsProvider = FutureProvider.autoDispose<List<ChatContact>>(
  (ref) => ref.watch(getChatContactsProvider)(const NoParams()),
);

class ChatContactsScreen extends ConsumerStatefulWidget {
  const ChatContactsScreen({super.key});

  static const route = 'new';

  @override
  ConsumerState<ChatContactsScreen> createState() => _ChatContactsScreenState();
}

class _ChatContactsScreenState extends ConsumerState<ChatContactsScreen> {
  final _search = TextEditingController();
  String? _opening;
  Failure? _failure;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(ChatContact contact) async {
    setState(() {
      _opening = contact.id;
      _failure = null;
    });
    try {
      final channel = await ref.read(openChatChannelProvider)(
        DirectChat(contact.id),
      );
      if (!mounted) return;
      // The conversation takes this page's place.
      context.pushReplacement(ChatListScreen.channelPath(channel.id));
    } on Failure catch (f) {
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _opening = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contacts = ref.watch(chatContactsProvider);
    Future<void> refresh() => ref.refresh(chatContactsProvider.future);
    return SpacePage(
      title: l10n.chatContactsTitle,
      onRefresh: refresh,
      slivers: [
        if (_failure case final failure?)
          PageBox(child: Notice(message: l10n.failureMessage(failure))),
        AsyncSlivers<List<ChatContact>>(
          value: contacts,
          onRetry: refresh,
          builder: (all) {
            if (all.isEmpty) {
              return MessageSliver(
                icon: Icons.people_outline_rounded,
                title: l10n.chatNoContacts,
                hint: l10n.chatNoContactsHint,
              );
            }
            final shown = [
              for (final c in all)
                if (matchesSearch(_search.text, [c.name])) c,
            ];
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  child: SearchField(
                    controller: _search,
                    hint: l10n.searchPeopleHint,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (shown.isEmpty)
                  MessageSliver(
                    icon: Icons.search_off_rounded,
                    title: l10n.noMatchesFound,
                    hint: l10n.noMatchesHint,
                  )
                else
                  PageBox(
                    child: ListCard(
                      children: [
                        for (final c in shown)
                          ListRow(
                            leading: InitialsAvatar(
                              name: c.name,
                              photoUrl: c.photoUrl,
                            ),
                            title: c.name,
                            trailing: _opening == c.id
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : null,
                            onTap: _opening == null ? () => _open(c) : null,
                          ),
                      ],
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
