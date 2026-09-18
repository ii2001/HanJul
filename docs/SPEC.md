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
7. Provide a user-controlled “오늘의 음악” player for bundled local audio through AVFoundation; never autoplay.

Supabase anonymous analytics defaults to on and remains user-disableable. It records only `app_open`, `favorite_toggle`, `notification_toggle`, `music_play`, and `music_pause`, together with a random UUID created once per installation. It never sends names, email addresses, quote contents, or favorites. The public client can insert allowlisted events through RLS but cannot read, update, or delete analytics rows.

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
- Analytics must default to enabled while honoring an explicit user opt-out.
- Local `mp3`, `m4a`, `wav`, and `aac` files added under `HanJul/Resources/Music/` are discovered automatically; a missing audio file must not prevent launch or build.

## Required Manual Xcode Setup

The app, test, and widget targets support macOS 14 or newer. Quote code and bundled resources are shared directly, so no App Group is required. Artwork changes daily by default; the menu-bar app and widget each allow an independent manual override. Configure a Signing Team in Xcode before distribution; bundle identifiers are `com.ii2001.HanJul` and `com.ii2001.HanJul.Widget`.
