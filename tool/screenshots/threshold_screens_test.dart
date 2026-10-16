// Renders the app's screens as phone-sized contact sheets.
//
//   flutter test --update-goldens tool/screenshots
//
// Output: build/screenshots/{threshold,app}_*.png. Not part of the
// regular suite (it lives outside test/).
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/app.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/core/router/app_router.dart';
import 'package:sp_cln_app/features/access/di/access_providers.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/auth/di/auth_providers.dart';
import 'package:sp_cln_app/features/calendar/di/calendar_providers.dart';
import 'package:sp_cln_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:sp_cln_app/features/complaints/di/complaints_providers.dart';
import 'package:sp_cln_app/features/complaints/domain/entities/complaint.dart';
import 'package:sp_cln_app/features/contacts/di/contacts_providers.dart';
import 'package:sp_cln_app/features/tasks/domain/entities/task.dart';
import 'package:sp_cln_app/features/tasks/di/tasks_providers.dart';
import 'package:sp_cln_app/features/contacts/domain/entities/contact.dart';
import 'package:sp_cln_app/features/locations/domain/entities/location.dart';
import 'package:sp_cln_app/features/contracts/di/contracts_providers.dart';
import 'package:sp_cln_app/features/contracts/domain/entities/contract.dart';
import 'package:sp_cln_app/features/invoices/domain/entities/invoice.dart';
import 'package:sp_cln_app/features/invoices/di/invoices_providers.dart';
import 'package:sp_cln_app/core/widgets/pdf_view.dart';
import 'package:sp_cln_app/features/locations/di/locations_providers.dart';
import 'package:sp_cln_app/features/scopes/di/scopes_providers.dart';
import 'package:sp_cln_app/features/scopes/domain/entities/scope.dart';
import 'package:sp_cln_app/features/team/di/team_providers.dart';
import 'package:sp_cln_app/features/clients/di/clients_providers.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/clients/domain/repositories/module_order_repository.dart';
import 'package:sp_cln_app/features/notifications/di/notifications_providers.dart';
import 'package:sp_cln_app/features/jobs/di/jobs_providers.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';
import 'package:sp_cln_app/features/jobs/presentation/controllers/jobs_providers.dart';
import 'package:sp_cln_app/features/password_reset/di/password_reset_providers.dart';
import 'package:sp_cln_app/features/proposals/di/proposals_providers.dart';
import 'package:sp_cln_app/features/proposals/domain/entities/proposal.dart';
import 'package:sp_cln_app/features/password_reset/presentation/controllers/password_reset_controller.dart';
import 'package:sp_cln_app/features/settings/di/settings_providers.dart';
import 'package:sp_cln_app/features/settings/domain/entities/app_language.dart';
import 'package:sp_cln_app/features/settings/domain/repositories/language_repository.dart';
import 'package:sp_cln_app/features/settings/domain/repositories/theme_mode_repository.dart';
import 'package:sp_cln_app/features/settings/domain/entities/app_theme_mode.dart';
import 'package:sp_cln_app/features/settings/presentation/widgets/language_toggle.dart';
import 'package:sp_cln_app/features/service_catalog/di/service_catalog_providers.dart';
import 'package:sp_cln_app/features/service_catalog/domain/entities/service_item.dart';
import 'package:sp_cln_app/features/users/di/users_providers.dart';

import '../../test/helpers/test_app.dart';
import 'fonts.dart';

class Phone {
  Phone(
    this.caption, {
    this.location = '/login',
    this.size = const Size(390, 844),
    this.dark = false,
    this.spanish = false,
    this.remembered = true,
    this.keyboard = 0,
    this.textScale = 1,
    this.loginError,
    this.restoring = false,
    this.signedIn = false,
    this.asOwner = false,
    this.act,
  });

  final String caption;
  final String location;
  final Size size;
  final bool dark;
  final bool spanish;
  final bool remembered;
  final double keyboard;
  final double textScale;
  final Failure? loginError;

  /// Holds the app on the splash, restoring a session.
  final bool restoring;

  /// Signed in as Ana with the demo accounts, jobs and permissions below.
  final bool signedIn;

  /// Signed in as an owner (user administration).
  final bool asOwner;

  /// Interaction to reach the state, run inside this phone.
  final Future<void> Function(WidgetTester tester, Finder phone)? act;

  late ProviderContainer container;
}

