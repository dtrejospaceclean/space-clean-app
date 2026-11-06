import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:sp_cln_app/features/chat/presentation/widgets/chat_scope.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

void main() {
  for (final (name, theme) in [
    ('light', SpaceTheme.light()),
    ('dark', SpaceTheme.dark()),
  ]) {
    testWidgets('the chat follows the app design in $name mode', (
      tester,
    ) async {
      late StreamTheme stream;
      late StreamChatThemeData screens;
      late SpaceColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              colors = context.colors;
              stream = chatTheme(context);
              screens = chatScreensTheme(context);
              return const SizedBox();
            },
          ),
        ),
      );

      final scheme = stream.colorScheme;
      // Orange acts, navy informs.
      expect(scheme.accentPrimary, colors.primary);
      expect(scheme.textLink, colors.accent);
      expect(scheme.backgroundApp, colors.ground);
      expect(scheme.textTertiary, colors.inkMuted);
      expect(stream.elevation.level3, 0);
      expect(stream.textTheme.bodyDefault.fontFamily, SpaceTheme.font);
      expect(screens.messageListViewTheme.backgroundColor, colors.ground);
      expect(
        screens.messageComposerTheme.surfaceStyle,
        StreamSurfaceStyle.floating,
      );
    });
  }
}
