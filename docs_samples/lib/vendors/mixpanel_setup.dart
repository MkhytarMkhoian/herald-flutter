import 'package:herald/herald.dart';
import 'package:herald_mixpanel/herald_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

Future<HeraldProvider> mixpanelProvider(String projectToken) async {
  // --8<-- [start:provider]
  final mixpanel = await Mixpanel.init(
    projectToken,
    trackAutomaticEvents: false,
    optOutTrackingDefault: true, // silent until consent
  );

  final tracker = MixpanelAnalyticsTrackerService(
    eventTrackerFactory: CompositeMixpanelEventTrackerFactory([
      ScreenViewMixpanelEventTrackerFactory(mixpanel),
      GenericMixpanelEventTrackerFactory(mixpanel),
    ]),
    propertySetterFactory: CompositeMixpanelPropertySetterFactory([
      UserPropertyMixpanelPropertySetterFactory(mixpanel), // people profile: must come first
      GenericMixpanelPropertySetterFactory(mixpanel), // super properties
    ]),
  );
  final service = MixpanelAnalyticsService(mixpanel);

  final provider = HeraldProvider(
    name: 'mixpanel',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
  // --8<-- [end:provider]
  return provider;
}
