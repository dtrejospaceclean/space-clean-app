import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('settings show the installed version, in either language', (
    tester,
  ) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('Settings'));
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('27'));
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('1.4.0'), findsOneWidget);
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('27'), findsOneWidget);

    await revealBelow(tester, find.text('Español'));
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('27'));
    expect(find.text('Acerca de'), findsOneWidget);
    expect(find.text('Versión'), findsOneWidget);
    expect(find.text('Compilación'), findsOneWidget);
  });
}