Future<void> _sheet(
  WidgetTester tester,
  String name,
  TargetPlatform platform,
  List<Phone> phones,
) async {
  await tester.runAsync(loadScreenshotFonts);
  debugDefaultTargetPlatformOverride = platform;
  const gap = 24.0;
  const captionHeight = 40.0;
  final width = phones.fold(gap * 2, (w, p) => w + p.size.width + gap);
  final height =
      phones.map((p) => p.size.height).reduce((a, b) => a > b ? a : b) +
      captionHeight +
      gap * 2;
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  for (final phone in phones) {
    phone.container = ProviderContainer(
      overrides: [
        languageRepositoryProvider.overrideWithValue(
          _MemoryLanguage(phone.spanish ? AppLanguage.es : AppLanguage.en),
        ),
        // Appearance: System, so each phone's own light/dark mode shows.
        themeModeRepositoryProvider.overrideWithValue(_MemoryThemeMode()),
        moduleOrderRepositoryProvider.overrideWithValue(_MemoryModuleOrder()),
        notificationsRepositoryProvider.overrideWithValue(
          FakeNotificationsRepository(3),
        ),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(
            rememberedEmail: phone.remembered
                ? 'ana.perez@spacecleanllc.com'
                : null,
            loginError: phone.loginError,
            sessionCheck: phone.restoring ? Completer<bool>().future : null,
            sessionUser: phone.asOwner
                ? owner
                : phone.signedIn
                ? ana
                : null,
          ),
        ),
        clientsRepositoryProvider.overrideWithValue(
          FakeClientsRepository(_demoClients),
        ),
        jobsRepositoryProvider.overrideWithValue(
          FakeJobsRepository(_demoJobs)
            ..accounts = {for (final c in _demoClients) c.id: c},
        ),
        accessRepositoryProvider.overrideWithValue(
          FakeAccessRepository(_demoAccess),
        ),
        usersRepositoryProvider.overrideWithValue(FakeUsersRepository()),
        rolesRepositoryProvider.overrideWithValue(FakeRolesRepository()),
        serviceCatalogRepositoryProvider.overrideWithValue(_demoCatalog()),
        proposalsRepositoryProvider.overrideWithValue(
          FakeProposalsRepository(_demoProposals()),
        ),
        calendarRepositoryProvider.overrideWithValue(_demoCalendar()),
        contractsRepositoryProvider.overrideWithValue(
          FakeContractsRepository(_demoContracts),
        ),
        invoicesRepositoryProvider.overrideWithValue(
          FakeInvoicesRepository(_demoInvoices),
        ),
        // The real viewer renders natively, which tests can't.
        pdfViewProvider.overrideWithValue(
          (bytes, name) => Center(child: Text(name)),
        ),
        scopesRepositoryProvider.overrideWithValue(
          FakeScopesRepository(_demoScopes),
        ),
        locationsRepositoryProvider.overrideWithValue(
          FakeLocationsRepository(_demoLocations),
        ),
        contactsRepositoryProvider.overrideWithValue(
          FakeContactsRepository(_demoContacts),
        ),
        complaintsRepositoryProvider.overrideWithValue(
          FakeComplaintsRepository(_demoComplaints),
        ),
        tasksRepositoryProvider.overrideWithValue(
          FakeTasksRepository(_demoTasksList),
        ),
        teamRepositoryProvider.overrideWithValue(FakeTeamRepository()),
        clockProvider.overrideWithValue(() => testNow),
        passwordResetRepositoryProvider.overrideWithValue(
          FakePasswordResetRepository(),
        ),
        appInfoRepositoryProvider.overrideWithValue(
          const FakeAppInfoRepository(),
        ),
      ],
      retry: (_, _) => null,
    );
    addTearDown(phone.container.dispose);
  }

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFFE7E5E4),
        child: Padding(
          padding: const EdgeInsets.all(gap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final phone in phones) ...[
                Column(
                  children: [
                    SizedBox(
                      height: captionHeight,
                      child: Text(
                        phone.caption,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1C1917),
                        ),
                      ),
                    ),
                    KeyedSubtree(
                      key: ValueKey(phone.caption),
                      child: SizedBox.fromSize(
                        size: phone.size,
                        child: MediaQuery(
                          data: MediaQueryData(
                            size: phone.size,
                            devicePixelRatio: 3,
                            padding: const EdgeInsets.only(top: 47, bottom: 34),
                            viewPadding: const EdgeInsets.only(
                              top: 47,
                              bottom: 34,
                            ),
                            viewInsets: EdgeInsets.only(bottom: phone.keyboard),
                            textScaler: TextScaler.linear(phone.textScale),
                            platformBrightness: phone.dark
                                ? Brightness.dark
                                : Brightness.light,
                          ),
                          child: UncontrolledProviderScope(
                            container: phone.container,
                            child: const App(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: gap),
              ],
            ],
          ),
        ),
      ),
    ),
  );
  await _settle(tester);

  for (final phone in phones) {
    if (phone.restoring) continue;
    final router = phone.container.read(appRouterProvider);
    if (phone.location.startsWith('/login/forgot/')) {
      await phone.container
          .read(passwordResetControllerProvider.notifier)
          .requestCode('ana.perez@spacecleanllc.com', language: 'en');
      router.go('/login/forgot');
      await _settle(tester);
      router.push(phone.location);
    } else {
      router.go(phone.location);
    }
    await _settle(tester);
    await phone.act?.call(tester, find.byKey(ValueKey(phone.caption)));
    await _settle(tester);
    _expectBarAtTop(tester, find.byKey(ValueKey(phone.caption)));
  }
  // Settle the logo SVG decode.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await _settle(tester);

  await expectLater(
    find.byType(Directionality).first,
    matchesGoldenFile('../../build/screenshots/$name.png'),
  );
  debugDefaultTargetPlatformOverride = null;
}

/// Settles, but gives up on endless animations (spinners) after a moment.
Future<void> _settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );
  } on FlutterError {
    // Still animating; the current frame is good enough.
  }
}

/// Back navigation and the language switch live in the top bar on every
/// device (safe area 47 + 64-dp bar), never inside a centered group.
void _expectBarAtTop(WidgetTester tester, Finder phone) {
  final top = tester.getTopLeft(phone).dy;
  // The header toggle; signed in, the language lives in Me → Settings.
  for (final type in [LanguageToggle]) {
    final found = _in(phone, find.byType(LanguageToggle));
    if (found.evaluate().isEmpty) continue;
    expect(
      tester.getTopLeft(found.first).dy - top,
      lessThan(47 + 64),
      reason: '$type drifted below the top bar',
    );
  }
}

Finder _in(Finder phone, Finder target) =>
    find.descendant(of: phone, matching: target);

Future<void> _submitWrongPassword(WidgetTester tester, Finder phone) async {
  await tester.enterText(
    _in(phone, find.byType(TextFormField)).at(1),
    'wrong-password',
  );
  // The label, not the widget type: Material and Cupertino buttons differ.
  await tester.tap(_in(phone, find.text('Sign in')).last);
  await tester.pump();
  expect(_in(phone, find.textContaining('Incorrect')), findsOneWidget);
  await _settle(tester);
  // The recovery link must stay in the first viewport with the notice up.
  expect(
    _in(phone, find.text('Forgot password?')).hitTestable(),
    findsOneWidget,
  );
}

Future<void> _submitEmpty(WidgetTester tester, Finder phone) async {
  await tester.enterText(_in(phone, find.byType(TextFormField)).at(0), 'ana@');
  // Validate directly: with the keyboard up the button sits under it.
  tester.state<FormState>(_in(phone, find.byType(Form))).validate();
  await tester.pump();
  expect(_in(phone, find.text('Enter a valid email address.')), findsOneWidget);
  expect(_in(phone, find.text('This field is required.')), findsOneWidget);
}

