import 'package:herald/herald.dart';

import 'appsflyer_event_tracker.dart';

/// Decides what AppsFlyer gets for an event: [Claimed] with the calls to make, [Dropped] to send
/// nothing, or [Declined] to let the next factory decide.
abstract interface class AppsFlyerEventTrackerFactory {
  Resolution<AppsFlyerEventTracker> create(Event event);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeAppsFlyerEventTrackerFactory(List<AppsFlyerEventTrackerFactory> factories)
    implements AppsFlyerEventTrackerFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<AppsFlyerEventTrackerFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<AppsFlyerEventTracker> create(Event event) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(event)));
}
