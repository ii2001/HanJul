# Repository Guidelines

## Project Structure & Module Organization

HanJul is a Korean macOS SwiftUI menu-bar app. The Xcode project is `HanJul.xcodeproj`; application code lives in `HanJul/`:

- `Domain/`: value types such as `Quote`.
- `Data/`: bundled-data loading and future persistence adapters.
- `Services/`: focused system and application services.
- `Resources/`: bundled JSON and other non-asset resources.
- `Assets.xcassets/`: colors and image assets.
- `HanJulTests/`: unit tests; add this directory to a macOS unit-test target before running it.

Keep feature UI close to its feature. Add shared layers only after two features need them.

## Build, Test, and Development Commands

Run from the repository root:

```sh
open "HanJul.xcodeproj"
xcodebuild -project "HanJul.xcodeproj" -scheme "HanJul" \
  -destination 'generic/platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild test -project "HanJul.xcodeproj" -scheme "HanJul" \
  -destination 'platform=macOS'
```

The test command requires a shared scheme containing the unit-test target. Use Xcode previews for layout checks, not as a substitute for unit tests.

## Coding Style & Naming Conventions

Use four-space indentation and standard Swift naming: `UpperCamelCase` for types, `lowerCamelCase` for members, and filenames matching their primary type. Prefer immutable values, small SwiftUI views, native Apple frameworks, and dependency injection only at time, storage, or system boundaries. Use `OSLog` instead of `print` in production code. No formatter or linter is configured; use Xcode's re-indent command.

## Testing Guidelines

Use XCTest. Name files `<Type>Tests.swift` and tests `test_<behavior>()`. Cover deterministic date selection, decoding failures, calendar/time-zone boundaries, and persistence behavior. Tests must not depend on the current date, locale, or random APIs.

## Commit & Pull Request Guidelines

Every commit message must use Gitmoji Conventional Commit format, for example `✨ feat(quotes): add daily selection` or `🐛 fix(widget): honor local day`. Keep commits focused. Pull requests should include purpose, verification commands, linked issues, and screenshots for UI changes.

## Xcode Project Safety

Do not hand-edit `project.pbxproj` unless explicitly requested. Add targets, signing, entitlements, App Groups, and capabilities through Xcode, and avoid committing `xcuserdata/` changes.
