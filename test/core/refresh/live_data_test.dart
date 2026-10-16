import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/refresh/live_data.dart';

void main() {
  var loads = <String, int>{};
  final onScreen = FutureProvider.autoDispose<int>(
    (ref) async => loads.update('onScreen', (n) => n + 1, ifAbsent: () => 1),
  );
  final kept = FutureProvider<int>(
    (ref) async => loads.update('kept', (n) => n + 1, ifAbsent: () => 1),
  );

  setUp(() => loads = {});

  testWidgets('coming back from the background reloads the data on screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        observers: const [LiveDataObserver()],
        child: RefreshOnReturn(
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(onScreen);
              ref.watch(kept);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(loads, {'onScreen': 1, 'kept': 1});

    // A system overlay (inactive and back) isn't a return.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(loads['onScreen'], 1);

    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
    expect(loads, {'onScreen': 2, 'kept': 1});
  });

  test('data no screen watches is not reloaded', () async {
    final container = ProviderContainer(observers: const [LiveDataObserver()]);
    addTearDown(container.dispose);
    final sub = container.listen(onScreen, (_, _) {});
    await container.read(onScreen.future);
    sub.close();
    await Future<void>.delayed(Duration.zero);

    LiveDataObserver.refresh(container);
    await Future<void>.delayed(Duration.zero);
    expect(loads['onScreen'], 1);
  });

  group('a screen in view keeps itself current', () {
    late int refreshes;
    late StateSetter setShown;
    var shown = true;

    Future<void> pump(WidgetTester tester) async {
      refreshes = 0;
      shown = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveRefreshIntervalProvider.overrideWithValue(
              const Duration(minutes: 1),
            ),
          ],
          child: StatefulBuilder(
            builder: (context, setState) {
              setShown = setState;
              // How a hidden tab or a covered page is marked.
              return TickerMode(
                enabled: shown,
                child: RefreshWhileShown(
                  onRefresh: () => refreshes++,
                  child: const SizedBox(),
                ),
              );
            },
          ),
        ),
      );
      // Unmounting cancels the timer before the test ends.
      addTearDown(() => tester.pumpWidget(const SizedBox()));
    }

    testWidgets('every minute while in view, not on the first showing', (
      tester,
    ) async {
      await pump(tester);
      expect(refreshes, 0);
      await tester.pump(const Duration(seconds: 59));
      expect(refreshes, 0);
      await tester.pump(const Duration(seconds: 1));
      expect(refreshes, 1);
      await tester.pump(const Duration(minutes: 2));
      expect(refreshes, 3);
    });

    testWidgets('again on coming back into view, and not while hidden', (
      tester,
    ) async {
      await pump(tester);
      setShown(() => shown = false);
      await tester.pump();
      await tester.pump(const Duration(minutes: 5));
      expect(refreshes, 0);

      setShown(() => shown = true);
      await tester.pump();
      expect(refreshes, 1);
      // A full minute from the reload before the next one.
      await tester.pump(const Duration(seconds: 59));
      expect(refreshes, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(refreshes, 2);
    });

    testWidgets('not while the app is in the background', (tester) async {
      await pump(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(minutes: 5));
      expect(refreshes, 0);

      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump(const Duration(minutes: 1));
      expect(refreshes, 1);
    });
  });
}
