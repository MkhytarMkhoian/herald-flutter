import 'analytics_error_reporter.dart';
import 'analytics_lifecycle_service.dart';
import 'analytics_operation.dart';
import 'consent_service.dart';
import 'event.dart';
import 'event_tracker_service.dart';
import 'identifiable_user_service.dart';
import 'identity.dart';
import 'property.dart';
import 'property_tracker_service.dart';

/// One vendor: a name and the capabilities it has.
///
/// An adapter with several capabilities is passed under each. [name] shows up in failure reports,
/// so pick one you'll recognise.
///
/// To skip or sample events for one vendor, wrap its capability in a decorator, like the one shown
/// on [EventTrackerService]:
///
/// ```dart
/// HeraldProvider(name: 'attribution', events: ExceptPiiEventTracker(attributionTracker))
/// ```
final class HeraldProvider({
  required final String name,
  final EventTrackerService? events,
  final PropertyTrackerService? properties,
  final IdentifiableUserService? identity,
  final AnalyticsLifecycleService? lifecycle,
  final ConsentService? consent,
}) {
  /// Throws an [ArgumentError] if [name] is blank or no capability is given.
  this {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'A provider needs a name; it is what identifies it in a failure report',
      );
    }
    if (events == null &&
        properties == null &&
        identity == null &&
        lifecycle == null &&
        consent == null) {
      throw ArgumentError(
        "Provider '$name' was registered with no capabilities, so it can never be called.",
      );
    }
  }

  @override
  String toString() => 'HeraldProvider($name)';
}

/// Sends each call to every vendor.
///
/// It implements all five capabilities. Give your classes the interface they need, such as
/// [EventTrackerService], not `Herald` itself.
///
/// ```dart
/// final herald = Herald(
///   providers: [
///     HeraldProvider(
///       name: 'analytics',
///       events: analyticsTracker,
///       properties: analyticsTracker,
///       identity: analyticsService,
///       lifecycle: analyticsService,
///       consent: analyticsService,
///     ),
///     HeraldProvider(name: 'attribution', events: attributionTracker),
///   ],
///   errorReporter: (failure) => crashReporter.recordError(failure.error, failure.stackTrace),
/// );
/// ```
///
/// ## Order
///
/// A call starts right away and reaches every vendor at once. It completes when every vendor has
/// handled it. Calls don't wait for each other, so when order matters, such as turning collection
/// off before tracking, await the earlier call:
///
/// ```dart
/// await herald.setEnabled(false);
/// await herald.track(event);
/// ```
///
/// ## Failures
///
/// If a vendor throws, the others still run. Failures go to the error reporter after all vendors
/// are done, in registration order. A call on `Herald` itself never fails.
///
/// Every provider needs its own name; a repeated name throws an [ArgumentError].
final class Herald({
  required Iterable<HeraldProvider> providers,
  final AnalyticsErrorReporter? _errorReporter,
}) implements
    EventTrackerService,
    PropertyTrackerService,
    IdentifiableUserService,
    AnalyticsLifecycleService,
    ConsentService {
  /// Failures go to `errorReporter`. Without one, they are ignored.
  this {
    final seen = <String>{};
    for (final provider in _providers) {
      if (!seen.add(provider.name)) {
        throw ArgumentError(
          "Two providers are named '${provider.name}', so a failure report couldn't tell them "
          'apart. Give each provider its own name.',
        );
      }
    }
  }

  final List<HeraldProvider> _providers = List.unmodifiable(providers);

  @override
  Future<void> track(Event event) => _send(
    TrackOperation(event.name),
    (provider) => provider.events,
    (events) => events.track(event),
  );

  @override
  Future<void> set(Property property) => _send(
    SetPropertyOperation(property.name),
    (provider) => provider.properties,
    (properties) => properties.set(property),
  );

  @override
  Future<void> identify(Identity identity) => _send(
    const IdentifyOperation(),
    (provider) => provider.identity,
    (service) => service.identify(identity),
  );

  @override
  Future<void> reset() =>
      _send(const ResetOperation(), (provider) => provider.identity, (service) => service.reset());

  @override
  Future<void> start() => _send(
    const StartOperation(),
    (provider) => provider.lifecycle,
    (lifecycle) => lifecycle.start(),
  );

  @override
  Future<void> setEnabled(bool enabled) => _send(
    SetEnabledOperation(enabled),
    (provider) => provider.consent,
    (consent) => consent.setEnabled(enabled),
  );

  @override
  Future<void> flush() => _send(
    const FlushOperation(),
    (provider) => provider.lifecycle,
    (lifecycle) => lifecycle.flush(),
  );

  /// Calls every provider that has the [capability] at once, then reports what failed, in
  /// registration order. Providers without it are skipped.
  Future<void> _send<S extends Object>(
    AnalyticsOperation operation,
    S? Function(HeraldProvider provider) capability,
    Future<void> Function(S service) call,
  ) async {
    final outcomes = await Future.wait([
      for (final provider in _providers)
        if (capability(provider) case final service?)
          _run(provider, operation, () => call(service)),
    ]);
    final failures = outcomes.whereType<AnalyticsFailure>();

    final reporter = _errorReporter;
    if (reporter == null) return;
    for (final failure in failures) {
      // A failing reporter has nowhere to report to, whether it throws or its future fails.
      Future.sync(() => reporter(failure)).ignore();
    }
  }

  /// Runs [call] for [provider], turning anything it throws into a failure.
  Future<AnalyticsFailure?> _run(
    HeraldProvider provider,
    AnalyticsOperation operation,
    Future<void> Function() call,
  ) async {
    try {
      await call();
      return null;
    } catch (error, stackTrace) {
      return AnalyticsFailure(provider.name, operation, error, stackTrace);
    }
  }
}
