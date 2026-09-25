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
import 'package:sp_cln_app/features/clients/di/clients_providers.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/jobs/di/jobs_providers.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';
import 'package:sp_cln_app/features/jobs/presentation/controllers/jobs_providers.dart';
import 'package:sp_cln_app/features/password_reset/di/password_reset_providers.dart';
import 'package:sp_cln_app/features/password_reset/presentation/controllers/password_reset_controller.dart';
import 'package:sp_cln_app/features/settings/di/settings_providers.dart';
import 'package:sp_cln_app/features/settings/domain/entities/app_language.dart';
import 'package:sp_cln_app/features/settings/domain/repositories/language_repository.dart';
import 'package:sp_cln_app/features/settings/domain/repositories/theme_mode_repository.dart';
import 'package:sp_cln_app/features/settings/domain/entities/app_theme_mode.dart';
import 'package:sp_cln_app/features/settings/presentation/widgets/language_toggle.dart';
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
    this.resetAvailable = true,
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
  final bool resetAvailable;

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
        jobsRepositoryProvider.overrideWithValue(FakeJobsRepository(_demoJobs)),
        accessRepositoryProvider.overrideWithValue(
          FakeAccessRepository(_demoAccess),
        ),
        usersRepositoryProvider.overrideWithValue(FakeUsersRepository()),
        rolesRepositoryProvider.overrideWithValue(FakeRolesRepository()),
        clockProvider.overrideWithValue(() => testNow),
        if (phone.resetAvailable)
          passwordResetRepositoryProvider.overrideWithValue(
            FakePasswordResetRepository(),
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
          .requestCode('ana.perez@spacecleanllc.com');
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
  // Only the header toggle; the full one on Me lives in a settings card.
  for (final type in [LanguageToggle]) {
    final found = _in(
      phone,
      find.byWidgetPredicate((w) => w is LanguageToggle && w.compact),
    );
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
        '2 · Reset unavailable',
        location: '/login/forgot?email=ana.perez@spacecleanllc.com',
        resetAvailable: false,
        act: (tester, phone) async =>
            tester.tap(_in(phone, find.text('Send code'))),
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
const _demoClients = [
  Client(id: 'c1', legalName: 'Post Oak Tower LLC', dba: 'Post Oak Tower'),
  Client(id: 'c2', legalName: 'Bayou City Pediatrics'),
  Client(
    id: 'c3',
    legalName: 'Westheimer Retail Partners',
    status: ClientStatus.prospect,
  ),
];

Job _demoJob(
  String id,
  String clientId,
  String title,
  int hour,
  String place, {
  JobStatus status = JobStatus.scheduled,
}) => Job(
  id: id,
  clientId: clientId,
  title: title,
  status: status,
  scheduledStart: DateTime(2026, 9, 23, hour),
  scheduledEnd: DateTime(2026, 9, 23, hour + 2),
  location: JobLocation(
    name: place,
    address: '1980 Post Oak Blvd',
    city: 'Houston',
  ),
  assignees: const [
    JobAssignee(userId: 'u1', name: 'Ana Pérez'),
    JobAssignee(userId: 'u2', name: 'Luis Gómez'),
  ],
  checklistTotal: 8,
  checklistDone: status == JobStatus.completed ? 8 : 3,
  instructions: 'Badge in at the loading dock. Floors 3–5 only.',
);

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