void main() {
  testWidgets('android', (tester) async {
    await _sheet(tester, 'threshold_android', TargetPlatform.android, [
      Phone('1 · First launch', remembered: false),
      Phone(
        '2 · Returning, wrong password',
        loginError: const UnauthorizedFailure('auth.invalid_credentials'),
        act: _submitWrongPassword,
      ),
      Phone(
        '3 · Keyboard open, field errors',
        remembered: false,
        keyboard: 336,
        act: _submitEmpty,
      ),
      Phone('4 · Phone in dark mode, Spanish', dark: true, spanish: true),
      Phone(
        '5 · Reset: code',
        location: '/login/forgot/code',
        act: (tester, phone) async =>
            tester.enterText(_in(phone, find.byType(TextField)), '482'),
      ),
      Phone(
        '6 · Reset: new password',
        location: '/login/forgot/password',
        act: (tester, phone) async => tester.enterText(
          _in(phone, find.byType(TextFormField)).first,
          'clean-floors-2026',
        ),
      ),
    ]);
  });

  testWidgets('ios', (tester) async {
    await _sheet(tester, 'threshold_ios', TargetPlatform.iOS, [
      Phone('1 · Returning'),
      Phone(
        '2 · Forgot password',
        location: '/login/forgot?email=ana.perez@spacecleanllc.com',
      ),
      Phone(
        '3 · iPhone SE, text 160%',
        size: const Size(375, 667),
        textScale: 1.6,
      ),
      Phone(
        '3b · iPhone SE, text 200%, scrolled',
        size: const Size(375, 667),
        textScale: 2,
        act: _scrollToBottom,
      ),
      Phone('4 · Splash', restoring: true),
      Phone(
        '5 · Reset done (phone in dark mode)',
        location: '/login/forgot/done',
        dark: true,
      ),
      Phone(
        '6 · New password, Spanish (phone dark)',
        location: '/login/forgot/password',
        dark: true,
        spanish: true,
      ),
    ]);
  });

  testWidgets('ios tablet', (tester) async {
    await _sheet(
      tester,
      'threshold_ios_tablet',
      TargetPlatform.iOS,
      _tablets(const Size(1024, 1366)),
    );
  });

  testWidgets('android tablet', (tester) async {
    await _sheet(
      tester,
      'threshold_android_tablet',
      TargetPlatform.android,
      _tablets(const Size(800, 1280)),
    );
  });

  List<Phone> appPhones({bool dark = false}) => [
    Phone('1 · Today', signedIn: true, dark: dark, location: '/today'),
    Phone('2 · Accounts', signedIn: true, dark: dark, location: '/accounts'),
    Phone('3 · Account', signedIn: true, dark: dark, location: '/accounts/c1'),
    Phone(
      '4 · Account jobs',
      signedIn: true,
      dark: dark,
      location: '/accounts/c1/jobs',
    ),
    Phone('5 · Job', signedIn: true, dark: dark, location: '/today/job/c1/j2'),
    Phone('6 · Me', signedIn: true, dark: dark, location: '/me'),
  ];

  testWidgets('app android', (tester) async {
    await _sheet(tester, 'app_android', TargetPlatform.android, appPhones());
  });

  testWidgets('app ios', (tester) async {
    await _sheet(tester, 'app_ios', TargetPlatform.iOS, appPhones());
  });

  // The same screens with the phone in dark mode (Appearance: System).
  testWidgets('app dark', (tester) async {
    await _sheet(tester, 'app_dark', TargetPlatform.iOS, appPhones(dark: true));
  });

  List<Phone> adminPhones({bool dark = false}) => [
    Phone('1 · Me (owner)', asOwner: true, dark: dark, location: '/me'),
    Phone('2 · Users', asOwner: true, dark: dark, location: '/me/users'),
    Phone('3 · User', asOwner: true, dark: dark, location: '/me/users/u1'),
    Phone('4 · New user', asOwner: true, dark: dark, location: '/me/users/new'),
    Phone(
      '5 · Edit user (scrolled)',
      asOwner: true,
      dark: dark,
      location: '/me/users/u1/edit',
      act: (tester, phone) async {
        await tester.drag(inPhoneScroll(phone), const Offset(0, -700));
      },
    ),
    Phone('6 · Roles', asOwner: true, dark: dark, location: '/me/roles'),
  ];

  testWidgets('admin android', (tester) async {
    await _sheet(
      tester,
      'admin_android',
      TargetPlatform.android,
      adminPhones(),
    );
  });

  testWidgets('admin ios', (tester) async {
    await _sheet(tester, 'admin_ios', TargetPlatform.iOS, adminPhones());
  });

  // An account's screen as an owner: every module, dark, reordering,
  // Spanish at 200%.
  testWidgets('account', (tester) async {
    await _sheet(tester, 'account', TargetPlatform.iOS, [
      Phone('1 · Account (owner)', asOwner: true, location: '/accounts/c1'),
      Phone('2 · Supervisor', signedIn: true, location: '/accounts/c1'),
      Phone('3 · Dark', asOwner: true, dark: true, location: '/accounts/c1'),
      Phone(
        '3b · Reordering',
        asOwner: true,
        location: '/accounts/c1',
        act: (tester, phone) async {
          await tester.tap(
            find.descendant(of: phone, matching: find.byTooltip('Reorder')),
          );
        },
      ),
      Phone(
        '4 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '/accounts/c1',
      ),
    ]);
  });

  // Me and its Settings screen: light, dark, and Spanish at 200%.
  testWidgets('settings', (tester) async {
    await _sheet(tester, 'settings', TargetPlatform.iOS, [
      Phone(
        '1 · Me (scrolled)',
        signedIn: true,
        location: '/me',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -400));
        },
      ),
      Phone('2 · Settings', signedIn: true, location: '/me/settings'),
      Phone(
        '3 · Settings dark',
        signedIn: true,
        dark: true,
        location: '/me/settings',
      ),
      Phone(
        '4 · Spanish, 200% text',
        signedIn: true,
        spanish: true,
        textScale: 2,
        location: '/me/settings',
      ),
    ]);
  });

  // Account details: full, sparse, editing, dark, and Spanish at 200%.
  testWidgets('account info', (tester) async {
    await _sheet(tester, 'account_info', TargetPlatform.iOS, [
      Phone('1 · Details', asOwner: true, location: '/accounts/c1/info'),
      Phone(
        '2 · Details (scrolled)',
        asOwner: true,
        location: '/accounts/c1/info',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -700));
        },
      ),
      Phone(
        '3 · Sparse prospect',
        asOwner: true,
        location: '/accounts/c3/info',
      ),
      Phone('4 · Edit', asOwner: true, location: '/accounts/c1/info/edit'),
      Phone(
        '5 · Dark',
        asOwner: true,
        dark: true,
        location: '/accounts/c1/info',
      ),
      Phone(
        '6 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '/accounts/c1/info',
      ),
    ]);
  });

  // Service catalog: its three lists, its forms, dark, and Spanish at 200%.
  testWidgets('catalog', (tester) async {
    await _sheet(tester, 'catalog', TargetPlatform.iOS, [
      Phone('1 · Services', asOwner: true, location: '/me/services'),
      Phone(
        '2 · Categories',
        asOwner: true,
        location: '/me/services/categories',
      ),
      Phone('3 · Units', asOwner: true, location: '/me/services/units'),
      Phone('4 · Edit service', asOwner: true, location: '/me/services/s1'),
      Phone(
        '5 · Category in use',
        asOwner: true,
        location: '/me/services/categories/c1',
      ),
      Phone('6 · New unit', asOwner: true, location: '/me/services/units/new'),
      Phone('7 · Dark', asOwner: true, dark: true, location: '/me/services'),
      Phone(
        '8 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '/me/services',
      ),
    ]);
  });

  // Proposals: the pipeline, a negotiation with history, its forms, an
  // approved one, dark, and Spanish at 200%.
  testWidgets('proposals', (tester) async {
    const base = '/accounts/c1/proposals';
    await _sheet(tester, 'proposals', TargetPlatform.iOS, [
      Phone('1 · Pipeline', asOwner: true, location: base),
      Phone('2 · Negotiation', asOwner: true, location: '$base/p3'),
      Phone(
        '3 · Negotiation (scrolled)',
        asOwner: true,
        location: '$base/p3',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -600));
        },
      ),
      Phone('4 · Earlier version', asOwner: true, location: '$base/p2'),
      Phone('5 · Edit', asOwner: true, location: '$base/p3/edit'),
      Phone('5a · New, no items yet', asOwner: true, location: '$base/new'),
      Phone(
        '5c · Edit, swiping an item away',
        asOwner: true,
        location: '$base/p3/edit',
        act: (tester, phone) async {
          // Held mid-swipe, so the frame shows what's revealed.
          final gesture = await tester.startGesture(
            tester.getCenter(
              find.descendant(
                of: phone,
                matching: find.text('Window washing, exterior'),
              ),
            ),
          );
          await gesture.moveBy(const Offset(-40, 0));
          await tester.pump();
          await gesture.moveBy(const Offset(-110, 0));
          await tester.pump();
        },
      ),
      Phone('6 · Approve', asOwner: true, location: '$base/p3/approve'),
      Phone(
        '6b · Add line item',
        asOwner: true,
        location: '$base/p3/edit/item',
      ),
      Phone(
        '5b · Edit (scrolled)',
        asOwner: true,
        location: '$base/p3/edit',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -500));
        },
      ),
      Phone('7 · Approved', asOwner: true, location: '$base/p5'),
      Phone('8 · Dark', asOwner: true, dark: true, location: '$base/p3'),
      Phone(
        '8b · Detail, Spanish 200%',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '$base/p3',
      ),
      Phone(
        '9 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: base,
      ),
      Phone(
        '10 · Edit, Spanish 200%',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '$base/p3/edit',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -700));
        },
      ),
    ]);
  });

  // A contract: signed and running, a draft, dark, and Spanish at 200%.
  testWidgets('contract', (tester) async {
    const base = '/accounts/c1/contracts';
    await _sheet(tester, 'contract', TargetPlatform.iOS, [
      Phone('1 · Active', asOwner: true, location: '$base/k1'),
      Phone(
        '2 · Active (scrolled)',
        asOwner: true,
        location: '$base/k1',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -600));
        },
      ),
      Phone('3 · Draft', asOwner: true, location: '$base/k2'),
      Phone('4 · Dark', asOwner: true, dark: true, location: '$base/k1'),
      Phone(
        '5 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '$base/k1',
      ),
    ]);
  });

  // Invoices: the list, an overdue one partly paid (and scrolled to its
  // payments), a draft, recording a payment, dark, Spanish at 200%.
  testWidgets('invoices', (tester) async {
    const base = '/accounts/c1/invoices';
    await _sheet(tester, 'invoices', TargetPlatform.iOS, [
      Phone('1 · List', asOwner: true, location: base),
      Phone('2 · Overdue', asOwner: true, location: '$base/inv1'),
      Phone(
        '3 · Overdue (scrolled)',
        asOwner: true,
        location: '$base/inv1',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -600));
        },
      ),
      Phone('4 · Draft', asOwner: true, location: '$base/inv3'),
      Phone('5 · Payment', asOwner: true, location: '$base/inv1/pay'),
      Phone('6 · New', asOwner: true, location: '$base/new'),
      Phone('6b · Send by email', asOwner: true, location: '$base/inv1/send'),
      Phone('7 · Dark', asOwner: true, dark: true, location: '$base/inv2'),
      Phone(
        '8 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '$base/inv1',
      ),
    ]);
  });

  // A scope of work: one with jobs, one that can go, dark, Spanish at 200%.
  testWidgets('scope', (tester) async {
    const base = '/accounts/c1/scopes';
    await _sheet(tester, 'scope', TargetPlatform.iOS, [
      Phone('1 · With jobs', asOwner: true, location: '$base/s1'),
      Phone(
        '2 · With jobs (scrolled)',
        asOwner: true,
        location: '$base/s1',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -600));
        },
      ),
      Phone('3 · No jobs yet', asOwner: true, location: '$base/s2'),
      Phone('4 · Dark', asOwner: true, dark: true, location: '$base/s1'),
      Phone(
        '5 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '$base/s1',
      ),
    ]);
  });

  // A contact and a location: full, sparse, dark, and Spanish at 200%.
  testWidgets('contact and location', (tester) async {
    const base = '/accounts/c1';
    await _sheet(tester, 'contact_location', TargetPlatform.iOS, [
      Phone('1 · Contact', asOwner: true, location: '$base/contacts/ct1'),
      Phone(
        '2 · Sparse contact',
        asOwner: true,
        location: '$base/contacts/ct2',
      ),
      Phone('3 · Location', asOwner: true, location: '$base/locations/l1'),
      Phone(
        '4 · Unused location',
        asOwner: true,
        location: '$base/locations/l2',
      ),
      Phone(
        '5 · Dark',
        asOwner: true,
        dark: true,
        location: '$base/contacts/ct1',
      ),
      Phone(
        '6 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '$base/locations/l1',
      ),
    ]);
  });

  // Tasks: the open list, the done list, an overdue task, a done one, the
  // form, dark, and Spanish at 200%.
  testWidgets('tasks', (tester) async {
    const base = '/accounts/c1/tasks';
    await _sheet(tester, 'tasks', TargetPlatform.iOS, [
      Phone('1 · Open', asOwner: true, location: base),
      Phone(
        '2 · Done',
        asOwner: true,
        location: base,
        act: (tester, phone) async {
          await tester.tap(
            find.descendant(of: phone, matching: find.text('Done')),
          );
        },
      ),
      Phone('3 · Overdue task', asOwner: true, location: '$base/t1'),
      Phone('4 · Completed', asOwner: true, location: '$base/t5'),
      Phone('5 · New', asOwner: true, location: '$base/new'),
      Phone('6 · Dark', asOwner: true, dark: true, location: '$base/t2'),
      Phone(
        '7 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: base,
      ),
    ]);
  });

  // Complaints: the open list, a case, a resolved one, the form, resolving,
  // dark, and Spanish at 200%.
  testWidgets('complaints', (tester) async {
    const base = '/accounts/c1/complaints';
    await _sheet(tester, 'complaints', TargetPlatform.iOS, [
      Phone('1 · Open', asOwner: true, location: base),
      Phone('2 · Open case', asOwner: true, location: '$base/q1'),
      Phone(
        '3 · Open case (scrolled)',
        asOwner: true,
        location: '$base/q1',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -600));
        },
      ),
      Phone('4 · Resolved', asOwner: true, location: '$base/q3'),
      Phone('5 · New', asOwner: true, location: '$base/new'),
      Phone('6 · Resolve', asOwner: true, location: '$base/q2/resolve'),
      Phone('7 · Dark', asOwner: true, dark: true, location: '$base/q2'),
      Phone(
        '7b · On its job (scrolled)',
        asOwner: true,
        location: '/accounts/c1/jobs/j1',
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -2000));
        },
      ),
      Phone(
        '8 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '$base/q1',
      ),
    ]);
  });

  testWidgets('calendar', (tester) async {
    const base = '/accounts/c1/calendar';
    await _sheet(tester, 'calendar', TargetPlatform.iOS, [
      Phone('1 · Month', asOwner: true, location: base),
      Phone(
        '2 · Month (scrolled)',
        asOwner: true,
        location: base,
        act: (tester, phone) async {
          await tester.drag(inPhoneScroll(phone), const Offset(0, -400));
        },
      ),
      Phone('3 · Event', asOwner: true, location: '$base/ev1'),
      Phone('4 · Moved, with history', asOwner: true, location: '$base/ev2'),
      Phone('5 · Reschedule', asOwner: true, location: '$base/ev1/reschedule'),
      Phone('6 · New event', asOwner: true, location: '$base/new'),
      Phone('7 · Dark', asOwner: true, dark: true, location: base),
      Phone(
        '8 · Spanish, 200% text',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: base,
      ),
      Phone(
        '9 · Event, Spanish 200%',
        asOwner: true,
        spanish: true,
        textScale: 2,
        location: '$base/ev2',
      ),
    ]);
  });

  testWidgets('job', (tester) async {
    Future<void> scroll(WidgetTester tester, Finder phone) =>
        tester.drag(inPhoneScroll(phone), const Offset(0, -560));
    await _sheet(tester, 'job', TargetPlatform.iOS, [
      Phone('Jobs list', signedIn: true, location: '/accounts/c1/jobs'),
      Phone(
        'Jobs list, dark',
        signedIn: true,
        dark: true,
        location: '/accounts/c1/jobs',
      ),
      Phone(
        'Jobs list, Spanish 200%',
        signedIn: true,
        spanish: true,
        textScale: 2,
        location: '/accounts/c1/jobs',
      ),
      Phone('1 · Scheduled', signedIn: true, location: '/today/job/c1/j2'),
      Phone(
        '2 · Scheduled (scrolled)',
        signedIn: true,
        location: '/today/job/c1/j2',
        act: scroll,
      ),
      Phone('3 · In progress', signedIn: true, location: '/today/job/c2/j3'),
      Phone(
        '4 · In progress (scrolled)',
        signedIn: true,
        location: '/today/job/c2/j3',
        act: scroll,
      ),
      Phone('5 · Completed', signedIn: true, location: '/today/job/c1/j1'),
      Phone(
        '6 · Completed (scrolled)',
        signedIn: true,
        location: '/today/job/c1/j1',
        act: scroll,
      ),
      Phone(
        '7 · Dark',
        signedIn: true,
        dark: true,
        location: '/today/job/c2/j3',
      ),
      Phone(
        '8 · Spanish, 200% text',
        signedIn: true,
        spanish: true,
        textScale: 2,
        location: '/today/job/c2/j3',
      ),
    ]);
  });

  testWidgets('admin dark', (tester) async {
    await _sheet(
      tester,
      'admin_dark',
      TargetPlatform.android,
      adminPhones(dark: true),
    );
  });
}

