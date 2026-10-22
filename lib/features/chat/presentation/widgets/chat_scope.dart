import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../../core/design/design.dart';
import '../controllers/chat_session.dart';

/// Puts the chat client above every page once it's connected, so Stream's
/// chat widgets find it, colored like the rest of the app. The pages keep
/// their state when it comes and goes (a [GlobalKey] moves them).
class ChatScope extends ConsumerStatefulWidget {
  const ChatScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ChatScope> createState() => _ChatScopeState();
}

class _ChatScopeState extends ConsumerState<ChatScope> {
  final _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: _childKey, child: widget.child);
    final client = ref.watch(chatClientProvider);
    if (client == null) return child;
    return Theme(
      data: Theme.of(context).copyWith(
        extensions: [
          ...Theme.of(context).extensions.values,
          chatTheme(context),
        ],
      ),
      child: StreamChat(client: client, child: child),
    );
  }
}

/// Stream's theme in the app's colors: the navy accent for the user's own
/// messages and links, on the app's ground and surfaces.
StreamTheme chatTheme(BuildContext context) {
  final c = context.colors;
  final brightness = Theme.of(context).brightness;
  final seeded = StreamColorScheme.fromSeed(
    brand: c.accent,
    brightness: brightness,
  );
  return StreamTheme(
    brightness: brightness,
    colorScheme: seeded.copyWith(
      accentPrimary: c.accent,
      accentError: c.danger,
      accentSuccess: c.success,
      textPrimary: c.ink,
      textSecondary: c.inkMuted,
      textTertiary: c.inkSoft,
      textOnAccent: c.onAccent,
      backgroundApp: c.ground,
      backgroundSurface: c.surface,
      backgroundSurfaceSubtle: c.sunken,
      borderDefault: c.line,
    ),
  );
}
