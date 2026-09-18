# HanJul Product Specification

## Product Goal

HanJul is a Korean macOS menu-bar app that presents one quote per local calendar day. It should be lightweight, work offline, and later expose the same daily quote in a desktop widget.

## MVP Scope

1. Show today's quote through `MenuBarExtra`.
2. Select the same quote for the entire local day with SHA256; never use `randomElement`, `Int.random`, or `hashValue`.
3. Load curated Korean quotes from bundled `Resources/quotes.json`.
4. Store favorites locally with SwiftData.
5. Schedule one user-configured daily notification with `UserNotifications`.
6. Provide a WidgetKit desktop widget using shared quote-selection logic.

Supabase anonymous analytics is deferred. It must remain opt-in, collect no quote or favorite contents, and use a non-identifying installation token if introduced.

## Data and Selection

`Quote` contains stable `id`, `text`, and `author` strings. Empty or malformed datasets are errors. `DailyQuoteService` derives a local date key from an injected `Calendar`, hashes it with CryptoKit SHA256, reads the first eight digest bytes as an unsigned integer, and applies modulo by quote count. Tests use a fixed calendar and time zone.

## Intended Structure

```text
HanJul/
  Domain/       Quote and future favorite models
  Data/         JSON loading and SwiftData access
  Services/     Daily quote and notification behavior
  Features/     Menu bar and favorites views
  Resources/    quotes.json
HanJulTests/
Widget/         Widget extension files (after target creation)
```

## Platform and Quality Requirements

- Deployment target: macOS 14 or newer.
- UI: SwiftUI; menu-bar presentation: `MenuBarExtra`.
- Diagnostics: privacy-aware `OSLog`; no `print` in production.
- The app must show a recoverable error if bundled quotes cannot load.
- Quote selection must remain stable across launches and process types for the same calendar day.

## Required Manual Xcode Setup

The generated project currently targets multiple Apple platforms and macOS 26.6.2. In Xcode, restrict Supported Destinations to macOS and set the app deployment target to macOS 14. Create a macOS Unit Testing Bundle for `HanJulTests` and include it in a shared scheme. Later, create a Widget Extension and enable one App Group on both targets for shared data. Configure signing and bundle identifiers in Xcode; do not edit `project.pbxproj` by hand.