Finder inPhoneScroll(Finder phone) =>
    find.descendant(of: phone, matching: find.byType(CustomScrollView)).first;

Future<void> _scrollToBottom(WidgetTester tester, Finder phone) async {
  await tester.drag(
    _in(phone, find.byType(CustomScrollView)),
    const Offset(0, -3000),
  );
  // Let the iOS bounce come to rest before checking.
  await _settle(tester);
  expect(
    _in(phone, find.text('Forgot password?')).hitTestable(),
    findsOneWidget,
  );
}

List<Phone> _tablets(Size portrait) {
  final landscape = Size(portrait.height, portrait.width);
  return [
    Phone('1 · First launch', size: portrait, remembered: false),
    Phone(
      '2 · Returning, wrong password',
      size: portrait,
      loginError: const UnauthorizedFailure('auth.invalid_credentials'),
      act: _submitWrongPassword,
    ),
    Phone('3 · Reset: code', size: portrait, location: '/login/forgot/code'),
    Phone(
      '4 · Landscape, keyboard open, field errors',
      size: landscape,
      remembered: false,
      keyboard: 400,
      act: _submitEmpty,
    ),
  ];
}

// Synthetic demo data for the signed-in sheets (not real customers).
// The test clock is Sep 23, 2026; in the server's order (soonest due first).
final _demoTasksList = [
  Task(
    id: 't1',
    clientId: 'c1',
    title: 'Send the floor 3 quote',
    description:
        'Two options for the new tenant on floor 3: weekly day '
        'cleaning or nightly. Include window washing as an extra.',
    priority: Priority.high,
    status: TaskStatus.pending,
    // The signed-in demo user's, so Today lists it as overdue.
    assignedToId: 'u1',
    assignedToName: 'Ana Pérez',
    dueDate: DateTime(2026, 9, 20),
    isOverdue: true,
    daysUntilDue: -3,
    accountName: 'Post Oak Tower',
  ),
  Task(
    id: 't2',
    clientId: 'c1',
    title: 'Order restroom supplies',
    priority: Priority.medium,
    status: TaskStatus.inProgress,
    assignedToId: 'u-luis',
    assignedToName: 'Luis Gómez',
    dueDate: DateTime(2026, 9, 24),
    daysUntilDue: 1,
  ),
  Task(
    id: 't3',
    clientId: 'c1',
    title: 'Book the carpet shampoo',
    priority: Priority.low,
    status: TaskStatus.pending,
    dueDate: DateTime(2026, 10, 2),
    daysUntilDue: 9,
  ),
  const Task(
    id: 't4',
    clientId: 'c1',
    title: 'File the permits',
    priority: Priority.medium,
    status: TaskStatus.pending,
  ),
  Task(
    id: 't5',
    clientId: 'c1',
    title: 'Walk the site with the client',
    priority: Priority.medium,
    status: TaskStatus.completed,
    assignedToId: 'u-ana',
    assignedToName: 'Ana Pérez',
    dueDate: DateTime(2026, 9, 15),
    daysUntilDue: -8,
  ),
];

