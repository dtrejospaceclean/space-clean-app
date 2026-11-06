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
      child: StreamChat(
        client: client,
        themeData: chatScreensTheme(context),
        child: child,
      ),
    );
  }
}

/// Stream's foundations in the app's design (DESIGN.md): the logo
/// palette, Manrope, no shadows. Orange acts (send, unread counts, the
/// cursor), navy informs (links, the user's own messages); incoming
/// messages are white cards on the blue-gray ground, the user's own sit on
/// Navy Wash, and the message box is a white pill with the 1px Soft Ink
/// outline of the app's search field.
StreamTheme chatTheme(BuildContext context) {
  final c = context.colors;
  final brightness = Theme.of(context).brightness;
  final seeded = StreamColorScheme.fromSeed(
    brand: c.accent,
    brightness: brightness,
  );
  return StreamTheme(
    brightness: brightness,
    // The app is flat: depth comes from tone, never shadows.
    elevation: const StreamElevation(
      level1: 0,
      level2: 0,
      level3: 0,
      level4: 0,
    ),
    textTheme: StreamTextTheme(typography: StreamTypography())
        .apply(color: c.ink, fontFamily: SpaceTheme.font),
    colorScheme: seeded.copyWith(
      accentPrimary: c.primary,
      accentSuccess: c.success,
      accentWarning: c.highlight,
      accentError: c.danger,
      accentNeutral: c.inkMuted,
      textPrimary: c.ink,
      textSecondary: c.inkMuted,
      // The Muted Floor Rule: hints and captions never go lighter.
      textTertiary: c.inkMuted,
      textDisabled: c.inkFaint,
      textLink: c.accent,
      textOnAccent: c.onPrimary,
      backgroundApp: c.ground,
      backgroundSurface: c.surface,
      backgroundSurfaceSubtle: c.sunken,
      backgroundSurfaceStrong: c.sunken,
      backgroundSurfaceCard: c.surface,
      backgroundHighlight: c.highlightSoft,
      backgroundDisabled: c.sunken,
      // The composer's backdrop is the ground; its pill a white surface.
      backgroundElevation0: c.ground,
      backgroundElevation1: c.surface,
      backgroundElevation2: c.surface,
      backgroundElevation3: c.surface,
      // Inputs carry the Soft Ink outline; dividers are hairlines.
      borderDefault: c.inkSoft,
      borderSubtle: c.line,
      borderStrong: c.inkSoft,
      borderFocus: c.primary,
    ),
    avatarTheme: StreamAvatarThemeData(
      backgroundColor: c.sunken,
      foregroundColor: c.ink,
    ),
    messageItemTheme: StreamMessageItemThemeData(
      bubble: StreamMessageBubbleStyle(
        backgroundColor: StreamMessageLayoutProperty.resolveWith(
          (layout) => switch ((layout.alignment, layout.contentKind)) {
            (_, StreamMessageContentKind.jumbomoji) => Colors.transparent,
            (StreamMessageAlignment.end, _) => c.accentSoft,
            _ => c.surface,
          },
        ),
        // Cards carry no border (the No-Shadow Rule).
        side: StreamMessageLayoutBorderSide.all(BorderSide.none),
      ),
      text: StreamMessageTextStyle.from(
        textStyle: const TextStyle(fontSize: 15, height: 1.45),
        textColor: c.ink,
        linkColor: c.accent,
      ),
      metadata: StreamMessageMetadataStyle.from(
        usernameTextStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        usernameColor: c.inkMuted,
        timestampTextStyle: const TextStyle(fontSize: 12.5),
        timestampColor: c.inkMuted,
      ),
    ),
  );
}

/// Stream's chat screens in the app's design: the blue-gray ground behind
/// messages, list rows titled like the app's (`ListRow`), and the message
/// box floating over the messages like the tab dock.
StreamChatThemeData chatScreensTheme(BuildContext context) {
  final c = context.colors;
  return StreamChatThemeData(
    messageListViewTheme: StreamMessageListViewThemeData(
      backgroundColor: c.ground,
    ),
    messageComposerTheme: const StreamMessageComposerThemeData(
      surfaceStyle: StreamSurfaceStyle.floating,
    ),
    channelListItemTheme: StreamChannelListItemThemeData(
      titleStyle: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: c.ink,
      ),
      subtitleStyle: TextStyle(fontSize: 13, color: c.inkMuted),
      timestampStyle: TextStyle(fontSize: 12.5, color: c.inkMuted),
      backgroundColor: WidgetStatePropertyAll(c.surface),
    ),
  );
}
