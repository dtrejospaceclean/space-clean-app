import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/chat_session.dart';
import '../widgets/chat_status.dart';
import 'chat_contacts_screen.dart';

/// Every conversation the user is in, latest first (Stream's own list):
/// their accounts' channels, job and complaint threads and direct
/// messages. Opened from Today.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  static const path = '/today/chat';

  static String channelPath(String channelId) =>
      '$path/${Uri.encodeComponent(channelId)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(chatSessionProvider);
    return SpacePage(
      title: l10n.chatTitle,
      actions: [
        if (session is ChatReady)
          CircleButton.light(
            icon: Icons.edit_square,
            tooltip: l10n.chatNewMessage,
            onPressed: () => context.push('$path/${ChatContactsScreen.route}'),
          ),
      ],
      body: switch (session) {
        ChatReady(:final client) => _ChannelList(client: client),
        _ => ChatStatus(session: session),
      },
    );
  }
}

class _ChannelList extends StatefulWidget {
  const _ChannelList({required this.client});

  final StreamChatClient client;

  @override
  State<_ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<_ChannelList> {
  late final _controller = StreamChannelListController(
    client: widget.client,
    filter: Filter.in_('members', [widget.client.state.currentUser!.id]),
    channelStateSort: const [SortOption.desc('last_message_at')],
    limit: 20,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const corner = Radius.circular(SpaceRadius.card);
    final side = pageSide(context);
    return RefreshIndicator.adaptive(
      onRefresh: _controller.refresh,
      color: context.colors.primary,
      // Stream's rows, grouped in one white card like the app's ListCard.
      child: StreamChannelListView(
        controller: _controller,
        padding: EdgeInsets.fromLTRB(
          side,
          4,
          side,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        itemBuilder: (context, channels, index, row) => ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: index == 0 ? corner : Radius.zero,
            bottom: index == channels.length - 1 ? corner : Radius.zero,
          ),
          child: row,
        ),
        separatorBuilder: (context, channels, index) => ColoredBox(
          color: context.colors.surface,
          child: const Divider(
            height: 1,
            indent: SpaceSpace.card,
            endIndent: SpaceSpace.card,
          ),
        ),
        onChannelTap: (channel) {
          if (channel.id case final id?) {
            context.push(ChatListScreen.channelPath(id));
          }
        },
      ),
    );
  }
}
