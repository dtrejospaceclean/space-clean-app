import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Tracks the server data on screen so it can be reloaded when the app comes
/// back to the foreground.
///
/// Server data is every `FutureProvider.autoDispose`: it lives only while a
/// screen watches it, so the mounted ones are exactly what's on screen.
/// Register it on the root `ProviderScope`.
final class LiveDataObserver extends ProviderObserver {
  const LiveDataObserver();

  static final _mounted = Expando<Set<ProviderBase<Object?>>>();

  static bool _isServerData(ProviderBase<Object?> provider) =>
      provider is FutureProvider && provider.isAutoDispose;

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    if (_isServerData(context.provider)) {
      (_mounted[context.container] ??= {}).add(context.provider);
    }
  }

  @override
  void didUnmountProvider(ProviderObserverContext context) {
    _mounted[context.container]?.remove(context.provider);
  }

  /// Reloads the server data [container] holds. Screens keep showing the
  /// last value while it loads, and keep it if the reload fails.
  static void refresh(ProviderContainer container) {
    for (final provider in [...?_mounted[container]]) {
      container.invalidate(provider);
    }
  }
}

/// Reloads the server data on screen when the app returns from the
/// background, so changes made elsewhere show up.
class RefreshOnReturn extends StatefulWidget {
  const RefreshOnReturn({super.key, required this.child});

  final Widget child;

  @override
  State<RefreshOnReturn> createState() => _RefreshOnReturnState();
}

class _RefreshOnReturnState extends State<RefreshOnReturn> {
  late final _lifecycle = AppLifecycleListener(
    // Hidden → inactive: back from the background, not just a system
    // overlay (the notification shade, an app switcher peek).
    onRestart: () => LiveDataObserver.refresh(
      ProviderScope.containerOf(context, listen: false),
    ),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
