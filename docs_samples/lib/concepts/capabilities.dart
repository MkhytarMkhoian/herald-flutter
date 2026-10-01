import 'package:herald/herald.dart';

import 'vocabulary.dart';

// --8<-- [start:consumers]
class PaywallViewModel(final EventTrackerService analytics) {
  Future<void> onPlanSelected(String plan, int seats) =>
      analytics.track(PlanSelected(plan, seats: seats, price: 9.99, trial: false));
}

class PrivacySettingsViewModel(final ConsentService consent) {
  Future<void> onAnalyticsToggled(bool allowed) => consent.setEnabled(allowed);
}
// --8<-- [end:consumers]

// --8<-- [start:fake]
/// A fake is a small class, because the interface has one method.
final class RecordingEventTracker implements EventTrackerService {
  final tracked = <Event>[];

  @override
  Future<void> track(Event event) async => tracked.add(event);
}
// --8<-- [end:fake]

PaywallViewModel paywallWithFake() => PaywallViewModel(RecordingEventTracker());
