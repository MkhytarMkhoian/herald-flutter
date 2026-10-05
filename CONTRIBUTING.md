# Contributing

Thanks for helping with Herald. This page explains how to get a change ready to become part of the
Flutter SDK: a new vendor package, a change to an existing one, or a change to `herald`.

Herald's design is shared with the [Android SDK](https://github.com/MkhytarMkhoian/herald). A
change to how Herald behaves — the factory chain, the fan-out, a vendor's consent rules — belongs
in both, so open an issue first and say which SDK you'd like to start with.

## Setting up

Herald uses the Flutter version in `.fvmrc` (Flutter 3.47.5, Dart 3.13). The repository is a
[pub workspace](https://dart.dev/tools/pub/workspaces) managed with [melos](https://melos.invertase.dev):
one `flutter pub get` at the root resolves every package.

```bash
flutter pub get
dart run melos run format:check  # formatting, 100 columns
dart run melos run analyze       # analysis, failing on infos
dart run melos run test          # every package's tests
dart run melos run publish:dry   # what pub.dev will receive
```

To try your change in an app, depend on your checkout by path:

```yaml
dependency_overrides:
  herald:
    path: ../herald-flutter/packages/herald
```

The [example app](example) uses every local package this way, through the workspace.

## What every change needs

- **Code that matches its surroundings.** Run `dart format .`. Use the same naming and the same
  amount of comments as the code around your change. Name things the way the analytics vendors do,
  for example `Identity.userId`, because every SDK calls it a user id.
- **Few comments, in simple words.** Document what a reader can't guess from the name: a vendor
  rule, a gotcha, why an order matters. Don't add a comment that repeats the name, such as
  "The event to track."
- **Primary constructors** for concrete classes, with fields declared in the class header. When
  the constructor needs a comment, put it on an in-body `this;`, or on `this { ... }` when it
  validates. Abstract bases with no fields keep a plain `const Base();`.
- **Core knows no vendor.** `herald` never names a vendor, in code, docs or examples. A vendor's
  rules, setup and gotchas go in that vendor's package.
- **Dart idioms over Kotlin ones.** Herald's design is shared with Android; its syntax isn't. An
  interface is implemented by a named class, not built from a closure.
- **Tests,** in the package's own `test/`. Core, log and testing use `package:test`; vendor
  packages use `flutter_test` and [mocktail](https://pub.dev/packages/mocktail). `herald_testing`
  is a package for apps' tests, not for Herald's own.
- **A careful public API.** Everything exported from a package's library file is Herald's API and
  can only change incompatibly in a major version. Keep helpers in `lib/src` and out of the export
  list.
- **Documentation, when users would notice.** Update the matching sample in `docs_samples`, which
  CI compiles and tests, and the matching website page if its wording changes. The website shows
  each `// --8<--` section and the marked sections of `README.md` by name, so keep those names, or
  rename them on the website in step. Links inside marked README sections must be absolute,
  because they also appear on the website.
- **A line in `CHANGELOG.md`** under the next, unreleased version, starting with `New:`, `Fix:`,
  `Upgrade:` or `Breaking:`.

## A new vendor package

A new vendor gets a package of its own, shaped like the existing ones. Use `herald_mixpanel` as the
template, or `herald_appsflyer` for a vendor that only takes events. A new vendor never needs a
change to `herald`.

- [ ] **The package.** `packages/herald_<vendor>`, with `resolution: workspace`, the vendor's
      Flutter plugin as a dependency, a `LICENSE` copy, a `README.md`, a `CHANGELOG.md`, the
      `analysis_options.yaml` every package has, and an `example/herald_<vendor>_example.dart`
      that sets the vendor up. pub.dev shows the example on the package page and scores the package
      on both. Add it to the root `pubspec.yaml` workspace list and to the publish order in
      `.github/workflows/publish.yml` and `RELEASING.md`.
- [ ] **The factory chain,** the same as every other vendor's: the handler and factory
      interfaces, the composites (which call `FallbackFactory.requireLast`), the `RequireMapped`
      factories and the tracker service.
- [ ] **The vendor's settings stay the app's.** The package takes a plugin object the app has
      already configured, and never sets keys, endpoints, data residency or log levels itself. A
      plugin made of static functions is called directly, as Adjust is, and its tests record the
      plugin's channel.
- [ ] **Services.** A `<Vendor>AnalyticsTrackerService` and a `<Vendor>AnalyticsService` for
      start-up, sign-in and consent.
- [ ] **Factories and handlers:**
    - [ ] a generic factory marked `FallbackFactory`, if sending an event under its own name makes
          sense for this vendor;
    - [ ] one handler class for each different vendor call, named after the vendor:
          `Generic<Vendor>EventTracker`, `ScreenView<Vendor>EventTracker`.
- [ ] **How consent works, backed by the vendor's own documentation.** What does a fresh install
      send? What does `setEnabled` call? Does the vendor remember the choice across launches?
- [ ] **Typed values.** Send numbers and booleans as themselves wherever the plugin accepts them.
- [ ] **Tests** for every service method, factory and handler.
- [ ] **Everywhere packages are listed:** the table in `README.md`, `docs_samples`, and the vendor
      page on the website.
