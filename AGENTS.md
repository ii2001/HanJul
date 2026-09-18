# Repository Guidelines

## Project Structure & Module Organization

HanJul is a Korean macOS SwiftUI menu-bar app. The Xcode project is `HanJul.xcodeproj`; application code lives in `HanJul/`:

- `HanJul/`: app-only UI, SwiftData models, and system services.
- `Shared/`: quote model, JSON loading, daily selection, and resources shared by app and widget.
- `Widget/`: WidgetKit extension source.
- `supabase/migrations/`: reviewed analytics schema migrations.
- `Assets.xcassets/`: colors and image assets.
- `HanJulTests/`: XCTest unit tests.

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

The shared scheme contains the unit-test target. Use Xcode previews for layout checks, not as a substitute for unit tests.

## Coding Style & Naming Conventions

Use four-space indentation and standard Swift naming: `UpperCamelCase` for types, `lowerCamelCase` for members, and filenames matching their primary type. Prefer immutable values, small SwiftUI views, native Apple frameworks, and dependency injection only at time, storage, or system boundaries. Use `OSLog` instead of `print` in production code. No formatter or linter is configured; use Xcode's re-indent command.

## Testing Guidelines

Use XCTest. Name files `<Type>Tests.swift` and tests `test_<behavior>()`. Cover deterministic date selection, decoding failures, calendar/time-zone boundaries, and persistence behavior. Tests must not depend on the current date, locale, or random APIs.

## Commit & Pull Request Guidelines

Every commit message must use Gitmoji Conventional Commit format, for example `✨ feat(quotes): add daily selection` or `🐛 fix(widget): honor local day`. Keep commits focused. Pull requests should include purpose, verification commands, linked issues, and screenshots for UI changes.

## Xcode Project Safety

Automate in-scope target, entitlement, and capability settings when needed. Keep `project.pbxproj` edits minimal, validate them with `xcodebuild`, never guess a signing team, and avoid committing `xcuserdata/` changes.

Never add Supabase secret or `service_role` keys to the app. The bundled Publishable Key is constrained by RLS; anonymous analytics must remain opt-in and must not include quote text, favorites, or persistent user identifiers.
