import 'package:herald/herald.dart';
import 'package:herald_log/herald_log.dart';

final class const CheckoutStarted(final String plan, final int seats) extends Event {
  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
}

Future<void> main() async {
  // In a Flutter app, pass debugPrint and register the provider in debug builds only.
  const AnalyticsLogger logger = print;
  final tracker = LogAnalyticsTrackerService(
    eventTrackerFactory: CompositeLogEventTrackerFactory([
      ScreenViewLogEventTrackerFactory(logger),
      GenericLogEventTrackerFactory(logger),
    ]),
    propertySetterFactory: CompositeLogPropertySetterFactory([
      GenericLogPropertySetterFactory(logger),
    ]),
  );
  final service = LogAnalyticsService(logger);
  final herald = Herald(
    providers: [
      HeraldProvider(
        name: 'log',
        events: tracker,
        properties: tracker,
        identity: service,
        lifecycle: service,
        consent: service,
      ),
    ],
  );

  await herald.start();
  await herald.track(const CheckoutStarted('pro', 3));
}