final _demoComplaints = [
  // High, open, from a job last night.
  Complaint(
    id: 'q1',
    clientId: 'c1',
    title: 'Restrooms out of paper',
    description:
        'Floor 3 restrooms had no paper towels or toilet paper this '
        'morning. Two tenants called the front desk.',
    priority: Priority.high,
    status: ComplaintStatus.open,
    reportedDate: DateTime(2026, 9, 23, 7, 40),
    locationId: 'l1',
    locationName: 'Post Oak Tower',
    area: 'Restrooms, floor 3',
    jobId: 'j1',
    jobTitle: 'Lobby and elevators',
    jobStart: DateTime(2026, 9, 23, 6),
    reportedByName: 'Carlos Medina',
  ),
  // Assigned, so in progress.
  Complaint(
    id: 'q2',
    clientId: 'c1',
    title: 'Lobby glass streaked',
    description: 'Streaks on the entrance doors, inside and out.',
    priority: Priority.medium,
    status: ComplaintStatus.inProgress,
    reportedDate: DateTime(2026, 9, 21, 16, 5),
    locationId: 'l1',
    locationName: 'Post Oak Tower',
    area: 'Lobby',
    assignedToId: 'u-ana',
    assignedToName: 'Ana Pérez',
    reportedByName: 'Lucía Ramos',
  ),
  // Resolved in an afternoon.
  Complaint(
    id: 'q3',
    clientId: 'c1',
    title: 'Coffee stains by the elevators',
    description: 'Carpet by the elevator bank on floor 7.',
    priority: Priority.low,
    status: ComplaintStatus.resolved,
    reportedDate: DateTime(2026, 9, 10, 9),
    locationId: 'l1',
    locationName: 'Post Oak Tower',
    area: 'Floor 7',
    assignedToId: 'u-ana',
    assignedToName: 'Ana Pérez',
    reportedByName: 'Carlos Medina',
    resolvedByName: 'Ana Pérez',
    resolutionTime: DateTime(2026, 9, 10, 13, 30),
    resolutionHours: 4.5,
    resolutionNotes:
        'Shampooed the carpet and added a mat by the coffee point.',
  ),
];

