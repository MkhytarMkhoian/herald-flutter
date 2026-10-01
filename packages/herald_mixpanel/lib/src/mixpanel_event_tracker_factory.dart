import 'package:herald/herald.dart';

import 'mixpanel_event_tracker.dart';

/// Decides what Mixpanel gets for an event: [Claimed] with the calls to make, [Dropped] to send
/// nothing, or [Declined] to let the next factory decide.
abstract interface class MixpanelEventTrackerFactory {
  Resolution<MixpanelEventTracker> create(Event event);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeMixpanelEventTrackerFactory(List<MixpanelEventTrackerFactory> factories)
    implements MixpanelEventTrackerFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<MixpanelEventTrackerFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<MixpanelEventTracker> create(Event event) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(event)));
}
