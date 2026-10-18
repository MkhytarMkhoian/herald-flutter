import 'package:herald/herald.dart';

import 'meta_event_tracker_factory.dart';

/// Sends events to Meta, as its factory chain decides. Meta keeps no user attributes, so there are
/// no properties.
final class const MetaAnalyticsTrackerService({
  required final MetaEventTrackerFactory eventTrackerFactory,
}) implements EventTrackerService {
  @override
  Future<void> track(Event event) async {
    for (final handler in eventTrackerFactory.create(event).handlers) {
      await handler.track();
    }
  }
}
