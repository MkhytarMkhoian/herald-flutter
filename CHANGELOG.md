# Change Log

## Version 1.0.0-dev.3

_Unreleased_

 * New: `herald_widgets`, an optional package for tracking from Flutter widgets, like the Android
   SDK's `herald-compose`. `TrackScreenView` tracks a screen view each time a screen becomes visible,
   `TrackOnScreen` tracks any event when a screen is shown or hidden, `TrackImpression` tracks
   something once it is really on screen, and `HeraldScope.of(context)` gives widgets the tracker
   for taps.

## Version 1.0.0-dev.2

_2026-10-05_

The first preview of Herald for Flutter: the Android SDK's design, in Dart, over each vendor's
official Flutter plugin.

 * New: `herald`, the core, in pure Dart: events and properties with typed values, the five
   capability interfaces, the factory chain and the `Herald` fan-out.
 * New: `herald_firebase`, `herald_adjust`, `herald_mixpanel`, `herald_appsflyer` and
   `herald_amplitude`, over `firebase_analytics` 12, `adjust_sdk` 5, `mixpanel_flutter` 2,
   `appsflyer_sdk` 7 and `amplitude_flutter` 4.
 * New: `herald_log`, which prints every call in the Android SDK's format.
 * New: `herald_testing`, with `FakeAnalyticsProvider` and its assertions.