const _demoContacts = [
  // The primary and billing contact, with a login.
  Contact(
    id: 'ct1',
    clientId: 'c1',
    firstName: 'Carlos',
    lastName: 'Medina',
    title: 'Facilities manager',
    email: 'carlos.medina@postoak.com',
    phone: '7135550142',
    isPrimary: true,
    isBillingContact: true,
    notes: 'Prefers calls before 10 AM. Ask for him at the front desk.',
    userId: 'u9',
  ),
  // No email, so no login can be given yet.
  Contact(
    id: 'ct2',
    clientId: 'c1',
    firstName: 'Lucía',
    lastName: 'Ramos',
    title: 'Front desk',
  ),
];

const _demoLocations = [
  // In use: scopes and jobs, so it can't be deleted.
  Location(
    id: 'l1',
    clientId: 'c1',
    name: 'Post Oak Tower',
    address: '1980 Post Oak Blvd, Suite 400',
    city: 'Houston',
    state: 'TX',
    zipCode: '77056',
    squareFootage: '48000',
    floorCount: 12,
    accessCodes: 'Side door 4512#, alarm 0907',
    specialInstructions: 'Badge in at the loading dock after 6 PM.',
    scopeOfWorkCount: 2,
    jobCount: 12,
  ),
  // New and unused: it can be deleted.
  Location(
    id: 'l2',
    clientId: 'c1',
    name: 'Galleria annex',
    address: '5085 Westheimer Rd',
    city: 'Houston',
    state: 'TX',
    zipCode: '77056',
  ),
];

final _demoScopes = [
  // Weekly offices with a paused evening window; already made jobs.
  Scope(
    id: 's1',
    contractId: 'k1',
    contractStart: DateTime(2026, 1, 15),
    contractEnd: DateTime(2027, 1, 15),
    locationId: 'l1',
    locationName: 'Post Oak Tower',
    locationCity: 'Houston',
    serviceName: 'Janitorial',
    areaName: 'Open offices, floor 3',
    frequency: ScopeFrequency.weekly,
    instructions: 'Empty bins, vacuum, wipe desks. Lock the side door.',
    exclusions: 'Server room',
    estimatedDurationMinutes: 90,
    jobCount: 12,
    schedules: const [
      ScopeSchedule(
        daysOfWeek: [1, 3, 5],
        startTime: ClockTime(19, 0),
        endTime: ClockTime(21, 0),
      ),
      ScopeSchedule(
        daysOfWeek: [6],
        startTime: ClockTime(8, 0),
        isActive: false,
      ),
    ],
  ),
  // Daily restrooms, no jobs yet, so it can be deleted.
  Scope(
    id: 's2',
    contractId: 'k1',
    contractStart: DateTime(2026, 1, 15),
    locationId: 'l1',
    locationName: 'Post Oak Tower',
    areaName: 'Restrooms',
    frequency: ScopeFrequency.daily,
    schedules: const [ScopeSchedule(startTime: ClockTime(12, 0))],
  ),
];

final _demoInvoices = [
  // Issued a month ago under k1, $600 of $1,800 paid, 5 days past due.
  Invoice(
    id: 'inv1',
    clientId: 'c1',
    contractId: 'k1',
    contractPaymentTerms: 'Net 30',
    invoiceNumber: 'INV-2026-00041',
    issueDate: DateTime(2026, 8, 19),
    dueDate: DateTime(2026, 9, 18),
    totalAmount: '1800',
    status: InvoiceStatus.partiallyPaid,
    lineItems: const [
      InvoiceLine(
        id: 'l1',
        description: 'Monthly cleaning, August',
        quantity: '1',
        unitPrice: '1500',
        lineTotal: '1500',
      ),
      InvoiceLine(
        id: 'l2',
        jobId: 'j1',
        jobTitle: 'Lobby deep clean',
        description: 'Lobby deep clean',
        quantity: '2',
        unitPrice: '150',
        lineTotal: '300',
      ),
    ],
    payments: [
      Payment(
        id: 'p1',
        amount: '600',
        method: PaymentMethod.check,
        paymentDate: DateTime(2026, 9, 2),
        reference: '#1042',
      ),
      Payment(
        id: 'p2',
        amount: '400',
        method: PaymentMethod.check,
        paymentDate: DateTime(2026, 9, 9),
        reference: '#1057',
        isVoided: true,
      ),
    ],
    amountPaid: '600',
    balanceDue: '1200',
    isOverdue: true,
    daysOverdue: 5,
  ),
  // July's, paid in full.
  Invoice(
    id: 'inv2',
    clientId: 'c1',
    contractId: 'k1',
    contractPaymentTerms: 'Net 30',
    invoiceNumber: 'INV-2026-00038',
    issueDate: DateTime(2026, 7, 20),
    dueDate: DateTime(2026, 8, 19),
    totalAmount: '1500',
    status: InvoiceStatus.paid,
    lineItems: const [
      InvoiceLine(
        id: 'l3',
        description: 'Monthly cleaning, July',
        quantity: '1',
        unitPrice: '1500',
        lineTotal: '1500',
      ),
    ],
    payments: [
      Payment(
        id: 'p3',
        amount: '1500',
        method: PaymentMethod.bankTransfer,
        paymentDate: DateTime(2026, 8, 12),
        reference: 'ACH 88213',
      ),
    ],
    amountPaid: '1500',
    balanceDue: '0',
  ),
  // September's, still a draft.
  Invoice(
    id: 'inv3',
    clientId: 'c1',
    contractId: 'k1',
    contractPaymentTerms: 'Net 30',
    invoiceNumber: 'INV-2026-00044',
    issueDate: DateTime(2026, 9, 23),
    dueDate: DateTime(2026, 10, 23),
    totalAmount: '1500',
    status: InvoiceStatus.draft,
    lineItems: const [
      InvoiceLine(
        id: 'l4',
        description: 'Monthly cleaning, September',
        quantity: '1',
        unitPrice: '1500',
        lineTotal: '1500',
      ),
    ],
  ),
  // Issued this week, nothing paid yet.
  Invoice(
    id: 'inv4',
    clientId: 'c1',
    invoiceNumber: 'INV-2026-00043',
    issueDate: DateTime(2026, 9, 21),
    dueDate: DateTime(2026, 10, 21),
    totalAmount: '320',
    status: InvoiceStatus.issued,
    lineItems: const [
      InvoiceLine(
        id: 'l5',
        description: 'Carpet spot treatment',
        quantity: '4',
        unitPrice: '80',
        lineTotal: '320',
      ),
    ],
    balanceDue: '320',
  ),
];

