import 'package:herald/herald.dart';

import 'firebase_event_tracker.dart';

/// Decides what Firebase gets for an event: [Claimed] with the calls to make, [Dropped] to send
/// nothing, or [Declined] to let the next factory decide.
abstract interface class FirebaseEventTrackerFactory {
  Resolution<FirebaseEventTracker> create(Event event);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeFirebaseEventTrackerFactory(List<FirebaseEventTrackerFactory> factories)
    implements FirebaseEventTrackerFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<FirebaseEventTrackerFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<FirebaseEventTracker> create(Event event) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(event)));
}
