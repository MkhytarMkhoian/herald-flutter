import 'package:adjust_sdk/adjust_config.dart';
import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';
import 'package:herald_adjust/herald_adjust.dart';

final class const CheckoutStarted(final String plan, final int seats) extends Event {
  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
}

HeraldProvider adjustProvider(AdjustConfig config) {
  final tracker = AdjustAnalyticsTrackerService(
    eventTrackerFactory: CompositeAdjustEventTrackerFactory([
      TokenAdjustEventTrackerFactory({'checkout_started': 'abc123'}), // from your Adjust dashboard
    ]), // nothing at the end: only events with a token are sent
    propertySetterFactory: CompositeAdjustPropertySetterFactory([
      const GenericAdjustPropertySetterFactory(),
    ]),
  );
  final service = AdjustAnalyticsService(config); // starts Adjust itself, silent until consent
  return HeraldProvider(
    name: 'adjust',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final herald = Herald(
    providers: [adjustProvider(AdjustConfig('YOUR_APP_TOKEN', AdjustEnvironment.sandbox))],
  );

  await herald.start();
  await herald.setEnabled(true); // the user agreed
  await herald.track(const CheckoutStarted('pro', 3));
}