final _demoContracts = [
  // Signed and running, from a proposal, one scope.
  Contract(
    id: 'k1',
    clientId: 'c1',
    contractValue: '1800',
    startDate: DateTime(2026, 1, 15),
    expirationDate: DateTime(2027, 1, 15),
    paymentTerms: 'Net 30',
    cancellationNoticeDays: 30,
    autoRenew: true,
    status: ContractStatus.active,
    signedByName: 'Carlos Medina',
    signedDate: DateTime(2026, 1, 12),
    proposalId: 'p5',
    proposalVersion: 1,
    scopeOfWorkCount: 1,
    daysUntilExpiration: 98,
  ),
  // A new draft: not signed, nothing built on it, so it can be deleted.
  Contract(
    id: 'k2',
    clientId: 'c1',
    contractValue: '950.50',
    startDate: DateTime(2026, 11, 1),
    status: ContractStatus.draft,
  ),
];

const _demoClients = [
  Client(
    id: 'c1',
    legalName: 'Post Oak Tower LLC',
    dba: 'Post Oak Tower',
    status: ClientStatus.active,
    industry: 'Commercial offices',
    serviceType: 'Nightly janitorial',
    taxId: '74-3920185',
    billingAddress: '1980 Post Oak Blvd, Suite 400',
    billingCity: 'Houston',
    billingState: 'TX',
    billingZip: '77056',
    accountManager: ClientAssignee(id: 'm1', name: 'Marco Díaz'),
    supervisor: ClientAssignee(id: 'u1', name: 'Ana Pérez'),
  ),
  Client(id: 'c2', legalName: 'Bayou City Pediatrics'),
  Client(
    id: 'c3',
    legalName: 'Westheimer Retail Partners',
    status: ClientStatus.prospect,
  ),
];

const _demoTasks = [
  'Empty trash and recycling',
  'Dust desks and sills',
  'Wipe kitchen counters',
  'Restock restrooms',
  'Clean restroom fixtures',
  'Vacuum carpets',
  'Mop hard floors',
  'Lock up and set the alarm',
];

Job _demoJob(
  String id,
  String clientId,
  String title,
  int hour,
  String place, {
  JobStatus status = JobStatus.scheduled,
}) {
  DateTime at(int h, int m) => DateTime(2026, 9, 23, h, m);
  final started = status != JobStatus.scheduled;
  final done = status == JobStatus.completed;
  return Job(
    id: id,
    clientId: clientId,
    title: title,
    status: status,
    scheduledStart: at(hour, 0),
    scheduledEnd: at(hour + 2, 0),
    location: JobLocation(
      name: place,
      address: '1980 Post Oak Blvd',
      city: 'Houston',
    ),
    assignees: [
      JobAssignee(
        userId: 'u1',
        name: 'Ana Pérez',
        roleOnJob: 'Lead',
        checkInTime: started ? at(hour - 1, 55) : null,
        checkOutTime: done ? at(hour + 2, 5) : null,
      ),
      JobAssignee(
        userId: 'u2',
        name: 'Luis Gómez',
        roleOnJob: 'Helper',
        checkInTime: started ? at(hour, 2) : null,
        checkOutTime: done ? at(hour + 1, 58) : null,
      ),
    ],
    checklist: [
      for (final (i, task) in _demoTasks.indexed)
        if (done || i < 3)
          ChecklistItem(
            id: 'i$i',
            description: task,
            isCompleted: true,
            completedByName: i.isEven ? 'Ana Pérez' : 'Luis Gómez',
            completedAt: at(hour, 10 + i * 12),
          )
        else
          ChecklistItem(id: 'i$i', description: task),
    ],
    instructions: 'Badge in at the loading dock. Floors 3–5 only.',
    scopeId: started ? 's1' : null,
    scopeArea: started ? 'Exam rooms' : null,
    actualStart: started ? at(hour, 3) : null,
    startedByName: started ? 'Ana Pérez' : null,
    actualEnd: done ? at(hour + 1, 55) : null,
    completedByName: done ? 'Ana Pérez' : null,
    qualityScore: done ? 4.5 : null,
    cleanerNotes: done ? 'Restroom faucet on floor 4 is leaking.' : null,
    clientSignoffName: done ? 'María López' : null,
    clientSignoffAt: done ? at(hour + 1, 58) : null,
  );
}

final _demoJobs = <String, Object>{
  'c1': [
    _demoJob(
      'j1',
      'c1',
      'Lobby and elevators',
      6,
      'North lobby',
      status: JobStatus.completed,
    ),
    _demoJob('j2', 'c1', 'Offices, floors 3–5', 18, 'Tower A'),
  ],
  'c2': [
    _demoJob(
      'j3',
      'c2',
      'Exam rooms sanitation',
      11,
      'Clinic',
      status: JobStatus.inProgress,
    ),
  ],
};

const _demoAccess = {
  'c1': AccountAccess(
    clientId: 'c1',
    baseRole: 'supervisor',
    permissions: {
      Permissions.infoView,
      Permissions.scopeView,
      Permissions.jobsView,
      Permissions.complaintsView,
      Permissions.calendarView,
      Permissions.tasksView,
      Permissions.filesView,
      Permissions.teamView,
    },
  ),
};

class _MemoryLanguage implements LanguageRepository {
  _MemoryLanguage(this.savedLanguage);

  @override
  AppLanguage? savedLanguage;

  @override
  Future<void> saveLanguage(AppLanguage language) async =>
      savedLanguage = language;
}

class _MemoryThemeMode implements ThemeModeRepository {
  @override
  AppThemeMode? savedThemeMode;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async => savedThemeMode = mode;
}

class _MemoryModuleOrder implements ModuleOrderRepository {
  @override
  List<String> savedOrder = const [];

  @override
  Future<void> saveOrder(List<String> routes) async => savedOrder = routes;
}

