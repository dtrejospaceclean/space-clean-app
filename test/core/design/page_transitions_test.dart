import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';

import '../../helpers/test_app.dart';

const _tower = Client(id: 'c1', legalName: 'Tower Holdings LLC', dba: 'Tower');

/// Opens Accounts and taps Tower, leaving the push mid-way.
Future<void> startOpeningTower(WidgetTester tester) async {
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: ana),
    clients: FakeClientsRepository([_tower]),
  );
  await tester.tap(find.byTooltip('Accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tower'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
}

/// Where the account page's message is drawn, left edge (Tower has no
/// access set up, so the page says so).
final _message = find.textContaining("don't have access");

void main() {
  testWidgets(
    'pushed pages slide in from the right',
    (tester) async {
      expect(
        SpaceTheme.light()
            .pageTransitionsTheme
            .builders[debugDefaultTargetPlatformOverride],
        isA<SlidePageTransitions>(),
      );
      await startOpeningTower(tester);
      expect(find.byType(CupertinoPageTransition), findsWidgets);
      final during = tester.getTopLeft(_message).dx;

      await tester.pumpAndSettle();
      final settled = tester.getTopLeft(_message).dx;
      // Still on its way in from the right, then in place.
      expect(during, greaterThan(settled + 20));
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('reduced motion shows the page at once', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await startOpeningTower(tester);
    final during = tester.getTopLeft(_message).dx;
    await tester.pumpAndSettle();
    expect(during, tester.getTopLeft(_message).dx);
  });
}
