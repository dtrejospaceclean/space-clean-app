import 'dart:async';

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

/// How often [RefreshWhileShown] reloads a screen that stays in view. Null
/// turns the polling off (tests, where a pending timer fails the test).
final liveRefreshIntervalProvider = Provider<Duration?>(
  (ref) => const Duration(minutes: 1),
);

/// Keeps a screen's server data current while it's the one on screen:
/// [onRefresh] runs when the screen comes back into view (its tab picked
/// again, a page on top of it closed) and every
/// [liveRefreshIntervalProvider] while it stays in view with the app in the
/// foreground. Coming back from the background is [RefreshOnReturn]'s.
///
/// "In view" is whether its tickers run: a hidden tab and a covered page
/// have them off.
class RefreshWhileShown extends ConsumerStatefulWidget {
  const RefreshWhileShown({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// Invalidates the screen's data; screens keep the last value meanwhile.
  final VoidCallback onRefresh;
  final Widget child;

  @override
  ConsumerState<RefreshWhileShown> createState() => _RefreshWhileShownState();
}

class _RefreshWhileShownState extends ConsumerState<RefreshWhileShown> {
  /// Null until the first build, so the first showing doesn't reload what
  /// just loaded.
  bool? _shown;
  bool _foreground = true;
  Timer? _timer;

  late final _lifecycle = AppLifecycleListener(
    onStateChange: (state) {
      _foreground = state == AppLifecycleState.resumed;
      _schedule();
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shown = TickerMode.valuesOf(context).enabled;
    if (_shown == false && shown) {
      // Not during the build that brought it back: reloading marks the
      // providers' listeners dirty.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onRefresh();
      });
    }
    _shown = shown;
    _schedule();
  }

  /// Polls only while in view, in the foreground, and when an interval is
  /// set; restarting on every change keeps a full interval after a reload.
  void _schedule() {
    _timer?.cancel();
    _timer = null;
    final every = ref.read(liveRefreshIntervalProvider);
    if (every == null || _shown != true || !_foreground) return;
    _timer = Timer.periodic(every, (_) => widget.onRefresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
