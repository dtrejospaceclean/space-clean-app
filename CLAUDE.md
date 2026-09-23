# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`sp_cln_app` is a Flutter **mobile** app (Android and iOS only; Dart SDK `^3.13.4`) for a REST backend documented in `docs/frontend-api.md` (endpoints, envelope, permission model) and `docs/api-message-keys.md` (every translation key the API can return). `docs/` is git-ignored, so read those files locally before building a feature against an endpoint.

Stack: Riverpod 3 (no codegen), Dio, go_router, flutter_secure_storage, shared_preferences, flutter_svg, gen-l10n (English + Spanish).

Product and design context: `PRODUCT.md` (users, roles, principles, accessibility) and `DESIGN.md` (visual system). Read them before UI work.

## Commands

```sh
flutter pub get
flutter gen-l10n                       # regenerate lib/l10n/app_localizations*.dart after editing .arb files
flutter run                            # add -d <device-id> (see `flutter devices`)
flutter run --dart-define=API_BASE_URL=http://localhost:3000   # default: https://space-clean-be-production.up.railway.app
                                       # local backend from the Android emulator: http://10.0.2.2:3000
flutter analyze
flutter test
flutter test test/core/network/auth_interceptor_test.dart
flutter test --plain-name "logs in and out"
dart format lib test tool
flutter test --update-goldens tool/screenshots   # phone + tablet contact sheets → build/screenshots/*.png (not in the regular suite)
flutter test --update-goldens tool/brand         # re-render native splash logo PNGs from the SVG
dart run flutter_native_splash:create           # regenerate native launch screens (config at the bottom of pubspec.yaml)
```

On a Windows dev machine, building with plugins requires Developer Mode (symlink support).

The app is mobile only. Don't add web or desktop code paths (`kIsWeb`, desktop-only plugins). The backend also doesn't send CORS headers, so a web build couldn't reach it.

## Architecture: Clean Architecture, feature-first

```
lib/core/                 cross-cutting: error/ (Failure), usecase/, network/, storage/, di/, router/, l10n/, theme/, widgets/
lib/features/<feature>/
  domain/                 entities/, repositories/ (abstract interfaces), usecases/  — pure Dart
  data/                   models/ (JSON → entity), datasources/, repositories/ (*_impl)
  presentation/           controllers/ (Riverpod notifiers), screens/
  di/                     <feature>_providers.dart — composition root
```

**Dependency rule, which must hold:**
- `domain/` imports only other domain code, `core/error` and `core/usecase`: no Flutter, Dio, Riverpod or `data/`.
- `presentation/` never imports `data/` or `core/network`. Controllers call use cases, and screens catch `Failure`.
- Only `di/` files know the concrete `*Impl` classes.

**Adding a feature** follows the auth layout:
1. Entity plus an abstract repository in `domain/`, with one use case class per action (`UseCase<T, Params>`, called via `call`).
2. A remote data source that calls `ApiClient` and throws `ApiException`. A model that maps JSON to the entity.
3. A `*RepositoryImpl` that wraps every call so each `ApiException` becomes a `Failure` via `toFailure()` (see `_guard` in `AuthRepositoryImpl`).
4. Providers in `di/`, then controllers and screens.

**Errors:** every error surfaced to the UI is a domain `Failure` (`core/error/failures.dart`): `NetworkFailure`, `UnauthorizedFailure` (401), `ValidationFailure` (field errors keyed by request-body path) or `ServerFailure`. `messageKey` is the API's translation key, never display text. `lib/core/l10n/failure_messages.dart` turns keys into localized strings (`failureMessage`, `fieldError`). Add a case there whenever a feature starts surfacing a new key.

**API layer (`core/network/`)**
- `ApiClient` unwraps the `{ success, message, data, errors, statusCode }` envelope.
- `AuthInterceptor` attaches the bearer token. On 401 with `auth.invalid_access_token`/`auth.missing_token`, it refreshes once through a separate interceptor-less Dio, with concurrent 401s sharing one refresh, and then replays the request. A rejected refresh calls `TokenStorage.expireSession()`, which emits on `sessionExpired`; `AuthController` listens through the `WatchSessionExpired` use case. A network failure during refresh keeps the session.
- Public calls pass `authenticated: false`.
- The backend rejects unknown body fields (`validation.whitelist_validation`), so send only the fields an endpoint defines.

**Session and routing**
- `authControllerProvider` (`AsyncNotifier<AuthState>`, sealed `Authenticated(user)` / `Unauthenticated`) restores the session via `RestoreSession` in `build()`. Auto-retry is disabled, and the splash screen offers a manual retry instead.
- `login()` throws a `Failure` to the form rather than entering an error state.
- There is no logout endpoint: logout clears the stored tokens.
- `core/router/app_router.dart` bridges auth state into go_router's `refreshListenable`. The redirect sends no value to `/splash`, `Unauthenticated` to `/login`, and `Authenticated` away from login/splash.

**Features:** `auth` (sign-in, session, remembered email), `password_reset` (email → 6-digit code → new password; its repository throws `UnavailableFailure` until the backend defines reset endpoints, so don't guess that contract), `settings` (EN/ES choice persisted in SharedPreferences; `null` follows the device), `home` (placeholder).

**UI conventions**
- Screens before sign-in use the "threshold" kit in `lib/core/widgets/threshold/`: `ThresholdScaffold` (white ground; the ember dark palette exists but is off, since the app is light-only via `themeMode: ThemeMode.light` in `app.dart`; bar pinned top; thumb-zone anchoring on phones, centered group capped at 480 dp on tablets), `BrandBlock`, `ThresholdField`, `ThresholdButton`/`ThresholdLinkButton`, `ThresholdNotice`. Colors (and the logo asset) come from `ThresholdPalette.of(context)`, never hard-coded. The native launch screen mirrors it; regenerate it after changing ground colors.
- Adaptive per OS: branch on `useCupertino(context)` (`core/widgets/adaptive.dart`) for buttons, segmented controls, indicators and icons: Material on Android, Cupertino on iOS.
- Use min-height rather than fixed heights for rows containing text, so 200% text scaling grows instead of clipping.
- `sharedPreferencesProvider` is loaded in `main()` and must be overridden. Tests use `test/helpers/test_app.dart` (`pumpApp`, fakes).

**Permissions** (not built yet): global roles live in `User.roles` (`GlobalRole` constants). Per-client-account permissions come from `GET /clients/:id/members/:userId` → `permissions` (see section 5 of `docs/frontend-api.md`).

## Testing

`test/` mirrors `lib/`. Each layer is tested with a fake of the layer below it:
- **Use cases:** a fake `AuthRepository`.
- **Repository impls:** a fake remote data source plus `FlutterSecureStorage.setMockInitialValues({})`.
- **Network:** a fake Dio `HttpClientAdapter`.
- **Widget flows:** `pumpApp` in `test/helpers/test_app.dart` overrides preferences and the auth and password-reset repositories with fakes on a phone-sized screen.
- **Visual checks:** `tool/screenshots/threshold_screens_test.dart` renders real fonts (Roboto stands in for San Francisco) and asserts each frame shows the state it claims.
