import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('settings show the installed version, in either language', (
    tester,
  ) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('Language and appearance'));
    await tester.tap(find.text('Language and appearance'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('1.4.0'));
    await tester.pumpAndSettle();
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('1.4.0'), findsOneWidget);
    // The build number isn't shown.
    expect(find.text('Build'), findsNothing);
    expect(find.text('27'), findsNothing);

    await tester.ensureVisible(find.text('Español'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('1.4.0'));
    await tester.pumpAndSettle();
    expect(find.text('Acerca de'), findsOneWidget);
    expect(find.text('Versión'), findsOneWidget);
    expect(find.text('Compilación'), findsNothing);
  });
}
