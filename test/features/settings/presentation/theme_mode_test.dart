import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/tokens.dart';

import '../../../helpers/test_app.dart';

Color ground(WidgetTester tester) =>
    tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor!;

/// Me → Settings.
Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Me'));
  await tester.pumpAndSettle();
  await revealBelow(tester, find.text('Language and appearance'));
  await tester.tap(find.text('Language and appearance'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('follows the phone until the user picks', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));

    expect(ground(tester), SpaceColors.light.ground);
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    // Me says what's in effect without opening Settings.
    await revealBelow(tester, find.text('English · System theme'));
    await openSettings(tester);
    expect(find.text('Appearance'), findsOneWidget);
    // "System" is the checked option of its group, for screen readers too.
    expect(
      tester.getSemantics(find.text('System')),
      isSemantics(
        isChecked: true,
        hasCheckedState: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Dark')),
      isSemantics(isChecked: false, hasCheckedState: true),
    );
  });

  testWidgets('choosing Dark switches now and is remembered', (tester) async {
    final prefs = await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
    );
    await openSettings(tester);

    await tester.ensureVisible(find.text('Dark'));
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(ground(tester), SpaceColors.dark.ground);
    expect(prefs.getString('settings.theme_mode'), 'dark');
    expect(
      tester.getSemantics(find.text('Dark')),
      isSemantics(isChecked: true),
    );

    // Back on Me, the summary follows.
    await tester.tap(find.byTooltip('Back').first);
    await tester.pumpAndSettle();
    expect(find.text('English · Dark theme'), findsOneWidget);
  });

  testWidgets('a saved choice wins over the phone', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      preferences: {'settings.theme_mode': 'light'},
    );

    expect(ground(tester), SpaceColors.light.ground);
  });
}
