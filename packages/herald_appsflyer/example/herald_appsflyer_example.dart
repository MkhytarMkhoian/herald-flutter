import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';
import 'package:herald_appsflyer/herald_appsflyer.dart';

final class const OrderPaid(final String orderId, final double total) extends Event {
  @override
  String get name => 'order_paid';

  @override
  Map<String, AnalyticsValue> get parameters => {'order_id': .string(orderId)};
}

/// Sends a paid order as AppsFlyer's af_purchase, and leaves every other event to the next factory.
final class const PurchaseAppsFlyerFactory(final AppsFlyerSdk appsFlyer)
    implements AppsFlyerEventTrackerFactory {
  @override
  Resolution<AppsFlyerEventTracker> create(Event event) => switch (event) {
    OrderPaid() => .claimed([
      PurchaseAppsFlyerEventTracker(
        AppsFlyerPurchaseEvent(
          name: event.name,
          revenue: event.total,
          currency: 'EUR',
          orderId: event.orderId, // counts a purchase sent twice once
        ),
        appsFlyer,
      ),
    ]),
    _ => const .declined(),
  };
}

HeraldProvider appsFlyerProvider(AppsFlyerSdk appsFlyer) {
  final tracker = AppsFlyerAnalyticsTrackerService(
    // Nothing at the end, so only the conversions a factory handles are sent.
    eventTrackerFactory: CompositeAppsFlyerEventTrackerFactory([
      PurchaseAppsFlyerFactory(appsFlyer),
    ]),
  );
  final service = AppsFlyerAnalyticsService(appsFlyer);
  return HeraldProvider(
    name: 'appsflyer',
    events: tracker, // no properties: AppsFlyer keeps no user attributes
    identity: service,
    lifecycle: service,
    consent: service,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appsFlyer = AppsFlyerSdk.instance;
  await appsFlyer.init(devKey: 'YOUR_DEV_KEY', appId: 'YOUR_APPLE_APP_ID');
  await appsFlyer.registerSessionReadyListener(() async {
    await appsFlyer.start();
  });
  final herald = Herald(providers: [appsFlyerProvider(appsFlyer)]);

  await herald.start(); // keeps AppsFlyer stopped
  await herald.setEnabled(true); // the user agreed: AppsFlyer starts
  await herald.track(const OrderPaid('order-1', 9.99));
}
