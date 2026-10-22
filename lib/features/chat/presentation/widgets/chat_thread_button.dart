import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/chat_session.dart';
import '../screens/chat_channel_screen.dart';

/// A job's or complaint's header button to its conversation, the page's
/// `chat` child route. Hidden when chat isn't set up on the server.
class ChatThreadButton extends ConsumerWidget {
  const ChatThreadButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(chatSessionProvider) is ChatOff) {
      return const SizedBox.shrink();
    }
    return CircleButton.light(
      icon: Icons.chat_bubble_outline_rounded,
      tooltip: AppLocalizations.of(context).chatTitle,
      onPressed: () => context.push(
        '${GoRouterState.of(context).matchedLocation}/'
        '${ChatChannelScreen.route}',
      ),
    );
  }
}
