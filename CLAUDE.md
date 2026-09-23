# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

`sp_cln_app` is a freshly generated Flutter app (stable channel, Dart SDK `^3.13.4`). `lib/main.dart` and `test/widget_test.dart` still hold the default counter template. No app architecture, state management, routing, or extra packages exist yet. Update this file once real structure is added.

## Commands

```sh
flutter pub get                        # install dependencies
flutter run                            # run on the default device (add -d windows / -d chrome / -d <id>)
flutter analyze                        # lint (flutter_lints via analysis_options.yaml)
flutter test                           # run all tests
flutter test test/widget_test.dart     # run a single test file
flutter test --plain-name "Counter increments smoke test"   # run a single test by name
dart format .                          # format
flutter build apk | ios | web | windows | macos | linux
```

## Notes

- `analysis_options.yaml` excludes `build/` and all platform folders (`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`) from analysis. Only `lib/` and `test/` are linted.
- Android `applicationId`/`namespace` is still the placeholder `com.example.sp_cln_app` (`android/app/build.gradle.kts`). Change it before any store release.
- The project targets all six Flutter platforms. Code in `lib/` should stay platform-agnostic unless a platform-specific plugin is added on purpose.
- The repo has no commits yet, and the default branch for PRs is `main` (the local branch is `master`).
