import 'package:herald/herald.dart';

import 'amplitude_event_tracker.dart';

/// Decides what Amplitude gets for an event: [Claimed] with the calls to make, [Dropped] to send
/// nothing, or [Declined] to let the next factory decide.
abstract interface class AmplitudeEventTrackerFactory {
  Resolution<AmplitudeEventTracker> create(Event event);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeAmplitudeEventTrackerFactory(List<AmplitudeEventTrackerFactory> factories)
    implements AmplitudeEventTrackerFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<AmplitudeEventTrackerFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<AmplitudeEventTracker> create(Event event) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(event)));
}