/// Torre Norte's pipeline: a fresh lead, a negotiation on its third
/// version, a walkthrough, and an approved renewal.
List<Proposal> _demoProposals() {
  ProposalLineItem item(
    String id,
    String description,
    String quantity,
    String price, {
    String? serviceId,
  }) => ProposalLineItem(
    id: id,
    serviceId: serviceId,
    description: description,
    quantity: quantity,
    unitPrice: price,
    lineTotal: centsToDecimal(lineTotalCents(quantity, price)),
  );
  Proposal version(
    String id,
    String group,
    int number, {
    required ProposalStage stage,
    bool current = true,
    String? note,
    String? agreed,
    List<ProposalLineItem> items = const [],
    String? approvedBy,
  }) => Proposal(
    id: id,
    clientId: 'c1',
    groupId: group,
    stage: stage,
    versionNumber: number,
    isCurrent: current,
    versionNote: note,
    agreedPrice: agreed,
    validUntil: DateTime(2026, 10, 31),
    preparedByName: 'Carlos Medina',
    approvedByName: approvedBy,
    approvedDate: approvedBy == null ? null : DateTime(2026, 9, 2),
    createdAt: DateTime(2026, 9, 10 + number),
    lineItems: items,
  );
  final offices = [
    item('a', 'Office cleaning, floors 1–12', '48000', '0.12', serviceId: 's1'),
    item('b', 'Lobby and restrooms, nightly', '22', '85'),
    item('c', 'Window washing, exterior', '4', '650'),
  ];
  return [
    version(
      'p1',
      'g1',
      1,
      stage: ProposalStage.pricing,
      current: false,
      note: 'First pass',
      items: [offices[0]],
    ),
    version(
      'p2',
      'g1',
      2,
      stage: ProposalStage.proposal,
      current: false,
      note: 'Added restrooms',
      items: offices.take(2).toList(),
    ),
    version(
      'p3',
      'g1',
      3,
      stage: ProposalStage.negotiation,
      note: 'Annual contract discount',
      agreed: '9800',
      items: offices,
    ),
    version(
      'p4',
      'g2',
      1,
      stage: ProposalStage.walkthrough,
      items: [item('d', 'Warehouse floor scrub', '1', '1200')],
    ),
    version(
      'p5',
      'g3',
      1,
      stage: ProposalStage.approved,
      agreed: '3150',
      approvedBy: 'Olga Ruiz',
      note: '2026 renewal',
      items: [item('e', 'Day porter, weekdays', '21', '150')],
    ),
    version('p6', 'g4', 1, stage: ProposalStage.lead),
  ];
}

FakeServiceCatalogRepository _demoCatalog() {
  const janitorial = ServiceCategory(
    id: 'c1',
    name: 'Janitorial',
    description: 'Nightly office cleaning',
  );
  const floors = ServiceCategory(
    id: 'c2',
    name: 'Floor care',
    description: 'Carpets, strip and wax, hard floors',
  );
  const windows = ServiceCategory(id: 'c3', name: 'Windows');
  const special = ServiceCategory(
    id: 'c4',
    name: 'Post-construction',
    isActive: false,
  );
  const sqft = UnitOfMeasure(
    id: 'm1',
    name: 'Square foot',
    abbreviation: 'sq ft',
  );
  const hour = UnitOfMeasure(id: 'm2', name: 'Hour', abbreviation: 'hr');
  const visit = UnitOfMeasure(id: 'm3', name: 'Visit');
  const pane = UnitOfMeasure(
    id: 'm4',
    name: 'Window pane',
    abbreviation: 'pane',
  );
  return FakeServiceCatalogRepository(
    categories: [janitorial, floors, windows, special],
    units: [sqft, hour, visit, pane],
    services: [
      ServiceItem(
        id: 's1',
        name: 'Office cleaning',
        category: janitorial,
        unit: sqft,
        defaultPrice: '0.12',
      ),
      ServiceItem(
        id: 's2',
        name: 'Restroom sanitation',
        category: janitorial,
        unit: visit,
        defaultPrice: '45',
      ),
      ServiceItem(
        id: 's3',
        name: 'Day porter',
        category: janitorial,
        unit: hour,
        defaultPrice: '28.5',
      ),
      ServiceItem(
        id: 's4',
        name: 'Carpet extraction',
        category: floors,
        unit: sqft,
        defaultPrice: '0.3',
      ),
      ServiceItem(
        id: 's5',
        name: 'Strip and wax VCT floors',
        category: floors,
        unit: sqft,
      ),
      ServiceItem(
        id: 's6',
        name: 'Exterior windows, ground floor',
        category: windows,
        unit: pane,
        defaultPrice: '6',
      ),
      ServiceItem(id: 's7', name: 'Supply restock', unit: visit),
      ServiceItem(
        id: 's8',
        name: 'Construction dust cleanup',
        category: special,
        unit: sqft,
        defaultPrice: '0.45',
        isActive: false,
      ),
    ],
  );
}

/// Torre Norte's calendar around the test clock (Wednesday, Sep 23):
/// visits from its scopes most weekdays, a one-off, a moved one and a
/// cancelled one.
FakeCalendarRepository _demoCalendar() {
  CalendarEvent scoped(
    String id,
    int day,
    String title,
    int hour, {
    CalendarEventStatus status = CalendarEventStatus.scheduled,
  }) => CalendarEvent(
    id: id,
    title: title,
    date: DateTime(2026, 9, day),
    startTime: ClockTime(hour, 0),
    endTime: ClockTime(hour + 1, 30),
    status: status,
    locationName: 'Torre Norte — Piso 3',
    scopeId: 's1',
    scopeArea: title,
    assignedToName: 'Carlos Medina',
    scheduleId: 'w$id',
  );
  final repo = FakeCalendarRepository([
    for (final day in [1, 3, 8, 10, 15, 17, 22, 29])
      scoped('o$day', day, 'Oficinas', 7),
    scoped('ev1', 23, 'Oficinas', 7),
    scoped('r23', 23, 'Baños', 13),
    scoped('ev2', 24, 'Recepción', 9, status: CalendarEventStatus.rescheduled),
    scoped('c25', 25, 'Baños', 13, status: CalendarEventStatus.cancelled),
    CalendarEvent(
      id: 'deep',
      title: 'Limpieza profunda de alfombras',
      date: DateTime(2026, 9, 23),
      startTime: const ClockTime(18, 0),
      status: CalendarEventStatus.scheduled,
      locationName: 'Torre Norte — Lobby',
      notes: 'Mover sillas de la sala de juntas.',
    ),
  ]);
  repo.moves['ev2'] = [
    EventReschedule(
      previousDate: DateTime(2026, 9, 22),
      previousStart: const ClockTime(9, 0),
      newDate: DateTime(2026, 9, 24),
      newStart: const ClockTime(9, 0),
      reason: 'El cliente pidió el jueves',
      byName: 'Ana Pérez',
    ),
  ];
  return repo;
}
