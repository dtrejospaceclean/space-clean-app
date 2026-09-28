# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`sp_cln_app` is a Flutter **mobile** app (Android and iOS only; Dart SDK `^3.13.4`) for a REST backend documented in `docs/frontend-api.md` (endpoints, envelope, permission model) and `docs/api-message-keys.md` (every translation key the API can return). `docs/` is git-ignored, so read those files locally before building a feature against an endpoint. The backend source (NestJS + Prisma) is at `D:\DevProjects\sp_cln_be`. Its DTOs (`src/**/dto/*.ts`) are the exact request contract (unknown fields are rejected), and they cover details the docs leave out, such as which fields `PATCH` accepts.

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

**Features:** `auth` (sign-in, session, remembered email), `password_reset` (email → 6-digit code → new password; its repository throws `UnavailableFailure` until the backend defines reset endpoints, so don't guess that contract), `settings` (EN/ES choice persisted in SharedPreferences; `null` follows the device), `clients` (the user's accounts), `contacts` (people at an account), `access` (per-account permissions), `jobs`, `profile` (Me: own profile via `PATCH /auth/me`, change password, Administration), `service_catalog` (`/service-catalog`), `shell`, `users` (user and role administration).

**Signed-in app:** `StatefulShellRoute` with three tabs (`/today`, `/accounts`, `/me`), each with its own stack (`features/shell/presentation/app_shell.dart`, custom `SpaceBottomBar`: a floating dock of icon-only tabs, found in tests with `find.byTooltip('Me')`). The "+" beside the dock is the app's only "+" (screens have none). Its options follow the page on top: `_byPage` in `app_shell.dart` maps a route pattern to options, `_noPlus` hides it on forms, and other pages get `_everywhere`. Each option is gated by a global-role policy. When a list page gets a create form, add its route there instead of a header button. Riverpod auto-retry is off (`retry: (_, _) => null` in `main.dart` and tests).
- **No cross-account endpoints:** jobs, calendar, complaints and tasks live under `/clients/:clientId/...`. Today merges accounts in `GetDayJobs` (one request per account in parallel; 403 accounts are skipped, other failures reported as `failedClients`).
- **Permissions:** build every action from `accountAccessProvider(clientId).can(Permissions.x)`, never from the role name. Global owners bypass membership (no request). Everyone else reads `GET /clients/:id/members/me`, which every member may call; a 403 means not a member (`AccountAccess.none`). `GET /clients` is already filtered to the user's accounts.
- **Own profile:** Me → Edit (`/me/edit`) is open to everyone and sends only `name`, `phoneNumber` and the emergency contact (`PATCH /auth/me`); the saved user goes back into `AuthController.replaceUser`. Email, roles and pay stay with owners in user administration. Change password is `/me/password`.
- **Service catalog** (`/me/services`, Administration): owners and account managers (`ServiceCatalogPolicy.canManage`) maintain it. Three list pages share `_CatalogPage` (a search-only `CatalogQuery` per `CatalogList`; no status filter, every row has a `StatusIcon` and inactive titles are muted, like the users list): every service at `/me/services` in one list by name, and `/me/services/categories` and `/me/services/units`, reached from the dock's "+". Services pick a category (optional) and a unit (required) from the active ones and show prices as `$0.12` with "Janitorial · per sq ft" (`UnitOfMeasure.short`). Services are never deleted, only set inactive. Categories and units share `LookupFormScreen`: Delete shows only while `serviceCount` is 0, otherwise the form says to set it Inactive. After any save or delete call `invalidateCatalog(ref)`. Later pickers should query `isActive: true`.
- **User administration** lives under Me → Administration (`/me/users`, `/me/roles`). It's visible to global `owner` and `account_manager` (`UserAdminPolicy.canView`), and only owners get write controls (`canEdit`). The Administration rows come from `adminModules` in `features/profile/presentation/admin_modules.dart`. Each entry has its own global-role visibility rule, so a new tool is one route under `/me` plus one entry there. Users are never deleted, only deactivated with `PATCH {isActive}`. Roles change via `PUT /users/:id/roles`, which `UpdateUser` calls only when they changed. Owners can reset a password by setting a new one in Edit. Forms are `FormSection`s (titled white cards) of `SpaceTextField`/`PickerField`, with roles as `ChoicePills` and a `PrimaryButton` pinned at the bottom. Server field errors are shown by re-running the validators after a failed save.
- **Account screen modules:** the account screen lists what a member can open as grouped rows. The rows come from `accountModules` in `features/clients/presentation/account_modules.dart`, filtered by permission. Only built modules get an entry, and there are no "coming soon" placeholders. To add a module, give it a route under `/accounts/:clientId` and an entry there (add an `AccountSection` if it needs a new group).
- **Account management** (`clients`): the Accounts tab's "+" (`/accounts/new`) is shown to global `owner`/`account_manager` (`AccountAdminPolicy.canCreate`). The Account details tile opens `/accounts/:id/info` (`info.view`). Edit (`info/edit`) needs `info.edit`, and Delete is for owners only. The API refuses to delete an account with history (`clients.has_related_records`), so users set it to Inactive instead. Creating an account doesn't make its creator a member, so only owners are taken to it afterwards. Everyone else gets a notice. Assignee pickers need `GET /users`, and they stay read-only for anyone who can't list users. On edit, assignees and status are sent only when they changed.
- **Contacts** (`/accounts/:clientId/contacts`, an Account-section module): listing needs `info.view`; add (from the dock's "+"), edit and delete need `info.edit`. The list isn't paginated and comes primary first; the detail screen reads from it (`contactProvider`), so invalidate `contactsProvider(clientId)` after any write. Setting Primary or Billing takes it from the other contacts on the server. Only global owners give a login (`ContactLoginPolicy`, `…/:contactId/login`), and only to a contact with an email. Deleting a contact leaves their login and membership, and the confirmation says so.
- **"+" inside an account:** `_PlusOption.inAccount` gates an option by a permission on the page's account (`accountAccessProvider`) and fills `:clientId` in its path.
- **Time:** `clockProvider` supplies "now" (tests pin it). Format dates and times with `core/l10n/formatting.dart`, which follows the locale and 12/24-hour setting.

**UI conventions**
- **Design system** (`lib/core/design/`, import `design.dart`), modeled on `docs/example_app.png` and the same on both platforms. Tokens: `SpaceColors` (`ground`, `surface`, `ink`, `accent`, `primary`, …), `SpaceRadius`, `SpaceSpace`. `SpaceColors` is a `ThemeExtension` with `light` and `dark` palettes, so always read colors with `context.colors.x`. Constants can't follow the theme, so give widgets nullable color parameters that resolve in `build`. `SpaceTheme.light()`/`dark()` set Manrope and orange pill `FilledButton`s. Appearance (System/Light/Dark, default System) lives in `settings` (`themeModeControllerProvider`, key `settings.theme_mode`), next to the language setting. Use `SpaceLogo` for the logo, which switches to the white knockout in dark mode. Every screen is a `SpacePage`: one header row with the back button (pushed screens), the title (or `heading:` for a `HeroHeadline`), and round `CircleButton`s with `PageBox`/`PageSliver` content. Components: `SpaceCard`, `StatCard`/`CardRow`, `TileCard`/`CardGrid`, `ListCard`/`ListRow`, `HeroHeadline` (two-tone), `SectionHeader`, `IconBadge`, `InitialsAvatar`, `StatusPill`, `SpaceProgressBar`, `AccentBanner`, `PrimaryButton`/`SecondaryButton`/`LinkButton`, `PillToggle`, `SpaceTextField`/`PickerField`/`ChoicePills`/`FormSection`, `SearchField`, `StatusIcon`, `Notice`, `SpaceBottomBar`, `AsyncSlivers`/`MessageSliver`. Don't use raw Material/Cupertino look-alikes or hard-coded colors.
- Only *behaviors* stay native (`core/widgets/adaptive.dart`, `core/design/widgets/pickers.dart`): adaptive dialogs (`adaptiveAction`), date and choice pickers, adaptive spinners, and page transitions. Visuals are the same on both OS. Pushed screens keep the native transition and back gesture. Top-level swaps (splash, login, the shell) cross-fade via `fadePage` (`core/router/transitions.dart`), and tab switches fade in via `FadeBranchContainer` (`features/shell/presentation/branch_container.dart`). Both are instant when the OS asks for reduced motion.
- Use min-height rather than fixed heights for rows containing text, so 200% text scaling grows instead of clipping.
- `sharedPreferencesProvider` is loaded in `main()` and must be overridden. Tests use `test/helpers/test_app.dart` (`pumpApp`, fakes).

**Permissions:** global roles live in `User.roles` (`GlobalRole` constants). Per-client-account permissions come from `GET /clients/:id/members/me` → `permissions` (see section 5 of `docs/frontend-api.md`).

## Testing

`test/` mirrors `lib/`. Each layer is tested with a fake of the layer below it:
- **Use cases:** a fake `AuthRepository`.
- **Repository impls:** a fake remote data source plus `FlutterSecureStorage.setMockInitialValues({})`.
- **Network:** a fake Dio `HttpClientAdapter`.
- **Widget flows:** `pumpApp` in `test/helpers/test_app.dart` puts fakes behind every repository (auth, password reset, clients, contacts, jobs, access, users, roles, profile, service catalog), pins the clock to `testNow`, and uses a phone-sized screen. `job()` builds test jobs.
- **Visual checks:** `tool/screenshots/threshold_screens_test.dart` renders sign-in (`threshold_*`) and signed-in (`app_*`, with synthetic demo data) sheets in real fonts (Roboto stands in for San Francisco), and asserts each frame shows the state it claims.
