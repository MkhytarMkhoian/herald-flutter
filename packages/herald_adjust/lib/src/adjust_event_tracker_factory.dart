import 'package:herald/herald.dart';

import 'adjust_event_tracker.dart';

/// Decides what Adjust gets for an event: [Claimed] with the calls to make, [Dropped] to send
/// nothing, or [Declined] to let the next factory decide.
abstract interface class AdjustEventTrackerFactory {
  Resolution<AdjustEventTracker> create(Event event);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeAdjustEventTrackerFactory(List<AdjustEventTrackerFactory> factories)
    implements AdjustEventTrackerFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<AdjustEventTrackerFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<AdjustEventTracker> create(Event event) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(event)));
}
