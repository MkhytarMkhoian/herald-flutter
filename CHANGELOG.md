# Change Log

## Version 1.0.0-dev.2

_Unreleased_

The first preview of Herald for Flutter: the Android SDK's design, in Dart, over each vendor's
official Flutter plugin.

 * New: `herald`, the core, in pure Dart: events and properties with typed values, the five
   capability interfaces, the factory chain and the `Herald` fan-out.
 * New: `herald_firebase`, `herald_adjust`, `herald_mixpanel`, `herald_appsflyer` and
   `herald_amplitude`, over `firebase_analytics` 12, `adjust_sdk` 5, `mixpanel_flutter` 2,
   `appsflyer_sdk` 7 and `amplitude_flutter` 4.
 * New: `herald_log`, which prints every call in the Android SDK's format.
 * New: `herald_testing`, with `FakeAnalyticsProvider` and its assertions.
