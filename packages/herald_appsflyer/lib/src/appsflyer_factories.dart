import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:herald/herald.dart';

import 'appsflyer_event_tracker.dart';
import 'appsflyer_event_tracker_factory.dart';
import 'trackers/generic_appsflyer_event_tracker.dart';

/// Logs any event under its own name with its parameters. Claims everything, so it belongs last
/// in a chain.
///
/// Most apps leave it out: AppsFlyer is for conversions, each one chosen on purpose, so a chain
/// without a fallback — where only the events a factory handles are sent — is the usual setup.
final class const GenericAppsFlyerEventTrackerFactory(final AppsFlyerSdk appsFlyer)
    implements AppsFlyerEventTrackerFactory, FallbackFactory {
  @override
  Resolution<AppsFlyerEventTracker> create(Event event) =>
      .claimed([GenericAppsFlyerEventTracker(event, appsFlyer)]);

  @override
  String toString() => 'GenericAppsFlyerEventTrackerFactory';
}
