import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';

import '../../../helpers/test_app.dart';

Future<FakeServiceCatalogRepository> openCatalog(
  WidgetTester tester,
  User user,
) async {
  final services = FakeServiceCatalogRepository();
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: user),
    services: services,
  );
  await tester.tap(find.text('Me'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Service catalog'));
  await tester.pumpAndSettle();
  return services;
}

void main() {
  testWidgets('only owners and account managers see the catalog', (
    tester,
  ) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();

    expect(find.text('Service catalog'), findsNothing);
  });

  testWidgets('lists active services with their price per unit', (
    tester,
  ) async {
    await openCatalog(tester, accountManager);

    expect(find.text('Office cleaning'), findsOneWidget);
    expect(find.text(r'Janitorial · $0.12 / sq ft'), findsOneWidget);
    // Retired ones only under Inactive.
    expect(find.text('Window washing'), findsNothing);

    await tester.tap(find.text('Inactive'));
    await tester.pumpAndSettle();
    expect(find.text('Window washing'), findsOneWidget);
    expect(find.text('per visit'), findsOneWidget);
  });

  testWidgets('adds a service', (tester) async {
    final services = await openCatalog(tester, accountManager);

    await tester.tap(find.byTooltip('Add service'));
    await tester.pumpAndSettle();
    // A new service starts active; there's no status to pick.
    expect(find.text('Status'), findsNothing);

    await tester.enterText(field('Name'), 'Carpet shampoo');
    await tester.enterText(field('Unit of measure'), 'sq ft');
    await tester.enterText(field('Default price per unit'), '0.3');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(services.writes, ['create']);
    expect(find.text('Carpet shampoo'), findsOneWidget);
    expect(find.text(r'$0.30 / sq ft'), findsOneWidget);
  });

  testWidgets('requires a name and a unit, and a valid price', (tester) async {
    final services = await openCatalog(tester, owner);
    await tester.tap(find.byTooltip('Add service'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Default price per unit'), '1.234');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(services.writes, isEmpty);
    expect(find.text('This field is required.'), findsNWidgets(2));
    expect(find.text('Enter an amount like 0.12 or 25.'), findsOneWidget);
  });

  testWidgets('retires a service instead of deleting it', (tester) async {
    final services = await openCatalog(tester, owner);

    await tester.tap(find.text('Office cleaning'));
    await tester.pumpAndSettle();
    expect(find.text('Edit service'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(field('Name')).controller!.text,
      'Office cleaning',
    );

    await revealBelow(tester, find.text('Inactive'));
    await tester.tap(find.text('Inactive'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(services.writes, ['update:s1']);
    expect(services.services.first.isActive, isFalse);
    // Gone from the active list.
    expect(find.text('Office cleaning'), findsNothing);
  });
}
