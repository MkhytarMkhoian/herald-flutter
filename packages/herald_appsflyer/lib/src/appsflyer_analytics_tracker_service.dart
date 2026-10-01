import 'package:herald/herald.dart';

import 'appsflyer_event_tracker_factory.dart';

/// Sends events to AppsFlyer, as its factory chain decides. The calls for one event run in order,
/// and if one fails the rest don't run. Events no factory claims aren't sent.
final class const AppsFlyerAnalyticsTrackerService({
  required final AppsFlyerEventTrackerFactory eventTrackerFactory,
}) implements EventTrackerService {
  @override
  Future<void> track(Event event) async {
    for (final handler in eventTrackerFactory.create(event).handlers) {
      await handler.track();
    }
  }
}
