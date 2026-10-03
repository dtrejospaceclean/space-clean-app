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
}
