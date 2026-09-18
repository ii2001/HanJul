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

Supabase anonymous analytics is opt-in and records only `app_open`, `favorite_toggle`, and `notification_toggle`. It collects no quote contents, favorites, or persistent user identifiers. The public client can insert allowlisted events through RLS but cannot read, update, or delete analytics rows.

## Data and Selection

`Quote` contains stable `id`, `text`, and `author` strings. Empty or malformed datasets are errors. `DailyQuoteService` derives a local date key from an injected `Calendar`, hashes it with CryptoKit SHA256, reads the first eight digest bytes as an unsigned integer, and applies modulo by quote count. Tests use a fixed calendar and time zone.

## Intended Structure

```text
HanJul/         App UI, SwiftData favorites, notifications
Shared/         Quote model, JSON loading, daily selection, quotes.json
HanJulTests/
Widget/         WidgetKit extension
```

## Platform and Quality Requirements

- Deployment target: macOS 14 or newer.
- UI: SwiftUI; menu-bar presentation: `MenuBarExtra`.
- Diagnostics: privacy-aware `OSLog`; no `print` in production.
- The app must show a recoverable error if bundled quotes cannot load.
- Quote selection must remain stable across launches and process types for the same calendar day.
- Analytics must remain disabled until the user explicitly opts in.

## Required Manual Xcode Setup

The app, test, and widget targets support macOS 14 or newer. The widget shares deterministic quote code and bundled JSON with the app, so no App Group is required. Configure a Signing Team in Xcode before distribution; bundle identifiers are `com.ii2001.HanJul` and `com.ii2001.HanJul.Widget`.
