import 'package:herald/herald.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../mixpanel_event_tracker.dart';
import '../mixpanel_values.dart';

final class const GenericMixpanelEventTracker(final Event event, final Mixpanel mixpanel)
    implements MixpanelEventTracker {
  @override
  Future<void> track() =>
      mixpanel.track(event.name, properties: event.parameters.toMixpanelProperties());
}
