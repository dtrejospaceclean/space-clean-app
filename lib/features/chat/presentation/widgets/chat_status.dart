import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/chat_session.dart';

/// A chat page's body while there's no connection: connecting, failed
/// (with a retry) or chat off.
class ChatStatus extends ConsumerWidget {
  const ChatStatus({super.key, required this.session});

  final ChatSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return CustomScrollView(
      slivers: [
        switch (session) {
          ChatConnecting() || ChatReady() => MessageSliver(
            icon: Icons.chat_bubble_outline_rounded,
            title: l10n.chatConnecting,
          ),
          ChatFailed(:final failure) => MessageSliver(
            icon: Icons.cloud_off_rounded,
            title: failure == null
                ? l10n.chatConnectFailed
                : l10n.failureMessage(failure),
            action: RetryButton(
              onRetry: ref.read(chatSessionProvider.notifier).retry,
            ),
          ),
          ChatOff() => MessageSliver(
            icon: Icons.chat_bubble_outline_rounded,
            title: l10n.chatUnavailable,
          ),
        },
      ],
    );
  }
}
