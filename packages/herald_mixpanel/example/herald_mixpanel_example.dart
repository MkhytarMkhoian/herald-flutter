import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';
import 'package:herald_mixpanel/herald_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

final class const CheckoutStarted(final String plan, final int seats) extends Event {
  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
}

HeraldProvider mixpanelProvider(Mixpanel mixpanel) {
  final tracker = MixpanelAnalyticsTrackerService(
    eventTrackerFactory: CompositeMixpanelEventTrackerFactory([
      ScreenViewMixpanelEventTrackerFactory(mixpanel),
      GenericMixpanelEventTrackerFactory(mixpanel),
    ]),
    propertySetterFactory: CompositeMixpanelPropertySetterFactory([
      UserPropertyMixpanelPropertySetterFactory(mixpanel), // the People profile: must come first
      GenericMixpanelPropertySetterFactory(mixpanel), // super properties
    ]),
  );
  final service = MixpanelAnalyticsService(mixpanel);
  return HeraldProvider(
    name: 'mixpanel',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final mixpanel = await Mixpanel.init(
    'YOUR_PROJECT_TOKEN',
    trackAutomaticEvents: false,
    optOutTrackingDefault: true, // silent until consent
  );
  final herald = Herald(providers: [mixpanelProvider(mixpanel)]);

  await herald.start();
  await herald.setEnabled(true); // the user agreed
  await herald.track(const CheckoutStarted('pro', 3));
}
