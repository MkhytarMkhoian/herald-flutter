import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:herald/herald.dart';

import '../appsflyer_event_tracker.dart';
import '../appsflyer_values.dart';

final class const GenericAppsFlyerEventTracker(final Event event, final AppsFlyerSdk appsFlyer)
    implements AppsFlyerEventTracker {
  @override
  Future<void> track() =>
      appsFlyer.logEvent(event.name, eventValues: event.parameters.toAppsFlyerEventValues());
}
