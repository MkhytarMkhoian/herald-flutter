<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/MkhytarMkhoian/herald/main/docs/assets/readme-banner-dark.png">
  <img alt="Herald" src="https://raw.githubusercontent.com/MkhytarMkhoian/herald/main/docs/assets/readme-banner-light.png">
</picture>

> *A herald announces an event to whoever is listening.*

[![CI](https://github.com/MkhytarMkhoian/herald-flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/MkhytarMkhoian/herald-flutter/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-website-indigo.svg)](https://mkhytarmkhoian.github.io/herald/)

Herald is an analytics library for mobile apps. Your app describes what happened as an event, and
Herald sends that event to every analytics service you use: Firebase, Adjust, Mixpanel, AppsFlyer,
Amplitude, or one you build yourself.

This repository is the **Flutter SDK**. It is the same design as the
[Android SDK](https://github.com/MkhytarMkhoian/herald) — the same events, interfaces, factories and
vendor rules — written in Dart, over each vendor's official Flutter plugin.

- **Your features don't know which vendors you use.** A feature tracks its own event, like
  `CheckoutStarted`, and never calls a vendor SDK directly.
- **Each vendor gets data the way it expects.** GA4 wants screen views as `screen_view`, Adjust
  only takes events you created a token for, and AppsFlyer counts money only as `af_revenue`. You
  describe these rules once per vendor.
- **It fits apps split into packages.** Each feature package keeps its own events and decides how
  they reach each vendor.
- **One broken vendor can't break the rest.** If a vendor plugin throws, Herald reports the error
  and keeps sending to the others.
- **Easy to test.** Your classes depend on a small interface, not a vendor plugin, and a fake
  records every event in tests.

## Install

```yaml
dependencies:
  herald: ^1.0.0-dev.1
  herald_firebase: ^1.0.0-dev.1 # one per vendor you use

dev_dependencies:
  herald_testing: ^1.0.0-dev.1
```

All packages share one version. Each vendor package pulls in `herald` and that vendor's Flutter
plugin. Herald needs Dart 3.13 and Flutter 3.47 or newer.

## In 30 seconds

An event is a type your app owns:

```dart
final class CheckoutStarted extends Event {
  const CheckoutStarted(this.plan, this.seats);

  final String plan;
  final int seats;

  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {
    'plan': .string(plan),
    'seats': .int(seats), // stays a number all the way to the vendor
  };
}
```

A class tracks it through `EventTrackerService`, a small interface. It doesn't know which vendors
exist:

```dart
class CheckoutViewModel {
  CheckoutViewModel(this.analytics);

  final EventTrackerService analytics;

  Future<void> onCheckout(String plan, int seats) => analytics.track(CheckoutStarted(plan, seats));
}
```

At start-up, you build one `Herald` with your vendors and give it to your classes as
`EventTrackerService`:

```dart
final herald = Herald(
  providers: [
    HeraldProvider(name: 'firebase', events: firebaseTracker, properties: firebaseTracker),
    HeraldProvider(name: 'adjust', events: adjustTracker),
  ],
  errorReporter: (failure) => FirebaseCrashlytics.instance.recordError(
    failure.error,
    failure.stackTrace,
    reason: '$failure',
  ),
);
```

## Packages

| Package | What it is |
| --- | --- |
| [`herald`](packages/herald) | Events, properties and `Herald` itself. Pure Dart, with no Flutter, vendor SDK or DI library. |
| [`herald_firebase`](packages/herald_firebase) | Sends to Firebase Analytics (GA4), over `firebase_analytics`. |
| [`herald_adjust`](packages/herald_adjust) | Sends to Adjust, over `adjust_sdk`: events by dashboard token, purchases and ad revenue. |
| [`herald_mixpanel`](packages/herald_mixpanel) | Sends to Mixpanel, over `mixpanel_flutter`: events, user profile and super properties. |
| [`herald_appsflyer`](packages/herald_appsflyer) | Sends to AppsFlyer, over `appsflyer_sdk` 7: conversions, purchases, subscriptions and ad revenue. |
| [`herald_amplitude`](packages/herald_amplitude) | Sends to Amplitude, over `amplitude_flutter`: events, user properties, screen views and revenue. |
| [`herald_log`](packages/herald_log) | Prints every call, for debug builds. Pure Dart. |
| [`herald_testing`](packages/herald_testing) | `FakeAnalyticsProvider`, a fake vendor that records events so your tests can check them. |

The Android SDK's `herald-compose` has no Flutter counterpart: track screen views from a
`NavigatorObserver`, as the [example app](example) does.

## What differs from Android

Herald's concepts are the same on both platforms. Where Dart differs from Kotlin, the API follows
Dart:

- **Futures, not coroutines.** Every capability returns a `Future<void>`. There is no dispatcher:
  vendor plugins already do their work off the UI thread.
- **Four value types.** Dart has one integer and one floating-point type, so `AnalyticsValue` is
  `.string`, `.int`, `.double` or `.bool`. Write parameters as a map with dot shorthands:
  `{'seats': .int(3)}`.
- **Failures come as one object.** The error reporter receives an `AnalyticsFailure`, with the
  vendor, the call, the error and its stack trace, like Flutter's `FlutterError.onError`.
- **Constructors, not builders.** `Herald(providers: [...])` and `HeraldProvider(name: ..., events:
  ...)`. Chains take a list: `CompositeFirebaseEventTrackerFactory([...])`.
- **Vendor-qualified handler names.** Dart has no sub-packages, so trackers are named after their
  vendor, as factories already are: `GenericFirebaseEventTracker`, `TokenAdjustEventTracker`.
- **Adjust takes no SDK object.** The Adjust plugin is static functions, so the adapter calls them
  directly. Its tests record what the plugin sends over its channel.

## Documentation

The full documentation is on the [project website](https://mkhytarmkhoian.github.io/herald/). Its
guides describe Herald itself, not one platform, so they apply here too.

The [example app](example) sends every call to the log and to an on-screen timeline, and its tests
use `herald_testing`.

See [CHANGELOG.md](CHANGELOG.md) for release notes and [CONTRIBUTING.md](CONTRIBUTING.md) to
contribute.

## License

    Copyright 2026 Mkhytar Mkhoian

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
