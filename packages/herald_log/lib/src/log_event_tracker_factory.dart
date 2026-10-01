import 'package:herald/herald.dart';

import 'log_event_tracker.dart';

/// Decides what the log gets for an event: [Claimed] with the calls to make, [Dropped] to send
/// nothing, or [Declined] to let the next factory decide.
abstract interface class LogEventTrackerFactory {
  Resolution<LogEventTracker> create(Event event);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeLogEventTrackerFactory(List<LogEventTrackerFactory> factories)
    implements LogEventTrackerFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<LogEventTrackerFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<LogEventTracker> create(Event event) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(event)));
}
