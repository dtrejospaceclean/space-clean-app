import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/tokens.dart';

import '../../../helpers/test_app.dart';

Color ground(WidgetTester tester) =>
    tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor!;

Future<void> openMe(WidgetTester tester) async {
  await tester.tap(find.text('Me').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('follows the phone until the user picks', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));

    expect(ground(tester), SpaceColors.light.ground);
    await openMe(tester);
    expect(find.text('Appearance'), findsOneWidget);
    // "System" is the selected option.
    expect(
      tester.getSemantics(find.text('System')),
      matchesSemantics(
        isSelected: true,
        hasSelectedState: true,
        isButton: true,
        label: 'System',
      ),
    );
  });

  testWidgets('choosing Dark switches now and is remembered', (tester) async {
    final prefs = await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
    );
    await openMe(tester);

    await tester.ensureVisible(find.text('Dark'));
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(ground(tester), SpaceColors.dark.ground);
    expect(prefs.getString('settings.theme_mode'), 'dark');
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
