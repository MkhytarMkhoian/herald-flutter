import 'dart:math';

import 'package:herald/herald.dart';

abstract interface class EventsApi {
  Future<void> send(String name, Map<String, String> parameters);
}

// --8<-- [start:backend]
final class const BackendAnalytics(final EventsApi api) implements EventTrackerService {
  @override
  Future<void> track(Event event) => api.send(event.name, {
    for (final MapEntry(:key, :value) in event.parameters.entries) key: value.asString,
  });
}
// --8<-- [end:backend]

/// An event with personal data, which must stay on the device.
abstract interface class PiiEvent implements Event {}

// --8<-- [start:decorators]
/// Sends only some events, for a vendor that charges per event.
final class SampledEventTracker(
  final EventTrackerService inner,
  final double rate, [
  Random? random,
]) implements EventTrackerService {
  final Random _random = random ?? Random();

  @override
  Future<void> track(Event event) async {
    if (_random.nextDouble() < rate) await inner.track(event);
  }
}

final class const ExceptEventTracker(
  final EventTrackerService inner,
  final bool Function(Event event) excluded,
) implements EventTrackerService {
  @override
  Future<void> track(Event event) async {
    if (!excluded(event)) await inner.track(event);
  }
}

extension EventTrackerDecorators on EventTrackerService {
  EventTrackerService sampled(double rate) => SampledEventTracker(this, rate);

  EventTrackerService except(bool Function(Event event) excluded) =>
      ExceptEventTracker(this, excluded);
}
// --8<-- [end:decorators]

Herald register(EventsApi api, EventTrackerService adjustTracker) {
  // --8<-- [start:register]
  final herald = Herald(
    providers: [
      HeraldProvider(
        name: 'backend',
        events: BackendAnalytics(api).except((event) => event is PiiEvent),
      ),
      HeraldProvider(name: 'adjust', events: adjustTracker.sampled(0.1)),
    ],
  );
  // --8<-- [end:register]
  return herald;
}
