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
  await tester.tap(find.byTooltip('Me'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Service catalog'));
  await tester.pumpAndSettle();
  return services;
}

/// Taps "+" beside the tab dock and, when it offers several, [option].
Future<void> plus(WidgetTester tester, [String? option]) async {
  await tester.tap(find.byTooltip('Create'));
  await tester.pumpAndSettle();
  if (option != null) {
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }
}

/// Opens the form picker field labeled [label] and chooses [option].
Future<void> pick(WidgetTester tester, String label, String option) async {
  final picker = find.ancestor(
    of: find.text(label).last,
    matching: find.byType(PickerField),
  );
  await tester.ensureVisible(picker);
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: picker, matching: find.byType(InkWell)).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('only owners and account managers see the catalog', (
    tester,
  ) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();

    expect(find.text('Service catalog'), findsNothing);
  });

  group('services', () {
    testWidgets('lists every service by name, each marked active or not', (
      tester,
    ) async {
      await openCatalog(tester, accountManager);

      // One list, active and inactive together: no status filter.
      expect(find.text('All'), findsNothing);
      expect(find.text('Office cleaning'), findsOneWidget);
      expect(find.text('Window washing'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Office cleaning')).dy,
        lessThan(tester.getTopLeft(find.text('Window washing')).dy),
      );

      expect(find.text('Janitorial · per sq ft'), findsOneWidget);
      expect(find.text(r'$0.12'), findsOneWidget);
      expect(find.byTooltip('Active'), findsOneWidget);
      // Uncategorized and unpriced; a unit without an abbreviation shows
      // its name.
      expect(find.text('per Visit'), findsOneWidget);
      expect(find.text('No price'), findsOneWidget);
      expect(find.byTooltip('Inactive'), findsOneWidget);
      // Icons, not words.
      expect(find.text('Active'), findsNothing);
      expect(find.text('Inactive'), findsNothing);
    });

    testWidgets('the list has no tabs or category filter', (tester) async {
      await openCatalog(tester, owner);

      expect(find.text('Categories'), findsNothing);
      expect(find.text('All categories'), findsNothing);
      expect(find.byType(PickerField), findsNothing);
    });

    testWidgets('+ offers a new service, categories and units', (tester) async {
      await openCatalog(tester, accountManager);
      await plus(tester);

      expect(find.text('New service'), findsOneWidget);
      expect(find.text('Manage categories'), findsOneWidget);
      expect(find.text('Manage units'), findsOneWidget);
      // Just the options, no "Create" heading.
      expect(find.text('Create'), findsNothing);
      // Only this page's options, not the general ones.
      expect(find.text('New account'), findsNothing);
    });

    testWidgets('adds a service with a category and a unit', (tester) async {
      final services = await openCatalog(tester, accountManager);

      await plus(tester, 'New service');
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
      expect(find.text('Floor care · per sq ft'), findsOneWidget);
      expect(find.text(r'$0.30'), findsOneWidget);
    });

    testWidgets('requires a name and a unit, and a valid price', (
      tester,
    ) async {
      final services = await openCatalog(tester, owner);
      await plus(tester, 'New service');

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
      await plus(tester, 'New service');

      await tester.enterText(field('Name'), 'Carpet shampoo');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        find.text('Add a unit first: Service catalog → + → Manage units.'),
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
      // Still listed, now marked inactive like Window washing.
      expect(find.text('Office cleaning'), findsOneWidget);
      expect(find.byTooltip('Inactive'), findsNWidgets(2));
      expect(find.byTooltip('Active'), findsNothing);
    });
  });

  group('categories', () {
    Future<FakeServiceCatalogRepository> openCategories(
      WidgetTester tester,
    ) async {
      final services = await openCatalog(tester, accountManager);
      await plus(tester, 'Manage categories');
      expect(find.text('Categories'), findsOneWidget);
      return services;
    }

    testWidgets('list with description and how many services use them', (
      tester,
    ) async {
      await openCategories(tester);

      // No status filter; each row carries its status icon.
      expect(find.text('All'), findsNothing);
      expect(find.byTooltip('Active'), findsNWidgets(2));
      expect(find.text('Janitorial'), findsOneWidget);
      expect(find.text('1 service'), findsOneWidget);
      expect(find.text('Carpets and hard floors'), findsOneWidget);
      expect(find.text('No services'), findsOneWidget);
    });

    testWidgets('adds one', (tester) async {
      final services = await openCategories(tester);

      // One option here, so + opens the form directly.
      await plus(tester);
      await tester.enterText(field('Name'), 'Windows');
      await tester.enterText(field('Description'), 'Inside and out');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(services.writes, ['create category']);
      expect(find.text('Inside and out'), findsOneWidget);
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
      await plus(tester, 'Manage units');

      expect(find.text('Shown as sq ft'), findsOneWidget);
      expect(find.text('Shown as hr'), findsOneWidget);
      expect(find.text('No services'), findsOneWidget);

      await tester.tap(find.text('Hour'));
      await tester.pumpAndSettle();
      expect(find.text('Edit unit'), findsOneWidget);
      await tester.enterText(field('Abbreviation'), 'h');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(services.writes, ['update unit:m3']);
      expect(find.text('Shown as h'), findsOneWidget);
    });

    testWidgets('a duplicate name shows on the name field', (tester) async {
      final services = _DuplicateNames();
      await openCatalog(tester, owner, services: services);
      await plus(tester, 'Manage units');

      await plus(tester);
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
