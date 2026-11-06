import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_localizations/stream_chat_localizations.dart';

import 'core/router/app_router.dart';
import 'core/design/theme.dart';
import 'features/chat/presentation/widgets/chat_scope.dart';
import 'features/notifications/presentation/controllers/push_listener.dart';
import 'features/settings/presentation/controllers/language_controller.dart';
import 'features/settings/presentation/controllers/theme_mode_controller.dart';
import 'l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: ref.watch(languageControllerProvider)?.locale,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        // The chat screens' own words.
        GlobalStreamChatLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: SpaceTheme.light(),
      darkTheme: SpaceTheme.dark(),
      themeMode: ref.watch(themeModeControllerProvider).material,
      builder: (context, child) => PushListener(
        child: ChatScope(child: SpaceTheme.scaleText(context, child)),
      ),
    );
  }
}
