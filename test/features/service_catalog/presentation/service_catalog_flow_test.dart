import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/service_catalog/domain/entities/service_item.dart';

import '../../../helpers/test_app.dart';

Future<FakeServiceCatalogRepository> openCatalog(
  WidgetTester tester,
  User user, {
  FakeServiceCatalogRepository? services,
}) async {
  services ??= FakeServiceCatalogRepository();
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

/// Opens the picker field showing [text] (its label or value) and chooses
/// [option] in the sheet.
Future<void> pick(WidgetTester tester, String text, String option) async {
  final picker = find.ancestor(
    of: find.text(text).last,
    matching: find.byType(PickerField),
  );
  await tester.ensureVisible(picker);
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(of: picker, matching: find.byType(InkWell)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
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

  group('services', () {
    testWidgets('lists active services with category and price per unit', (
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
      // A unit without an abbreviation shows its name.
      expect(find.text('per Visit'), findsOneWidget);
    });

    testWidgets('filters by category', (tester) async {
      await openCatalog(tester, owner);

      await pick(tester, 'All categories', 'Floor care');
      expect(find.text('Office cleaning'), findsNothing);
      expect(find.text('Nothing matches'), findsOneWidget);

      await pick(tester, 'Floor care', 'Janitorial');
      expect(find.text('Office cleaning'), findsOneWidget);
    });

    testWidgets('adds a service with a category and a unit', (tester) async {
      final services = await openCatalog(tester, accountManager);

      await tester.tap(find.byTooltip('Add service'));
      await tester.pumpAndSettle();
      // A new service starts active; there's no status to pick.
      expect(find.text('Status'), findsNothing);

      await tester.enterText(field('Name'), 'Carpet shampoo');
      await pick(tester, 'Category', 'Floor care');
      await pick(tester, 'Unit of measure', 'Square foot (sq ft)');
      await tester.enterText(field('Default price per unit'), '0.3');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(services.writes, ['create']);
      expect(services.services.last.category?.id, 'c2');
      expect(find.text('Carpet shampoo'), findsOneWidget);
      expect(find.text(r'Floor care · $0.30 / sq ft'), findsOneWidget);
    });

    testWidgets('requires a name and a unit, and a valid price', (
      tester,
    ) async {
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

    testWidgets('says to add a unit first when there are none', (tester) async {
      await openCatalog(
        tester,
        owner,
        services: FakeServiceCatalogRepository(services: [], units: []),
      );
      await tester.tap(find.byTooltip('Add service'));
      await tester.pumpAndSettle();

      await tester.enterText(field('Name'), 'Carpet shampoo');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        find.text('Add a unit under Service catalog → Units first.'),
        findsOneWidget,
      );
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
  });

  group('categories', () {
    Future<FakeServiceCatalogRepository> openCategories(
      WidgetTester tester,
    ) async {
      final services = await openCatalog(tester, accountManager);
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
      return services;
    }

    testWidgets('list with description and how many services use them', (
      tester,
    ) async {
      await openCategories(tester);

      expect(find.text('Janitorial'), findsOneWidget);
      expect(find.text('1 service'), findsOneWidget);
      expect(
        find.text('Carpets and hard floors · No services'),
        findsOneWidget,
      );
    });

    testWidgets('adds one', (tester) async {
      final services = await openCategories(tester);

      await tester.tap(find.byTooltip('Add category'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Name'), 'Windows');
      await tester.enterText(field('Description'), 'Inside and out');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(services.writes, ['create category']);
      expect(find.text('Inside and out · No services'), findsOneWidget);
    });

    testWidgets('an unused one can be deleted', (tester) async {
      final services = await openCategories(tester);

      await tester.tap(find.text('Floor care'));
      await tester.pumpAndSettle();
      await revealBelow(tester, find.text('Delete category'));
      await tester.tap(find.text('Delete category'));
      await tester.pumpAndSettle();
      // Confirm.
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(services.writes, ['delete category:c2']);
      expect(find.text('Floor care'), findsNothing);
    });

    testWidgets('a used one offers Inactive instead of delete', (tester) async {
      await openCategories(tester);

      await tester.tap(find.text('Janitorial'));
      await tester.pumpAndSettle();
      await revealBelow(tester, find.textContaining("can't be deleted"));

      expect(find.text('Delete category'), findsNothing);
      expect(
        find.text(
          "1 service uses this, so it can't be deleted. "
          'Set it to Inactive instead.',
        ),
        findsOneWidget,
      );
    });
  });

  group('units', () {
    testWidgets('list with abbreviation, and edit one', (tester) async {
      final services = await openCatalog(tester, owner);
      await tester.tap(find.text('Units'));
      await tester.pumpAndSettle();

      expect(find.text('sq ft · 1 service'), findsOneWidget);
      expect(find.text('hr · No services'), findsOneWidget);

      await tester.tap(find.text('Hour'));
      await tester.pumpAndSettle();
      expect(find.text('Edit unit'), findsOneWidget);
      await tester.enterText(field('Abbreviation'), 'h');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(services.writes, ['update unit:m3']);
      expect(find.text('h · No services'), findsOneWidget);
    });

    testWidgets('a duplicate name shows on the name field', (tester) async {
      final services = _DuplicateNames();
      await openCatalog(tester, owner, services: services);
      await tester.tap(find.text('Units'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add unit'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Name'), 'Hour');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Another one already has this name.'), findsOneWidget);
    });
  });
}

/// Refuses new units the way the API refuses a duplicate name.
class _DuplicateNames extends FakeServiceCatalogRepository {
  @override
  Future<UnitOfMeasure> saveUnit(String? id, LookupDraft draft) async =>
      throw const ServerFailure('errors.unique_violation', statusCode: 409);
}
