---
name: rent
description: Use when working in the rent Flutter app, especially for rent and bill calculation features, Dart or Flutter UI changes, tests, theme persistence, assets, Android or iOS build configuration, and repository workflow decisions.
---

# rent Flutter Development Patterns

Use this skill when changing or reviewing code in the `rent` repository. This is a Flutter app for rent and bill calculation.

## Project Layout

- Application code lives in `lib/`.
- `lib/main.dart` starts the app.
- `lib/app.dart` wires app-level setup.
- Shared theme logic belongs in `lib/core/`.
- Feature code belongs in `lib/features/<feature>/`.
- Current feature folders include `home/`, `coaching/`, and `dashboard/`.
- Reusable feature widgets should live under the matching feature's `widgets/` folder.
- Tests live in `test/`, including widget tests like `test/widget_test.dart`.
- Image assets live in `assets/` and must be declared in `pubspec.yaml`.
- Platform-specific code and build configuration live under `android/` and `ios/`.

## Development Commands

- Run `flutter pub get` after dependency changes.
- Run `flutter run` to launch the app on a selected simulator, emulator, or device.
- Run `flutter test` for the test suite.
- Run `flutter analyze` for analyzer checks.
- Run `dart format lib test` after Dart edits.
- Run `flutter build apk --release` to create a release Android APK.

## Coding Style

- Use standard Dart formatting with 2-space indentation.
- Use trailing commas where they improve Flutter widget readability.
- Keep filenames in `snake_case.dart`.
- Use `PascalCase` for classes and widgets.
- Use `lowerCamelCase` for variables, methods, and controllers.
- Prefer small widgets and controllers over large screen files as behavior grows.
- Keep feature-specific code inside the matching `lib/features/<feature>/` folder.

## Testing Expectations

- Use `flutter_test` for widget and unit coverage.
- Name test files with the `_test.dart` suffix.
- Mock persistent app state, such as `SharedPreferences`, before pumping widgets when needed.
- Add or update tests when changing calculation behavior, validation, navigation, or theme persistence.
- Run `flutter test` before opening a pull request.

## Repository Workflow

- Use short Conventional Commit-style messages such as `feat:`, `fix:`, `test:`, `docs:`, or `refactor:`.
- Keep each commit focused on one logical change.
- Pull requests should include a concise summary, testing performed, linked issue or task when available, and screenshots or screen recordings for visible UI changes.

## Security And Configuration

- Do not commit generated build output, local IDE state, signing keys, or device-specific secrets.
- Keep assets registered in `pubspec.yaml`.
- Verify Android and iOS permission changes on a real device when adding platform capabilities.
