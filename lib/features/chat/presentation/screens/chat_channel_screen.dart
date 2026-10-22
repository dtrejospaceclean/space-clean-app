import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../di/chat_providers.dart';
import '../../domain/entities/chat.dart';
import '../controllers/chat_session.dart';
import '../widgets/chat_status.dart';

/// One conversation, in Stream's own message list and composer: an
/// existing channel ([channelId], from the chat list or a push) or one the
/// server opens for [target] (a job's or complaint's thread). With
/// `tasks.edit` or `complaints.edit` in the channel's account, a message's
/// long-press menu turns it into a task or a complaint.
class ChatChannelScreen extends ConsumerStatefulWidget {
  const ChatChannelScreen({super.key, this.channelId, this.target})
    : assert(channelId != null || target != null);

  /// Under a job or complaint page.
  static const route = 'chat';

  /// Child routes of a conversation; `?client=` names the account where
  /// the path doesn't. The message comes in `extra`.
  static const newTaskRoute = 'new-task';
  static const newComplaintRoute = 'new-complaint';

  /// Every channel the server makes is of this type.
  static const channelType = 'messaging';

  final String? channelId;
  final ChatTarget? target;

  @override
  ConsumerState<ChatChannelScreen> createState() => _ChatChannelScreenState();
}

class _ChatChannelScreenState extends ConsumerState<ChatChannelScreen> {
  ChatChannelRef? _ref;
  Failure? _failure;
  bool _opening = false;

  /// The channel for the connected client; a new connection gets a new one.
  (StreamChatClient, Channel)? _channel;

  @override
  void initState() {
    super.initState();
    if (widget.channelId case final id?) {
      _ref = ChatChannelRef(type: ChatChannelScreen.channelType, id: id);
    } else {
      _open();
    }
  }

  Future<void> _open() async {
    setState(() {
      _opening = true;
      _failure = null;
    });
    try {
      final ref = await this.ref.read(openChatChannelProvider)(widget.target!);
      if (mounted) setState(() => _ref = ref);
    } on Failure catch (f) {
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Channel? _channelFor(StreamChatClient client) {
    final ref = _ref;
    if (ref == null) return null;
    if (_channel case (final c, final channel) when c == client) {
      return channel;
    }
    final channel = client.channel(ref.type, id: ref.id);
    _channel = (client, channel);
    return channel;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(chatSessionProvider);
    final channel = switch (session) {
      ChatReady(:final client) => _channelFor(client),
      _ => null,
    };
    final failure = _failure;

    return SpacePage(
      title: channel == null ? l10n.chatTitle : null,
      heading: channel == null
          ? null
          : StreamChannelName(
              channel: channel,
              textStyle: Theme.of(context).textTheme.headlineSmall,
            ),
      body: switch (session) {
        ChatReady() when failure != null => CustomScrollView(
          slivers: [
            MessageSliver(
              icon: Icons.cloud_off_rounded,
              title: l10n.failureMessage(failure),
              action: RetryButton(onRetry: _open, loading: _opening),
            ),
          ],
        ),
        ChatReady() when channel != null => StreamChannel(
          channel: channel,
          child: _Conversation(channel: channel),
        ),
        ChatReady() => const ChatStatus(session: ChatConnecting()),
        _ => ChatStatus(session: session),
      },
    );
  }
}

class _Conversation extends ConsumerStatefulWidget {
  const _Conversation({required this.channel});

  final Channel channel;

  @override
  ConsumerState<_Conversation> createState() => _ConversationState();
}

class _ConversationState extends ConsumerState<_Conversation> {
  final _composer = StreamMessageComposerController();
  final _focus = FocusNode();
  late final String? _channelId;
  late final OpenChatChannelController _openChannel;

  @override
  void initState() {
    super.initState();
    _channelId = widget.channel.id;
    // Read now: `ref` can't be used in dispose.
    _openChannel = ref.read(openChatChannelIdProvider.notifier);
    if (_channelId case final id?) {
      // After this frame: providers can't change while building.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openChannel.opened(id);
      });
    }
  }

  @override
  void dispose() {
    if (_channelId case final id?) {
      // Providers can't change while the tree is being torn down.
      final openChannel = _openChannel;
      Future(() => openChannel.closed(id));
    }
    _composer.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _reply(Message message) {
    _composer.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    final info = ChatChannelInfo.fromData(widget.channel.extraData);
    final access = switch (info.clientId) {
      final clientId? => ref.watch(accountAccessProvider(clientId)).value,
      null => null,
    };
    return Column(
      children: [
        Expanded(
          child: StreamMessageListView(
            config: const StreamMessageListViewConfiguration(
              swipeToReply: true,
            ),
            onReplyTap: _reply,
            threadBuilder: (_, parent) => _ThreadPage(parent: parent!),
            messageBuilder: (context, message, props) =>
                StreamMessageItem.fromProps(
                  key: ValueKey(message.id),
                  props: props.copyWith(
                    actionsBuilder: (context, defaults) =>
                        StreamContextMenuAction.partitioned(
                          items: [
                            ...defaults,
                            ..._recordActions(context, message, info, access),
                          ],
                        ),
                  ),
                ),
          ),
        ),
        StreamMessageComposer(
          focusNode: _focus,
          messageComposerController: _composer,
          onQuotedMessageCleared: _composer.clearQuotedMessage,
        ),
      ],
    );
  }

  /// "Create task" and "Report complaint" for a message with text in an
  /// account's channel, as the user's access there allows.
  List<StreamContextMenuAction<MessageAction>> _recordActions(
    BuildContext context,
    Message message,
    ChatChannelInfo info,
    AccountAccess? access,
  ) {
    final clientId = info.clientId;
    final text = message.text?.trim() ?? '';
    if (clientId == null ||
        access == null ||
        text.isEmpty ||
        message.isDeleted) {
      return const [];
    }
    final l10n = AppLocalizations.of(context);
    final from = ChatMessageRef(
      id: message.id,
      text: text,
      authorName: message.user?.name,
      jobId: info.jobId,
    );
    final here = GoRouterState.of(this.context).uri.path;
    void open(String route) =>
        this.context.push('$here/$route?client=$clientId', extra: from);
    return [
      if (access.can(Permissions.tasksEdit))
        StreamContextMenuAction(
          leading: const Icon(Icons.add_task_rounded),
          label: Text(l10n.chatCreateTask),
          onTap: () => open(ChatChannelScreen.newTaskRoute),
        ),
      if (access.can(Permissions.complaintsEdit) &&
          info.kind != ChatChannelKind.complaint)
        StreamContextMenuAction(
          leading: const Icon(Icons.report_outlined),
          label: Text(l10n.chatReportComplaint),
          onTap: () => open(ChatChannelScreen.newComplaintRoute),
        ),
    ];
  }
}

/// Replies to one message, in Stream's list and composer.
class _ThreadPage extends StatefulWidget {
  const _ThreadPage({required this.parent});

  final Message parent;

  @override
  State<_ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<_ThreadPage> {
  late final _composer = StreamMessageComposerController(
    message: Message(parentId: widget.parent.id),
  );

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SpacePage(
    title: AppLocalizations.of(context).chatThread,
    body: Column(
      children: [
        Expanded(child: StreamMessageListView(parentMessage: widget.parent)),
        StreamMessageComposer(messageComposerController: _composer),
      ],
    ),
  );
}
